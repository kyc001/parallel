#include "../../../omp/flat_scan_omp.h"
#include "mains/flat_bench_common.h"

int main(int argc, char** argv) {
    return ann_flat_main::RunIntra(argc, argv, "flat_omp_static_intra",
                                   flat_search_intra_omp);
}
