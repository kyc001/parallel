#include "benchmark.hpp"
#include "data_utils.hpp"
#include "matrix_experiment.hpp"
#include "sum_experiment.hpp"

#include <exception>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

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

double checksum(const std::vector<double>& data) {
    return std::accumulate(data.begin(), data.end(), 0.0);
}

Measurement measure_matrix(const std::string& algorithm, std::size_t n) {
    const auto matrix = make_matrix(n);
    const auto vec = make_vector(n);
    std::vector<double> out(n, 0.0);

    if (algorithm == "naive") {
        return benchmark([&]() {
            matrix_dot_naive(matrix.data(), vec.data(), out.data(), n);
            return checksum(out);
        }, 250.0);
    }
    if (algorithm == "row_major") {
        return benchmark([&]() {
            matrix_dot_row_major(matrix.data(), vec.data(), out.data(), n);
            return checksum(out);
        }, 250.0);
    }
    if (algorithm == "row_major_unrolled4") {
        return benchmark([&]() {
            matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out.data(), n);
            return checksum(out);
        }, 250.0);
    }
    throw std::invalid_argument("unknown matrix algorithm: " + algorithm);
}

Measurement measure_sum(const std::string& algorithm, std::size_t n) {
    const auto data = make_vector(n);
    std::vector<double> scratch(n, 0.0);

    if (algorithm == "naive") {
        return benchmark([&]() { return sum_naive(data.data(), n); }, 250.0);
    }
    if (algorithm == "superscalar2") {
        return benchmark([&]() { return sum_superscalar2(data.data(), n); }, 250.0);
    }
    if (algorithm == "superscalar4") {
        return benchmark([&]() { return sum_superscalar4(data.data(), n); }, 250.0);
    }
    if (algorithm == "pairwise") {
        return benchmark([&]() { return sum_pairwise(data.data(), n, scratch); }, 250.0);
    }
    throw std::invalid_argument("unknown sum algorithm: " + algorithm);
}

void print_usage(const char* argv0) {
    std::cerr
        << "Usage:\n"
        << "  " << argv0 << " matrix <naive|row_major|row_major_unrolled4> <n>\n"
        << "  " << argv0 << " sum <naive|superscalar2|superscalar4|pairwise> <n>\n";
}

}  // namespace

int main(int argc, char** argv) {
    try {
        if (argc != 4) {
            print_usage(argv[0]);
            return 1;
        }

        const std::string kind = argv[1];
        const std::string algorithm = argv[2];
        const std::size_t n = parse_size(argv[3], "n");

        pin_to_core_zero();
        detect_first_allowed_cpu();

        Measurement result;
        if (kind == "matrix") {
            result = measure_matrix(algorithm, n);
        } else if (kind == "sum") {
            result = measure_sum(algorithm, n);
        } else {
            throw std::invalid_argument("unknown workload kind: " + kind);
        }

        std::cout << kind << ','
                  << algorithm << ','
                  << n << ','
                  << result.iterations << ','
                  << std::fixed << std::setprecision(6)
                  << result.total_ms << ','
                  << result.avg_ms << ','
                  << std::setprecision(12)
                  << result.checksum << '\n';
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "lab1_opt_compare failed: " << ex.what() << '\n';
        print_usage(argv[0]);
        return 1;
    }
}
