#include "../../../../pthread/sq_scan_pthread.h"
#include "mains/sq_bench_common.h"

int main(int argc, char** argv) {
    return ann_sq_main::RunIntra(argc, argv, "sq_pthread_pool_intra",
                                 sq_search_intra_pool);
}
