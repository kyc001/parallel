#include "data_utils.hpp"

#include <algorithm>
#include <cmath>

std::vector<double> make_vector(std::size_t n) {
    std::vector<double> data(n);
    for (std::size_t i = 0; i < n; ++i) {
        // 使用不同的生成公式: 0.5 + (19*i + 13) % 127 / 127.0
        data[i] = 0.5 + static_cast<double>((i * 19 + 13) % 127) / 127.0;
    }
    return data;
}

std::vector<double> make_matrix(std::size_t n) {
    std::vector<double> data(n * n);
    for (std::size_t row = 0; row < n; ++row) {
        for (std::size_t col = 0; col < n; ++col) {
            // 使用不同的生成公式: 0.2 + (137*row + 23*col) % 257 / 257.0
            data[row * n + col] = 0.2 + static_cast<double>((row * 137 + col * 23) % 257) / 257.0;
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
