#include "omp/pq_scan_omp.h"
#include "mains/pq_bench_common.h"

int main(int argc, char** argv) {
    return ann_pq_main::RunInter(argc, argv, "pq_omp_static_inter",
                                 pq_search_inter_omp);
}
