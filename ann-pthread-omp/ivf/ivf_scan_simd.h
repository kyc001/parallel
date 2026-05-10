#pragma once

#include "ivf/ivf_index.h"

static inline ann_ivf::SearchHeap ivf_search(
    const ann_ivf::IVFIndex& index, const float* query, size_t k, size_t nprobe) {
    const std::vector<uint32_t> probes = index.select_probes(query, nprobe);
    ann_ivf::SearchHeap result;
    for (size_t i = 0; i < probes.size(); ++i) {
        ann_ivf::ScanList(index, query, probes[i], k, result);
    }
    return result;
}
