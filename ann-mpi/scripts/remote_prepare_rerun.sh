#!/bin/sh
set -eu

stamp=${1:-$(date '+%Y%m%d_%H%M%S')}
cd "$HOME"

if [ ! -f ann-mpi-rerun.tar ]; then
    echo "missing $HOME/ann-mpi-rerun.tar" >&2
    exit 1
fi

if [ -d ann-mpi ]; then
    mv ann-mpi "ann-mpi.backup.$stamp"
fi

tar -xf ann-mpi-rerun.tar -C "$HOME"
chmod +x ann-mpi/scripts/*.sh ann-mpi/qsub_mpi.sh

cd ann-mpi
pwd
hostname
uname -m
ls -l main.cc qsub_mpi.sh scripts/run_kunpeng_smoke.sh scripts/submit_kunpeng_pbs_smoke.sh
