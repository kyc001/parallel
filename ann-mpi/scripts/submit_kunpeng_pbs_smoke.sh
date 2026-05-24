#!/bin/sh
set -eu

PROJECT=${PROJECT:-ann-mpi}
NP=${NP:-2}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
QUERY_N=${QUERY_N:-200}
NLIST=${NLIST:-16}
NPROBE=${NPROBE:-4}
RERANK_P=${RERANK_P:-1000}
HNSW_M=${HNSW_M:-16}
HNSW_EF=${HNSW_EF:-50}
POLL_SECONDS=${POLL_SECONDS:-10}
MAX_POLLS=${MAX_POLLS:-36}
LOG=${LOG:-results/kunpeng_pbs_smoke.txt}

cd "/home/${USER}/${PROJECT}"
mkdir -p "$(dirname "$LOG")"
rm -f test.o test.e

{
    echo "Kunpeng PBS smoke validation"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(hostname)"
    echo "NP=$NP"
    echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
    echo "QUERY_N=$QUERY_N"
    echo "NLIST=$NLIST"
    echo "NPROBE=$NPROBE"
    echo "RERANK_P=$RERANK_P"
    echo "HNSW_M=$HNSW_M"
    echo "HNSW_EF=$HNSW_EF"
    echo "COMMAND: qsub -v NP=$NP,OMP_NUM_THREADS=$OMP_NUM_THREADS,QUERY_N=$QUERY_N,NLIST=$NLIST,NPROBE=$NPROBE,RERANK_P=$RERANK_P,HNSW_M=$HNSW_M,HNSW_EF=$HNSW_EF qsub_mpi.sh"
} > "$LOG"

job=$(qsub -v "NP=$NP,OMP_NUM_THREADS=$OMP_NUM_THREADS,QUERY_N=$QUERY_N,NLIST=$NLIST,NPROBE=$NPROBE,RERANK_P=$RERANK_P,HNSW_M=$HNSW_M,HNSW_EF=$HNSW_EF" qsub_mpi.sh)
echo "JOB: $job" >> "$LOG"

i=0
while [ "$i" -lt "$MAX_POLLS" ]; do
    if qstat "$job" >> "$LOG" 2>&1; then
        sleep "$POLL_SECONDS"
        i=$((i + 1))
    else
        echo "JOB_DONE_OR_NOT_IN_QSTAT" >> "$LOG"
        break
    fi
done

{
    echo "---"
    echo "test.o tail"
    tail -n 120 test.o 2>/dev/null || true
    echo "---"
    echo "test.e tail"
    tail -n 120 test.e 2>/dev/null || true
} >> "$LOG"

tail -n 160 "$LOG"
