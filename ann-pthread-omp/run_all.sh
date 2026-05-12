#!/usr/bin/env bash
set -euo pipefail

CXX=${CXX:-g++}
THREADS=${THREADS:-"1 2 4 8 16"}
RESULT_DIR=${RESULT_DIR:-results/local}
SQ_RERANK_P=${SQ_RERANK_P:-100}
PQ_RERANK_P=${PQ_RERANK_P:-1000}
IVF_NLIST=${IVF_NLIST:-16}
IVF_NPROBE=${IVF_NPROBE:-4}
IVFPQ_NLIST=${IVFPQ_NLIST:-16}
IVFPQ_NPROBE=${IVFPQ_NPROBE:-4}
IVFPQ_RERANK_P=${IVFPQ_RERANK_P:-1000}
IVFPQ_MODE=${IVFPQ_MODE:-local}
HNSW_EF=${HNSW_EF:-50}
HNSW_NLIST=${HNSW_NLIST:-16}
HNSW_NPROBE=${HNSW_NPROBE:-8}
mkdir -p build "$RESULT_DIR"

ARCH=$(uname -m 2>/dev/null || echo unknown)
FLAGS="-O2 -std=c++11 -I. -fopenmp -lpthread"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
  FLAGS="$FLAGS -mavx2 -mfma"
fi

variants=(
  mains/omp/inter/main_flat.cc
  mains/omp/intra/main_flat.cc
  mains/pthread/static/inter/main_flat.cc
  mains/pthread/static/intra/main_flat.cc
  mains/pthread/dynamic/inter/main_flat.cc
  mains/pthread/dynamic/intra/main_flat.cc
  mains/pthread/pool/inter/main_flat.cc
  mains/pthread/pool/intra/main_flat.cc

  mains/omp/inter/main_sq.cc
  mains/omp/intra/main_sq.cc
  mains/pthread/static/inter/main_sq.cc
  mains/pthread/static/intra/main_sq.cc
  mains/pthread/dynamic/inter/main_sq.cc
  mains/pthread/dynamic/intra/main_sq.cc
  mains/pthread/pool/inter/main_sq.cc
  mains/pthread/pool/intra/main_sq.cc

  mains/omp/inter/main_pq.cc
  mains/omp/intra/main_pq.cc
  mains/pthread/static/inter/main_pq.cc
  mains/pthread/static/intra/main_pq.cc
  mains/pthread/dynamic/inter/main_pq.cc
  mains/pthread/dynamic/intra/main_pq.cc
  mains/pthread/pool/inter/main_pq.cc
  mains/pthread/pool/intra/main_pq.cc

  mains/omp/inter/main_fastscan.cc
  mains/omp/intra/main_fastscan.cc
  mains/pthread/static/inter/main_fastscan.cc
  mains/pthread/static/intra/main_fastscan.cc
  mains/pthread/dynamic/inter/main_fastscan.cc
  mains/pthread/dynamic/intra/main_fastscan.cc
  mains/pthread/pool/inter/main_fastscan.cc
  mains/pthread/pool/intra/main_fastscan.cc

  mains/ivf/simd/main_ivf.cc
  mains/ivf/omp/inter/main_ivf.cc
  mains/ivf/omp/intra/main_ivf.cc
  mains/ivf/pthread/static/inter/main_ivf.cc
  mains/ivf/pthread/static/intra/main_ivf.cc
  mains/ivf/pthread/dynamic/inter/main_ivf.cc
  mains/ivf/pthread/dynamic/intra/main_ivf.cc
  mains/ivf/pthread/pool/inter/main_ivf.cc
  mains/ivf/pthread/pool/intra/main_ivf.cc

  mains/ivf/simd/main_ivfpq.cc
  mains/ivf/omp/inter/main_ivfpq.cc
  mains/ivf/omp/intra/main_ivfpq.cc
  mains/ivf/pthread/static/inter/main_ivfpq.cc
  mains/ivf/pthread/static/intra/main_ivfpq.cc
  mains/ivf/pthread/dynamic/inter/main_ivfpq.cc
  mains/ivf/pthread/dynamic/intra/main_ivfpq.cc
  mains/ivf/pthread/pool/inter/main_ivfpq.cc
  mains/ivf/pthread/pool/intra/main_ivfpq.cc

  mains/hnsw/main_baseline.cc
  mains/hnsw/main_multi_entry_omp.cc
  mains/hnsw/main_multi_entry_static.cc
  mains/hnsw/main_multi_entry_dynamic.cc
  mains/hnsw/main_multi_entry_pool.cc
  mains/hnsw/main_edge_omp.cc
  mains/hnsw/main_edge_static.cc
  mains/hnsw/main_layer0_omp.cc
  mains/hnsw/main_layer0_static.cc
  mains/hnsw/main_ivf_nested_omp.cc
  mains/hnsw/main_ivf_nested_static.cc
)

for src in "${variants[@]}"; do
  [[ -f "$src" ]] || continue
  name=${src#mains/}
  name=${name%.cc}
  name=${name//\//_}
  echo "==> $name"
  cp "$src" main.cc
  $CXX main.cc -o build/run_one $FLAGS

  case "$src" in
    *main_baseline.cc|mains/simd/*)
      ./build/run_one > "$RESULT_DIR/${name}.txt" 2>&1
      ;;
    *ivfpq*)
      for t in $THREADS; do ./build/run_one "$t" "$IVFPQ_NLIST" "$IVFPQ_NPROBE" "$IVFPQ_RERANK_P" "$IVFPQ_MODE" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      ;;
    *ivf*)
      for t in $THREADS; do ./build/run_one "$t" "$IVF_NLIST" "$IVF_NPROBE" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      ;;
    *hnsw*)
      for t in 1 4 8 16; do ./build/run_one "$t" "$HNSW_EF" "$HNSW_NLIST" "$HNSW_NPROBE" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      ;;
    *main_pq.cc|*main_sq.cc)
      if [[ "$src" == *main_pq.cc ]]; then
        for t in $THREADS; do ./build/run_one "$t" "$PQ_RERANK_P" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      else
        for t in 1 4 8 16; do ./build/run_one "$t" "$SQ_RERANK_P" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      fi
      ;;
    *main_fastscan.cc)
      for t in 1 4 8 16; do ./build/run_one "$t" 1000 > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      ;;
    *)
      for t in $THREADS; do ./build/run_one "$t" > "$RESULT_DIR/${name}_t${t}.txt" 2>&1; done
      ;;
  esac
done
