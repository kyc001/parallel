# Coroutine Benchmark Results - 2026-05-25

Working directory: `D:\Study\26sp\parallel\OT-协程技术调研`

## Environment

- CPU: 13th Gen Intel(R) Core(TM) i9-13900H, 14 cores, 20 logical processors
- OS: Microsoft Windows 11 Home China, version 10.0.26200, 64-bit
- Memory visible to OS: 33271672 KB
- Python: 3.12.9
- Go: go1.25.6 windows/amd64
- Java: OpenJDK Temurin 21.0.5+11 LTS

## Python

Command:

```powershell
python bench.py all
```

Output:

```text
[asyncio I/O]     0.601s  peak WS: 15.0MB
[threading I/O]   5.524s  peak WS: 21.4MB
[asyncio CPU]     15.419s  peak WS: 1.0MB
[threading CPU]   20.805s  peak WS: 2.2MB
[ctx switch 1M]   7.824s
```

## Go

Command:

```powershell
go run bench.go
```

Output:

```text
[goroutine I/O x10000]    156.2726ms
[goroutine CPU x1000]    53.1434ms
[goroutine switch x100k] 122.9039ms
```

## Java

Command:

```powershell
& 'D:\jdk\bin\javac.exe' Bench.java
& 'D:\jdk\bin\java.exe' Bench
```

Output:

```text
[VirtualThread I/O x10000]   190 ms
[PlatformThread I/O x10000]  5447 ms
[VirtualThread CPU x1000]   62 ms
[PlatformThread CPU x1000]  32 ms
[VirtualThread switch x100k] 124 ms
```

## Notes

- I/O benchmark: 10000 logical tasks, each sleeps for 100 ms.
- CPU benchmark: 1000 logical tasks, each computes `fib(25)`.
- Python memory is peak process working set sampled during each benchmark segment.
- Cross-language memory is not compared because Go and Java peak RSS/working set were not sampled with the same method.
- Switch microbenchmarks are not isomorphic across languages; they are used only for order-of-magnitude discussion.
