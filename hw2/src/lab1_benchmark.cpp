#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <linux/perf_event.h>
#include <numeric>
#include <sched.h>
#include <sstream>
#include <stdexcept>
#include <string>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <vector>

namespace fs = std::filesystem;
using Clock = std::chrono::steady_clock;

struct Measurement {
    std::size_t iterations = 0;
    double total_ms = 0.0;
    double avg_ms = 0.0;
    double checksum = 0.0;
};

struct PerfReadings {
    bool available = false;
    std::uint64_t cycles = 0;
    std::uint64_t instructions = 0;
    std::uint64_t cache_references = 0;
    std::uint64_t cache_misses = 0;
    std::string error;
};

[[gnu::noinline]] void matrix_dot_naive(const double* matrix, const double* vec, double* out, std::size_t n) {
    for (std::size_t col = 0; col < n; ++col) {
        double acc = 0.0;
        for (std::size_t row = 0; row < n; ++row) {
            acc += matrix[row * n + col] * vec[row];
        }
        out[col] = acc;
    }
}

[[gnu::noinline]] void matrix_dot_row_major(const double* matrix, const double* vec, double* out, std::size_t n) {
    std::fill(out, out + n, 0.0);
    for (std::size_t row = 0; row < n; ++row) {
        const double factor = vec[row];
        const double* row_ptr = matrix + row * n;
        for (std::size_t col = 0; col < n; ++col) {
            out[col] += row_ptr[col] * factor;
        }
    }
}

[[gnu::noinline]] double sum_naive(const double* data, std::size_t n) {
    double sum = 0.0;
    for (std::size_t i = 0; i < n; ++i) {
        sum += data[i];
    }
    return sum;
}

[[gnu::noinline]] double sum_superscalar4(const double* data, std::size_t n) {
    double s0 = 0.0;
    double s1 = 0.0;
    double s2 = 0.0;
    double s3 = 0.0;
    std::size_t i = 0;
    const std::size_t unrolled_end = n - (n % 4);
    for (; i < unrolled_end; i += 4) {
        s0 += data[i];
        s1 += data[i + 1];
        s2 += data[i + 2];
        s3 += data[i + 3];
    }

    double sum = (s0 + s1) + (s2 + s3);
    for (; i < n; ++i) {
        sum += data[i];
    }
    return sum;
}

[[gnu::noinline]] double sum_pairwise(const double* data, std::size_t n, std::vector<double>& scratch) {
    std::copy(data, data + n, scratch.begin());
    std::size_t active = n;
    while (active > 1) {
        const std::size_t pairs = active / 2;
        for (std::size_t i = 0; i < pairs; ++i) {
            scratch[i] = scratch[2 * i] + scratch[2 * i + 1];
        }
        if (active % 2 != 0) {
            scratch[pairs] = scratch[active - 1];
            active = pairs + 1;
        } else {
            active = pairs;
        }
    }
    return scratch[0];
}

bool pin_to_core_zero() {
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(0, &set);
    return sched_setaffinity(0, sizeof(set), &set) == 0;
}

template <class T>
inline void do_not_optimize(const T& value) {
    asm volatile("" : : "g"(value) : "memory");
}

inline void clobber_memory() {
    asm volatile("" : : : "memory");
}

int open_perf_event(std::uint32_t type, std::uint64_t config) {
    perf_event_attr attr{};
    attr.type = type;
    attr.size = sizeof(attr);
    attr.config = config;
    attr.disabled = 1;
    attr.exclude_kernel = 1;
    attr.exclude_hv = 1;
    return static_cast<int>(syscall(__NR_perf_event_open, &attr, 0, -1, -1, 0));
}

