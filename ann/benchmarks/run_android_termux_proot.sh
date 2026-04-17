#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULT_DIR="${ROOT_DIR}/bench_results/android_termux_proot_ubuntu"
BIN="${ROOT_DIR}/benchmarks/bench_experiments"

cd "${ROOT_DIR}"
mkdir -p "${RESULT_DIR}"

python3 benchmarks/plot_tradeoff.py --out-dir "${RESULT_DIR}"

g++ benchmarks/bench_experiments.cc -I. -o "${BIN}" -O2 -fopenmp -lpthread -std=c++11

"${BIN}" e1 "${RESULT_DIR}" > "${RESULT_DIR}/E1_alignment.log" 2>&1
"${BIN}" e2 "${RESULT_DIR}" > "${RESULT_DIR}/E2_prefetch.log" 2>&1
"${BIN}" e3 "${RESULT_DIR}" > "${RESULT_DIR}/E3_scale.log" 2>&1
