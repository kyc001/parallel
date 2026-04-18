#!/bin/bash
set -euo pipefail

task_id="${1:-1}"
node_count="${2:-1}"

backup_file="main.cc.fastscan_backup"
cp main.cc "${backup_file}"
restore_main() {
  if [ -f "${backup_file}" ]; then
    mv -f "${backup_file}" main.cc
  fi
}
trap restore_main EXIT

cp main_fastscan_submit.cc main.cc
bash test.sh "${task_id}" "${node_count}"
cp test.o result_fastscan.txt
echo "---- Result for fastscan ----"
cat result_fastscan.txt
