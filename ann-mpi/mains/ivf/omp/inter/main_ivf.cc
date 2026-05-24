#include "../../../../ivf/ivf_scan_omp.h"
#include "mains/ivf_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivf_main::RunInter(argc, argv, "ivf_omp_static_inter",
                                  ivf_search_inter_omp);
}
