# ANN Pthread + OpenMP 并行化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 ann-pthread-omp 目录完成 Flat/PQ/IVF/IVF-PQ 主线 + SQ/FastScan/HNSW 扩展的全部 pthread + OpenMP + SIMD 并行化实现，含一键构建/运行脚本。

**Architecture:** 分 8 阶段推进：基础设施 → Flat → PQ → IVF → IVF-PQ → 扩展(SQ/FastScan/HNSW) → 脚本 → 实验。每阶段产出可编译可测试的中间产物。pthread 和 omp 并行逻辑放在独立子目录的头文件中，所有 main 变体集中在 mains/ 按算法→策略分层。

**Tech Stack:** C++17, pthread, OpenMP, ARM NEON intrinsics, x86 AVX2 intrinsics, Make

---

## 文件迁移清单（阶段 1 执行）

**移入 `simd/`（共 15 个文件）：**
- `ann_bench_common.h`
- `flat_scan_simd.h`, `flat_scan_avx2.h`, `flat_scan_avx2_blocked.h`, `flat_scan_avx2_topkarr.h`
- `sq_scan_simd.h`, `sq_scan_avx2.h`
- `pq_scan_simd.h`, `pq_scan_avx2.h`
- `pq_blocked_neon.h`, `pq_blocked_avx2.h`
- `pq_fastscan_simd.h`, `pq_fastscan_neon.h`, `pq_fastscan_avx2.h`, `pq_fastscan_avx2_safe.h`

**移入 `scripts/`（旧脚本，非一键运行）：**
- `build_fastscan.sh`, `build_fastscan.ps1`
- `run_all.sh`, `run_all_with_fastscan.sh`
- `run_fastscan_bigp.sh`, `run_fastscan_kunpeng.sh`, `run_fastscan_pcore.ps1`, `run_fastscan_test.sh`
- `run_full_score_bench.ps1`, `run_vtune_flat_pcore.ps1`, `run_vtune_windows_admin.sh`
- `parse_win_results.ps1`

**移入 `mains/simd/`（纯 SIMD main 文件）：**
- `main_baseline.cc`, `main_flatsimd.cc`, `main_sqsimd.cc`, `main_pqsimd.cc`
- `main_fastscan.cc`, `main_fastscan_submit.cc`

**移入 `mains/win/`（Windows 专用测试文件，不移入 simd/ 目录）：**
- `main_win_avx2.cc`, `main_win_ext.cc`, `main_win_fastscan.cc`, `main_win_fastscan_ext.cc`

**根目录保留（不动）：**
- `hnswlib/`, `flat_scan.h`, `main.cc`, `qsub.sh`, `test.sh`
- `report/`, `files/`

---

## 阶段 1：基础设施

### Task 1.1: 创建子目录结构 & 移动文件

**创建目录：**
```
simd/  pthread/  omp/  ivf/  hnsw/
mains/  mains/simd/  mains/win/
mains/omp/inter/  mains/omp/intra/
mains/pthread/static/inter/  mains/pthread/static/intra/
mains/pthread/dynamic/inter/  mains/pthread/dynamic/intra/
mains/pthread/pool/inter/  mains/pthread/pool/intra/
mains/ivf/simd/  mains/ivf/omp/inter/  mains/ivf/omp/intra/
mains/ivf/pthread/static/inter/  mains/ivf/pthread/static/intra/
mains/ivf/pthread/dynamic/inter/  mains/ivf/pthread/dynamic/intra/
mains/ivf/pthread/pool/inter/  mains/ivf/pthread/pool/intra/
mains/hnsw/
scripts/  results/  build/
```

- [ ] **Step 1: 创建所有目录**

```bash
cd D:/Study/26sp/parallel/ann-pthread-omp
mkdir -p simd pthread omp ivf hnsw
mkdir -p mains/simd mains/win
mkdir -p mains/omp/inter mains/omp/intra
mkdir -p mains/pthread/static/inter mains/pthread/static/intra
mkdir -p mains/pthread/dynamic/inter mains/pthread/dynamic/intra
mkdir -p mains/pthread/pool/inter mains/pthread/pool/intra
mkdir -p mains/ivf/simd
mkdir -p mains/ivf/omp/inter mains/ivf/omp/intra
mkdir -p mains/ivf/pthread/static/inter mains/ivf/pthread/static/intra
mkdir -p mains/ivf/pthread/dynamic/inter mains/ivf/pthread/dynamic/intra
mkdir -p mains/ivf/pthread/pool/inter mains/ivf/pthread/pool/intra
mkdir -p mains/hnsw
mkdir -p scripts results build
```

