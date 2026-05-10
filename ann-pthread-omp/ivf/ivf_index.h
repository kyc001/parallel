#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <limits>
#include <queue>
#include <utility>
#include <vector>

#if defined(__aarch64__) || defined(__ARM_NEON)
#include "simd/flat_scan_simd.h"
#define ANN_IVF_HAS_NEON 1
#elif defined(__AVX2__)
#include "simd/flat_scan_avx2.h"
#define ANN_IVF_HAS_AVX2 1
#else
#include "flat_scan.h"
#endif

namespace ann_ivf {

using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;

static inline float Distance(const float* x, const float* y, size_t d) {
#if defined(ANN_IVF_HAS_NEON)
    return ip_distance_simd(x, y, static_cast<int>(d));
#elif defined(ANN_IVF_HAS_AVX2)
    return ann_avx2::ip_distance_avx2(x, y, static_cast<int>(d));
#else
    float dot = 0.0f;
    for (size_t i = 0; i < d; ++i) {
        dot += x[i] * y[i];
    }
    return 1.0f - dot;
#endif
}

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
    if (k == 0) {
        return;
    }
    if (heap.size() < k) {
        heap.push(std::make_pair(dist, id));
    } else if (dist < heap.top().first) {
        heap.push(std::make_pair(dist, id));
        heap.pop();
    }
}

static inline SearchHeap MergeHeaps(std::vector<SearchHeap>& heaps, size_t k) {
    SearchHeap result;
    for (size_t i = 0; i < heaps.size(); ++i) {
        SearchHeap& heap = heaps[i];
        while (!heap.empty()) {
            const std::pair<float, uint32_t> item = heap.top();
            heap.pop();
            PushTopK(result, item.first, item.second, k);
        }
    }
    return result;
}

struct IVFIndex {
    size_t nlist = 0;
    size_t n = 0;
    size_t d = 0;
    const float* base = nullptr;

    std::vector<float> centroids;
    std::vector<std::vector<uint32_t>> inverted_lists;

    std::vector<float> reordered_base;
    std::vector<uint32_t> reordered_ids;
    std::vector<size_t> list_offsets;

    size_t nearest_centroid(const float* vec) const {
        size_t best = 0;
        float best_dist = std::numeric_limits<float>::max();
        for (size_t c = 0; c < nlist; ++c) {
            const float dist = Distance(vec, centroids.data() + c * d, d);
            if (dist < best_dist) {
                best_dist = dist;
                best = c;
            }
        }
        return best;
    }

    void build(const float* base_, size_t n_, size_t d_, size_t nlist_,
               int niter = 8) {
        base = base_;
        n = n_;
        d = d_;
        nlist = std::max<size_t>(1, std::min(nlist_, n));
        niter = std::max(1, niter);

        centroids.assign(nlist * d, 0.0f);
        inverted_lists.assign(nlist, std::vector<uint32_t>());

        std::cerr << "[IVF] Building index: nlist=" << nlist
                  << ", niter=" << niter << "\n";

        for (size_t c = 0; c < nlist; ++c) {
            const size_t src = (c * 9973) % n;
            std::memcpy(centroids.data() + c * d, base + src * d, d * sizeof(float));
        }

        std::vector<uint32_t> assign(n, 0);
        for (int iter = 0; iter < niter; ++iter) {
            for (size_t i = 0; i < n; ++i) {
                assign[i] = static_cast<uint32_t>(nearest_centroid(base + i * d));
            }

            std::vector<float> next_centroids(nlist * d, 0.0f);
            std::vector<size_t> counts(nlist, 0);
            for (size_t i = 0; i < n; ++i) {
                const size_t c = assign[i];
                ++counts[c];
                const float* vec = base + i * d;
                float* dst = next_centroids.data() + c * d;
                for (size_t j = 0; j < d; ++j) {
                    dst[j] += vec[j];
                }
            }

            for (size_t c = 0; c < nlist; ++c) {
                if (counts[c] == 0) {
                    const size_t src = ((c + static_cast<size_t>(iter) + 1) * 7919) % n;
                    std::memcpy(next_centroids.data() + c * d, base + src * d,
                                d * sizeof(float));
                    continue;
                }
                const float inv = 1.0f / static_cast<float>(counts[c]);
                float* dst = next_centroids.data() + c * d;
                for (size_t j = 0; j < d; ++j) {
                    dst[j] *= inv;
                }
            }

            centroids.swap(next_centroids);
        }

        for (size_t i = 0; i < n; ++i) {
            assign[i] = static_cast<uint32_t>(nearest_centroid(base + i * d));
            inverted_lists[assign[i]].push_back(static_cast<uint32_t>(i));
        }

        build_reordered_storage();
        std::cerr << "[IVF] Index built.\n";
    }

    void build_reordered_storage() {
        list_offsets.assign(nlist + 1, 0);
        for (size_t c = 0; c < nlist; ++c) {
            list_offsets[c + 1] = list_offsets[c] + inverted_lists[c].size();
        }

        reordered_ids.resize(n);
        reordered_base.resize(n * d);
        for (size_t c = 0; c < nlist; ++c) {
            size_t pos = list_offsets[c];
            for (size_t j = 0; j < inverted_lists[c].size(); ++j, ++pos) {
                const uint32_t id = inverted_lists[c][j];
                reordered_ids[pos] = id;
                std::memcpy(reordered_base.data() + pos * d,
                            base + static_cast<size_t>(id) * d,
                            d * sizeof(float));
            }
        }
    }

    std::vector<uint32_t> select_probes(const float* query, size_t nprobe) const {
        nprobe = std::max<size_t>(1, std::min(nprobe, nlist));
        SearchHeap heap;
        for (size_t c = 0; c < nlist; ++c) {
            const float dist = Distance(query, centroids.data() + c * d, d);
            PushTopK(heap, dist, static_cast<uint32_t>(c), nprobe);
        }

        std::vector<uint32_t> probes;
        probes.reserve(nprobe);
        while (!heap.empty()) {
            probes.push_back(heap.top().second);
            heap.pop();
        }
        std::reverse(probes.begin(), probes.end());
        return probes;
    }
};

static inline void ScanList(const IVFIndex& index, const float* query,
                            uint32_t list_id, size_t k, SearchHeap& heap) {
    const size_t begin = index.list_offsets[list_id];
    const size_t end = index.list_offsets[static_cast<size_t>(list_id) + 1];
    for (size_t pos = begin; pos < end; ++pos) {
        const uint32_t id = index.reordered_ids[pos];
        const float dist = Distance(index.reordered_base.data() + pos * index.d,
                                    query, index.d);
        PushTopK(heap, dist, id, k);
    }
}

}  // namespace ann_ivf
