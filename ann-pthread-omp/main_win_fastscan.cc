// 独立 main, 不 include main_win_avx2.cc, 不改变任何已有文件
#include <iostream>
#include <fstream>
#include <vector>
#include <chrono>
#include <string>
#include <set>
#include <cstdint>
#include "pq_fastscan_avx2.h"

// —— 从你现有 main_win_avx2.cc 里复制 LoadData / gt 读取的函数到这里 ——
// 或直接 #include 一个抽出来的 data_loader.h (如果你之前已抽过)
// 这里给出最小接口假设:
// 标准 fbin/ibin loader: 头 8 字节 uint32 (n, d), 后接 n*d 个 T
template<typename T>
T* LoadData(const std::string& path, size_t& n, size_t& d) {
    std::ifstream fin(path, std::ios::binary);
    if (!fin) {
        std::cerr << "cannot open: " << path << std::endl;
        std::exit(1);
    }
    uint32_t n32 = 0, d32 = 0;
    fin.read(reinterpret_cast<char*>(&n32), 4);
    fin.read(reinterpret_cast<char*>(&d32), 4);
    n = n32; d = d32;
    T* data = new T[(size_t)n * d];
    fin.read(reinterpret_cast<char*>(data), (std::streamsize)sizeof(T) * n * d);
    std::cout << "loaded " << path << "  n=" << n << " d=" << d << std::endl;
    return data;
}
int main(int argc, char** argv) {
    std::string data_path = "./files/";
    size_t base_number = 0, vecdim = 0;
    size_t test_number = 0, test_gt_d = 0;
    auto base       = LoadData<float>(data_path + "DEEP100K.base.100k.fbin",   base_number, vecdim);
    auto test_query = LoadData<float>(data_path + "DEEP100K.query.fbin",        test_number, vecdim);
    auto test_gt    = LoadData<int>  (data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, test_gt_d);
    test_number = 2000;
    const size_t k = 10;

    // 仅扫几组 p (候选数)
    std::vector<int> p_list = {40, 100, 500, 1000, 2000, 5000};

    ann_fs::FastScanIndex idx;
    std::cout << "[FastScan] training ..." << std::endl;
    ann_fs::train_fastscan(idx, base, (int)base_number, (int)vecdim);
    ann_fs::encode_fastscan(idx, base);
    std::cout << "[FastScan] trained, codes_packed bytes = "
              << idx.codes_packed.size() << std::endl;

    for (int p : p_list) {
        double sum_recall = 0, sum_us = 0;
        for (size_t qi = 0; qi < test_number; ++qi) {
            auto t0 = std::chrono::high_resolution_clock::now();
            auto heap = ann_fs::fastscan_search(
                idx, base, test_query + qi * vecdim, k, p);
            auto t1 = std::chrono::high_resolution_clock::now();
            double us = std::chrono::duration<double, std::micro>(t1 - t0).count();
            sum_us += us;

            std::set<int> gt;
            for (size_t j = 0; j < k; ++j)
                gt.insert(test_gt[qi * test_gt_d + j]);
            size_t hit = 0;
            while (!heap.empty()) {
                if (gt.count((int)heap.top().second)) hit++;
                heap.pop();
            }
            sum_recall += (double)hit / k;
        }
        double avg_us = sum_us / test_number;
        double avg_rc = sum_recall / test_number;
        std::cout << "p=" << p
                  << "  recall=" << avg_rc
                  << "  latency=" << avg_us << " us" << std::endl;

        // 结果写独立子目录
        std::ofstream out("bench_results/windows_i9_13900h/fastscan/speed_fastscan_p" + std::to_string(p) + ".txt");
        out << "mode=fastscan p=" << p
            << " recall=" << avg_rc
            << " latency_us=" << avg_us << "\n";
    }
    return 0;
}