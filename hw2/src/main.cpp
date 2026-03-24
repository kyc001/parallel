#include "benchmark.hpp"
#include "environment.hpp"
#include "matrix_experiment.hpp"
#include "profile.hpp"
#include "sum_experiment.hpp"

#include <iostream>
#include <stdexcept>

int main() {
    const fs::path output_dir = "results";
    fs::create_directories(output_dir);

    const bool affinity_pinned = pin_to_core_zero();
    const int pinned_cpu = affinity_pinned ? detect_first_allowed_cpu() : -1;
    write_environment(output_dir, affinity_pinned, pinned_cpu);

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
