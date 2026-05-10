#include "ivf/ivf_scan_omp.h"
#include "mains/ivf_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivf_main::RunIntra(argc, argv, "ivf_omp_dynamic_intra",
                                  ivf_search_intra_omp);
}
