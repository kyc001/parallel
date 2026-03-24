#pragma once

#include "fs_compat.hpp"

void write_environment(const fs::path& output_dir, bool affinity_pinned, int pinned_cpu);
