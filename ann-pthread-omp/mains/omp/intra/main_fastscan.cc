#include "omp/pq_fastscan_omp.h"
#include "mains/fastscan_bench_common.h"

int main(int argc, char** argv) {
    return ann_fastscan_main::RunIntra(argc, argv, "fastscan_omp_static_intra",
                                       fastscan_search_intra_omp);
}
