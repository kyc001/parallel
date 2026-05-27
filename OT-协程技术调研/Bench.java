import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.util.concurrent.*;

/**
 * Java 虚拟线程 vs 平台线程基准测试
 * 测试场景：I/O 密集型、CPU 密集型和上下文切换
 * 每个测试跑 N_REPEAT 次，报告 mean ± std
 */
public class Bench {
    static final int N_IO = 10_000;
    static final int N_CPU = 1_000;
    static final int FIB_N = 25;
    static final int N_REPEAT = 5;

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

    // ==================== 统计工具 ====================

    static double mean(long[] data) {
        long sum = 0;
        for (long v : data) sum += v;
        return (double) sum / data.length;
    }

    static double std(long[] data) {
        double m = mean(data);
        double sumSq = 0;
        for (long v : data) sumSq += (v - m) * (v - m);
        return Math.sqrt(sumSq / data.length);
    }

    static long getMemoryMB() {
        MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
        MemoryUsage heap = memBean.getHeapMemoryUsage();
        MemoryUsage nonHeap = memBean.getNonHeapMemoryUsage();
        return (heap.getUsed() + nonHeap.getUsed()) / (1024 * 1024);
    }

    // ==================== 主函数 ====================

    public static void main(String[] args) throws Exception {
        System.out.println("============================================================");
        System.out.println("Java 虚拟线程 vs 平台线程基准测试");
        System.out.printf("N_IO=%d, N_CPU=%d, FIB_N=%d, N_REPEAT=%d%n", N_IO, N_CPU, FIB_N, N_REPEAT);
        System.out.println("============================================================");

        // Virtual Thread I/O
        long[] vtIoTimes = new long[N_REPEAT];
        for (int i = 0; i < N_REPEAT; i++) vtIoTimes[i] = benchVirtualThreadIO();
        System.out.printf("%n[VirtualThread I/O x%d]   %.0f±%.0f ms%n", N_IO, mean(vtIoTimes), std(vtIoTimes));

        // Platform Thread I/O
        long[] ptIoTimes = new long[N_REPEAT];
        for (int i = 0; i < N_REPEAT; i++) ptIoTimes[i] = benchPlatformThreadIO();
        System.out.printf("[PlatformThread I/O x%d]  %.0f±%.0f ms%n", N_IO, mean(ptIoTimes), std(ptIoTimes));

        // Virtual Thread CPU
        long[] vtCpuTimes = new long[N_REPEAT];
        for (int i = 0; i < N_REPEAT; i++) vtCpuTimes[i] = benchVirtualThreadCPU();
        System.out.printf("[VirtualThread CPU x%d]   %.0f±%.0f ms%n", N_CPU, mean(vtCpuTimes), std(vtCpuTimes));

        // Platform Thread CPU
        long[] ptCpuTimes = new long[N_REPEAT];
        for (int i = 0; i < N_REPEAT; i++) ptCpuTimes[i] = benchPlatformThreadCPU();
        System.out.printf("[PlatformThread CPU x%d]  %.0f±%.0f ms%n", N_CPU, mean(ptCpuTimes), std(ptCpuTimes));

        // Virtual Thread Switch
        long[] vtSwTimes = new long[N_REPEAT];
        for (int i = 0; i < N_REPEAT; i++) vtSwTimes[i] = benchVirtualThreadSwitch(100_000);
        System.out.printf("%n[VirtualThread switch x100k] %.0f±%.0f ms%n", mean(vtSwTimes), std(vtSwTimes));

        // Memory
        long memMB = getMemoryMB();
        System.out.printf("[Java memory]              %d MB (heap+nonHeap after tests)%n", memMB);

        System.out.println("\n============================================================");
        System.out.println("完成!");
    }
}
