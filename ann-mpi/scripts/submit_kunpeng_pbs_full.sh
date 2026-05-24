#!/bin/sh
set -eu

PROJECT=${PROJECT:-ann-mpi}
NP=${NP:-8}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
QUERY_N=${QUERY_N:-2000}
NLIST=${NLIST:-16}
NPROBE=${NPROBE:-4}
RERANK_P=${RERANK_P:-1000}
HNSW_M=${HNSW_M:-16}
HNSW_EF=${HNSW_EF:-50}
HNSW_ON_HNSW_NPROBE=${HNSW_ON_HNSW_NPROBE:-$NLIST}
POLL_SECONDS=${POLL_SECONDS:-10}
MAX_POLLS=${MAX_POLLS:-120}
LOG=${LOG:-results/kunpeng_pbs_full.txt}

cd "/home/${USER}/${PROJECT}"
mkdir -p "$(dirname "$LOG")"
rm -f test.o test.e

{
    echo "Kunpeng PBS full validation"
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
    echo "HNSW_ON_HNSW_NPROBE=$HNSW_ON_HNSW_NPROBE"
    echo "COMMAND: qsub -v NP=$NP,OMP_NUM_THREADS=$OMP_NUM_THREADS,QUERY_N=$QUERY_N,NLIST=$NLIST,NPROBE=$NPROBE,RERANK_P=$RERANK_P,HNSW_M=$HNSW_M,HNSW_EF=$HNSW_EF,HNSW_ON_HNSW_NPROBE=$HNSW_ON_HNSW_NPROBE qsub_mpi.sh"
} > "$LOG"

job=$(qsub -v "NP=$NP,OMP_NUM_THREADS=$OMP_NUM_THREADS,QUERY_N=$QUERY_N,NLIST=$NLIST,NPROBE=$NPROBE,RERANK_P=$RERANK_P,HNSW_M=$HNSW_M,HNSW_EF=$HNSW_EF,HNSW_ON_HNSW_NPROBE=$HNSW_ON_HNSW_NPROBE" qsub_mpi.sh)
echo "JOB: $job" >> "$LOG"

i=0
while [ "$i" -lt "$MAX_POLLS" ]; do
    qstat_out=$(qstat "$job" 2>&1) || {
        printf '%s\n' "$qstat_out" >> "$LOG"
        echo "JOB_DONE_OR_NOT_IN_QSTAT" >> "$LOG"
        break
    }
    printf '%s\n' "$qstat_out" >> "$LOG"
    if printf '%s\n' "$qstat_out" | awk -v job="$job" '$1 == job && $5 == "C" { found = 1 } END { exit found ? 0 : 1 }'; then
        echo "JOB_COMPLETED_IN_QSTAT" >> "$LOG"
        break
    else
        sleep "$POLL_SECONDS"
        i=$((i + 1))
    fi
done

{
    echo "---"
    echo "test.o tail"
    tail -n 160 test.o 2>/dev/null || true
    echo "---"
    echo "test.e tail"
    tail -n 160 test.e 2>/dev/null || true
} >> "$LOG"

tail -n 200 "$LOG"
