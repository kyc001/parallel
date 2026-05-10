#include "pthread/pq_fastscan_pthread.h"
#include "mains/fastscan_bench_common.h"

int main(int argc, char** argv) {
    return ann_fastscan_main::RunIntra(argc, argv, "fastscan_pthread_static_intra",
                                       fastscan_search_intra_static);
}
