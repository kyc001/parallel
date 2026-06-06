#!/bin/sh
#PBS -N ann_mpi_final_gaps
#PBS -e final_gaps.e
#PBS -o final_gaps.o
#PBS -l nodes=2:ppn=8

set -eu

PROJECT=${PROJECT:-ann-mpi}
NP=${NP:-8}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
QUERY_N=${QUERY_N:-2000}
SHUFFLE_SEED=${SHUFFLE_SEED:-20260525}
export OMP_NUM_THREADS

NODES=$(sort -u "$PBS_NODEFILE")

for node in $NODES; do
    scp "master_ubss1:/home/${USER}/${PROJECT}/main" "${node}:/home/${USER}/main" 1>&2
    scp -r "master_ubss1:/home/${USER}/${PROJECT}/files" "${node}:/home/${USER}/" 1>&2 || true
done

if [ -d /anndata ]; then
    export ANN_DATA_PATH=/anndata
elif [ -d "/home/${USER}/files" ]; then
    export ANN_DATA_PATH="/home/${USER}/files"
fi

run_case() {
    experiment=$1
    label=$2
    shift 2
    echo "---"
    echo "CASE: ${experiment} ${label}"
    unset USE_SHUFFLED_BASE USE_MPI_THREAD_MULTIPLE BASE_SHUFFLE_SEED || true
    if [ "$experiment" = "load_balance" ] && [ "$label" = "shuffled" ]; then
        export USE_SHUFFLED_BASE=1
        export BASE_SHUFFLE_SEED="$SHUFFLE_SEED"
    fi
    if [ "$experiment" = "thread_level" ] && [ "$label" = "multiple" ]; then
        export USE_MPI_THREAD_MULTIPLE=1
    fi
    /usr/local/bin/mpiexec -np "$NP" -machinefile "$PBS_NODEFILE" "/home/${USER}/main" "$@"
}

echo "Kunpeng PBS ANN MPI final gap experiments"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo "NP=$NP"
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "QUERY_N=$QUERY_N"
echo "SHUFFLE_SEED=$SHUFFLE_SEED"
echo "ANN_DATA_PATH=${ANN_DATA_PATH:-}"

run_case load_balance contiguous "$OMP_NUM_THREADS" 16 50 1000 "$QUERY_N" hnsw
run_case load_balance shuffled "$OMP_NUM_THREADS" 16 50 1000 "$QUERY_N" hnsw
run_case thread_level funneled "$OMP_NUM_THREADS" 16 4 1000 "$QUERY_N" local
run_case thread_level multiple "$OMP_NUM_THREADS" 16 4 1000 "$QUERY_N" local

unset USE_SHUFFLED_BASE USE_MPI_THREAD_MULTIPLE BASE_SHUFFLE_SEED || true
echo "=== Kunpeng PBS final gap experiments complete ==="
