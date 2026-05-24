#include "../../../../../ivf/ivf_pq_pthread.h"
#include "mains/ivfpq_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivfpq_main::RunIntra(argc, argv, "ivfpq_pthread_pool_intra",
                                    ivf_pq_search_intra_pool);
}
