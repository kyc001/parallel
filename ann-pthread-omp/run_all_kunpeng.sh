#!/usr/bin/env bash
# Kunpeng one-key runner.
# The wrapper builds the selected unified benchmark locally, submits it with
# qsub, and waits for PBS output. It intentionally bypasses test.sh because
# that legacy wrapper recompiles with C++11/no -I. and has a short timeout.
set -euo pipefail

PHASES="${ANN_PHASES:-}"
RESULT_FILE="${ANN_RESULTS_FILE:-results/kunpeng_results.txt}"
RESUME_FILE="${ANN_CKPT_FILE:-results/kunpeng_checkpoint.txt}"
DISABLE_CHECKPOINT="${ANN_DISABLE_CHECKPOINT:-0}"
DATA_DIR="${ANN_DATA_DIR:-/anndata}"
NODES="${ANN_NODES:-1}"
QSUB_TIMEOUT="${ANN_QSUB_TIMEOUT:-7200}"
QSUB_INTERVAL="${ANN_QSUB_INTERVAL:-5}"

case "$DATA_DIR" in
  */) DATA_DIR_SLASH="$DATA_DIR" ;;
  *) DATA_DIR_SLASH="$DATA_DIR/" ;;
esac

mkdir -p build results
if [[ ! -e files && ! -L files ]]; then
  ln -s "$DATA_DIR" files
fi

echo "==> data dir: $DATA_DIR_SLASH"
if [[ -L files ]]; then
  echo "==> files -> $(readlink -f files 2>/dev/null || readlink files)"
else
  echo "==> files exists locally; using compiled data dir for qsub"
fi
echo "==> result file: $RESULT_FILE"
if [[ -n "$PHASES" ]]; then
  echo "==> selected phases: $PHASES"
else
  echo "==> selected phases: all"
fi

echo "==> copy unified benchmark entry to main.cc"
cp mains/unified_bench.cc main.cc

CONFIG_HEADER="build/ann_run_config.h"
cat > "$CONFIG_HEADER" <<EOF
#define ANN_DEFAULT_PHASES "$PHASES"
#define ANN_DEFAULT_RESULTS_FILE "$RESULT_FILE"
#define ANN_DEFAULT_CKPT_FILE "$RESUME_FILE"
#define ANN_DEFAULT_DISABLE_CHECKPOINT $DISABLE_CHECKPOINT
#define ANN_DEFAULT_DATA_PATH "$DATA_DIR_SLASH"
EOF

echo "==> precompile main (-std=c++17 -I.)"
g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I. -include "$CONFIG_HEADER"

if [[ -f "$RESUME_FILE" ]]; then
  echo "==> checkpoint found: $(cat "$RESUME_FILE"); continuing from next phase"
else
  echo "==> fresh run"
fi

rm -f test.o test.e
echo "==> submit qsub job (nodes=$NODES, timeout=${QSUB_TIMEOUT}s)"
jobid="$(qsub -l nodes="$NODES" qsub.sh)"
echo "Submitted job with ID: $jobid"

elapsed=0
while [[ ! -f test.o && "$elapsed" -lt "$QSUB_TIMEOUT" ]]; do
  sleep "$QSUB_INTERVAL"
  elapsed=$((elapsed + QSUB_INTERVAL))
done

if [[ ! -f test.o ]]; then
  echo "Timeout reached before test.o was generated for job $jobid." >&2
  echo "The PBS job may still be running; check qstat/test.e/test.o before rerunning." >&2
  exit 1
fi

if [[ -f test.e ]]; then
  cat test.e
fi
cat test.o

echo "==> done. Re-run this script to resume from the checkpoint if interrupted."
