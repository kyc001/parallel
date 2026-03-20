#pragma once

#include <cstddef>
#include <vector>

std::vector<double> make_vector(std::size_t n);
std::vector<double> make_matrix(std::size_t n);
double max_abs_diff(const std::vector<double>& lhs, const std::vector<double>& rhs);
