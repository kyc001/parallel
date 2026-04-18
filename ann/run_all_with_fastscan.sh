#!/bin/bash
set -euo pipefail

task_id="${1:-1}"
node_count="${2:-1}"

backup_file="main.cc.all_backup"
cp main.cc "${backup_file}"
restore_main() {
  if [ -f "${backup_file}" ]; then
    mv -f "${backup_file}" main.cc
  fi
}
trap restore_main EXIT

variants=(
  "baseline:main_baseline.cc:result_baseline.txt"
  "flatsimd:main_flatsimd.cc:result_flatsimd.txt"
  "sqsimd:main_sqsimd.cc:result_sqsimd.txt"
  "pqsimd:main_pqsimd.cc:result_pqsimd.txt"
  "fastscan:main_fastscan_submit.cc:result_fastscan.txt"
)

for item in "${variants[@]}"; do
  IFS=":" read -r name source output <<< "${item}"
  echo "==== Running ${name} ===="
  cp "${source}" main.cc
  bash test.sh "${task_id}" "${node_count}"
  cp test.o "${output}"
  echo "---- Result for ${name} ----"
  cat "${output}"
  echo ""
done
