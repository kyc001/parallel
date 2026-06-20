#pragma once

#include "common.cuh"

namespace ann_gpu {

__device__ inline void PushTopKScore(float score, uint32_t id,
                                     float* best_score,
                                     uint32_t* best_id) {
    int worst = 0;
#pragma unroll
    for (int i = 1; i < kGpuTopK; ++i) {
        if (best_score[i] < best_score[worst]) {
            worst = i;
        }
    }
    if (score > best_score[worst]) {
        best_score[worst] = score;
        best_id[worst] = id;
    }
}

__global__ void ScoreTopKKernel(const float* __restrict__ scores,
                                float* __restrict__ out_dist,
                                uint32_t* __restrict__ out_id,
                                int base_n) {
    const int query_id = blockIdx.x;
    const int tid = threadIdx.x;
    float local_score[kGpuTopK];
    uint32_t local_id[kGpuTopK];

#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        local_score[i] = ANN_GPU_NEG_INFINITY;
        local_id[i] = kInvalidId;
    }

    const float* row = scores + static_cast<size_t>(query_id) * base_n;
    for (int base_id = tid; base_id < base_n; base_id += blockDim.x) {
        PushTopKScore(row[base_id], static_cast<uint32_t>(base_id),
                      local_score, local_id);
    }

    extern __shared__ unsigned char shared_raw[];
    float* shared_score = reinterpret_cast<float*>(shared_raw);
    uint32_t* shared_id =
        reinterpret_cast<uint32_t*>(shared_score + blockDim.x * kGpuTopK);
    const int offset = tid * kGpuTopK;
#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        shared_score[offset + i] = local_score[i];
        shared_id[offset + i] = local_id[i];
    }
    __syncthreads();

    if (tid == 0) {
        float final_score[kGpuTopK];
        uint32_t final_id[kGpuTopK];
#pragma unroll
        for (int i = 0; i < kGpuTopK; ++i) {
            final_score[i] = ANN_GPU_NEG_INFINITY;
            final_id[i] = kInvalidId;
        }
        for (int i = 0; i < blockDim.x * kGpuTopK; ++i) {
            if (shared_id[i] != kInvalidId) {
                PushTopKScore(shared_score[i], shared_id[i],
                              final_score, final_id);
            }
        }

        for (int slot = 0; slot < kGpuTopK; ++slot) {
            int best = 0;
            for (int i = 1; i < kGpuTopK; ++i) {
                if (final_score[i] > final_score[best]) {
                    best = i;
                }
            }
            out_dist[static_cast<size_t>(query_id) * kGpuTopK + slot] =
                1.0f - final_score[best];
            out_id[static_cast<size_t>(query_id) * kGpuTopK + slot] =
                final_id[best];
            final_score[best] = ANN_GPU_NEG_INFINITY;
            final_id[best] = kInvalidId;
        }
    }
}

__device__ inline void MergeTopKInto(float* dst_score, uint32_t* dst_id,
                                     const float* src_score,
                                     const uint32_t* src_id) {
#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        if (src_id[i] != kInvalidId) {
            PushTopKScore(src_score[i], src_id[i], dst_score, dst_id);
        }
    }
}

__device__ inline void EmitTopK(float* final_score, uint32_t* final_id,
                                float* out_dist, uint32_t* out_id,
                                int query_id) {
    for (int slot = 0; slot < kGpuTopK; ++slot) {
        int best = 0;
        for (int i = 1; i < kGpuTopK; ++i) {
            if (final_score[i] > final_score[best]) {
                best = i;
            }
        }
        out_dist[static_cast<size_t>(query_id) * kGpuTopK + slot] =
            1.0f - final_score[best];
        out_id[static_cast<size_t>(query_id) * kGpuTopK + slot] =
            final_id[best];
        final_score[best] = ANN_GPU_NEG_INFINITY;
        final_id[best] = kInvalidId;
    }
}

__global__ void ScoreTopKTreeKernel(const float* __restrict__ scores,
                                    float* __restrict__ out_dist,
                                    uint32_t* __restrict__ out_id,
                                    int base_n) {
    const int query_id = blockIdx.x;
    const int tid = threadIdx.x;
    float local_score[kGpuTopK];
    uint32_t local_id[kGpuTopK];

#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        local_score[i] = ANN_GPU_NEG_INFINITY;
        local_id[i] = kInvalidId;
    }

    const float* row = scores + static_cast<size_t>(query_id) * base_n;
    for (int base_id = tid; base_id < base_n; base_id += blockDim.x) {
        PushTopKScore(row[base_id], static_cast<uint32_t>(base_id),
                      local_score, local_id);
    }

    extern __shared__ unsigned char shared_raw[];
    float* shared_score = reinterpret_cast<float*>(shared_raw);
    uint32_t* shared_id =
        reinterpret_cast<uint32_t*>(shared_score + blockDim.x * kGpuTopK);
    const int offset = tid * kGpuTopK;
#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        shared_score[offset + i] = local_score[i];
        shared_id[offset + i] = local_id[i];
    }
    __syncthreads();

    for (int stride = blockDim.x >> 1; stride > 0; stride >>= 1) {
        if (tid < stride) {
            float* mine_score = shared_score + tid * kGpuTopK;
            uint32_t* mine_id = shared_id + tid * kGpuTopK;
            const float* other_score =
                shared_score + (tid + stride) * kGpuTopK;
            const uint32_t* other_id =
                shared_id + (tid + stride) * kGpuTopK;
            MergeTopKInto(mine_score, mine_id, other_score, other_id);
        }
        __syncthreads();
    }

    if (tid == 0) {
        EmitTopK(shared_score, shared_id, out_dist, out_id, query_id);
    }
}

__global__ void ScoreTopKWithIdsTreeKernel(
    const float* __restrict__ scores,
    const uint32_t* __restrict__ candidate_ids,
    float* __restrict__ out_dist,
    uint32_t* __restrict__ out_id,
    int base_n) {
    const int query_id = blockIdx.x;
    const int tid = threadIdx.x;
    float local_score[kGpuTopK];
    uint32_t local_id[kGpuTopK];

#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        local_score[i] = ANN_GPU_NEG_INFINITY;
        local_id[i] = kInvalidId;
    }

    const float* row = scores + static_cast<size_t>(query_id) * base_n;
    for (int base_id = tid; base_id < base_n; base_id += blockDim.x) {
        PushTopKScore(row[base_id], candidate_ids[base_id],
                      local_score, local_id);
    }

    extern __shared__ unsigned char shared_raw[];
    float* shared_score = reinterpret_cast<float*>(shared_raw);
    uint32_t* shared_id =
        reinterpret_cast<uint32_t*>(shared_score + blockDim.x * kGpuTopK);
    const int offset = tid * kGpuTopK;
#pragma unroll
    for (int i = 0; i < kGpuTopK; ++i) {
        shared_score[offset + i] = local_score[i];
        shared_id[offset + i] = local_id[i];
    }
    __syncthreads();

    for (int stride = blockDim.x >> 1; stride > 0; stride >>= 1) {
        if (tid < stride) {
            float* mine_score = shared_score + tid * kGpuTopK;
            uint32_t* mine_id = shared_id + tid * kGpuTopK;
            const float* other_score =
                shared_score + (tid + stride) * kGpuTopK;
            const uint32_t* other_id =
                shared_id + (tid + stride) * kGpuTopK;
            MergeTopKInto(mine_score, mine_id, other_score, other_id);
        }
        __syncthreads();
    }

    if (tid == 0) {
        EmitTopK(shared_score, shared_id, out_dist, out_id, query_id);
    }
}

}  // namespace ann_gpu
