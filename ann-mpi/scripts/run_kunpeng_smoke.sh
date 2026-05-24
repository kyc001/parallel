#!/bin/sh
set -eu

LOG=${1:-results/kunpeng_smoke.txt}
MPIEXEC=${MPIEXEC:-/usr/local/bin/mpiexec}
MPICXX=${MPICXX:-/usr/local/bin/mpic++}
NP=${NP:-2}
THREADS=${THREADS:-2}
QUERY_N=${QUERY_N:-200}

mkdir -p "$(dirname "$LOG")"

{
    echo "Kunpeng smoke validation"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(hostname)"
    echo "Arch: $(uname -m)"
    echo "MPIEXEC=$MPIEXEC"
    echo "MPICXX=$MPICXX"
    echo "NP=$NP"
    echo "THREADS=$THREADS"
    echo "QUERY_N=$QUERY_N"
    if [ -d /anndata ]; then
        echo "ANN_DATA_PATH=/anndata"
    else
        echo "ANN_DATA_PATH=${ANN_DATA_PATH:-}"
    fi
    echo
} > "$LOG"

if [ -d /anndata ]; then
    export ANN_DATA_PATH=/anndata
fi

run_step() {
    label=$1
    shift
    {
        echo "---"
        echo "STEP: $label"
        printf 'COMMAND:'
        for arg in "$@"; do
            printf ' %s' "$arg"
        done
        echo
    } >> "$LOG"

    if "$@" >> "$LOG" 2>&1; then
        echo "EXIT: 0" >> "$LOG"
    else
        code=$?
        echo "EXIT: $code" >> "$LOG"
        return "$code"
    fi
}

run_step "build" "$MPICXX" main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread
run_step "MPI IVF-PQ smoke" "$MPIEXEC" -np "$NP" ./main "$THREADS" 16 4 1000 "$QUERY_N" local
run_step "MPI block-HNSW smoke" "$MPIEXEC" -np "$NP" ./main "$THREADS" 16 50 1000 "$QUERY_N" hnsw

tail -n 120 "$LOG"