PerfReadings profile_once(const std::function<double()>& fn, std::size_t repeat) {
    const int fd_cycles = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CPU_CYCLES);
    const int fd_instructions = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_INSTRUCTIONS);
    const int fd_cache_ref = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CACHE_REFERENCES);
    const int fd_cache_miss = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CACHE_MISSES);

    auto close_all = [&]() {
        for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
            if (fd >= 0) {
                close(fd);
            }
        }
    };

    if (fd_cycles < 0 || fd_instructions < 0 || fd_cache_ref < 0 || fd_cache_miss < 0) {
        close_all();
        PerfReadings readings;
        readings.available = false;
        readings.error = "perf_event_open is unavailable in this environment";
        return readings;
    }

    for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
        ioctl(fd, PERF_EVENT_IOC_RESET, 0);
        ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
    }

    double checksum = 0.0;
    for (std::size_t i = 0; i < repeat; ++i) {
        checksum += fn();
    }
    do_not_optimize(checksum);
    clobber_memory();

    PerfReadings readings;
    readings.available = true;
    for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
        ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    }

    if (read(fd_cycles, &readings.cycles, sizeof(readings.cycles)) != static_cast<ssize_t>(sizeof(readings.cycles)) ||
        read(fd_instructions, &readings.instructions, sizeof(readings.instructions)) != static_cast<ssize_t>(sizeof(readings.instructions)) ||
        read(fd_cache_ref, &readings.cache_references, sizeof(readings.cache_references)) != static_cast<ssize_t>(sizeof(readings.cache_references)) ||
        read(fd_cache_miss, &readings.cache_misses, sizeof(readings.cache_misses)) != static_cast<ssize_t>(sizeof(readings.cache_misses))) {
        readings.available = false;
        readings.error = "failed to read hardware counters";
    }

    close_all();
    return readings;
}

template <class Fn>
Measurement benchmark(Fn&& fn, double min_total_ms) {
    volatile double sink = 0.0;

    for (int i = 0; i < 2; ++i) {
        const double value = fn();
        do_not_optimize(value);
        sink += value;
        clobber_memory();
    }

    std::size_t iterations = 1;
    double elapsed_ms = 0.0;
    while (true) {
        const auto start = Clock::now();
        double checksum = 0.0;
        for (std::size_t i = 0; i < iterations; ++i) {
            const double value = fn();
            do_not_optimize(value);
            checksum += value;
            clobber_memory();
        }
        const auto end = Clock::now();
        elapsed_ms = std::chrono::duration<double, std::milli>(end - start).count();
        do_not_optimize(checksum);
        sink = checksum;
        if (elapsed_ms >= min_total_ms || iterations > (1u << 20)) {
            break;
        }
        iterations *= 2;
    }

    Measurement m;
    m.iterations = iterations;
    m.total_ms = elapsed_ms;
    m.avg_ms = elapsed_ms / static_cast<double>(iterations);
    m.checksum = sink;
    return m;
}

std::vector<double> make_vector(std::size_t n) {
    std::vector<double> data(n);
    for (std::size_t i = 0; i < n; ++i) {
        data[i] = 0.25 + static_cast<double>((i * 17 + 11) % 97) / 97.0;
    }
    return data;
}

std::vector<double> make_matrix(std::size_t n) {
    std::vector<double> data(n * n);
    for (std::size_t row = 0; row < n; ++row) {
        for (std::size_t col = 0; col < n; ++col) {
            data[row * n + col] = 0.1 + static_cast<double>((row * 131 + col * 17) % 251) / 251.0;
        }
    }
    return data;
}

double max_abs_diff(const std::vector<double>& lhs, const std::vector<double>& rhs) {
    double diff = 0.0;
    for (std::size_t i = 0; i < lhs.size(); ++i) {
        diff = std::max(diff, std::abs(lhs[i] - rhs[i]));
    }
    return diff;
}

std::string detect_os_pretty_name() {
    std::ifstream input("/etc/os-release");
    std::string line;
    while (std::getline(input, line)) {
        constexpr char prefix[] = "PRETTY_NAME=";
        if (line.rfind(prefix, 0) == 0) {
            std::string value = line.substr(sizeof(prefix) - 1);
            if (!value.empty() && value.front() == '"' && value.back() == '"') {
                value = value.substr(1, value.size() - 2);
            }
            return value;
        }
    }
    return "Unknown";
}

std::string detect_compiler_version() {
    std::ifstream input("/proc/version");
    std::string line;
    std::getline(input, line);
    return line.empty() ? "Unknown" : line;
}

void write_environment(const fs::path& output_dir, bool affinity_pinned) {
    std::ofstream env(output_dir / "environment.txt");
    env << "OS: " << detect_os_pretty_name() << '\n';
    env << "Compiler: g++ (Ubuntu 12.3.0-1ubuntu1~22.04.3) 12.3.0" << '\n';
    env << "Kernel: " << detect_compiler_version() << '\n';
    env << "Benchmark affinity pinned to CPU0: " << (affinity_pinned ? "yes" : "no") << '\n';
    env << "Build flags: -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize" << '\n';
    env << "CPU info: 13th Gen Intel(R) Core(TM) i9-13900H, L1d 48 KiB/core, L2 1.25 MiB/core, L3 24 MiB shared" << '\n';
}

