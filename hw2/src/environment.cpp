#include "environment.hpp"

#include <fstream>
#include <string>

namespace {

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

}  // namespace

void write_environment(const std::filesystem::path& output_dir, bool affinity_pinned) {
    std::ofstream env(output_dir / "environment.txt");
    env << "OS: " << detect_os_pretty_name() << '\n';
    env << "Kernel: " << detect_kernel_string() << '\n';
    env << "Compiler: g++ " << __VERSION__ << '\n';
    env << "Benchmark affinity pinned to CPU0: " << (affinity_pinned ? "yes" : "no") << '\n';
    env << "Build flags: -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize" << '\n';
    env << "CPU model: " << detect_cpu_model() << '\n';
    env << "L1d cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index0/size") << '\n';
    env << "L2 cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index2/size") << '\n';
    env << "L3 cache: " << read_trimmed_line("/sys/devices/system/cpu/cpu0/cache/index3/size") << '\n';
}
