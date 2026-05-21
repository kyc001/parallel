import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Java 虚拟线程 vs 平台线程基准测试
 * 测试场景：I/O 密集型和上下文切换
 */
public class Bench {
    static final int N_IO = 10_000;
    static final int N_CPU = 1_000;
    static final int FIB_N = 25;

    static int fib(int n) {
        if (n <= 1) return n;
        return fib(n - 1) + fib(n - 2);
    }

    // ==================== I/O 密集 ====================

    static long benchVirtualThreadIO() throws Exception {
        long start = System.nanoTime();
        try (var exec = Executors.newVirtualThreadPerTaskExecutor()) {
            var futures = new Future<?>[N_IO];
            for (int i = 0; i < N_IO; i++) {
                futures[i] = exec.submit(() -> {
                    Thread.sleep(100);
                    return null;
                });
            }
            for (var f : futures) f.get();
        }
        return (System.nanoTime() - start) / 1_000_000;
    }

    static long benchPlatformThreadIO() throws Exception {
        long start = System.nanoTime();
        try (var exec = Executors.newFixedThreadPool(200)) {
            var futures = new Future<?>[N_IO];
            for (int i = 0; i < N_IO; i++) {
                futures[i] = exec.submit(() -> {
                    Thread.sleep(100);
                    return null;
                });
            }
            for (var f : futures) f.get();
        }
        return (System.nanoTime() - start) / 1_000_000;
    }

    // ==================== CPU 密集 ====================

    static long benchVirtualThreadCPU() throws Exception {
        long start = System.nanoTime();
        try (var exec = Executors.newVirtualThreadPerTaskExecutor()) {
            var futures = new Future<?>[N_CPU];
            for (int i = 0; i < N_CPU; i++) {
                futures[i] = exec.submit(() -> fib(FIB_N));
            }
            for (var f : futures) f.get();
        }
        return (System.nanoTime() - start) / 1_000_000;
    }

    static long benchPlatformThreadCPU() throws Exception {
        long start = System.nanoTime();
        try (var exec = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors())) {
            var futures = new Future<?>[N_CPU];
            for (int i = 0; i < N_CPU; i++) {
                futures[i] = exec.submit(() -> fib(FIB_N));
            }
            for (var f : futures) f.get();
        }
        return (System.nanoTime() - start) / 1_000_000;
    }

    // ==================== 上下文切换 ====================

    static long benchVirtualThreadSwitch(int n) throws Exception {
        long start = System.nanoTime();
        try (var exec = Executors.newVirtualThreadPerTaskExecutor()) {
            var futures = new Future<?>[n];
            for (int i = 0; i < n; i++) {
                futures[i] = exec.submit(() -> {
                    Thread.sleep(0);
                    return null;
                });
            }
            for (var f : futures) f.get();
        }
        return (System.nanoTime() - start) / 1_000_000;
    }

    // ==================== 主函数 ====================

    public static void main(String[] args) throws Exception {
        System.out.println("============================================================");
        System.out.println("Java 虚拟线程 vs 平台线程基准测试");
        System.out.printf("N_IO=%d, N_CPU=%d, FIB_N=%d%n", N_IO, N_CPU, FIB_N);
        System.out.println("============================================================");

        // I/O 密集
        long ms = benchVirtualThreadIO();
        System.out.printf("%n[VirtualThread I/O x%d]   %d ms%n", N_IO, ms);

        ms = benchPlatformThreadIO();
        System.out.printf("[PlatformThread I/O x%d]  %d ms%n", N_IO, ms);

        // CPU 密集
        ms = benchVirtualThreadCPU();
        System.out.printf("[VirtualThread CPU x%d]   %d ms%n", N_CPU, ms);

        ms = benchPlatformThreadCPU();
        System.out.printf("[PlatformThread CPU x%d]  %d ms%n", N_CPU, ms);

        // 上下文切换
        ms = benchVirtualThreadSwitch(100_000);
        System.out.printf("%n[VirtualThread switch x100k] %d ms%n", ms);

        System.out.println("\n============================================================");
        System.out.println("完成!");
    }
}
