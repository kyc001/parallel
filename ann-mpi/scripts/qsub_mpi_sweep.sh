#!/bin/sh
#PBS -N ann_mpi_sweep
#PBS -e sweep.e
#PBS -o sweep.o
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
    label=$1
    shift
    echo "---"
    echo "CASE: $label"
    echo "COMMAND: /usr/local/bin/mpiexec -np $1 -machinefile \$PBS_NODEFILE /home/${USER}/main $2 $3 $4 $5 $6 $7"
    /usr/local/bin/mpiexec -np "$1" -machinefile "$PBS_NODEFILE" "/home/${USER}/main" "$2" "$3" "$4" "$5" "$6" "$7"
}

echo "Kunpeng PBS ANN MPI sweep"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo "NP=$NP"
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "QUERY_N=$QUERY_N"
echo "ANN_DATA_PATH=${ANN_DATA_PATH:-}"

echo "=== Parameter sweep: IVF-PQ nprobe ==="
for nprobe in 1 2 4 8 16; do
    run_case "parameter IVF-PQ nlist=16 nprobe=${nprobe}" "$NP" "$OMP_NUM_THREADS" 16 "$nprobe" 1000 "$QUERY_N" local
done

echo "=== Parameter sweep: IVF-PQ nlist ==="
for nlist in 8 16 32 64; do
    run_case "parameter IVF-PQ nlist=${nlist} nprobe=4" "$NP" "$OMP_NUM_THREADS" "$nlist" 4 1000 "$QUERY_N" local
done

echo "=== Parameter sweep: Block-HNSW ef ==="
for ef in 10 20 50 100 200; do
    run_case "parameter Block-HNSW ef=${ef}" "$NP" "$OMP_NUM_THREADS" 16 "$ef" 1000 "$QUERY_N" hnsw
done

echo "=== Parameter sweep: IVF+HNSW nprobe ==="
for nprobe in 1 2 4 8 16; do
    run_case "parameter IVF+HNSW nprobe=${nprobe}" "$NP" "$OMP_NUM_THREADS" 16 "$nprobe" 50 "$QUERY_N" ivf-hnsw
done

echo "=== Parameter sweep: HNSW-on-HNSW nprobe_blocks ==="
for nprobe in 1 2 4 8 16; do
    run_case "parameter HNSW-on-HNSW nprobe_blocks=${nprobe}" "$NP" "$OMP_NUM_THREADS" 16 "$nprobe" 50 "$QUERY_N" hnsw-on-hnsw
done

echo "=== Strong scaling ==="
for np in 1 2 4 8; do
    run_case "scalability IVF-PQ np=${np}" "$np" "$OMP_NUM_THREADS" 16 4 1000 "$QUERY_N" local
done
for np in 1 2 4 8; do
    run_case "scalability Block-HNSW np=${np}" "$np" "$OMP_NUM_THREADS" 16 50 1000 "$QUERY_N" hnsw
done
for np in 1 2 4 8; do
    run_case "scalability IVF+HNSW np=${np}" "$np" "$OMP_NUM_THREADS" 16 4 50 "$QUERY_N" ivf-hnsw
done
for np in 1 2 4 8; do
    run_case "scalability HNSW-on-HNSW np=${np}" "$np" "$OMP_NUM_THREADS" 16 8 50 "$QUERY_N" hnsw-on-hnsw
done

echo "=== Kunpeng PBS sweep complete ==="
