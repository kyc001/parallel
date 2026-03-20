#include "profile.hpp"

#include "benchmark.hpp"
#include "data_utils.hpp"
#include "matrix_experiment.hpp"
#include "sum_experiment.hpp"

#include <fstream>
#include <iomanip>
#include <numeric>
#include <vector>

namespace {

double emit_ipc(const PerfReadings& readings) {
    if (readings.cycles == 0) {
        return 0.0;
    }
    return static_cast<double>(readings.instructions) / static_cast<double>(readings.cycles);
}

double emit_miss_rate(const PerfReadings& readings) {
    if (readings.cache_references == 0) {
        return 0.0;
    }
    return static_cast<double>(readings.cache_misses) / static_cast<double>(readings.cache_references);
}

void write_profile_row(std::ofstream& csv,
                       const std::string& experiment,
                       const std::string& algorithm,
                       std::size_t repeat,
                       const PerfReadings& readings) {
    if (!readings.available) {
        csv << experiment << ',' << algorithm << ',' << repeat << ",0,0,0,0,0,0," << readings.error << '\n';
        return;
    }
    csv << experiment << ','
        << algorithm << ','
        << repeat << ','
        << readings.cycles << ','
        << readings.instructions << ','
        << std::fixed << std::setprecision(6)
        << emit_ipc(readings) << ','
        << readings.cache_references << ','
        << readings.cache_misses << ','
        << emit_miss_rate(readings) << ",\n";
}

}  // namespace

void run_profile_experiment(const std::filesystem::path& output_dir) {
    std::ofstream csv(output_dir / "profile_results.csv");
    csv << "experiment,algorithm,repeat,cycles,instructions,ipc,cache_references,cache_misses,miss_rate,error\n";

    const std::size_t matrix_n = 2048;
    const auto matrix = make_matrix(matrix_n);
    const auto vec = make_vector(matrix_n);
    std::vector<double> out(matrix_n, 0.0);

    write_profile_row(
        csv,
        "matrix_2048",
        "naive",
        2,
        profile_once(
            [&]() {
                matrix_dot_naive(matrix.data(), vec.data(), out.data(), matrix_n);
                return std::accumulate(out.begin(), out.end(), 0.0);
            },
            2));

    write_profile_row(
        csv,
        "matrix_2048",
        "row_major",
        2,
        profile_once(
            [&]() {
                matrix_dot_row_major(matrix.data(), vec.data(), out.data(), matrix_n);
                return std::accumulate(out.begin(), out.end(), 0.0);
            },
            2));

    write_profile_row(
        csv,
        "matrix_2048",
        "row_major_unrolled4",
        2,
        profile_once(
            [&]() {
                matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out.data(), matrix_n);
                return std::accumulate(out.begin(), out.end(), 0.0);
            },
            2));

    const std::size_t sum_n = 1u << 20;
    const auto data = make_vector(sum_n);
    std::vector<double> scratch(sum_n, 0.0);

    write_profile_row(csv, "sum_1048576", "naive", 128, profile_once([&]() { return sum_naive(data.data(), sum_n); }, 128));
    write_profile_row(csv, "sum_1048576", "superscalar2", 128, profile_once([&]() { return sum_superscalar2(data.data(), sum_n); }, 128));
    write_profile_row(csv, "sum_1048576", "superscalar4", 128, profile_once([&]() { return sum_superscalar4(data.data(), sum_n); }, 128));
    write_profile_row(csv, "sum_1048576", "pairwise", 32, profile_once([&]() { return sum_pairwise(data.data(), sum_n, scratch); }, 32));
}
