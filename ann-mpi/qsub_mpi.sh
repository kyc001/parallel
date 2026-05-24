#!/bin/sh
#PBS -N ann_mpi
#PBS -e test.e
#PBS -o test.o
#PBS -l nodes=2:ppn=8

set -eu

PROJECT=ann-mpi
NP=${NP:-8}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-2}
export OMP_NUM_THREADS

NODES=$(sort -u "$PBS_NODEFILE")

for node in $NODES; do
    scp "master_ubss1:/home/${USER}/${PROJECT}/main" "${node}:/home/${USER}/main" 1>&2
    scp -r "master_ubss1:/home/${USER}/${PROJECT}/files" "${node}:/home/${USER}/" 1>&2
done

/usr/local/bin/mpiexec -np "$NP" -machinefile "$PBS_NODEFILE" \
    "/home/${USER}/main" "$OMP_NUM_THREADS" 16 4 1000 2000 local

scp -r "/home/${USER}/files/" "master_ubss1:/home/${USER}/${PROJECT}/" 2>&1
