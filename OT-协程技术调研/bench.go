// bench.go — Go goroutine vs OS 线程基准测试
// 测试场景：I/O 密集型和上下文切换
package main

import (
	"fmt"
	"sync"
	"time"
)

const (
	N_IO  = 10_000   // I/O 任务数
	N_CPU = 1_000    // CPU 任务数
	FIB_N = 25
)

func fib(n int) int {
	if n <= 1 {
		return n
	}
	return fib(n-1) + fib(n-2)
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

func main() {
	fmt.Println("============================================================")
	fmt.Println("Go goroutine 基准测试")
	fmt.Printf("N_IO=%d, N_CPU=%d, FIB_N=%d\n", N_IO, N_CPU, FIB_N)
	fmt.Println("============================================================")

	// I/O 密集
	d := benchGoroutineIO()
	fmt.Printf("\n[goroutine I/O x%d]    %v\n", N_IO, d)

	// CPU 密集
	d = benchGoroutineCPU()
	fmt.Printf("[goroutine CPU x%d]    %v\n", N_CPU, d)

	// 上下文切换
	d = benchGoroutineSwitch(100_000)
	fmt.Printf("[goroutine switch x100k] %v\n", d)

	fmt.Println("\n============================================================")
	fmt.Println("完成!")
}