void run_matrix_experiment(const fs::path& output_dir) {
    const std::vector<std::size_t> sizes = {64, 128, 256, 384, 512, 768, 1024, 1536, 2048};
    std::ofstream csv(output_dir / "matrix_results.csv");
    csv << "n,matrix_bytes,naive_ms,row_major_ms,speedup,max_abs_diff,naive_checksum,row_major_checksum\n";

    std::cout << "[matrix] running " << sizes.size() << " cases\n";
    for (const std::size_t n : sizes) {
        const auto matrix = make_matrix(n);
        const auto vec = make_vector(n);
        std::vector<double> out_naive(n, 0.0);
        std::vector<double> out_row(n, 0.0);

        matrix_dot_naive(matrix.data(), vec.data(), out_naive.data(), n);
        matrix_dot_row_major(matrix.data(), vec.data(), out_row.data(), n);
        const double diff = max_abs_diff(out_naive, out_row);

        const auto naive_measure = benchmark(
            [&]() {
                matrix_dot_naive(matrix.data(), vec.data(), out_naive.data(), n);
                return std::accumulate(out_naive.begin(), out_naive.end(), 0.0);
            },
            250.0);

        const auto row_measure = benchmark(
            [&]() {
                matrix_dot_row_major(matrix.data(), vec.data(), out_row.data(), n);
                return std::accumulate(out_row.begin(), out_row.end(), 0.0);
            },
            250.0);

        const std::size_t matrix_bytes = n * n * sizeof(double);
        const double speedup = naive_measure.avg_ms / row_measure.avg_ms;
        csv << n << ','
            << matrix_bytes << ','
            << std::fixed << std::setprecision(6)
            << naive_measure.avg_ms << ','
            << row_measure.avg_ms << ','
            << speedup << ','
            << diff << ','
            << naive_measure.checksum << ','
            << row_measure.checksum << '\n';

        std::cout << "  n=" << std::setw(4) << n
                  << " naive=" << std::setw(9) << std::fixed << std::setprecision(4) << naive_measure.avg_ms << " ms"
                  << " row_major=" << std::setw(9) << row_measure.avg_ms << " ms"
                  << " speedup=" << std::setw(7) << std::setprecision(2) << speedup
                  << " diff=" << std::scientific << diff << '\n';
        std::cout.unsetf(std::ios::floatfield);
    }
}

void run_sum_experiment(const fs::path& output_dir) {
    const std::vector<std::size_t> sizes = {1u << 10, 1u << 12, 1u << 14, 1u << 16, 1u << 18, 1u << 20, 1u << 22, 1u << 23};
    std::ofstream csv(output_dir / "sum_results.csv");
    csv << "n,array_bytes,naive_ms,superscalar4_ms,pairwise_ms,speedup_superscalar4,speedup_pairwise,diff_superscalar4,diff_pairwise\n";

    std::cout << "[sum] running " << sizes.size() << " cases\n";
    for (const std::size_t n : sizes) {
        const auto data = make_vector(n);
        std::vector<double> scratch(n, 0.0);

        const double reference = sum_naive(data.data(), n);
        const double superscalar_reference = sum_superscalar4(data.data(), n);
        const double pairwise_reference = sum_pairwise(data.data(), n, scratch);

        const auto naive_measure = benchmark(
            [&]() {
                return sum_naive(data.data(), n);
            },
            250.0);

        const auto superscalar_measure = benchmark(
            [&]() {
                return sum_superscalar4(data.data(), n);
            },
            250.0);

        const auto pairwise_measure = benchmark(
            [&]() {
                return sum_pairwise(data.data(), n, scratch);
            },
            250.0);

        const double diff_superscalar = std::abs(reference - superscalar_reference);
        const double diff_pairwise = std::abs(reference - pairwise_reference);
        const double speedup_superscalar = naive_measure.avg_ms / superscalar_measure.avg_ms;
        const double speedup_pairwise = naive_measure.avg_ms / pairwise_measure.avg_ms;

        csv << n << ','
            << (n * sizeof(double)) << ','
            << std::fixed << std::setprecision(6)
            << naive_measure.avg_ms << ','
            << superscalar_measure.avg_ms << ','
            << pairwise_measure.avg_ms << ','
            << speedup_superscalar << ','
            << speedup_pairwise << ','
            << std::scientific << std::setprecision(12)
            << diff_superscalar << ','
            << diff_pairwise << '\n';

        std::cout << "  n=" << std::setw(8) << n
                  << " naive=" << std::setw(8) << std::fixed << std::setprecision(4) << naive_measure.avg_ms << " ms"
                  << " superscalar4=" << std::setw(8) << superscalar_measure.avg_ms << " ms"
                  << " pairwise=" << std::setw(8) << pairwise_measure.avg_ms << " ms"
                  << " speedup4=" << std::setw(6) << std::setprecision(2) << speedup_superscalar
                  << " speedup_pair=" << std::setw(6) << speedup_pairwise
                  << " diff_pair=" << std::scientific << diff_pairwise << '\n';
        std::cout.unsetf(std::ios::floatfield);
    }
}

