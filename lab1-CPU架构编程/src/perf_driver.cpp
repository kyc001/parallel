#include "benchmark.hpp"
#include "data_utils.hpp"
#include "matrix_experiment.hpp"
#include "sum_experiment.hpp"

#include <cstdlib>
#include <exception>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

void print_usage(const char* argv0) {
    std::cerr
        << "Usage:\n"
        << "  " << argv0 << " matrix <naive|row_major|row_major_unrolled4> <n> <repeat>\n"
        << "  " << argv0 << " sum <naive|superscalar2|superscalar4|pairwise> <n> <repeat>\n"
        << "  " << argv0 << " list\n";
}

std::size_t parse_size(const char* arg, const char* name) {
    try {
        const unsigned long long value = std::stoull(arg);
        if (value == 0) {
            throw std::invalid_argument("zero");
        }
        return static_cast<std::size_t>(value);
    } catch (const std::exception&) {
        throw std::invalid_argument(std::string("invalid ") + name + ": " + arg);
    }
}

double run_matrix_workload(const std::string& algorithm, std::size_t n, std::size_t repeat) {
    const auto matrix = make_matrix(n);
    const auto vec = make_vector(n);
    std::vector<double> out(n, 0.0);

    // Warm up once so perf focuses on the steady-state kernel behavior.
    if (algorithm == "naive") {
        matrix_dot_naive(matrix.data(), vec.data(), out.data(), n);
    } else if (algorithm == "row_major") {
        matrix_dot_row_major(matrix.data(), vec.data(), out.data(), n);
    } else if (algorithm == "row_major_unrolled4") {
        matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out.data(), n);
    } else {
        throw std::invalid_argument("unknown matrix algorithm: " + algorithm);
    }

    double checksum = 0.0;
    for (std::size_t iter = 0; iter < repeat; ++iter) {
        if (algorithm == "naive") {
            matrix_dot_naive(matrix.data(), vec.data(), out.data(), n);
        } else if (algorithm == "row_major") {
            matrix_dot_row_major(matrix.data(), vec.data(), out.data(), n);
        } else {
            matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out.data(), n);
        }
        checksum += out[(iter * 1315423911u) % n];
        do_not_optimize(checksum);
        clobber_memory();
    }

    checksum += std::accumulate(out.begin(), out.end(), 0.0);
    do_not_optimize(checksum);
    clobber_memory();
    return checksum;
}

double run_sum_workload(const std::string& algorithm, std::size_t n, std::size_t repeat) {
    const auto data = make_vector(n);
    std::vector<double> scratch(n, 0.0);

    auto execute_once = [&]() -> double {
        if (algorithm == "naive") {
            return sum_naive(data.data(), n);
        }
        if (algorithm == "superscalar2") {
            return sum_superscalar2(data.data(), n);
        }
        if (algorithm == "superscalar4") {
            return sum_superscalar4(data.data(), n);
        }
        if (algorithm == "pairwise") {
            return sum_pairwise(data.data(), n, scratch);
        }
        throw std::invalid_argument("unknown sum algorithm: " + algorithm);
    };

    do_not_optimize(execute_once());
    clobber_memory();

    double checksum = 0.0;
    for (std::size_t iter = 0; iter < repeat; ++iter) {
        checksum += execute_once();
        do_not_optimize(checksum);
        clobber_memory();
    }
    return checksum;
}

}  // namespace

int main(int argc, char** argv) {
    try {
        if (argc == 2 && std::string(argv[1]) == "list") {
            std::cout
                << "matrix: naive, row_major, row_major_unrolled4\n"
                << "sum: naive, superscalar2, superscalar4, pairwise\n";
            return 0;
        }

        if (argc != 5) {
            print_usage(argv[0]);
            return 1;
        }

        const std::string kind = argv[1];
        const std::string algorithm = argv[2];
        const std::size_t n = parse_size(argv[3], "n");
        const std::size_t repeat = parse_size(argv[4], "repeat");

        const bool pinned = pin_to_core_zero();
        const int pinned_cpu = detect_first_allowed_cpu();
        std::cerr << "[perf-driver] affinity_pinned=" << (pinned ? "yes" : "no")
                  << " cpu=" << pinned_cpu << '\n';

        double checksum = 0.0;
        if (kind == "matrix") {
            checksum = run_matrix_workload(algorithm, n, repeat);
        } else if (kind == "sum") {
            checksum = run_sum_workload(algorithm, n, repeat);
        } else {
            throw std::invalid_argument("unknown workload kind: " + kind);
        }

        std::cout << std::fixed << std::setprecision(12) << checksum << '\n';
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "lab1_perf failed: " << ex.what() << '\n';
        print_usage(argv[0]);
        return 1;
    }
}
