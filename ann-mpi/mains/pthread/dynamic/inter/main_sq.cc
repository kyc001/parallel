#include "../../../../pthread/sq_scan_pthread.h"
#include "mains/sq_bench_common.h"

int main(int argc, char** argv) {
    return ann_sq_main::RunInter(argc, argv, "sq_pthread_dynamic_inter",
                                 sq_search_inter_dynamic);
}