void run_profile_experiment(const fs::path& output_dir) {
    std::ofstream csv(output_dir / "profile_results.csv");
    csv << "experiment,algorithm,repeat,cycles,instructions,ipc,cache_references,cache_misses,miss_rate,error\n";

    const std::size_t matrix_n = 2048;
    const auto matrix = make_matrix(matrix_n);
    const auto vec = make_vector(matrix_n);
    std::vector<double> out(matrix_n, 0.0);

    const auto matrix_naive = profile_once(
        [&]() {
            matrix_dot_naive(matrix.data(), vec.data(), out.data(), matrix_n);
            return std::accumulate(out.begin(), out.end(), 0.0);
        },
        2);

    const auto matrix_row = profile_once(
        [&]() {
            matrix_dot_row_major(matrix.data(), vec.data(), out.data(), matrix_n);
            return std::accumulate(out.begin(), out.end(), 0.0);
        },
        2);

    const std::size_t sum_n = 1u << 20;
    const auto data = make_vector(sum_n);
    std::vector<double> scratch(sum_n, 0.0);

    const auto sum_naive_profile = profile_once(
        [&]() {
            return sum_naive(data.data(), sum_n);
        },
        128);

    const auto sum_superscalar_profile = profile_once(
        [&]() {
            return sum_superscalar4(data.data(), sum_n);
        },
        128);

    const auto sum_pairwise_profile = profile_once(
        [&]() {
            return sum_pairwise(data.data(), sum_n, scratch);
        },
        32);

    const auto emit = [&](const std::string& experiment,
                          const std::string& algorithm,
                          std::size_t repeat,
                          const PerfReadings& readings) {
        if (!readings.available) {
            csv << experiment << ',' << algorithm << ',' << repeat << ",0,0,0,0,0,0," << readings.error << '\n';
            return;
        }
        const double ipc = readings.cycles == 0 ? 0.0 : static_cast<double>(readings.instructions) / static_cast<double>(readings.cycles);
        const double miss_rate = readings.cache_references == 0
            ? 0.0
            : static_cast<double>(readings.cache_misses) / static_cast<double>(readings.cache_references);
        csv << experiment << ','
            << algorithm << ','
            << repeat << ','
            << readings.cycles << ','
            << readings.instructions << ','
            << std::fixed << std::setprecision(6)
            << ipc << ','
            << readings.cache_references << ','
            << readings.cache_misses << ','
            << miss_rate << ",\n";
    };

    emit("matrix_2048", "naive", 2, matrix_naive);
    emit("matrix_2048", "row_major", 2, matrix_row);
    emit("sum_1048576", "naive", 128, sum_naive_profile);
    emit("sum_1048576", "superscalar4", 128, sum_superscalar_profile);
    emit("sum_1048576", "pairwise", 32, sum_pairwise_profile);
}

int main() {
    const fs::path output_dir = "results";
    fs::create_directories(output_dir);

    const bool affinity_pinned = pin_to_core_zero();
    write_environment(output_dir, affinity_pinned);

    try {
        run_matrix_experiment(output_dir);
        run_sum_experiment(output_dir);
        run_profile_experiment(output_dir);
    } catch (const std::exception& ex) {
        std::cerr << "benchmark failed: " << ex.what() << '\n';
        return 1;
    }

    std::cout << "results written to " << output_dir << '\n';
    return 0;
}
