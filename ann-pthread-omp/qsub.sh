#!/bin/sh
#PBS -N qsub
#PBS -e test.e
#PBS -o test.o

set -eu

LOGIN_HOST=${ANN_LOGIN_HOST:-master_ubss1}
PROJECT_DIR=${ANN_PROJECT_DIR:-/home/${USER}/ann}
RUN_DIR=${ANN_RUN_DIR:-/home/${USER}}
DATA_DIR=${ANN_DATA_DIR:-/anndata}

/usr/local/bin/pssh -h "$PBS_NODEFILE" "mkdir -p '$RUN_DIR'" 1>&2
scp "${LOGIN_HOST}:${PROJECT_DIR}/main" "${RUN_DIR}/main" 1>&2
/usr/local/bin/pscp -h "$PBS_NODEFILE" "${RUN_DIR}/main" "$RUN_DIR" 1>&2

if [ -d "$DATA_DIR" ]; then
    export ANN_DATA_PATH="${ANN_DATA_PATH:-$DATA_DIR/}"
fi

"${RUN_DIR}/main"
rm -f "${RUN_DIR}/main"
