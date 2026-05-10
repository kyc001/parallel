#include "ivf/ivf_scan_simd.h"
#include "mains/ivf_bench_common.h"

int main(int argc, char** argv) {
    return ann_ivf_main::RunSerial(argc, argv, "ivf_simd_serial", ivf_search);
}
