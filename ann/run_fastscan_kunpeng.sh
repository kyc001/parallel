#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

bash ./build_fastscan.sh

out_dir="bench_results/kunpeng_server/fastscan"
mkdir -p "$out_dir"

./main_fastscan \
  --data_path=/anndata/ \
  --output_dir="$out_dir" \
  --queries=2000 \
  --k=10 \
  --p=40,100,500,1000,2000,5000 \
  | tee "$out_dir/stdout.txt"
