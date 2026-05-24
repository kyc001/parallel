// Dump IVF inverted-list 长度分布
// 编译: g++ tools/dump_ivf_hist.cc -o build/dump_ivf_hist.exe -O2 -mavx2 -mfma -std=c++17 -I.
// 运行: ./build/dump_ivf_hist.exe  (会写出 results/ivf_list_histogram.csv)

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "simd/ann_bench_common.h"
#include "ivf/ivf_index.h"

int main() {
    size_t base_n = 0, base_d = 0;
    const std::string data_path = ann_bench::DefaultDataPath();
    auto base = ann_bench::LoadData<float>(
        data_path + "DEEP100K.base.100k.fbin", base_n, base_d);

    const size_t nlist = 16;
    ann_ivf::IVFIndex idx;
    idx.build(base.get(), base_n, base_d, nlist, 8);

    std::ofstream csv("results/ivf_list_histogram.csv");
    csv << "list_id,size\n";
    std::vector<size_t> sizes(nlist);
    for (size_t c = 0; c < nlist; ++c) {
        sizes[c] = idx.list_offsets[c + 1] - idx.list_offsets[c];
        csv << c << "," << sizes[c] << "\n";
    }
    csv.close();

    std::sort(sizes.begin(), sizes.end());
    const size_t mn   = sizes.front();
    const size_t mx   = sizes.back();
    const size_t med  = sizes[nlist / 2];
    const double mean = static_cast<double>(base_n) / static_cast<double>(nlist);
    double var = 0.0;
    for (size_t s : sizes) {
        const double diff = static_cast<double>(s) - mean;
        var += diff * diff;
    }
    var /= static_cast<double>(nlist);

    std::cout << "nlist=" << nlist << " base_n=" << base_n << "\n";
    std::cout << "min=" << mn << " median=" << med << " max=" << mx << "\n";
    std::cout << "mean=" << mean << " stddev=" << std::sqrt(var) << "\n";
    std::cout << "max/mean=" << (static_cast<double>(mx) / mean) << "\n";
    return 0;
}
