#!/usr/bin/env bash
set -euo pipefail

THREADS=${THREADS:-"1 2 4 8 16"}
RESULT_DIR=${RESULT_DIR:-results/kunpeng}
mkdir -p "$RESULT_DIR"

variants=(
  mains/omp/inter/main_flat.cc
  mains/omp/intra/main_flat.cc
  mains/pthread/static/inter/main_flat.cc
  mains/pthread/static/intra/main_flat.cc
  mains/pthread/dynamic/inter/main_flat.cc
  mains/pthread/dynamic/intra/main_flat.cc
  mains/pthread/pool/inter/main_flat.cc
  mains/pthread/pool/intra/main_flat.cc
  mains/omp/inter/main_pq.cc
  mains/omp/intra/main_pq.cc
  mains/pthread/static/inter/main_pq.cc
  mains/pthread/static/intra/main_pq.cc
  mains/pthread/dynamic/inter/main_pq.cc
  mains/pthread/dynamic/intra/main_pq.cc
  mains/pthread/pool/inter/main_pq.cc
  mains/pthread/pool/intra/main_pq.cc
  mains/ivf/simd/main_ivf.cc
  mains/ivf/omp/inter/main_ivf.cc
  mains/ivf/omp/intra/main_ivf.cc
  mains/ivf/pthread/dynamic/inter/main_ivf.cc
  mains/ivf/pthread/dynamic/intra/main_ivf.cc
  mains/ivf/simd/main_ivfpq.cc
  mains/ivf/omp/inter/main_ivfpq.cc
  mains/ivf/omp/intra/main_ivfpq.cc
  mains/ivf/pthread/dynamic/inter/main_ivfpq.cc
  mains/ivf/pthread/dynamic/intra/main_ivfpq.cc
  mains/hnsw/main_baseline.cc
  mains/hnsw/main_multi_entry_omp.cc
  mains/hnsw/main_multi_entry_static.cc
)

for src in "${variants[@]}"; do
  [[ -f "$src" ]] || continue
  name=${src#mains/}
  name=${name%.cc}
  name=${name//\//_}
  cp "$src" main.cc
  for t in $THREADS; do
    echo "==> $name t=$t"
    g++ main.cc -o main -O2 -fopenmp -lpthread -std=c++17 -I.
    case "$src" in
      *ivfpq*) ./main "$t" 16 4 100 global > "$RESULT_DIR/${name}_t${t}.txt" 2>&1 ;;
      *ivf*) ./main "$t" 16 4 > "$RESULT_DIR/${name}_t${t}.txt" 2>&1 ;;
      *hnsw*) ./main "$t" 50 16 4 > "$RESULT_DIR/${name}_t${t}.txt" 2>&1 ;;
      *main_pq.cc) ./main "$t" 100 > "$RESULT_DIR/${name}_t${t}.txt" 2>&1 ;;
      *) ./main "$t" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1 ;;
    esac
  done
done
