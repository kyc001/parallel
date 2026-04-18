#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
cd "${script_dir}"

task_id="${1:-1}"
node_count="${2:-1}"
rerank_p="${FASTSCAN_RERANK_P:-1000}"

mkdir -p files

backup_file="main.cc.fastscan_backup"
cp main.cc "${backup_file}"
restore_main() {
  if [ -f "${backup_file}" ]; then
    mv -f "${backup_file}" main.cc
  fi
}
trap restore_main EXIT

sed "s/^#define FASTSCAN_DEFAULT_RERANK_P 1000$/#define FASTSCAN_DEFAULT_RERANK_P ${rerank_p}/" \
  main_fastscan_submit.cc > main.cc
test_rc=0
set +e
bash test.sh "${task_id}" "${node_count}"
test_rc=$?
set -e
if [ "${test_rc}" -ne 0 ]; then
  echo "warning: test.sh exited with status ${test_rc}, trying to collect test.o anyway" >&2
fi

if [ ! -f test.o ]; then
  echo "error: test.o not found after test.sh" >&2
  exit "${test_rc:-1}"
fi

cp test.o result_fastscan.txt
echo "---- Result for fastscan ----"
cat result_fastscan.txt

if [ "${test_rc}" -ne 0 ]; then
  echo "warning: ignoring non-zero test.sh exit because result_fastscan.txt was produced" >&2
fi