- [ ] **Step 2: 移动 SIMD 头文件到 simd/**

```bash
mv ann_bench_common.h simd/
mv flat_scan_simd.h flat_scan_avx2.h flat_scan_avx2_blocked.h flat_scan_avx2_topkarr.h simd/
mv sq_scan_simd.h sq_scan_avx2.h simd/
mv pq_scan_simd.h pq_scan_avx2.h simd/
mv pq_blocked_neon.h pq_blocked_avx2.h simd/
mv pq_fastscan_simd.h pq_fastscan_neon.h pq_fastscan_avx2.h pq_fastscan_avx2_safe.h simd/
```

- [ ] **Step 3: 移动旧脚本到 scripts/**

```bash
mv build_fastscan.sh build_fastscan.ps1 scripts/
mv run_all.sh run_all_with_fastscan.sh scripts/
mv run_fastscan_bigp.sh run_fastscan_kunpeng.sh run_fastscan_pcore.ps1 run_fastscan_test.sh scripts/
mv run_full_score_bench.ps1 run_vtune_flat_pcore.ps1 run_vtune_windows_admin.sh scripts/
mv parse_win_results.ps1 scripts/
```

- [ ] **Step 4: 移动 main 文件**

```bash
mv main_baseline.cc main_flatsimd.cc main_sqsimd.cc main_pqsimd.cc mains/simd/
mv main_fastscan.cc main_fastscan_submit.cc mains/simd/
mv main_win_avx2.cc main_win_ext.cc main_win_fastscan.cc main_win_fastscan_ext.cc mains/win/
```

- [ ] **Step 5: 更新所有移动文件的 #include 路径**

所有 `#include "flat_scan.h"` 保持不变（根目录）, 所有 `#include "flat_scan_simd.h"` → `#include "simd/flat_scan_simd.h"` 等。批量 sed：

```bash
cd D:/Study/26sp/parallel/ann-pthread-omp
for f in $(find . -name '*.cc' -o -name '*.h'); do
  sed -i 's|#include "flat_scan_simd\.h"|#include "simd/flat_scan_simd.h"|g' "$f"
  sed -i 's|#include "flat_scan_avx2\.h"|#include "simd/flat_scan_avx2.h"|g' "$f"
  sed -i 's|#include "flat_scan_avx2_blocked\.h"|#include "simd/flat_scan_avx2_blocked.h"|g' "$f"
  sed -i 's|#include "flat_scan_avx2_topkarr\.h"|#include "simd/flat_scan_avx2_topkarr.h"|g' "$f"
  sed -i 's|#include "sq_scan_simd\.h"|#include "simd/sq_scan_simd.h"|g' "$f"
  sed -i 's|#include "sq_scan_avx2\.h"|#include "simd/sq_scan_avx2.h"|g' "$f"
  sed -i 's|#include "pq_scan_simd\.h"|#include "simd/pq_scan_simd.h"|g' "$f"
  sed -i 's|#include "pq_scan_avx2\.h"|#include "simd/pq_scan_avx2.h"|g' "$f"
  sed -i 's|#include "pq_blocked_neon\.h"|#include "simd/pq_blocked_neon.h"|g' "$f"
  sed -i 's|#include "pq_blocked_avx2\.h"|#include "simd/pq_blocked_avx2.h"|g' "$f"
  sed -i 's|#include "pq_fastscan_simd\.h"|#include "simd/pq_fastscan_simd.h"|g' "$f"
  sed -i 's|#include "pq_fastscan_neon\.h"|#include "simd/pq_fastscan_neon.h"|g' "$f"
  sed -i 's|#include "pq_fastscan_avx2\.h"|#include "simd/pq_fastscan_avx2.h"|g' "$f"
  sed -i 's|#include "pq_fastscan_avx2_safe\.h"|#include "simd/pq_fastscan_avx2_safe.h"|g' "$f"
  sed -i 's|#include "ann_bench_common\.h"|#include "simd/ann_bench_common.h"|g' "$f"
done
```

- [ ] **Step 6: 修正 simd/ann_bench_common.h 数据路径**

把 `DefaultDataPath()` 的 Windows 返回改为 `../files/`：

```cpp
inline std::string DefaultDataPath() {
#ifdef _WIN32
    return "../files/";
#else
    return "/anndata/";
#endif
}
```

- [ ] **Step 7: 验证编译基线**

```bash
cp mains/simd/main_baseline.cc main.cc
g++ main.cc -o build/test_baseline -O2 -std=c++17 -I. 2>&1
# 期望：编译成功（可能缺 -fopenmp 等，仅验证 include 路径正确）
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: modularize directory structure, move headers to simd/"
```

---

## 阶段 2：Flat 主线（flat_scan_pthread.h + flat_scan_omp.h + 12 mains）

### Task 2.1: 创建 pthread/thread_pool.h（纯 pthread 线程池）

**Files:** Create `pthread/thread_pool.h`

封装 `pthread_mutex_t` + `pthread_cond_t` 任务队列，供 pool 变体和后续 IVF 复用。

```cpp
#pragma once
#include <pthread.h>
#include <vector>
#include <queue>
#include <functional>

struct ThreadPool {
    struct Task {
        size_t start, end;
        std::function<void(size_t,size_t)> fn;
    };

    std::vector<pthread_t> workers;
    std::queue<Task> tasks;
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    pthread_cond_t done_cond;
    int active_count;
    bool stop;

    static void* worker_fn(void* arg) {
        ThreadPool* pool = static_cast<ThreadPool*>(arg);
        while (true) {
            pthread_mutex_lock(&pool->mutex);
            while (pool->tasks.empty() && !pool->stop)
                pthread_cond_wait(&pool->cond, &pool->mutex);
            if (pool->stop && pool->tasks.empty()) {
                pthread_mutex_unlock(&pool->mutex);
                break;
            }
            Task t = std::move(pool->tasks.front());
            pool->tasks.pop();
            pthread_mutex_unlock(&pool->mutex);

            t.fn(t.start, t.end);

            pthread_mutex_lock(&pool->mutex);
            pool->active_count--;
            if (pool->active_count == 0 && pool->tasks.empty())
                pthread_cond_signal(&pool->done_cond);
            pthread_mutex_unlock(&pool->mutex);
        }
        return nullptr;
    }

    ThreadPool(int nthreads) : active_count(0), stop(false) {
        pthread_mutex_init(&mutex, nullptr);
        pthread_cond_init(&cond, nullptr);
        pthread_cond_init(&done_cond, nullptr);
        workers.resize(nthreads);
        for (int i = 0; i < nthreads; ++i)
            pthread_create(&workers[i], nullptr, worker_fn, this);
    }

    void enqueue(Task t) {
        pthread_mutex_lock(&mutex);
        active_count++;
        tasks.push(std::move(t));
        pthread_cond_signal(&cond);
        pthread_mutex_unlock(&mutex);
    }

    void wait_all() {
        pthread_mutex_lock(&mutex);
        while (active_count > 0 || !tasks.empty())
            pthread_cond_wait(&done_cond, &mutex);
        pthread_mutex_unlock(&mutex);
    }

    ~ThreadPool() {
        pthread_mutex_lock(&mutex);
        stop = true;
        pthread_cond_broadcast(&cond);
        pthread_mutex_unlock(&mutex);
        for (pthread_t& w : workers)
            pthread_join(w, nullptr);
        pthread_mutex_destroy(&mutex);
        pthread_cond_destroy(&cond);
        pthread_cond_destroy(&done_cond);
    }
};
```

- [ ] **Step 1: 写入上述代码到 pthread/thread_pool.h**

- [ ] **Step 2: 编译验证**

```bash
echo '#include "pthread/thread_pool.h"
int main(){ ThreadPool p(2); return 0; }' > build/_test_pool.cc
g++ build/_test_pool.cc -o build/_test_pool -O2 -lpthread -std=c++17 -I.
./build/_test_pool
rm build/_test_pool.cc build/_test_pool
```

- [ ] **Step 3: Commit**

```bash
git add pthread/thread_pool.h
git commit -m "feat: add pure-pthread thread pool"
```

### Task 2.2: 创建 pthread/flat_scan_pthread.h

**Files:** Create `pthread/flat_scan_pthread.h`

包含 6 个函数：
- `flat_search_inter_static(base, queries, base_n, query_n, d, k, nthreads)` — 查询级静态划分
- `flat_search_intra_static(base, query, base_n, d, k, nthreads)` — 查询内静态划分
- `flat_search_inter_dynamic(...)` — 查询级 atomic 抢任务
- `flat_search_intra_dynamic(...)` — 查询内 atomic 抢 base 向量
- `flat_search_inter_pool(...)` — 查询级线程池
- `flat_search_intra_pool(...)` — 查询内线程池

通用工具函数（本文件内 static）：
- `merge_heaps()` — 合并多个 local heaps 得到全局 top-k

```cpp
#pragma once
#include <queue>
#include <vector>
#include <utility>
#include <cstdint>
#include <cstring>
#include <algorithm>
#include <atomic>
#include <pthread.h>
#include "simd/flat_scan_simd.h"
#include "pthread/thread_pool.h"

// ============================================================
// 工具函数
// ============================================================
static inline std::priority_queue<std::pair<float, uint32_t>>
merge_heaps(std::vector<std::priority_queue<std::pair<float, uint32_t>>>& heaps, size_t k) {
    std::priority_queue<std::pair<float, uint32_t>> result;
    for (auto& h : heaps) {
        while (!h.empty()) {
            auto item = h.top(); h.pop();
            if (result.size() < k) {
                result.push(item);
            } else if (item.first < result.top().first) {
                result.push(item);
                result.pop();
            }
        }
    }
    return result;
}

// ============================================================
// Static / Barrier — 查询级并行 (inter-query)
// ============================================================
struct FlatInterStaticArg {
    float* base; float* queries; size_t base_n; size_t vecdim; size_t k;
    size_t q_start, q_end;
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>* results;
};

static inline void* flat_inter_static_worker(void* arg) {
    FlatInterStaticArg* a = static_cast<FlatInterStaticArg*>(arg);
    for (size_t i = a->q_start; i < a->q_end; ++i) {
        (*a->results)[i] = flat_search(a->base, a->queries + i * a->vecdim, a->base_n, a->vecdim, a->k);
    }
    return nullptr;
}

static inline void flat_search_inter_static(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, int nthreads,
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>& results)
{
    results.resize(query_n);
    std::vector<pthread_t> threads(nthreads);
    std::vector<FlatInterStaticArg> args(nthreads);
    size_t chunk = (query_n + nthreads - 1) / nthreads;

    for (int t = 0; t < nthreads; ++t) {
        args[t] = {base, queries, base_n, d, k,
                   t * chunk, std::min((t + 1) * chunk, query_n), &results};
        pthread_create(&threads[t], nullptr, flat_inter_static_worker, &args[t]);
    }
    for (int t = 0; t < nthreads; ++t)
        pthread_join(threads[t], nullptr);
}

// ============================================================
// Static / Barrier — 查询内并行 (intra-query)
// ============================================================
struct FlatIntraStaticArg {
    float* base; float* query; size_t base_n; size_t vecdim; size_t k;
    size_t b_start, b_end;
    std::priority_queue<std::pair<float, uint32_t>> local_heap;
};

static inline void* flat_intra_static_worker(void* arg) {
    FlatIntraStaticArg* a = static_cast<FlatIntraStaticArg*>(arg);
    for (size_t i = a->b_start; i < a->b_end; ++i) {
        float dis = ip_distance_simd(a->base + i * a->vecdim, a->query, static_cast<int>(a->vecdim));
        if (a->local_heap.size() < a->k) {
            a->local_heap.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < a->local_heap.top().first) {
            a->local_heap.push({dis, static_cast<uint32_t>(i)});
            a->local_heap.pop();
        }
    }
    return nullptr;
}

static inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_intra_static(float* base, float* query, size_t base_n, size_t d, size_t k, int nthreads) {
    std::vector<pthread_t> threads(nthreads);
    std::vector<FlatIntraStaticArg> args(nthreads);
    size_t chunk = (base_n + nthreads - 1) / nthreads;

    for (int t = 0; t < nthreads; ++t) {
        args[t] = {base, query, base_n, d, k,
                   t * chunk, std::min((t + 1) * chunk, base_n), {}};
        pthread_create(&threads[t], nullptr, flat_intra_static_worker, &args[t]);
    }
    for (int t = 0; t < nthreads; ++t)
        pthread_join(threads[t], nullptr);

    std::vector<std::priority_queue<std::pair<float, uint32_t>>> heaps;
    for (int t = 0; t < nthreads; ++t)
        heaps.push_back(std::move(args[t].local_heap));
    return merge_heaps(heaps, k);
}

// ============================================================
// Dynamic — 查询级并行 (inter-query, atomic 抢查询)
// ============================================================
struct FlatInterDynamicArg {
    float* base; float* queries; size_t base_n; size_t query_n; size_t vecdim; size_t k;
    std::atomic<size_t>* counter;
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>* results;
};

static inline void* flat_inter_dynamic_worker(void* arg) {
    FlatInterDynamicArg* a = static_cast<FlatInterDynamicArg*>(arg);
    while (true) {
        size_t i = a->counter->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->query_n) break;
        (*a->results)[i] = flat_search(a->base, a->queries + i * a->vecdim, a->base_n, a->vecdim, a->k);
    }
    return nullptr;
}

static inline void flat_search_inter_dynamic(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, int nthreads,
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>& results)
{
    results.resize(query_n);
    std::atomic<size_t> counter{0};
    std::vector<pthread_t> threads(nthreads);
    FlatInterDynamicArg arg = {base, queries, base_n, query_n, d, k, &counter, &results};

    for (int t = 0; t < nthreads; ++t)
        pthread_create(&threads[t], nullptr, flat_inter_dynamic_worker, &arg);
    for (int t = 0; t < nthreads; ++t)
        pthread_join(threads[t], nullptr);
}

// ============================================================
// Dynamic — 查询内并行 (intra-query, atomic 抢 base 向量)
// ============================================================
struct FlatIntraDynamicArg {
    float* base; float* query; size_t base_n; size_t vecdim; size_t k;
    std::atomic<size_t>* counter;
};

static inline void* flat_intra_dynamic_worker(void* arg) {
    FlatIntraDynamicArg* a = static_cast<FlatIntraDynamicArg*>(arg);
    std::priority_queue<std::pair<float, uint32_t>> local_heap;
    while (true) {
        size_t i = a->counter->fetch_add(1, std::memory_order_relaxed);
        if (i >= a->base_n) break;
        float dis = ip_distance_simd(a->base + i * a->vecdim, a->query, static_cast<int>(a->vecdim));
        if (local_heap.size() < a->k) {
            local_heap.push({dis, static_cast<uint32_t>(i)});
        } else if (dis < local_heap.top().first) {
            local_heap.push({dis, static_cast<uint32_t>(i)});
            local_heap.pop();
        }
    }
    // 通过 pthread 返回值传回 (用 new 分配)
    auto* result = new std::priority_queue<std::pair<float, uint32_t>>(std::move(local_heap));
    return result;
}

static inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_intra_dynamic(float* base, float* query, size_t base_n, size_t d, size_t k, int nthreads) {
    std::atomic<size_t> counter{0};
    std::vector<pthread_t> threads(nthreads);
    FlatIntraDynamicArg arg = {base, query, base_n, d, k, &counter};

    for (int t = 0; t < nthreads; ++t)
        pthread_create(&threads[t], nullptr, flat_intra_dynamic_worker, &arg);

    std::vector<std::priority_queue<std::pair<float, uint32_t>>> heaps;
    for (int t = 0; t < nthreads; ++t) {
        void* ret;
        pthread_join(threads[t], &ret);
        auto* h = static_cast<std::priority_queue<std::pair<float, uint32_t>>*>(ret);
        heaps.push_back(std::move(*h));
        delete h;
    }
    return merge_heaps(heaps, k);
}

// ============================================================
// Pool — 查询级并行 (inter-query, ThreadPool)
// ============================================================
static inline void flat_search_inter_pool(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, int nthreads,
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>& results)
{
    results.resize(query_n);
    ThreadPool pool(nthreads);

    for (size_t i = 0; i < query_n; ++i) {
        pool.enqueue({i, i + 1, [&, i](size_t, size_t) {
            results[i] = flat_search(base, queries + i * d, base_n, d, k);
        }});
    }
    pool.wait_all();
}

// ============================================================
// Pool — 查询内并行 (intra-query, ThreadPool + chunk 划分)
// ============================================================
static inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_intra_pool(float* base, float* query, size_t base_n, size_t d, size_t k, int nthreads) {
    ThreadPool pool(nthreads);
    size_t chunk = (base_n + nthreads - 1) / nthreads;
    std::vector<std::priority_queue<std::pair<float, uint32_t>>> heaps(nthreads);

    for (int t = 0; t < nthreads; ++t) {
        size_t start = t * chunk;
        size_t end = std::min((t + 1) * chunk, base_n);
        pool.enqueue({start, end, [&, t, start, end](size_t, size_t) {
            for (size_t i = start; i < end; ++i) {
                float dis = ip_distance_simd(base + i * d, query, static_cast<int>(d));
                if (heaps[t].size() < k) {
                    heaps[t].push({dis, static_cast<uint32_t>(i)});
                } else if (dis < heaps[t].top().first) {
                    heaps[t].push({dis, static_cast<uint32_t>(i)});
                    heaps[t].pop();
                }
            }
        }});
    }
    pool.wait_all();
    return merge_heaps(heaps, k);
}
```

- [ ] **Step 1: 写入上述代码到 pthread/flat_scan_pthread.h**

- [ ] **Step 2: Commit**

### Task 2.3: 创建 omp/flat_scan_omp.h

**Files:** Create `omp/flat_scan_omp.h`

```cpp
#pragma once
#include <queue>
#include <vector>
#include <utility>
#include <cstdint>
#include <omp.h>
#include "simd/flat_scan_simd.h"

// ============================================================
// Inter-query OMP
// ============================================================
static inline void flat_search_inter_omp(
    float* base, float* queries, size_t base_n, size_t query_n,
    size_t d, size_t k, int nthreads,
    std::vector<std::priority_queue<std::pair<float, uint32_t>>>& results)
{
    results.resize(query_n);
    #pragma omp parallel for num_threads(nthreads) schedule(static)
    for (size_t i = 0; i < query_n; ++i) {
        results[i] = flat_search(base, queries + i * d, base_n, d, k);
    }
}

// ============================================================
// Intra-query OMP
// ============================================================
static inline std::priority_queue<std::pair<float, uint32_t>>
flat_search_intra_omp(float* base, float* query, size_t base_n, size_t d, size_t k, int nthreads) {
    std::vector<std::priority_queue<std::pair<float, uint32_t>>> heaps(nthreads);

    #pragma omp parallel num_threads(nthreads)
    {
        int tid = omp_get_thread_num();
        #pragma omp for schedule(static)
        for (size_t i = 0; i < base_n; ++i) {
            float dis = ip_distance_simd(base + i * d, query, static_cast<int>(d));
            if (heaps[tid].size() < k) {
                heaps[tid].push({dis, static_cast<uint32_t>(i)});
            } else if (dis < heaps[tid].top().first) {
                heaps[tid].push({dis, static_cast<uint32_t>(i)});
                heaps[tid].pop();
            }
        }
    }

    // 串行 merge
    std::priority_queue<std::pair<float, uint32_t>> result;
    for (auto& h : heaps) {
        while (!h.empty()) {
            auto item = h.top(); h.pop();
            if (result.size() < k) {
                result.push(item);
            } else if (item.first < result.top().first) {
                result.push(item);
                result.pop();
            }
        }
    }
    return result;
}
```

- [ ] **Step 1: 写入上述代码到 omp/flat_scan_omp.h**

- [ ] **Step 2: Commit**

### Task 2.4: 创建 Flat 的全部 12 个 mains 文件

每个 main 文件结构相同：加载数据 → 用指定并行方式搜索 → 计时 → 输出 recall 和 latency。

以 `mains/pthread/static/inter/main_flat.cc` 为例，其余 11 个仅需修改 include 和调用的搜索函数名。由于 12 个文件高度相似，在此列出每个文件的关键差异：

| 文件路径 | include | 搜索调用 |
|---|---|---|
| `mains/omp/inter/main_flat.cc` | `omp/flat_scan_omp.h` | `flat_search_inter_omp(base, queries, base_n, query_n, d, k, nthreads, res_heaps)` |
| `mains/omp/intra/main_flat.cc` | `omp/flat_scan_omp.h` | 循环内 `flat_search_intra_omp(base, query, base_n, d, k, nthreads)` |
| `mains/pthread/static/inter/main_flat.cc` | `pthread/flat_scan_pthread.h` | `flat_search_inter_static(...)` |
| `mains/pthread/static/intra/main_flat.cc` | `pthread/flat_scan_pthread.h` | `flat_search_intra_static(...)` |
| `mains/pthread/dynamic/inter/main_flat.cc` | `pthread/flat_scan_pthread.h` | `flat_search_inter_dynamic(...)` |
| `mains/pthread/dynamic/intra/main_flat.cc` | `pthread/flat_scan_pthread.h` | `flat_search_intra_dynamic(...)` |
| `mains/pthread/pool/inter/main_flat.cc` | `pthread/flat_scan_pthread.h` + `pthread/thread_pool.h` | `flat_search_inter_pool(...)` |
| `mains/pthread/pool/intra/main_flat.cc` | `pthread/flat_scan_pthread.h` + `pthread/thread_pool.h` | `flat_search_intra_pool(...)` |

注：`mains/simd/main_flat.cc` 和 `mains/simd/main_baseline.cc` 已在阶段 1 移入。

**通用 main 模板（inter-query 变体）：**

```cpp
#include <vector>
#include <cstring>
#include <string>
#include <iostream>
#include <fstream>
#include <set>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <sys/time.h>
#include <omp.h>
#include <algorithm>
#include "hnswlib/hnswlib/hnswlib.h"
#include "flat_scan.h"
#include "pthread/flat_scan_pthread.h"   // ← 各变体改此行
// 可以自行添加需要的头文件

using namespace hnswlib;

template<typename T>
T *LoadData(std::string data_path, size_t& n, size_t& d)
{
    std::ifstream fin;
    fin.open(data_path, std::ios::in | std::ios::binary);
    fin.read((char*)&n,4);
    fin.read((char*)&d,4);
    T* data = new T[n*d];
    int sz = sizeof(T);
    for(int i = 0; i < n; ++i){
        fin.read(((char*)data + i*d*sz), d*sz);
    }
    fin.close();
    std::cerr<<"load data "<<data_path<<"\n";
    std::cerr<<"dimension: "<<d<<"  number:"<<n<<"  size_per_element:"<<sizeof(T)<<"\n";
    return data;
}

struct SearchResult { float recall; int64_t latency; };

int main(int argc, char *argv[])
{
    size_t test_number = 0, base_number = 0;
    size_t test_gt_d = 0, vecdim = 0;

#ifdef _WIN32
    std::string data_path = "../files/";
#else
    std::string data_path = "/anndata/";
#endif
    auto test_query = LoadData<float>(data_path + "DEEP100K.query.fbin", test_number, vecdim);
    auto test_gt = LoadData<int>(data_path + "DEEP100K.gt.query.100k.top100.bin", test_number, test_gt_d);
    auto base = LoadData<float>(data_path + "DEEP100K.base.100k.fbin", base_number, vecdim);
    test_number = 2000;

    const size_t k = 10;
    int nthreads = 4;
    if (argc > 1) nthreads = std::atoi(argv[1]);

    const unsigned long Converter = 1000 * 1000;
    struct timeval val;
    gettimeofday(&val, NULL);

    // --- Inter-query 并行搜索（一次调用处理全部查询）---
    std::vector<std::priority_queue<std::pair<float, uint32_t>>> res_heaps;
    flat_search_inter_static(base, test_query, base_number, test_number, vecdim, k, nthreads, res_heaps);

    struct timeval newVal;
    gettimeofday(&newVal, NULL);
    int64_t total_diff = (newVal.tv_sec * Converter + newVal.tv_usec) - (val.tv_sec * Converter + val.tv_usec);

    double avg_recall = 0.0;
    for (int i = 0; i < test_number; ++i) {
        std::set<uint32_t> gtset;
        for (int j = 0; j < k; ++j) gtset.insert(test_gt[j + i*test_gt_d]);
        size_t acc = 0;
        while (res_heaps[i].size()) {
            int x = res_heaps[i].top().second;
            if (gtset.find(x) != gtset.end()) ++acc;
            res_heaps[i].pop();
        }
        avg_recall += (float)acc/k;
    }
    avg_recall /= test_number;
    double avg_latency = (double)total_diff / test_number;

    std::cout << std::fixed << std::setprecision(5);
    std::cout << "flat_pthread_static_inter, nthreads=" << nthreads << "\n";
    std::cout << "average recall: " << avg_recall << "\n";
    std::cout << "average latency (us): " << avg_latency << "\n";
    return 0;
}
```

- [ ] **Step 1: 写入 12 个 Flat mains 文件（按上表逐个创建，修改 include 和调用行）**

- [ ] **Step 2: 编译测试一个 Flat 变体**

```bash
cp mains/pthread/static/inter/main_flat.cc main.cc
g++ main.cc -o build/test_flat -O2 -fopenmp -lpthread -std=c++17 -I. 2>&1
```

- [ ] **Step 3: Commit**

```bash
git add omp/ pthread/ mains/
git commit -m "feat: add Flat pthread+omp parallel (12 variants + 2 headers)"
```

---

## 阶段 3：PQ 主线

（类似 Flat 结构，LUT 构建 + ADC 查表两个阶段各自并行化）

### Task 3.1: 创建 pthread/pq_scan_pthread.h

包含 6 个函数（static/dynamic/pool × inter/intra）调用 `simd/pq_scan_simd.h` 的 `pq_search()`。

inter 函数为批量接口（一次调 LUT+ADC+rerank 全部查询），intra 为单查询内 base 向量划分。

- [ ] **Step 1: 写入 pthread/pq_scan_pthread.h**

### Task 3.2: 创建 omp/pq_scan_omp.h

- [ ] **Step 1: 写入 omp/pq_scan_omp.h**

### Task 3.3: 创建 PQ 的 12 个 mains 文件

- [ ] **Step 1: 写入 12 个 PQ mains（在 mains/pthread/*/inter|intra/ 和 mains/omp/inter|intra/ 下）**

