#pragma once

#include "compiler_compat.hpp"
#include "fs_compat.hpp"

#include <cstddef>
#include <vector>

LAB1_NOINLINE double sum_naive(const double* data, std::size_t n);
LAB1_NOINLINE double sum_superscalar2(const double* data, std::size_t n);
LAB1_NOINLINE double sum_superscalar4(const double* data, std::size_t n);
LAB1_NOINLINE double sum_pairwise(const double* data, std::size_t n, std::vector<double>& scratch);

void run_sum_experiment(const fs::path& output_dir);
