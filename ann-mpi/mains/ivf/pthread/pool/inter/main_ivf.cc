#include "../../../../../ivf/ivf_scan_pthread.h"
#include "mains/ivf_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivf_main::RunInter(argc, argv, "ivf_pthread_pool_inter",
                                  ivf_search_inter_pool);
}
