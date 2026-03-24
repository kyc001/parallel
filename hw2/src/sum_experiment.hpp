#pragma once

#include "fs_compat.hpp"

#include <cstddef>
#include <vector>

[[gnu::noinline]] double sum_naive(const double* data, std::size_t n);
[[gnu::noinline]] double sum_superscalar2(const double* data, std::size_t n);
[[gnu::noinline]] double sum_superscalar4(const double* data, std::size_t n);
[[gnu::noinline]] double sum_pairwise(const double* data, std::size_t n, std::vector<double>& scratch);

void run_sum_experiment(const fs::path& output_dir);
