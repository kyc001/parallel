#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

OUT_DIR="results/gprof_cli"
mkdir -p "$OUT_DIR"

echo "[gprof] project root: $ROOT_DIR"

if ! command -v gprof >/dev/null 2>&1; then
  echo "[gprof] error: gprof command not found" >&2
  echo "[gprof] install suggestion: sudo apt install binutils" >&2
  exit 1
fi

echo "[gprof] building dedicated gprof driver..."
make gprof

cat > "$OUT_DIR/README.txt" <<'EOF'
This directory contains gprof fallback reports for environments where perf is blocked.

Compared with perf:
- available: function hotspots, flat profile, call graph
- unavailable: cycles, instructions, IPC, cache references, cache misses, miss rate
EOF

run_case() {
  local kind="$1"
  local algorithm="$2"
  local n="$3"
  local repeat="$4"
  local base="$OUT_DIR/${kind}_${algorithm}_n${n}_r${repeat}"

  echo "[gprof] run ${kind}/${algorithm} n=${n} repeat=${repeat}"
  rm -f gmon.out
  ./bin/lab1_gprof "$kind" "$algorithm" "$n" "$repeat" >/dev/null

  if [[ ! -f gmon.out ]]; then
    echo "[gprof] error: gmon.out not generated for ${kind}/${algorithm}" >&2
    exit 1
  fi

  mv gmon.out "${base}.gmon"
  gprof ./bin/lab1_gprof "${base}.gmon" > "${base}_report.txt"
}

# Mirror the representative hotspot workloads from run_perf.sh.
run_case matrix naive 2048 4
run_case matrix row_major_unrolled4 2048 128
run_case sum naive 1048576 512
run_case sum superscalar4 1048576 2048

cat <<EOF
[gprof] done
[gprof] raw outputs: $OUT_DIR
[gprof] next steps:
       1. 查看 *_report.txt 中的热点函数
       2. 将这些热点与 results/assembly_excerpt.txt 对照分析
       3. 注意 gprof 不能替代 perf 的 IPC / cache miss 指标
EOF
