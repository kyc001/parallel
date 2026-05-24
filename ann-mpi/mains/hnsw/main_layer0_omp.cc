#include "../../hnsw/hnsw_layer0_parallel.h"
#include "mains/hnsw_bench_common.h"

int main(int argc, char** argv) {
    return ann_hnsw_main::RunSingleIndex(argc, argv, "hnsw_layer0_omp",
                                         hnsw_layer0_search_omp);
}
