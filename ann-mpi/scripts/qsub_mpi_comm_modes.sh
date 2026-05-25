#!/bin/sh
#PBS -N ann_mpi_comm
#PBS -e comm.e
#PBS -o comm.o
#PBS -l nodes=2:ppn=8

set -eu

PROJECT=${PROJECT:-ann-mpi}
NP=${NP:-8}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
QUERY_N=${QUERY_N:-2000}
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
    mode=$1
    label=$2
    shift 2
    echo "---"
    echo "CASE: ${mode} ${label}"
    if [ "$mode" = "nonblocking" ]; then
        export USE_NONBLOCKING_MPI=1
    else
        unset USE_NONBLOCKING_MPI || true
    fi
    /usr/local/bin/mpiexec -np "$NP" -machinefile "$PBS_NODEFILE" "/home/${USER}/main" "$@"
}

echo "Kunpeng PBS ANN MPI communication modes"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo "NP=$NP"
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "QUERY_N=$QUERY_N"
echo "ANN_DATA_PATH=${ANN_DATA_PATH:-}"

run_case blocking IVF-PQ "$OMP_NUM_THREADS" 16 4 1000 "$QUERY_N" local
run_case nonblocking IVF-PQ "$OMP_NUM_THREADS" 16 4 1000 "$QUERY_N" local
run_case blocking Block-HNSW "$OMP_NUM_THREADS" 16 50 1000 "$QUERY_N" hnsw
run_case nonblocking Block-HNSW "$OMP_NUM_THREADS" 16 50 1000 "$QUERY_N" hnsw
run_case blocking IVF+HNSW "$OMP_NUM_THREADS" 16 4 50 "$QUERY_N" ivf-hnsw
run_case nonblocking IVF+HNSW "$OMP_NUM_THREADS" 16 4 50 "$QUERY_N" ivf-hnsw
run_case blocking HNSW-on-HNSW "$OMP_NUM_THREADS" 16 16 50 "$QUERY_N" hnsw-on-hnsw
run_case nonblocking HNSW-on-HNSW "$OMP_NUM_THREADS" 16 16 50 "$QUERY_N" hnsw-on-hnsw

unset USE_NONBLOCKING_MPI || true
echo "=== Kunpeng PBS communication mode comparison complete ==="
