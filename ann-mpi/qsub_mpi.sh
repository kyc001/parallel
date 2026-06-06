#!/bin/sh
#PBS -N ann_mpi
#PBS -e test.e
#PBS -o test.o
#PBS -l nodes=2:ppn=8

set -eu

PROJECT=ann-mpi
NP=${NP:-4}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
QUERY_N=${QUERY_N:-2000}
NLIST=${NLIST:-16}
NPROBE=${NPROBE:-4}
RERANK_P=${RERANK_P:-1000}
HNSW_M=${HNSW_M:-16}
HNSW_EF=${HNSW_EF:-50}
export OMP_NUM_THREADS

NODES=$(sort -u "$PBS_NODEFILE")

for node in $NODES; do
    scp "master_ubss1:/home/${USER}/${PROJECT}/main" "${node}:/home/${USER}/main" 1>&2
    scp -r "master_ubss1:/home/${USER}/${PROJECT}/files" "${node}:/home/${USER}/" 1>&2 || true
done

if [ -d /anndata ]; then
    export ANN_DATA_PATH=/anndata
elif [ -d /home/${USER}/files ]; then
    export ANN_DATA_PATH=/home/${USER}/files
fi

echo "ANN MPI representative submission"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "NP=$NP"
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "main_default=Block-HNSW m=16 ef=50 query_n=2000"
echo "ANN_DATA_PATH=${ANN_DATA_PATH:-}"
echo "COMMAND: /usr/local/bin/mpiexec -np $NP -machinefile \$PBS_NODEFILE /home/${USER}/main"

/usr/local/bin/mpiexec -np "$NP" -machinefile "$PBS_NODEFILE" \
    "/home/${USER}/main"

if [ -d /home/${USER}/files ]; then
    scp -r "/home/${USER}/files/" "master_ubss1:/home/${USER}/${PROJECT}/" 2>&1
fi