- [ ] **Step 2: 编译测试一个 PQ 变体**

- [ ] **Step 3: Commit**

---

## 阶段 4：IVF 主线

### Task 4.1: 创建 ivf/ivf_index.h — IVF 索引结构 + KMeans 聚类构建

```cpp
// IVF 索引：
// - centroids: kmeans 聚类的 nlist 个质心
// - inverted_lists: 每个簇包含的 base 向量 ID 列表
// - 可选：簇内向量连续重排存储
struct IVFIndex {
    size_t nlist, n, d;
    std::vector<float> centroids;
    std::vector<std::vector<uint32_t>> inverted_lists;
    // 簇内重排后的 base 数据（连续存储）
    std::vector<float> reordered_base;
    std::vector<size_t> list_offsets;

    void build(const float* base, size_t n_, size_t d_, size_t nlist_, int niter=20);
};
```

- [ ] **Step 1: 写入 ivf/ivf_index.h（含 KMeans++ 初始化 + Lloyd 迭代，SIMD 加速距离计算）**

### Task 4.2: 创建 ivf/ivf_scan_simd.h — IVF SIMD 搜索

```cpp
// ivf_search(base, query, k, idx, nprobe):
//   1) 粗排：计算 query 到所有质心的距离（SIMD），取 top-nprobe 簇
//   2) 精排：扫描选中簇中的点（SIMD），维护 top-k 堆
```

