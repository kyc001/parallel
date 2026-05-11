#!/usr/bin/env bash
# Kunpeng full experiment, part 2.
# Runs the longer IVF-PQ and HNSW families in a separate server time window.
set -euo pipefail

RESULT_FILE=${ANN_RESULTS_FILE:-results/kunpeng_part2_results.txt}
CKPT_FILE=${ANN_CKPT_FILE:-results/kunpeng_part2_checkpoint.txt}

if [[ ! -f "$CKPT_FILE" ]]; then
  rm -f "$RESULT_FILE"
fi

ANN_PHASES="ivfpq_global,ivfpq_local,hnsw,hnsw_nested" \
ANN_RESULTS_FILE="$RESULT_FILE" \
ANN_CKPT_FILE="$CKPT_FILE" \
  bash run_all_kunpeng.sh
