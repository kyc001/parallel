"""
协程 vs 多线程基准测试 — Python 版
测试场景：I/O 密集型 (模拟网络请求) 和 CPU 密集型
"""
import asyncio
import threading
import time
import sys
import os
import platform
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

# ==================== 内存采样 ====================

def get_memory_mb():
    """获取当前进程工作集/RSS 内存 (MB)"""
    try:
        import psutil
        return psutil.Process(os.getpid()).memory_info().rss / 1024 / 1024
    except ImportError:
        pass

    if platform.system() == "Windows":
        try:
            import ctypes
            from ctypes import wintypes

            class PROCESS_MEMORY_COUNTERS(ctypes.Structure):
                _fields_ = [
                    ("cb", wintypes.DWORD),
                    ("PageFaultCount", wintypes.DWORD),
                    ("PeakWorkingSetSize", ctypes.c_size_t),
                    ("WorkingSetSize", ctypes.c_size_t),
                    ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
                    ("QuotaPagedPoolUsage", ctypes.c_size_t),
                    ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
                    ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
                    ("PagefileUsage", ctypes.c_size_t),
                    ("PeakPagefileUsage", ctypes.c_size_t),
                ]

            counters = PROCESS_MEMORY_COUNTERS()
            counters.cb = ctypes.sizeof(PROCESS_MEMORY_COUNTERS)
            handle = ctypes.windll.kernel32.GetCurrentProcess()
            ok = ctypes.windll.psapi.GetProcessMemoryInfo(
                handle, ctypes.byref(counters), counters.cb
            )
            if ok:
                return counters.WorkingSetSize / 1024 / 1024
        except Exception:
            pass

    current, peak = tracemalloc.get_traced_memory()
    return peak / 1024 / 1024

class MemorySampler:
    """后台采样当前进程工作集，记录 benchmark 期间的峰值。"""

    def __init__(self, interval=0.005):
        self.interval = interval
        self.peak_mb = 0.0
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, daemon=True)

    def _sample(self):
        self.peak_mb = max(self.peak_mb, get_memory_mb())

    def _run(self):
        while not self._stop.is_set():
            self._sample()
            time.sleep(self.interval)

    def __enter__(self):
        self._sample()
        self._thread.start()
        return self

    def __exit__(self, exc_type, exc, tb):
        self._stop.set()
        self._thread.join()
        self._sample()

# ==================== 主函数 ====================

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"

    print(f"{'='*60}")
    print(f"Python 协程 vs 多线程基准测试")
    print(f"N_IO={N_IO}, N_CPU={N_CPU}, FIB_N={FIB_N}")
    print(f"{'='*60}")

    results = {}

    if mode in ("all", "io_async", "async"):
        tracemalloc.start()
        with MemorySampler() as sampler:
            elapsed = asyncio.run(bench_async_io())
        peak_mb = sampler.peak_mb
        tracemalloc.stop()
        results["async_io"] = {"time": elapsed, "mem": peak_mb}
        print(f"\n[asyncio I/O]     {elapsed:.3f}s  peak WS: {peak_mb:.1f}MB")

    if mode in ("all", "io_thread", "thread"):
        tracemalloc.start()
        with MemorySampler() as sampler:
            elapsed = bench_thread_io()
        peak_mb = sampler.peak_mb
        tracemalloc.stop()
        results["thread_io"] = {"time": elapsed, "mem": peak_mb}
        print(f"[threading I/O]   {elapsed:.3f}s  peak WS: {peak_mb:.1f}MB")

    if mode in ("all", "cpu_async"):
        tracemalloc.start()
        with MemorySampler() as sampler:
            elapsed = asyncio.run(bench_async_cpu())
        peak_mb = sampler.peak_mb
        tracemalloc.stop()
        results["async_cpu"] = {"time": elapsed, "mem": peak_mb}
        print(f"[asyncio CPU]     {elapsed:.3f}s  peak WS: {peak_mb:.1f}MB")

    if mode in ("all", "cpu_thread"):
        tracemalloc.start()
        with MemorySampler() as sampler:
            elapsed = bench_thread_cpu()
        peak_mb = sampler.peak_mb
        tracemalloc.stop()
        results["thread_cpu"] = {"time": elapsed, "mem": peak_mb}
        print(f"[threading CPU]   {elapsed:.3f}s  peak WS: {peak_mb:.1f}MB")

    if mode in ("all", "ctx"):
        elapsed = asyncio.run(bench_context_switch())
        results["ctx_switch"] = {"time": elapsed}
        print(f"[ctx switch 1M]   {elapsed:.3f}s")

    print(f"\n{'='*60}")
    print("完成!")
    return results

if __name__ == "__main__":
    main()
