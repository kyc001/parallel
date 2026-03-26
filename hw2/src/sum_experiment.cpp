#include "sum_experiment.hpp"

#include "benchmark.hpp"
#include "data_utils.hpp"

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>

LAB1_NOINLINE double sum_naive(const double* data, std::size_t n) {
    double sum = 0.0;
    for (std::size_t i = 0; i < n; ++i) {
        sum += data[i];
    }
    return sum;
}

LAB1_NOINLINE double sum_superscalar2(const double* data, std::size_t n) {
    double s0 = 0.0;
    double s1 = 0.0;
    std::size_t i = 0;
    const std::size_t unrolled_end = n - (n % 2);
    for (; i < unrolled_end; i += 2) {
        s0 += data[i];
        s1 += data[i + 1];
    }
    double sum = s0 + s1;
    for (; i < n; ++i) {
        sum += data[i];
    }
    return sum;
}

LAB1_NOINLINE double sum_superscalar4(const double* data, std::size_t n) {
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

LAB1_NOINLINE double sum_pairwise(const double* data, std::size_t n, std::vector<double>& scratch) {
    std::copy(data, data + n, scratch.begin());
    std::size_t active = n;
    while (active > 1) {
        const std::size_t pairs = active / 2;
        std::size_t i = 0;
        for (; i + 1 < pairs; i += 2) {
            scratch[i] = scratch[2 * i] + scratch[2 * i + 1];
            scratch[i + 1] = scratch[2 * i + 2] + scratch[2 * i + 3];
        }
        for (; i < pairs; ++i) {
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

void run_sum_experiment(const fs::path& output_dir) {
    const std::vector<std::size_t> sizes = {1u << 10, 1u << 12, 1u << 14, 1u << 16, 1u << 18, 1u << 20, 1u << 22, 1u << 23};
    std::ofstream csv(output_dir / "sum_results.csv");
    csv << "n,array_bytes,naive_ms,superscalar2_ms,superscalar4_ms,pairwise_ms,"
           "speedup_superscalar2,speedup_superscalar4,speedup_pairwise,"
           "diff_superscalar2,diff_superscalar4,diff_pairwise\n";

    std::cout << "[sum] running " << sizes.size() << " cases\n";
    for (const std::size_t n : sizes) {
        const auto data = make_vector(n);
        std::vector<double> scratch(n, 0.0);

        const double reference = sum_naive(data.data(), n);
        const double superscalar2_reference = sum_superscalar2(data.data(), n);
        const double superscalar4_reference = sum_superscalar4(data.data(), n);
        const double pairwise_reference = sum_pairwise(data.data(), n, scratch);

        const auto naive_measure = benchmark(
            [&]() {
                return sum_naive(data.data(), n);
            },
            250.0);

        const auto superscalar2_measure = benchmark(
            [&]() {
                return sum_superscalar2(data.data(), n);
            },
            250.0);

        const auto superscalar4_measure = benchmark(
            [&]() {
                return sum_superscalar4(data.data(), n);
            },
            250.0);

        const auto pairwise_measure = benchmark(
            [&]() {
                return sum_pairwise(data.data(), n, scratch);
            },
            250.0);

        const double diff_superscalar2 = std::abs(reference - superscalar2_reference);
        const double diff_superscalar4 = std::abs(reference - superscalar4_reference);
        const double diff_pairwise = std::abs(reference - pairwise_reference);
        const double speedup_superscalar2 = naive_measure.avg_ms / superscalar2_measure.avg_ms;
        const double speedup_superscalar4 = naive_measure.avg_ms / superscalar4_measure.avg_ms;
        const double speedup_pairwise = naive_measure.avg_ms / pairwise_measure.avg_ms;

        csv << n << ','
            << (n * sizeof(double)) << ','
            << std::fixed << std::setprecision(6)
            << naive_measure.avg_ms << ','
            << superscalar2_measure.avg_ms << ','
            << superscalar4_measure.avg_ms << ','
            << pairwise_measure.avg_ms << ','
            << speedup_superscalar2 << ','
            << speedup_superscalar4 << ','
            << speedup_pairwise << ','
            << std::scientific << std::setprecision(12)
            << diff_superscalar2 << ','
            << diff_superscalar4 << ','
            << diff_pairwise << '\n';

        std::cout << "  n=" << std::setw(8) << n
                  << " naive=" << std::setw(8) << std::fixed << std::setprecision(4) << naive_measure.avg_ms << " ms"
                  << " sp2=" << std::setw(8) << superscalar2_measure.avg_ms << " ms"
                  << " sp4=" << std::setw(8) << superscalar4_measure.avg_ms << " ms"
                  << " pair=" << std::setw(8) << pairwise_measure.avg_ms << " ms"
                  << " sp2x=" << std::setw(5) << std::setprecision(2) << speedup_superscalar2
                  << " sp4x=" << std::setw(5) << speedup_superscalar4
                  << " pairx=" << std::setw(5) << speedup_pairwise << '\n';
        std::cout.unsetf(std::ios::floatfield);
    }
}
