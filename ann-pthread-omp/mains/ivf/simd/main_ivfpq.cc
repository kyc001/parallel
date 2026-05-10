#include "ivf/ivf_pq_simd.h"
#include "mains/ivfpq_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivfpq_main::RunSerial(argc, argv, "ivfpq_simd_serial",
                                     ivf_pq_search);
}
