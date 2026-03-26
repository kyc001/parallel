#include "benchmark.hpp"

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <cerrno>
#include <cstring>
#include <linux/perf_event.h>
#include <sched.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>
#endif

namespace {

#ifdef _WIN32

int g_pinned_cpu = -1;

DWORD_PTR current_process_affinity_mask() {
    DWORD_PTR process_mask = 0;
    DWORD_PTR system_mask = 0;
    if (!GetProcessAffinityMask(GetCurrentProcess(), &process_mask, &system_mask)) {
        return 0;
    }
    return process_mask;
}

int first_set_cpu(DWORD_PTR mask) {
    for (int cpu = 0; cpu < static_cast<int>(sizeof(DWORD_PTR) * 8); ++cpu) {
        const DWORD_PTR cpu_mask = static_cast<DWORD_PTR>(1) << cpu;
        if ((mask & cpu_mask) != 0) {
            return cpu;
        }
    }
    return -1;
}

#else

int open_perf_event(std::uint32_t type, std::uint64_t config) {
    perf_event_attr attr{};
    attr.type = type;
    attr.size = sizeof(attr);
    attr.config = config;
    attr.disabled = 1;
    attr.exclude_kernel = 1;
    attr.exclude_hv = 1;
    return static_cast<int>(syscall(__NR_perf_event_open, &attr, 0, -1, -1, 0));
}

#endif

}  // namespace

int detect_first_allowed_cpu() {
#ifdef _WIN32
    if (g_pinned_cpu >= 0) {
        return g_pinned_cpu;
    }
    return first_set_cpu(current_process_affinity_mask());
#else
    cpu_set_t current_mask;
    CPU_ZERO(&current_mask);
    if (sched_getaffinity(0, sizeof(current_mask), &current_mask) != 0) {
        return -1;
    }
    for (int cpu = 0; cpu < CPU_SETSIZE; ++cpu) {
        if (CPU_ISSET(cpu, &current_mask)) {
            return cpu;
        }
    }
    return -1;
#endif
}

bool pin_to_core_zero() {
#ifdef _WIN32
    const DWORD_PTR process_mask = current_process_affinity_mask();
    if (process_mask == 0) {
        return false;
    }

    DWORD_PTR target_mask = process_mask & static_cast<DWORD_PTR>(1);
    int target_cpu = 0;
    if (target_mask == 0) {
        target_cpu = first_set_cpu(process_mask);
        if (target_cpu < 0) {
            return false;
        }
        target_mask = static_cast<DWORD_PTR>(1) << target_cpu;
    }

    const DWORD_PTR previous_mask = SetThreadAffinityMask(GetCurrentThread(), target_mask);
    if (previous_mask == 0) {
        return false;
    }
    g_pinned_cpu = target_cpu;
    return true;
#else
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(0, &set);
    if (sched_setaffinity(0, sizeof(set), &set) == 0) {
        return true;
    }

    const int fallback_cpu = detect_first_allowed_cpu();
    if (fallback_cpu < 0) {
        return false;
    }

    CPU_ZERO(&set);
    CPU_SET(fallback_cpu, &set);
    return sched_setaffinity(0, sizeof(set), &set) == 0;
#endif
}

PerfReadings profile_once(const std::function<double()>& fn, std::size_t repeat) {
#ifdef _WIN32
    double checksum = 0.0;
    for (std::size_t i = 0; i < repeat; ++i) {
        checksum += fn();
    }
    do_not_optimize(checksum);
    clobber_memory();

    PerfReadings readings;
    readings.error = "external VTune collection required on Windows";
    return readings;
#else
    const int fd_cycles = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CPU_CYCLES);
    const int perf_errno = errno;
    const int fd_instructions = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_INSTRUCTIONS);
    const int fd_cache_ref = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CACHE_REFERENCES);
    const int fd_cache_miss = open_perf_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CACHE_MISSES);

    auto close_all = [&]() {
        for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
            if (fd >= 0) {
                close(fd);
            }
        }
    };

    if (fd_cycles < 0 || fd_instructions < 0 || fd_cache_ref < 0 || fd_cache_miss < 0) {
        close_all();
        PerfReadings readings;
        readings.error = "perf_event_open failed: " + std::string(std::strerror(perf_errno));
        return readings;
    }

    for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
        ioctl(fd, PERF_EVENT_IOC_RESET, 0);
        ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
    }

    double checksum = 0.0;
    for (std::size_t i = 0; i < repeat; ++i) {
        checksum += fn();
    }
    do_not_optimize(checksum);
    clobber_memory();

    PerfReadings readings;
    readings.available = true;
    for (const int fd : {fd_cycles, fd_instructions, fd_cache_ref, fd_cache_miss}) {
        ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    }

    if (read(fd_cycles, &readings.cycles, sizeof(readings.cycles)) != static_cast<ssize_t>(sizeof(readings.cycles)) ||
        read(fd_instructions, &readings.instructions, sizeof(readings.instructions)) != static_cast<ssize_t>(sizeof(readings.instructions)) ||
        read(fd_cache_ref, &readings.cache_references, sizeof(readings.cache_references)) != static_cast<ssize_t>(sizeof(readings.cache_references)) ||
        read(fd_cache_miss, &readings.cache_misses, sizeof(readings.cache_misses)) != static_cast<ssize_t>(sizeof(readings.cache_misses))) {
        readings.available = false;
        readings.error = "failed to read hardware counters";
    }

    close_all();
    return readings;
#endif
}
