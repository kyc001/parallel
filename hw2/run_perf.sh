#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

OUT_DIR="results/perf_cli"
mkdir -p "$OUT_DIR"

echo "[perf] project root: $ROOT_DIR"

is_wsl() {
  grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null || \
    grep -qi microsoft /proc/version 2>/dev/null
}

if is_wsl; then
  echo "[perf] error: WSL environment detected ($(uname -r))" >&2
  echo "[perf] this script targets Linux environments with real PMU access" >&2
  echo "[perf] in WSL2, perf hardware events for cycles/cache/LLC/uncore are not a reliable target" >&2
  echo "[perf] recommended options:" >&2
  echo "       1. rerun on native Linux host" >&2
  echo "       2. use a full Hyper-V Ubuntu VM with vPMU enabled for core PMU events" >&2
  echo "       3. fallback hotspot-only analysis: ./run_gprof.sh" >&2
  exit 2
fi

if ! command -v perf >/dev/null 2>&1; then
  echo "[perf] error: perf command not found" >&2
  echo "[perf] install suggestion: sudo apt install linux-tools-common linux-tools-generic linux-tools-\$(uname -r)" >&2
  exit 1
fi

PARANOID="$(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo unknown)"
if [[ "$PARANOID" =~ ^-?[0-9]+$ ]] && (( PARANOID > 1 )); then
  echo "[perf] warning: kernel.perf_event_paranoid=$PARANOID" >&2
  echo "[perf] hardware counters may fail for non-root users" >&2
  echo "[perf] suggested temporary fix:" >&2
  echo "       sudo sysctl -w kernel.perf_event_paranoid=1" >&2
  echo "[perf] if still blocked, try:" >&2
  echo "       sudo sysctl -w kernel.perf_event_paranoid=-1" >&2
fi

echo "[perf] building dedicated perf driver..."
make perf

STAT_EVENTS="task-clock,cycles,instructions,cache-references,cache-misses"
if perf list 2>/dev/null | grep -q "branch-misses"; then
  STAT_EVENTS="$STAT_EVENTS,branch-misses"
fi

L1_EVENTS=""
if perf list 2>/dev/null | grep -q "L1-dcache-loads"; then
  L1_EVENTS="L1-dcache-loads,L1-dcache-load-misses"
fi

LLC_EVENTS=""
if perf list 2>/dev/null | grep -q "LLC-loads"; then
  LLC_EVENTS="LLC-loads,LLC-load-misses"
fi

echo "[perf] probing hardware counter access..."
if ! perf stat -e cycles,instructions -- ./bin/lab1_perf sum naive 1024 1 >/dev/null 2>"$OUT_DIR/probe.stderr"; then
  echo "[perf] error: hardware counter probe failed" >&2
  sed -n '1,40p' "$OUT_DIR/probe.stderr" >&2
  echo "[perf] try the following before rerunning:" >&2
  echo "       sudo sysctl -w kernel.perf_event_paranoid=1" >&2
  echo "       sudo sysctl -w kernel.kptr_restrict=0" >&2
  echo "[perf] if you are in a VM/container, make sure PMU/performance counters are exposed" >&2
  echo "[perf] fallback for hotspot-only analysis: ./run_gprof.sh" >&2
  exit 1
fi
rm -f "$OUT_DIR/probe.stderr"

SUMMARY_CSV="$OUT_DIR/summary.csv"
echo "kind,algorithm,n,repeat,task_clock,cycles,instructions,ipc,cache_references,cache_misses,miss_rate,branch_misses,l1_loads,l1_load_misses,l1_miss_rate,llc_loads,llc_load_misses,llc_miss_rate" > "$SUMMARY_CSV"

extract_metric() {
  local file="$1"
  local event="$2"
  awk -F, -v ev="$event" '$3 == ev {gsub(/[[:space:]]/, "", $1); print $1; exit}' "$file"
}

calc_ratio() {
  local numerator="${1:-}"
  local denominator="${2:-}"
  if [[ -z "$numerator" || -z "$denominator" || "$denominator" == "0" ]]; then
    printf ""
    return
  fi
  awk -v n="$numerator" -v d="$denominator" 'BEGIN { printf "%.6f", n / d }'
}

