#pragma once

#include "common.cuh"

namespace ann_gpu {

// Computes base[n*d] * query[d*m] -> score[n*m], stored as score[m*n]
// so each query's row is contiguous for the Top-k kernel.
__global__ void ScoreGemmKernel(const float* __restrict__ base,
                                const float* __restrict__ queries,
                                float* __restrict__ scores,
                                int base_n, int query_n, int dim) {
    const int tile = 16;
    __shared__ float base_tile[tile][tile];
    __shared__ float query_tile[tile][tile];

    const int base_id = blockIdx.x * tile + threadIdx.x;
    const int query_id = blockIdx.y * tile + threadIdx.y;
    float sum = 0.0f;

    for (int start = 0; start < dim; start += tile) {
        const int kd_x = start + threadIdx.x;
        const int kd_y = start + threadIdx.y;
        base_tile[threadIdx.y][threadIdx.x] =
            (base_id < base_n && kd_y < dim)
                ? base[static_cast<size_t>(base_id) * dim + kd_y]
                : 0.0f;
        query_tile[threadIdx.y][threadIdx.x] =
            (query_id < query_n && kd_x < dim)
                ? queries[static_cast<size_t>(query_id) * dim + kd_x]
                : 0.0f;
        __syncthreads();

#pragma unroll
        for (int k = 0; k < tile; ++k) {
            sum += base_tile[k][threadIdx.x] * query_tile[threadIdx.y][k];
        }
        __syncthreads();
    }

    if (base_id < base_n && query_id < query_n) {
        scores[static_cast<size_t>(query_id) * base_n + base_id] = sum;
    }
}

}  // namespace ann_gpu
