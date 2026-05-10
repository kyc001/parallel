#include "hnsw/hnsw_edge_parallel.h"
#include "mains/hnsw_bench_common.h"

int main(int argc, char** argv) {
    return ann_hnsw_main::RunSingleIndex(argc, argv, "hnsw_edge_omp",
                                         hnsw_edge_search_omp);
}
