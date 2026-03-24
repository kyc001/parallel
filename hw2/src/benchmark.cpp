#include "benchmark.hpp"

#include <cerrno>
#include <cstring>
#include <linux/perf_event.h>
#include <sched.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>

namespace {

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

}  // namespace

int detect_first_allowed_cpu() {
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
}

bool pin_to_core_zero() {
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
}

PerfReadings profile_once(const std::function<double()>& fn, std::size_t repeat) {
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
}
