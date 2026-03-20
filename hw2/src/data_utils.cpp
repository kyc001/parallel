#include "data_utils.hpp"

#include <algorithm>
#include <cmath>

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
