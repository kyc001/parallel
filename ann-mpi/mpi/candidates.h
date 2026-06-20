#pragma once

#include <cmath>
#include <cstdint>
#include <limits>
#include <set>
#include <utility>

#include "common.h"

namespace ann_mpi {

static inline void PackCandidates(std::vector<SearchHeap>& results,
                                  size_t query_n, size_t k,
                                  const std::vector<uint64_t>& local_global_ids,
                                  std::vector<float>& distances,
                                  std::vector<uint64_t>& ids) {
    distances.assign(query_n * k, std::numeric_limits<float>::infinity());
    ids.assign(query_n * k, kInvalidId);

    for (size_t qi = 0; qi < query_n; ++qi) {
        SearchHeap& heap = results[qi];
        size_t slot = 0;
        while (!heap.empty() && slot < k) {
            const std::pair<float, uint32_t> item = heap.top();
            heap.pop();
            distances[qi * k + slot] = item.first;
            if (static_cast<size_t>(item.second) < local_global_ids.size()) {
                ids[qi * k + slot] = local_global_ids[item.second];
            }
            ++slot;
        }
    }
}

static inline double RecallAtK(std::vector<SearchHeap>& results, const int* gt,
                               size_t query_n, size_t gt_dim, size_t k) {
    double total = 0.0;
    for (size_t i = 0; i < query_n; ++i) {
        std::set<uint32_t> gtset;
        for (size_t j = 0; j < k; ++j) {
            gtset.insert(static_cast<uint32_t>(gt[i * gt_dim + j]));
        }

        size_t hits = 0;
        SearchHeap& heap = results[i];
        while (!heap.empty()) {
            const uint32_t id = heap.top().second;
            heap.pop();
            if (gtset.find(id) != gtset.end()) {
                ++hits;
            }
        }
        total += static_cast<double>(hits) / static_cast<double>(k);
    }
    return total / static_cast<double>(query_n);
}

static inline void MergeGatheredCandidates(
    const std::vector<float>& all_distances,
    const std::vector<uint64_t>& all_ids,
    int world_size, size_t query_n, size_t k,
    std::vector<SearchHeap>& merged) {
    merged.assign(query_n, SearchHeap());
    for (size_t qi = 0; qi < query_n; ++qi) {
        SearchHeap& heap = merged[qi];
        for (int rank = 0; rank < world_size; ++rank) {
            const size_t base =
                (static_cast<size_t>(rank) * query_n + qi) * k;
            for (size_t j = 0; j < k; ++j) {
                const uint64_t id = all_ids[base + j];
                const float dist = all_distances[base + j];
                if (id == kInvalidId || !std::isfinite(dist)) {
                    continue;
                }
                ann_ivf::PushTopK(heap, dist, static_cast<uint32_t>(id), k);
            }
        }
    }
}

}  // namespace ann_mpi
