#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
cd "${script_dir}"

task_id="${1:-1}"
node_count="${2:-1}"
rerank_p="${FASTSCAN_RERANK_P:-1000}"

mkdir -p files

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
  if [ "${name}" = "fastscan" ]; then
    sed "s/^#define FASTSCAN_DEFAULT_RERANK_P 1000$/#define FASTSCAN_DEFAULT_RERANK_P ${rerank_p}/" \
      "${source}" > main.cc
  else
    cp "${source}" main.cc
  fi
  test_rc=0
  set +e
  bash test.sh "${task_id}" "${node_count}"
  test_rc=$?
  set -e
  if [ "${test_rc}" -ne 0 ]; then
    echo "warning: test.sh exited with status ${test_rc} for ${name}, trying to collect test.o anyway" >&2
  fi
  if [ ! -f test.o ]; then
    echo "error: test.o not found for ${name}" >&2
    exit "${test_rc:-1}"
  fi
  cp test.o "${output}"
  echo "---- Result for ${name} ----"
  cat "${output}"
  echo ""
  if [ "${test_rc}" -ne 0 ]; then
    echo "warning: ignoring non-zero test.sh exit for ${name} because ${output} was produced" >&2
  fi
done
