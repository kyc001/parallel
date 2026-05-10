#include "omp/pq_scan_omp.h"
#include "mains/pq_bench_common.h"

int main(int argc, char** argv) {
    return ann_pq_main::RunIntra(argc, argv, "pq_omp_static_intra",
                                 pq_search_intra_omp);
}
