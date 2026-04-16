#!/usr/bin/env bash
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RESULTS_DIR="${ANN_DIR}/local_results/termux_arm64/simpleperf"
BIN_DIR="${ANN_DIR}/local_results/termux_arm64/bin"

mkdir -p "${RESULTS_DIR}" "${BIN_DIR}"
cd "${ANN_DIR}" || exit 1

BENCH="${BIN_DIR}/bench_simpleperf"
PERF_DATA="${RESULTS_DIR}/bench_simpleperf.data"

{
    echo "===== simpleperf environment ====="
    date
    echo ""
    echo "simpleperf path:"
    which simpleperf
    echo ""
    echo "simpleperf version:"
    simpleperf --version
    echo ""
    echo "user:"
    id
    echo ""
    echo "kernel:"
    uname -a
    echo ""
    echo "perf_event_paranoid:"
    cat /proc/sys/kernel/perf_event_paranoid
    echo ""
} > "${RESULTS_DIR}/simpleperf_env.txt" 2>&1

g++ "${SCRIPT_DIR}/bench_optlevel.cc" \
    -o "${BENCH}" \
    -O2 -g -fno-omit-frame-pointer -std=c++11 \
    > "${RESULTS_DIR}/compile.log" 2>&1

{
    echo "===== simpleperf stat ====="
    simpleperf stat "${BENCH}"
} > "${RESULTS_DIR}/simpleperf_stat.txt" 2>&1

{
    echo "===== simpleperf stat software counters ====="
    simpleperf stat -e task-clock,cpu-clock "${BENCH}"
} > "${RESULTS_DIR}/simpleperf_stat_software.txt" 2>&1

{
    echo "===== simpleperf record ====="
    simpleperf record -o "${PERF_DATA}" -- "${BENCH}"
} > "${RESULTS_DIR}/simpleperf_record.log" 2>&1

if [ -f "${PERF_DATA}" ]; then
    simpleperf report -i "${PERF_DATA}" \
        > "${RESULTS_DIR}/simpleperf_report.txt" 2>&1
else
    {
        echo "simpleperf record did not produce ${PERF_DATA}."
        echo "See simpleperf_record.log for the exact error."
    } > "${RESULTS_DIR}/simpleperf_report.txt"
fi

{
    echo "===== simpleperf result files ====="
    find "${RESULTS_DIR}" -maxdepth 1 -type f -print | sort
    echo ""
    echo "===== stat output ====="
    cat "${RESULTS_DIR}/simpleperf_stat.txt"
    echo ""
    echo "===== record output ====="
    cat "${RESULTS_DIR}/simpleperf_record.log"
    echo ""
    echo "===== report output ====="
    cat "${RESULTS_DIR}/simpleperf_report.txt"
} | tee "${RESULTS_DIR}/simpleperf_summary.txt"
