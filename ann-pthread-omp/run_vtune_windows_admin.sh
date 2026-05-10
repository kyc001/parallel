#!/usr/bin/env bash
set -u

# Run this from an Administrator Git Bash on native Windows.
# It collects VTune reports for the Windows AVX2 executable and writes
# text reports under bench_results/windows_i9_13900h/.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

OUT_DIR="bench_results/windows_i9_13900h"
EXE="./main_win_avx2.exe"
mkdir -p "$OUT_DIR"

to_win_path() {
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -w "$1"
    else
        printf '%s\n' "$1"
    fi
}

find_vtune() {
    if command -v vtune >/dev/null 2>&1; then
        command -v vtune
        return 0
    fi

    local candidates=(
        "/c/Program Files (x86)/Intel/oneAPI/vtune/latest/bin64/vtune.exe"
        "/c/Program Files/Intel/oneAPI/vtune/latest/bin64/vtune.exe"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

if ! VTUNE="$(find_vtune)"; then
    echo "ERROR: vtune.exe not found in PATH or default oneAPI locations." >&2
    exit 1
fi

if [[ ! -x "$EXE" ]]; then
    echo "Building $EXE ..."
    g++ main_win_avx2.cc -o main_win_avx2.exe -O2 -mavx2 -mfma -fopenmp -lpthread -std=c++11
fi

for data_file in \
    files/DEEP100K.base.100k.fbin \
    files/DEEP100K.query.fbin \
    files/DEEP100K.gt.query.100k.top100.bin; do
    if [[ ! -f "$data_file" ]]; then
        echo "ERROR: missing $data_file" >&2
        exit 1
    fi
done

if net session >/dev/null 2>&1; then
    echo "Administrator check: OK"
else
    echo "WARNING: administrator check failed. VTune PMU collection may fail." >&2
fi

failures=()

run_collect_report() {
    local result_dir="$1"
    local analysis="$2"
    local report_kind="$3"
    local report_file="$4"
    shift 4
    local cmd=("$@")
    local collect_log="$OUT_DIR/${result_dir}_collect.log"
    local report_log="$OUT_DIR/${result_dir}_report.log"
    local report_path="$OUT_DIR/$report_file"

    echo
    echo "==> Collecting $analysis into $result_dir"
    rm -rf "$result_dir"

    if ! "$VTUNE" -collect "$analysis" -result-dir "$result_dir" -- "${cmd[@]}" >"$collect_log" 2>&1; then
        {
            echo "VTune $analysis collection failed."
            echo
            echo "Command:"
            printf '%q ' "$VTUNE" -collect "$analysis" -result-dir "$result_dir" -- "${cmd[@]}"
            echo
            echo
            echo "Collector log:"
            cat "$collect_log"
        } >"$report_path"
        failures+=("$result_dir")
        echo "FAILED: $analysis. See $report_path"
        return 0
    fi

    echo "==> Exporting $report_kind report to $report_path"
    if ! "$VTUNE" -report "$report_kind" -result-dir "$result_dir" \
        -report-output "$(to_win_path "$report_path")" -format text >"$report_log" 2>&1; then
        {
            echo "VTune $report_kind report export failed."
            echo
            echo "Command:"
            printf '%q ' "$VTUNE" -report "$report_kind" -result-dir "$result_dir" \
                -report-output "$(to_win_path "$report_path")" -format text
            echo
            echo
            echo "Report log:"
            cat "$report_log"
        } >"$report_path"
        failures+=("$result_dir")
        echo "FAILED: report export. See $report_path"
        return 0
    fi

    echo "OK: $report_path"
}

run_collect_report "vtune_hotspots_flat" "hotspots" "hotspots" \
    "vtune_hotspots_flat.txt" "$EXE" flat

run_collect_report "vtune_uarch_flat" "uarch-exploration" "summary" \
    "vtune_uarch_flat.txt" "$EXE" flat

run_collect_report "vtune_mem_flat" "memory-access" "summary" \
    "vtune_mem_flat.txt" "$EXE" flat

run_collect_report "vtune_uarch_sq" "uarch-exploration" "summary" \
    "vtune_uarch_sq.txt" "$EXE" sq

run_collect_report "vtune_uarch_pq" "uarch-exploration" "summary" \
    "vtune_uarch_pq.txt" "$EXE" pq

echo
echo "Generated reports:"
ls -lh "$OUT_DIR"/vtune_*.txt 2>/dev/null || true

if (( ${#failures[@]} )); then
    echo
    echo "Some VTune tasks failed: ${failures[*]}" >&2
    exit 1
fi

echo
echo "All VTune tasks completed."