- [ ] **Step 1: 写入 ivf/ivf_scan_simd.h**

### Task 4.3: 创建 ivf/ivf_scan_pthread.h + ivf/ivf_scan_omp.h

- IVF inter-query: 粗排和精排整体由不同线程处理不同查询
- IVF intra-query: 精排阶段 inverted list 分配给不同线程（dynamic 优势场景）
- 粗排计算量小不做 intra

- [ ] **Step 1: 写入 ivf/ivf_scan_pthread.h**

- [ ] **Step 2: 写入 ivf/ivf_scan_omp.h**

### Task 4.4: 创建 IVF 的 24 个 mains + SIMD baseline

（ivf/simd 2 + omp inter/intra 2 + pthread static/dynamic/pool × inter/intra = 6，考虑 IVF 还有 inter 粗排和 intra 精排组合，保守 12+ 个）

- [ ] **Step 1: 写入全部 IVF mains**

- [ ] **Step 2: Commit**

---

## 阶段 5：IVF-PQ 主线

### Task 5.1: 创建 ivf/ivf_pq_simd.h

两种构建方式：
1. 先 PQ 编码全部 base → 构建 IVF 索引
2. 先 IVF 聚类 → 每簇内独立 PQ

搜索：IVF 粗排选出 nprobe 簇 → 簇内 PQ ADC 距离 → rerank

