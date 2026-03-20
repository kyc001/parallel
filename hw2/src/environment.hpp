#pragma once

#include <filesystem>

void write_environment(const std::filesystem::path& output_dir, bool affinity_pinned);
