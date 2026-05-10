#include "pthread/pq_scan_pthread.h"
#include "mains/pq_bench_common.h"

int main(int argc, char** argv) {
    return ann_pq_main::RunIntra(argc, argv, "pq_pthread_dynamic_intra",
                                 pq_search_intra_dynamic);
}
