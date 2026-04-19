#!/bin/bash
# Sweep FastScan rerank_p in {10000, 50000, 100000} on Kunpeng 920.
# Saves one result_fastscan_pN.txt per p value so the report's final
# tradeoff table can extend past p=5000.
#
# Usage (on Kunpeng):
#   cd ~/ann/
#   bash run_fastscan_bigp.sh 1 1
# Arguments forwarded to run_fastscan_test.sh (task id, node count).

set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
cd "${script_dir}"

task_id="${1:-1}"
node_count="${2:-1}"

mkdir -p bench_results/kunpeng_server/fastscan_bigp

for p in 10000 50000 100000; do
    echo "==== FastScan p=$p on Kunpeng ===="
    FASTSCAN_RERANK_P=$p bash run_fastscan_test.sh "${task_id}" "${node_count}"
    if [ -f result_fastscan.txt ]; then
        out="bench_results/kunpeng_server/fastscan_bigp/result_fastscan_p${p}.txt"
        cp result_fastscan.txt "$out"
        echo "saved -> $out"
    fi
done

echo ""
echo "==== Summary ===="
for p in 10000 50000 100000; do
    f="bench_results/kunpeng_server/fastscan_bigp/result_fastscan_p${p}.txt"
    if [ -f "$f" ]; then
        echo "--- p=$p ---"
        grep -E "fastscan|recall|latency" "$f" | head -6
    fi
done