- [ ] **Step 1: 写入 ivf/ivf_pq_simd.h**

### Task 5.2: 创建 ivf/ivf_pq_pthread.h + ivf/ivf_pq_omp.h

- [ ] **Step 1: 写入并行头文件**

### Task 5.3: 创建 IVF-PQ 的全部 mains

- [ ] **Step 1: 写入全部 IVF-PQ mains**

- [ ] **Step 2: Commit**

---

## 阶段 6：扩展（SQ + FastScan + HNSW）

### Task 6.1: SQ 并行化

- `pthread/sq_scan_pthread.h` + `omp/sq_scan_omp.h`（复用 sq_scan_simd.h）
- 8 mains: omp inter/intra + pthread static inter/intra + dynamic inter/intra + pool inter/intra
- 粗排/精排两阶段各自独立并行

- [ ] **Step 1: 写入 SQ 头文件 + mains**

- [ ] **Step 2: Commit**

### Task 6.2: FastScan 并行化

- `pthread/pq_fastscan_pthread.h` + `omp/pq_fastscan_omp.h`
- 8 mains
- 注意：FastScan 是 memory-bound，线程数不宜多，报告写清楚

- [ ] **Step 1: 写入 FastScan 头文件 + mains**

- [ ] **Step 2: Commit**

### Task 6.3: HNSW 图搜索并行化

