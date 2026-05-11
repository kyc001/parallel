#!/usr/bin/env bash
# Kunpeng full experiment, part 1.
# Runs regular scan/index families that fit in the first server time window.
set -euo pipefail

RESULT_FILE=${ANN_RESULTS_FILE:-results/kunpeng_part1_results.txt}
CKPT_FILE=${ANN_CKPT_FILE:-results/kunpeng_part1_checkpoint.txt}

if [[ ! -f "$CKPT_FILE" ]]; then
  rm -f "$RESULT_FILE"
fi

ANN_PHASES="flat,sq,pq,fastscan,ivf" \
ANN_RESULTS_FILE="$RESULT_FILE" \
ANN_CKPT_FILE="$CKPT_FILE" \
  bash run_all_kunpeng.sh
