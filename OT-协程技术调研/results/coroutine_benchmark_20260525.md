# Coroutine Benchmark Results - 2026-05-27 (Rerun with 5 repetitions)

Working directory: `D:\Study\26sp\parallel\OT-协程技术调研`

## Environment

- CPU: 13th Gen Intel(R) Core(TM) i9-13900H, 14 cores, 20 logical processors
- OS: Microsoft Windows 11 Home China, version 10.0.26200, 64-bit
- Memory visible to OS: 33271672 KB
- Python: 3.12.9
- Go: go1.25.6 windows/amd64
- Java: OpenJDK Temurin 21.0.5+11 LTS

## Python (N_REPEAT=5)

Command:

```powershell
python bench.py all
```

Output:

```text
[asyncio I/O]     0.446±0.012s  peak WS: 14.1±0.5MB
[threading I/O]   3.130±0.426s  peak WS: 21.1±0.4MB
[asyncio CPU]     7.647±0.293s  peak WS: 0.9±0.0MB
[threading CPU]   9.521±1.591s  peak WS: 2.2±0.0MB
[ctx switch 1M]   2.494±0.144s
```

## Go (N_REPEAT=5)

Command:

```powershell
go run bench.go
```

Output:

```text
[goroutine I/O x10000]    116±20 ms
[goroutine memory]     106.5 MB (Sys after I/O test)
[goroutine CPU x1000]    39±10 ms
[goroutine switch x100k] 122±15 ms
```

## Java (N_REPEAT=5)

Command:

```powershell
javac Bench.java
java -cp . Bench
```

Output:

```text
[VirtualThread I/O x10000]   235±173 ms
[PlatformThread I/O x10000]  5458±13 ms
[VirtualThread CPU x1000]   40±13 ms
[PlatformThread CPU x1000]  34±2 ms
[VirtualThread switch x100k] 75±32 ms
[Java memory]              246 MB (heap+nonHeap after tests)
```

## Notes

- I/O benchmark: 10000 logical tasks, each sleeps for 100 ms.
- CPU benchmark: 1000 logical tasks, each computes `fib(25)`.
- Each test repeated 5 times; reported as mean ± standard deviation.
- Python memory is peak process working set sampled during each benchmark segment.
- Go memory is `runtime.MemStats.Sys` sampled after I/O test.
- Java memory is `HeapMemoryUsage + NonHeapMemoryUsage` sampled after all tests.
- Cross-language memory comparison is approximate due to different measurement methods.
- Switch microbenchmarks are not isomorphic across languages; they are used only for order-of-magnitude discussion.
- Java VirtualThread I/O variance (±173ms) is likely due to JIT warmup on first runs.
