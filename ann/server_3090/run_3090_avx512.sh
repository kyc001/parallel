#!/bin/bash
# Run on Xeon 8358 container (3090 host). Assumes DEEP100K data lives in
# ./files/ relative to the ann/ repo root; if it does not, adjust the
# data_path in server_3090/main_3090_avx512.cc or symlink files/.
#
# What it does:
#   1. Verifies the CPU actually has AVX-512F (container could be
#      launched with --cpu-shares that hides it).
#   2. Builds two variants: -mavx2 and -mavx512f, both with -O3 -mfma -std=c++17.
#   3. Runs both and prints a 3-row comparison (NEON was on Kunpeng,
#      AVX2 on i9, AVX-512 here).
#
# Output is written to bench_results/server_3090_xeon_8358/.
set -e

cd "$(dirname "$0")/.."  # jump to ann/

OUT=bench_results/server_3090_xeon_8358
mkdir -p "$OUT"

echo "==== CPU info ===="
cat /proc/cpuinfo | grep -m1 'model name'
if grep -q avx512f /proc/cpuinfo; then
    echo "AVX-512F: yes"
else
    echo "AVX-512F: NO -- this machine cannot run the 512-bit variant"
    exit 1
fi

echo "==== Build baseline (serial) ===="
g++ server_3090/main_3090_avx512.cc -o m_3090_serial.exe \
    -O3 -mfma -std=c++17
./m_3090_serial.exe baseline | tee "$OUT/speed_baseline.csv"

echo "==== Build AVX-512 ===="
g++ server_3090/main_3090_avx512.cc -o m_3090_avx512.exe \
    -O3 -mavx512f -mavx512bw -mavx512dq -mfma -std=c++17
./m_3090_avx512.exe flat_avx512 | tee "$OUT/speed_flat_avx512.csv"

echo ""
echo "==== Summary ===="
grep -v "mode,k" "$OUT"/*.csv

echo ""
echo "Results saved under $OUT/"