基于 hnswlib 开发，**利用其公开内部 API**（`get_linklist_at_level()`, `getDataByInternalId()`, `enterpoint_node_`, `element_levels_`, `maxlevel_`）访问底层图结构，**不修改 hnswlib 源码**。

实现四种并行策略：

**(a) 多入口点并行** (`hnsw/hnsw_search_pthread.h` + `hnsw/hnsw_search_omp.h`)
- 从 Layer 0 随机选取 T 个入口点（T = 线程数）
- 每线程从自己的入口点出发，执行 hnswlib 标准 `searchKnn`（修改 ef 参数）
- 各线程返回局部 top-k，最后 merge 得到全局 top-k
- 接口：`hnsw_search_multi_entry_static/dynamic/pool()` + `hnsw_search_multi_entry_omp()`

**(b) 边划分并行** (`hnsw/hnsw_edge_parallel.h`)
- 在 `searchKnn` 的内层循环中，对当前节点的出边（通过 `get_linklist_at_level()` 获取）
- 将出边集合划分为 T 份，每线程计算一部分边的距离
- 合并候选结果后继续下一层
- 限制：只对度数高的 Layer 0 有益（maxM0=2M），上层边数少时并行开销大

**(c) Layer 0 点划分并行** (`hnsw/hnsw_layer0_parallel.h`)
- 将 Layer 0 的全部节点按 ID 范围等分给 T 个线程
- 每线程扫描自己的分区，直接计算 query 到分区内所有节点的距离
- 各线程维护局部 top-k，最后 merge
- 类似 Flat intra-query 但只扫描 Layer 0（最密层，约占全部节点）

