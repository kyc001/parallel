#include "../../../../pthread/flat_scan_pthread.h"
#include "mains/flat_bench_common.h"

int main(int argc, char** argv) {
    return ann_flat_main::RunIntra(argc, argv, "flat_pthread_dynamic_intra",
                                   flat_search_intra_dynamic);
}
