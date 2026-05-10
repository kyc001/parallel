#include "hnsw/hnsw_search_pthread.h"
#include "mains/hnsw_bench_common.h"

int main(int argc, char** argv) {
    return ann_hnsw_main::RunSingleIndex(argc, argv, "hnsw_multi_entry_pool",
                                         hnsw_search_multi_entry_pool);
}
