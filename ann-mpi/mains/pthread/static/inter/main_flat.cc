#include "../../../../pthread/flat_scan_pthread.h"
#include "mains/flat_bench_common.h"

int main(int argc, char** argv) {
    return ann_flat_main::RunInter(argc, argv, "flat_pthread_static_inter",
                                   flat_search_inter_static);
}
