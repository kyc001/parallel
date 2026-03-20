#include "matrix_experiment.hpp"

#include "benchmark.hpp"
#include "data_utils.hpp"

#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <vector>

namespace {

double checksum(const std::vector<double>& data) {
    return std::accumulate(data.begin(), data.end(), 0.0);
}

}  // namespace

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

[[gnu::noinline]] void matrix_dot_row_major_unrolled4(const double* matrix, const double* vec, double* out, std::size_t n) {
    std::fill(out, out + n, 0.0);
    for (std::size_t row = 0; row < n; ++row) {
        const double factor = vec[row];
        const double* row_ptr = matrix + row * n;
        std::size_t col = 0;
        for (; col + 3 < n; col += 4) {
            out[col] += row_ptr[col] * factor;
            out[col + 1] += row_ptr[col + 1] * factor;
            out[col + 2] += row_ptr[col + 2] * factor;
            out[col + 3] += row_ptr[col + 3] * factor;
        }
        for (; col < n; ++col) {
            out[col] += row_ptr[col] * factor;
        }
    }
}

void run_matrix_experiment(const std::filesystem::path& output_dir) {
    const std::vector<std::size_t> sizes = {64, 128, 256, 384, 512, 768, 1024, 1536, 2048};
    std::ofstream csv(output_dir / "matrix_results.csv");
    csv << "n,matrix_bytes,naive_ms,row_major_ms,row_major_unrolled4_ms,"
           "speedup_row_major,speedup_row_major_unrolled4,"
           "diff_row_major,diff_row_major_unrolled4\n";

    std::cout << "[matrix] running " << sizes.size() << " cases\n";
    for (const std::size_t n : sizes) {
        const auto matrix = make_matrix(n);
        const auto vec = make_vector(n);
        std::vector<double> out_naive(n, 0.0);
        std::vector<double> out_row(n, 0.0);
        std::vector<double> out_unrolled(n, 0.0);

        matrix_dot_naive(matrix.data(), vec.data(), out_naive.data(), n);
        matrix_dot_row_major(matrix.data(), vec.data(), out_row.data(), n);
        matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out_unrolled.data(), n);

        const double diff_row_major = max_abs_diff(out_naive, out_row);
        const double diff_unrolled = max_abs_diff(out_naive, out_unrolled);

        const auto naive_measure = benchmark(
            [&]() {
                matrix_dot_naive(matrix.data(), vec.data(), out_naive.data(), n);
                return checksum(out_naive);
            },
            250.0);

        const auto row_measure = benchmark(
            [&]() {
                matrix_dot_row_major(matrix.data(), vec.data(), out_row.data(), n);
                return checksum(out_row);
            },
            250.0);

        const auto unrolled_measure = benchmark(
            [&]() {
                matrix_dot_row_major_unrolled4(matrix.data(), vec.data(), out_unrolled.data(), n);
                return checksum(out_unrolled);
            },
            250.0);

        const std::size_t matrix_bytes = n * n * sizeof(double);
        const double speedup_row_major = naive_measure.avg_ms / row_measure.avg_ms;
        const double speedup_unrolled = naive_measure.avg_ms / unrolled_measure.avg_ms;
        csv << n << ','
            << matrix_bytes << ','
            << std::fixed << std::setprecision(6)
            << naive_measure.avg_ms << ','
            << row_measure.avg_ms << ','
            << unrolled_measure.avg_ms << ','
            << speedup_row_major << ','
            << speedup_unrolled << ','
            << diff_row_major << ','
            << diff_unrolled << '\n';

        std::cout << "  n=" << std::setw(4) << n
                  << " naive=" << std::setw(9) << std::fixed << std::setprecision(4) << naive_measure.avg_ms << " ms"
                  << " row=" << std::setw(9) << row_measure.avg_ms << " ms"
                  << " row+u4=" << std::setw(9) << unrolled_measure.avg_ms << " ms"
                  << " sp(row)=" << std::setw(6) << std::setprecision(2) << speedup_row_major
                  << " sp(u4)=" << std::setw(6) << speedup_unrolled
                  << " diff=" << std::scientific << diff_unrolled << '\n';
        std::cout.unsetf(std::ios::floatfield);
    }
}
