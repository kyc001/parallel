// bench.go — Go goroutine vs OS 线程基准测试
// 测试场景：I/O 密集型、CPU 密集型和上下文切换
// 每个测试跑 N_REPEAT 次，报告 mean ± std
package main

import (
	"fmt"
	"math"
	"runtime"
	"sync"
	"time"
)

const (
	N_IO      = 10_000 // I/O 任务数
	N_CPU     = 1_000  // CPU 任务数
	FIB_N     = 25
	N_REPEAT  = 5 // 重复测量次数
)

func fib(n int) int {
	if n <= 1 {
		return n
	}
	return fib(n-1) + fib(n-2)
}

// getMemMB 返回当前进程的 Sys 内存 (MB)
func getMemMB() float64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return float64(m.Sys) / 1024 / 1024
}

// benchGoroutineIO 测试 goroutine I/O 密集场景
func benchGoroutineIO() time.Duration {
	var wg sync.WaitGroup
	start := time.Now()
	for i := 0; i < N_IO; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			time.Sleep(100 * time.Millisecond)
		}()
	}
	wg.Wait()
	return time.Since(start)
}

// benchGoroutineCPU 测试 goroutine CPU 密集场景
func benchGoroutineCPU() time.Duration {
	var wg sync.WaitGroup
	start := time.Now()
	for i := 0; i < N_CPU; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			_ = fib(FIB_N)
		}()
	}
	wg.Wait()
	return time.Since(start)
}

// benchGoroutineSwitch 测试大量 goroutine 创建和切换
func benchGoroutineSwitch(n int) time.Duration {
	var wg sync.WaitGroup
	start := time.Now()
	ch := make(chan struct{}, 1)
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			ch <- struct{}{}
			<-ch
		}()
	}
	wg.Wait()
	return time.Since(start)
}

// meanStd 计算均值和标准差
func meanStd(data []float64) (float64, float64) {
	n := float64(len(data))
	var sum, sumSq float64
	for _, v := range data {
		sum += v
		sumSq += v * v
	}
	mean := sum / n
	variance := sumSq/n - mean*mean
	if variance < 0 {
		variance = 0
	}
	return mean, math.Sqrt(variance)
}

func main() {
	fmt.Println("============================================================")
	fmt.Println("Go goroutine 基准测试")
	fmt.Printf("N_IO=%d, N_CPU=%d, FIB_N=%d, N_REPEAT=%d\n", N_IO, N_CPU, FIB_N, N_REPEAT)
	fmt.Println("============================================================")

	// I/O 密集
	ioTimes := make([]float64, N_REPEAT)
	for i := 0; i < N_REPEAT; i++ {
		ioTimes[i] = float64(benchGoroutineIO().Milliseconds())
	}
	ioMean, ioStd := meanStd(ioTimes)
	fmt.Printf("\n[goroutine I/O x%d]    %.0f±%.0f ms\n", N_IO, ioMean, ioStd)

	// 内存采样（在 I/O 测试后读取）
	memMB := getMemMB()
	fmt.Printf("[goroutine memory]     %.1f MB (Sys after I/O test)\n", memMB)

	// CPU 密集
	cpuTimes := make([]float64, N_REPEAT)
	for i := 0; i < N_REPEAT; i++ {
		cpuTimes[i] = float64(benchGoroutineCPU().Milliseconds())
	}
	cpuMean, cpuStd := meanStd(cpuTimes)
	fmt.Printf("[goroutine CPU x%d]    %.0f±%.0f ms\n", N_CPU, cpuMean, cpuStd)

	// 上下文切换
	switchTimes := make([]float64, N_REPEAT)
	for i := 0; i < N_REPEAT; i++ {
		switchTimes[i] = float64(benchGoroutineSwitch(100_000).Milliseconds())
	}
	switchMean, switchStd := meanStd(switchTimes)
	fmt.Printf("[goroutine switch x100k] %.0f±%.0f ms\n", switchMean, switchStd)

	fmt.Println("\n============================================================")
	fmt.Println("完成!")
}
