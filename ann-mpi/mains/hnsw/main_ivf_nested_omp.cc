#include "../../hnsw/hnsw_ivf_nested.h"
#include "mains/hnsw_bench_common.h"

int main(int argc, char** argv) {
    return ann_hnsw_main::RunNested(argc, argv, "hnsw_ivf_nested_omp",
                                    hnsw_ivf_nested_search_omp);
}
