#include "pthread/pq_fastscan_pthread.h"
#include "mains/fastscan_bench_common.h"

int main(int argc, char** argv) {
    return ann_fastscan_main::RunInter(argc, argv, "fastscan_pthread_static_inter",
                                       fastscan_search_inter_static);
}
