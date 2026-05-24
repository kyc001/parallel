#pragma once

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <omp.h>
#include <utility>
#include <vector>

#include "hnsw_graph_utils.h"

namespace ann_hnsw_on_hnsw {

struct BlockRange {
    size_t begin;
    size_t end;
};

struct BlockIndex {
    BlockRange range;
    ann_hnsw::HnswHolder holder;
};

struct HierarchicalIndex {
    size_t d = 0;
    std::vector<float> centroids;
    ann_hnsw::HnswHolder top_index;
    std::vector<BlockIndex> blocks;

    void build(const float* base, size_t n, size_t d_, size_t nblocks,
               size_t M = 16, size_t ef_construction = 120,
               size_t ef_search = 50) {
        d = d_;
        nblocks = std::max<size_t>(1, std::min(nblocks, n));
        blocks.resize(nblocks);
        centroids.assign(nblocks * d, 0.0f);

        for (size_t b = 0; b < nblocks; ++b) {
            const BlockRange range = Partition(n, b, nblocks);
            blocks[b].range = range;
            const size_t count = range.end - range.begin;
            float* centroid = centroids.data() + b * d;
            for (size_t i = range.begin; i < range.end; ++i) {
                const float* vec = base + i * d;
                for (size_t j = 0; j < d; ++j) {
                    centroid[j] += vec[j];
                }
            }
            const float inv = 1.0f / static_cast<float>(count);
            for (size_t j = 0; j < d; ++j) {
                centroid[j] *= inv;
            }

            blocks[b].holder = ann_hnsw::BuildIndex(
                base + range.begin * d, count, d, M, ef_construction,
                ef_search);
        }

        top_index = ann_hnsw::BuildIndex(centroids.data(), nblocks, d,
                                         std::max<size_t>(2, std::min(M, nblocks)),
                                         ef_construction, ef_search);
    }

private:
    static BlockRange Partition(size_t n, size_t rank, size_t parts) {
        const size_t base = n / parts;
        const size_t extra = n % parts;
        const size_t begin = rank * base + std::min(rank, extra);
        const size_t count = base + (rank < extra ? 1 : 0);
        BlockRange range = {begin, begin + count};
        return range;
    }
};

static inline ann_hnsw::SearchHeap hnsw_on_hnsw_search_omp(
    const HierarchicalIndex& index, const float* query, size_t k,
    size_t ef, size_t nprobe, int nthreads) {
    if (nthreads < 1) {
        nthreads = 1;
    }
    nprobe = std::max<size_t>(1, std::min(nprobe, index.blocks.size()));
    ef = std::max(ef, k);

    ann_hnsw::SearchHeap selected =
        ann_hnsw::StandardSearch(*index.top_index.index, query, nprobe,
                                 std::max(ef, nprobe), 1);
    std::vector<uint32_t> block_ids;
    block_ids.reserve(nprobe);
    while (!selected.empty()) {
        block_ids.push_back(selected.top().second);
        selected.pop();
    }

    std::vector<ann_hnsw::SearchHeap> heaps(block_ids.size());
#pragma omp parallel for num_threads(nthreads) schedule(dynamic)
    for (long long i = 0; i < static_cast<long long>(block_ids.size()); ++i) {
        const size_t slot = static_cast<size_t>(i);
        const uint32_t block_id = block_ids[slot];
        if (block_id >= index.blocks.size()) {
            continue;
        }
        const BlockIndex& block = index.blocks[block_id];
        ann_hnsw::SearchHeap local =
            ann_hnsw::StandardSearch(*block.holder.index, query, k, ef, 1);
        while (!local.empty()) {
            const std::pair<float, uint32_t> item = local.top();
            local.pop();
            ann_hnsw::PushTopK(
                heaps[slot], item.first,
                static_cast<uint32_t>(block.range.begin) + item.second, k);
        }
    }

    return ann_hnsw::MergeHeaps(heaps, k);
}

}  // namespace ann_hnsw_on_hnsw