**(d) IVF+HNSW 嵌套** (`hnsw/hnsw_ivf_nested.h`)
- 先用 IVF KMeans 将 base 数据聚类为 nlist 个簇
- 每个簇独立构建一个小 HNSW 索引（hnswlib `HierarchicalNSW`）
- 查询时：先粗排找到最近 nprobe 个簇，再对每个簇的 HNSW 并行搜索（各线程分配不同簇）
- 最后 merge 各簇的结果

**HNSW mains 文件：**
```
mains/hnsw/
├── main_baseline.cc          # hnswlib 原始 searchKnn 基线
├── main_multi_entry_omp.cc   # 多入口点 OMP
├── main_multi_entry_static.cc
├── main_multi_entry_dynamic.cc
├── main_multi_entry_pool.cc
├── main_edge_omp.cc          # 边划分 OMP
├── main_edge_static.cc
├── main_layer0_omp.cc        # Layer 0 点划分 OMP
├── main_layer0_static.cc
├── main_ivf_nested_omp.cc    # IVF+HNSW 嵌套 OMP
└── main_ivf_nested_static.cc
```
共计 11 个 HNSW mains。

- [ ] **Step 1: 创建 hnsw/hnsw_graph_utils.h** — 封装 hnswlib 内部 API 访问的工具函数（随机入口点、获取图层信息、提取 Layer 0 节点列表等）

