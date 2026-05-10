#include "omp/sq_scan_omp.h"
#include "mains/sq_bench_common.h"

int main(int argc, char** argv) {
    return ann_sq_main::RunIntra(argc, argv, "sq_omp_static_intra",
                                 sq_search_intra_omp);
}
