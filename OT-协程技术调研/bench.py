"""
协程 vs 多线程基准测试 — Python 版
测试场景：I/O 密集型 (模拟网络请求) 和 CPU 密集型
"""
import asyncio
import threading
import time
import sys
import os
import tracemalloc

N_IO = 10_000       # I/O 任务数
N_CPU = 1_000       # CPU 任务数
FIB_N = 25          # 斐波那契数列第 n 项

def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

# ==================== I/O 密集 ====================

async def io_task_async():
    await asyncio.sleep(0.1)

def io_task_thread():
    time.sleep(0.1)

async def bench_async_io():
    t = time.perf_counter()
    await asyncio.gather(*(io_task_async() for _ in range(N_IO)))
    elapsed = time.perf_counter() - t
    return elapsed

def bench_thread_io():
    t = time.perf_counter()
    threads = [threading.Thread(target=io_task_thread) for _ in range(N_IO)]
    for th in threads:
        th.start()
    for th in threads:
        th.join()
    elapsed = time.perf_counter() - t
    return elapsed

# ==================== CPU 密集 ====================

async def cpu_task_async():
    return fib(FIB_N)

def cpu_task_thread():
    return fib(FIB_N)

async def bench_async_cpu():
    t = time.perf_counter()
    await asyncio.gather(*(cpu_task_async() for _ in range(N_CPU)))
    elapsed = time.perf_counter() - t
    return elapsed

def bench_thread_cpu():
    t = time.perf_counter()
    threads = [threading.Thread(target=cpu_task_thread) for _ in range(N_CPU)]
    for th in threads:
        th.start()
    for th in threads:
        th.join()
    elapsed = time.perf_counter() - t
    return elapsed

# ==================== 上下文切换微基准 ====================

async def yield_task():
    for _ in range(1000):
        await asyncio.sleep(0)  # yield control

async def bench_context_switch():
    t = time.perf_counter()
    await asyncio.gather(*(yield_task() for _ in range(1000)))
    elapsed = time.perf_counter() - t
    return elapsed

# ==================== 主函数 ====================

def get_memory_mb():
    """获取当前进程 RSS 内存 (MB)"""
    try:
        import psutil
        return psutil.Process(os.getpid()).memory_info().rss / 1024 / 1024
    except ImportError:
        # fallback: 使用 tracemalloc
        current, peak = tracemalloc.get_traced_memory()
        return peak / 1024 / 1024

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"

    print(f"{'='*60}")
    print(f"Python 协程 vs 多线程基准测试")
    print(f"N_IO={N_IO}, N_CPU={N_CPU}, FIB_N={FIB_N}")
    print(f"{'='*60}")

    results = {}

    if mode in ("all", "io_async", "async"):
        tracemalloc.start()
        mem_before = get_memory_mb()
        elapsed = asyncio.run(bench_async_io())
        mem_after = get_memory_mb()
        tracemalloc.stop()
        results["async_io"] = {"time": elapsed, "mem": mem_after}
        print(f"\n[asyncio I/O]     {elapsed:.3f}s  RSS: {mem_after:.1f}MB")

    if mode in ("all", "io_thread", "thread"):
        tracemalloc.start()
        mem_before = get_memory_mb()
        elapsed = bench_thread_io()
        mem_after = get_memory_mb()
        tracemalloc.stop()
        results["thread_io"] = {"time": elapsed, "mem": mem_after}
        print(f"[threading I/O]   {elapsed:.3f}s  RSS: {mem_after:.1f}MB")

    if mode in ("all", "cpu_async"):
        tracemalloc.start()
        elapsed = asyncio.run(bench_async_cpu())
        mem_after = get_memory_mb()
        tracemalloc.stop()
        results["async_cpu"] = {"time": elapsed, "mem": mem_after}
        print(f"[asyncio CPU]     {elapsed:.3f}s  RSS: {mem_after:.1f}MB")

    if mode in ("all", "cpu_thread"):
        tracemalloc.start()
        elapsed = bench_thread_cpu()
        mem_after = get_memory_mb()
        tracemalloc.stop()
        results["thread_cpu"] = {"time": elapsed, "mem": mem_after}
        print(f"[threading CPU]   {elapsed:.3f}s  RSS: {mem_after:.1f}MB")

    if mode in ("all", "ctx"):
        elapsed = asyncio.run(bench_context_switch())
        results["ctx_switch"] = {"time": elapsed}
        print(f"[ctx switch 1M]   {elapsed:.3f}s")

    print(f"\n{'='*60}")
    print("完成!")
    return results

if __name__ == "__main__":
    main()