- [ ] **Step 2: 创建 hnsw/hnsw_search_pthread.h** — 多入口点 static/dynamic/pool 实现

- [ ] **Step 3: 创建 hnsw/hnsw_search_omp.h** — 多入口点 OMP 实现

- [ ] **Step 4: 创建 hnsw/hnsw_edge_parallel.h** — 边划分并行（修改 searchKnn 内循环）

- [ ] **Step 5: 创建 hnsw/hnsw_layer0_parallel.h** — Layer 0 点划分并行

- [ ] **Step 6: 创建 hnsw/hnsw_ivf_nested.h** — IVF+HNSW 嵌套结构（含索引构建和搜索）

- [ ] **Step 7: 写入 11 个 HNSW mains 文件**

- [ ] **Step 8: Commit**

---

## 阶段 7：构建 & 运行脚本

### Task 7.1: Makefile

```makefile
CXX = g++
CXXFLAGS = -O2 -std=c++17 -I. -fopenmp -lpthread
LDFLAGS = -fopenmp -lpthread

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  UNAME_M := $(shell uname -m)
  ifeq ($(UNAME_M),aarch64)
    PLATFORM = arm
  else
    PLATFORM = x86
  endif
else
  PLATFORM = x86
endif

ifeq ($(PLATFORM),x86)
  CXXFLAGS += -mavx2 -mfma
endif

MAINS_DIR = mains
BUILD_DIR = build

TARGETS = \
  $(BUILD_DIR)/simd_flat $(BUILD_DIR)/simd_sq $(BUILD_DIR)/simd_pq $(BUILD_DIR)/simd_fastscan \
  $(BUILD_DIR)/omp_inter_flat $(BUILD_DIR)/omp_intra_flat \
  ...（省略完整列表，运行时动态扫描 mains/）

all: $(TARGETS)

$(BUILD_DIR)/%: $(MAINS_DIR)/*/%.cc
  $(CXX) $< -o $@ $(CXXFLAGS)

clean:
  rm -rf $(BUILD_DIR)/*
```

- [ ] **Step 1: 写入 Makefile**

### Task 7.2: run_all.sh（本机一键运行）

遍历核心矩阵组合，每个变体 × 每个线程数运行一次，收集输出到 results/。

```bash
#!/bin/bash
VARIANTS=(
  "simd/main_flat"
  "pthread/static/inter/main_flat"
  ... # 核心矩阵
)
THREADS=(1 2 4 8 16)

for v in "${VARIANTS[@]}"; do
  for t in "${THREADS[@]}"; do
    cp "mains/${v}.cc" main.cc
    g++ main.cc -o build/run -O2 -fopenmp -lpthread -std=c++17 -I.
    ./build/run $t > "results/$(basename $v)_t${t}.txt"
  done
done
```

- [ ] **Step 1: 写入 run_all.sh**

### Task 7.3: run_all_kunpeng.sh（鲲鹏一键运行）

```bash
#!/bin/bash
for v in ...; do
  for t in ...; do
    cp "mains/${v}.cc" main.cc
    bash test.sh 1 1
    cp test.o "results/$(basename $v)_t${t}.txt"
  done
done
```

- [ ] **Step 1: 写入 run_all_kunpeng.sh**

### Task 7.4: run_all.ps1（本机 PowerShell）

- [ ] **Step 1: 写入 run_all.ps1**

- [ ] **Step 2: Commit**

---

## 阶段 8：实验 & 报告

（不在编码阶段执行，待所有代码就绪后按矩阵运行实验收集数据）

- [ ] 核心矩阵实验：Flat, PQ, IVF, IVF-PQ，完整线程数 + 策略组合
- [ ] 补充矩阵实验：SQ, FastScan, HNSW，代表性参数
- [ ] 跨平台对比：本机 x86 结果 vs 鲲鹏 ARM 结果
- [ ] 撰写报告：整合数据、图表、分析
