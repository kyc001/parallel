#include "ivf/ivf_scan_pthread.h"
#include "mains/ivf_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivf_main::RunIntra(argc, argv, "ivf_pthread_static_intra",
                                  ivf_search_intra_static);
}
