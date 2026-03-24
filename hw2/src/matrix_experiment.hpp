#pragma once

#include "fs_compat.hpp"

#include <cstddef>

[[gnu::noinline]] void matrix_dot_naive(const double* matrix, const double* vec, double* out, std::size_t n);
[[gnu::noinline]] void matrix_dot_row_major(const double* matrix, const double* vec, double* out, std::size_t n);
[[gnu::noinline]] void matrix_dot_row_major_unrolled4(const double* matrix, const double* vec, double* out, std::size_t n);

void run_matrix_experiment(const fs::path& output_dir);