run_stat() {
  local kind="$1"
  local algorithm="$2"
  local n="$3"
  local repeat="$4"
  local base="$OUT_DIR/${kind}_${algorithm}_n${n}_r${repeat}"
  local stat_file="${base}_stat.csv"

  echo "[perf] stat ${kind}/${algorithm} n=${n} repeat=${repeat}"
  perf stat -x, -r 5 -e "$STAT_EVENTS" -o "$stat_file" -- ./bin/lab1_perf "$kind" "$algorithm" "$n" "$repeat" >/dev/null

  local l1_file=""
  if [[ -n "$L1_EVENTS" ]]; then
    l1_file="${base}_l1.csv"
    perf stat -x, -r 5 -e "$L1_EVENTS" -o "$l1_file" -- ./bin/lab1_perf "$kind" "$algorithm" "$n" "$repeat" >/dev/null
  fi

  local llc_file=""
  if [[ -n "$LLC_EVENTS" ]]; then
    llc_file="${base}_llc.csv"
    perf stat -x, -r 5 -e "$LLC_EVENTS" -o "$llc_file" -- ./bin/lab1_perf "$kind" "$algorithm" "$n" "$repeat" >/dev/null
  fi

  local task_clock cycles instructions cache_refs cache_misses branch_misses ipc miss_rate
  task_clock="$(extract_metric "$stat_file" task-clock)"
  cycles="$(extract_metric "$stat_file" cycles)"
  instructions="$(extract_metric "$stat_file" instructions)"
  cache_refs="$(extract_metric "$stat_file" cache-references)"
  cache_misses="$(extract_metric "$stat_file" cache-misses)"
  branch_misses="$(extract_metric "$stat_file" branch-misses)"
  ipc="$(calc_ratio "$instructions" "$cycles")"
  miss_rate="$(calc_ratio "$cache_misses" "$cache_refs")"

  local l1_loads="" l1_load_misses="" l1_miss_rate=""
  if [[ -n "$l1_file" ]]; then
    l1_loads="$(extract_metric "$l1_file" L1-dcache-loads)"
    l1_load_misses="$(extract_metric "$l1_file" L1-dcache-load-misses)"
    l1_miss_rate="$(calc_ratio "$l1_load_misses" "$l1_loads")"
  fi

  local llc_loads="" llc_load_misses="" llc_miss_rate=""
  if [[ -n "$llc_file" ]]; then
    llc_loads="$(extract_metric "$llc_file" LLC-loads)"
    llc_load_misses="$(extract_metric "$llc_file" LLC-load-misses)"
    llc_miss_rate="$(calc_ratio "$llc_load_misses" "$llc_loads")"
  fi

  echo "${kind},${algorithm},${n},${repeat},${task_clock},${cycles},${instructions},${ipc},${cache_refs},${cache_misses},${miss_rate},${branch_misses},${l1_loads},${l1_load_misses},${l1_miss_rate},${llc_loads},${llc_load_misses},${llc_miss_rate}" >> "$SUMMARY_CSV"
}

run_record() {
  local kind="$1"
  local algorithm="$2"
  local n="$3"
  local repeat="$4"
  local base="$OUT_DIR/${kind}_${algorithm}_n${n}_r${repeat}"
  echo "[perf] record ${kind}/${algorithm} n=${n} repeat=${repeat}"
  perf record --call-graph fp -g -o "${base}.data" -- ./bin/lab1_perf "$kind" "$algorithm" "$n" "$repeat" >/dev/null
  perf report --stdio -i "${base}.data" > "${base}_report.txt"
}

# Matrix: choose repeats so each case runs for roughly 0.5s or longer.
run_stat matrix naive 2048 8
run_stat matrix row_major 2048 200
run_stat matrix row_major_unrolled4 2048 256

# Sum: choose repeats so each case runs for roughly 1s.
run_stat sum naive 1048576 1024
run_stat sum superscalar2 1048576 2048
run_stat sum superscalar4 1048576 4096
run_stat sum pairwise 1048576 1024

# Representative call-graph samples for hotspot analysis.
run_record matrix naive 2048 4
run_record matrix row_major_unrolled4 2048 128
run_record sum naive 1048576 512
run_record sum superscalar4 1048576 2048

cat <<EOF
[perf] done
[perf] raw outputs: $OUT_DIR
[perf] parsed summary: $SUMMARY_CSV
[perf] next steps:
       1. 查看 summary.csv 中的 IPC 和 miss_rate
       2. 查看 *_report.txt 中的热点函数
       3. 如需更稳定的数据，可把 -r 5 提高到 -r 10
EOF
