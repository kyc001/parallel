#include "../../../../../ivf/ivf_pq_pthread.h"
#include "mains/ivfpq_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivfpq_main::RunInter(argc, argv, "ivfpq_pthread_dynamic_inter",
                                    ivf_pq_search_inter_dynamic);
}
