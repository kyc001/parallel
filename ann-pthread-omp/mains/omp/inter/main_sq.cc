#include "omp/sq_scan_omp.h"
#include "mains/sq_bench_common.h"

int main(int argc, char** argv) {
    return ann_sq_main::RunInter(argc, argv, "sq_omp_static_inter",
                                 sq_search_inter_omp);
}
