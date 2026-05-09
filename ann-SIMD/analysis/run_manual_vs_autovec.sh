#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p local_results/manual_vs_autovec

cxx="${CXX:-g++}"
arch="$(uname -m)"
common_flags=(-O3 -std=c++17 -Wall -Wextra -Wno-unused-parameter)
vec_report="local_results/manual_vs_autovec/vectorization.log"
out_bin="local_results/manual_vs_autovec/manual_vs_autovec"
out_txt="local_results/manual_vs_autovec/results.txt"

case "$arch" in
  x86_64|amd64)
    arch_flags=(-mavx2 -mfma)
    ;;
  aarch64|arm64)
    arch_flags=(-mcpu=native)
    ;;
  *)
    echo "unsupported arch: $arch" >&2
    exit 1
    ;;
esac

"$cxx" analysis/manual_vs_autovec.cc -o "$out_bin" \
  "${common_flags[@]}" "${arch_flags[@]}" \
  -fopt-info-vec-optimized -fopt-info-vec-missed \
  2> "$vec_report"

"$out_bin" | tee "$out_txt"
