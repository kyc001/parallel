#pragma once

#include <algorithm>
#include <cstdint>
#include <cstddef>
#include <memory>
#include <queue>
#include <set>
#include <stdexcept>
#include <utility>
#include <vector>

#include "hnswlib/hnswlib/hnswlib.h"

namespace ann_hnsw {

using HnswIndex = hnswlib::HierarchicalNSW<float>;
using SearchHeap = std::priority_queue<std::pair<float, uint32_t>>;

struct HnswHolder {
    std::unique_ptr<hnswlib::InnerProductSpace> space;
    std::unique_ptr<HnswIndex> index;
};

static inline void PushTopK(SearchHeap& heap, float dist, uint32_t id, size_t k) {
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
        while (!heaps[i].empty()) {
            const std::pair<float, uint32_t> item = heaps[i].top();
            heaps[i].pop();
            PushTopK(result, item.first, item.second, k);
        }
    }
    return result;
}

static inline SearchHeap ConvertResult(
    std::priority_queue<std::pair<float, hnswlib::labeltype>> result, size_t k) {
    SearchHeap heap;
    while (!result.empty()) {
        const std::pair<float, hnswlib::labeltype> item = result.top();
        result.pop();
        PushTopK(heap, item.first, static_cast<uint32_t>(item.second), k);
    }
    return heap;
}

static inline HnswHolder BuildIndex(const float* base, size_t n, size_t d,
                                    size_t M = 16, size_t ef_construction = 120,
                                    size_t ef_search = 50) {
    HnswHolder holder;
    holder.space.reset(new hnswlib::InnerProductSpace(d));
    holder.index.reset(new HnswIndex(holder.space.get(), n, M, ef_construction));
    for (size_t i = 0; i < n; ++i) {
        holder.index->addPoint(base + i * d, static_cast<hnswlib::labeltype>(i));
    }
    holder.index->setEf(ef_search);
    return holder;
}

static inline float Distance(const HnswIndex& index, const float* query, uint32_t internal_id) {
    return index.fstdistfunc_(query, index.getDataByInternalId(internal_id),
                              index.dist_func_param_);
}

static inline std::vector<uint32_t> GetNeighbors(const HnswIndex& index,
                                                 uint32_t internal_id,
                                                 int level = 0) {
    std::vector<uint32_t> neighbors;
    if (internal_id >= index.cur_element_count || level > index.element_levels_[internal_id]) {
        return neighbors;
    }
    hnswlib::linklistsizeint* list = index.get_linklist_at_level(internal_id, level);
    const size_t count = index.getListCount(list);
    hnswlib::tableint* data = reinterpret_cast<hnswlib::tableint*>(list + 1);
    neighbors.reserve(count);
    for (size_t i = 0; i < count; ++i) {
        if (data[i] < index.cur_element_count) {
            neighbors.push_back(static_cast<uint32_t>(data[i]));
        }
    }
    return neighbors;
}

static inline std::vector<uint32_t> PickEntries(const HnswIndex& index, int nentries) {
    if (nentries < 1) {
        nentries = 1;
    }
    const size_t count = static_cast<size_t>(index.cur_element_count);
    std::vector<uint32_t> entries;
    if (count == 0) {
        return entries;
    }
    entries.reserve(static_cast<size_t>(nentries));
    for (int i = 0; i < nentries; ++i) {
        const size_t pos = (static_cast<size_t>(i) * count) / static_cast<size_t>(nentries);
        entries.push_back(static_cast<uint32_t>(std::min(pos, count - 1)));
    }
    return entries;
}

static inline SearchHeap SearchLayer0FromEntry(const HnswIndex& index,
                                               const float* query, uint32_t entry,
                                               size_t k, size_t ef) {
    ef = std::max(ef, k);
    const size_t count = static_cast<size_t>(index.cur_element_count);
    std::vector<uint8_t> visited(count, 0);
    SearchHeap top;

    typedef std::pair<float, uint32_t> Candidate;
    struct MinDist {
        bool operator()(const Candidate& a, const Candidate& b) const {
            return a.first > b.first;
        }
    };
    std::priority_queue<Candidate, std::vector<Candidate>, MinDist> candidates;

    const float entry_dist = Distance(index, query, entry);
    candidates.push(std::make_pair(entry_dist, entry));
    PushTopK(top, entry_dist, entry, ef);
    visited[entry] = 1;

    while (!candidates.empty()) {
        const Candidate current = candidates.top();
        candidates.pop();
        if (top.size() >= ef && current.first > top.top().first) {
            break;
        }

        const std::vector<uint32_t> neighbors = GetNeighbors(index, current.second, 0);
        for (size_t i = 0; i < neighbors.size(); ++i) {
            const uint32_t nb = neighbors[i];
            if (nb >= count || visited[nb]) {
                continue;
            }
            visited[nb] = 1;
            const float dist = Distance(index, query, nb);
            if (top.size() < ef || dist < top.top().first) {
                candidates.push(std::make_pair(dist, nb));
                PushTopK(top, dist, nb, ef);
            }
        }
    }

    std::vector<SearchHeap> heaps(1);
    heaps[0] = std::move(top);
    return MergeHeaps(heaps, k);
}

static inline SearchHeap StandardSearch(const HnswIndex& index, const float* query,
                                        size_t k, size_t ef, int) {
    const_cast<HnswIndex&>(index).setEf(ef);
    return ConvertResult(index.searchKnn(query, k), k);
}

}  // namespace ann_hnsw
