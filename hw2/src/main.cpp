#include "benchmark.hpp"
#include "environment.hpp"
#include "matrix_experiment.hpp"
#include "profile.hpp"
#include "sum_experiment.hpp"

#include <filesystem>
#include <iostream>
#include <stdexcept>

namespace fs = std::filesystem;

int main() {
    const fs::path output_dir = "results";
    fs::create_directories(output_dir);

    const bool affinity_pinned = pin_to_core_zero();
    write_environment(output_dir, affinity_pinned);

    try {
        run_matrix_experiment(output_dir);
        run_sum_experiment(output_dir);
        run_profile_experiment(output_dir);
    } catch (const std::exception& ex) {
        std::cerr << "benchmark failed: " << ex.what() << '\n';
        return 1;
    }

    std::cout << "results written to " << output_dir << '\n';
    return 0;
}
