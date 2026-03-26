#include "environment.hpp"

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <winreg.h>
#endif
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>

namespace {

#ifdef _WIN32

std::string format_bytes(std::size_t bytes) {
    std::ostringstream oss;
    if (bytes % (1024 * 1024) == 0) {
        oss << (bytes / (1024 * 1024)) << "M";
    } else if (bytes % 1024 == 0) {
        oss << (bytes / 1024) << "K";
    } else {
        oss << bytes << "B";
    }
    return oss.str();
}

std::string read_registry_string(HKEY root, const char* subkey, const char* value_name) {
    char buffer[512] = {};
    DWORD buffer_size = sizeof(buffer);
    const LONG status = RegGetValueA(root, subkey, value_name, RRF_RT_REG_SZ, nullptr, buffer, &buffer_size);
    if (status != ERROR_SUCCESS || buffer_size <= 1) {
        return "Unknown";
    }
    return std::string(buffer);
}

bool read_registry_dword(HKEY root, const char* subkey, const char* value_name, DWORD& value) {
    DWORD size = sizeof(value);
    return RegGetValueA(root, subkey, value_name, RRF_RT_REG_DWORD, nullptr, &value, &size) == ERROR_SUCCESS;
}

struct WindowsCacheInfo {
    std::string l1d = "Unknown";
    std::string l2 = "Unknown";
    std::string l3 = "Unknown";
};

WindowsCacheInfo detect_windows_caches() {
    DWORD needed = 0;
    GetLogicalProcessorInformation(nullptr, &needed);
    if (needed == 0) {
        return {};
    }

    std::vector<unsigned char> buffer(needed);
    auto* info = reinterpret_cast<PSYSTEM_LOGICAL_PROCESSOR_INFORMATION>(buffer.data());
    if (!GetLogicalProcessorInformation(info, &needed)) {
        return {};
    }

    WindowsCacheInfo caches;
    const DWORD count = needed / sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
    for (DWORD i = 0; i < count; ++i) {
        if (info[i].Relationship != RelationCache) {
            continue;
        }

        const CACHE_DESCRIPTOR& cache = info[i].Cache;
        if (cache.Level == 1 && cache.Type == CacheData && caches.l1d == "Unknown") {
            caches.l1d = format_bytes(cache.Size);
        } else if (cache.Level == 2 && caches.l2 == "Unknown") {
            caches.l2 = format_bytes(cache.Size);
        } else if (cache.Level == 3 && caches.l3 == "Unknown") {
            caches.l3 = format_bytes(cache.Size);
        }
    }
    return caches;
}

std::string detect_os_pretty_name() {
    std::string product_name = read_registry_string(
        HKEY_LOCAL_MACHINE,
        "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
        "ProductName");
    const std::string display_version = read_registry_string(
        HKEY_LOCAL_MACHINE,
        "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
        "DisplayVersion");

    const std::string build_string = read_registry_string(
        HKEY_LOCAL_MACHINE,
        "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
        "CurrentBuildNumber");
    if (build_string != "Unknown" && product_name.rfind("Windows 10", 0) == 0) {
        try {
            const auto current_build = std::stoul(build_string);
            if (current_build >= 22000) {
                product_name.replace(0, std::string("Windows 10").size(), "Windows 11");
            }
        } catch (...) {
        }
    }

    if (display_version == "Unknown") {
        return product_name;
    }
    return product_name + " " + display_version;
}

std::string detect_kernel_string() {
    const std::string current_build = read_registry_string(
        HKEY_LOCAL_MACHINE,
        "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
        "CurrentBuildNumber");
    if (current_build == "Unknown") {
        return "Windows NT";
    }

    DWORD ubr = 0;
    if (!read_registry_dword(
            HKEY_LOCAL_MACHINE,
            "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
            "UBR",
            ubr)) {
        return "Windows NT build " + current_build;
    }
    return "Windows NT build " + current_build + "." + std::to_string(ubr);
}

std::string detect_cpu_model() {
    return read_registry_string(
        HKEY_LOCAL_MACHINE,
        "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0",
        "ProcessorNameString");
}

#else

std::string read_first_value_after_colon(const std::string& path, const std::string& prefix) {
    std::ifstream input(path);
    std::string line;
    while (std::getline(input, line)) {
        if (line.rfind(prefix, 0) == 0) {
            auto pos = line.find(':');
            if (pos == std::string::npos) {
                continue;
            }
            const std::size_t value_pos = line.find_first_not_of(" \t", pos + 1);
            return value_pos == std::string::npos ? std::string() : line.substr(value_pos);
        }
    }
    return "Unknown";
}

std::string read_trimmed_line(const std::string& path) {
    std::ifstream input(path);
    std::string line;
    std::getline(input, line);
    return line.empty() ? "Unknown" : line;
}

std::string detect_os_pretty_name() {
    std::ifstream input("/etc/os-release");
    std::string line;
    while (std::getline(input, line)) {
        constexpr char prefix[] = "PRETTY_NAME=";
        if (line.rfind(prefix, 0) == 0) {
            std::string value = line.substr(sizeof(prefix) - 1);
            if (!value.empty() && value.front() == '"' && value.back() == '"') {
                value = value.substr(1, value.size() - 2);
            }
            return value;
        }
    }
    return "Unknown";
}

std::string detect_kernel_string() {
    return read_trimmed_line("/proc/version");
}

std::string detect_cpu_model() {
    return read_first_value_after_colon("/proc/cpuinfo", "model name");
}

#endif

}  // namespace

void write_environment(const fs::path& output_dir, bool affinity_pinned, int pinned_cpu) {
    std::ofstream env(output_dir / "environment.txt");
#ifdef _WIN32
    const WindowsCacheInfo caches = detect_windows_caches();
#endif
    env << "OS: " << detect_os_pretty_name() << '\n';
    env << "Kernel: " << detect_kernel_string() << '\n';
    env << "Compiler: g++ " << __VERSION__ << '\n';
    env << "Benchmark affinity pinned: " << (affinity_pinned ? "yes" : "no") << '\n';
    env << "Pinned CPU: " << (pinned_cpu >= 0 ? std::to_string(pinned_cpu) : "Unknown") << '\n';
#ifdef _WIN32
    env << "Build flags: -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize -g -fno-omit-frame-pointer" << '\n';
#else
    env << "Build flags: -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize" << '\n';
#endif
    env << "CPU model: " << detect_cpu_model() << '\n';
#ifdef _WIN32
    env << "L1d cache: " << caches.l1d << '\n';
    env << "L2 cache: " << caches.l2 << '\n';
    env << "L3 cache: " << caches.l3 << '\n';
    env << "perf_event_paranoid: N/A (Windows VTune workflow)" << '\n';
#else
    env << "L1d cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index0/size") << '\n';
    env << "L2 cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index2/size") << '\n';
    env << "L3 cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index3/size") << '\n';
    env << "perf_event_paranoid: " << read_trimmed_line("/proc/sys/kernel/perf_event_paranoid") << '\n';
#endif
}
