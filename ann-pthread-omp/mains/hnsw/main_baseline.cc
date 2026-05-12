#include "../../hnsw/hnsw_graph_utils.h"
#include "mains/hnsw_bench_common.h"

int main(int argc, char** argv) {
    return ann_hnsw_main::RunSingleIndex(argc, argv, "hnsw_baseline",
                                         ann_hnsw::StandardSearch);
}
