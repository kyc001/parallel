#!/usr/bin/env bash
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RESULTS_DIR="${ANN_DIR}/local_results/termux_arm64"
BIN_DIR="${RESULTS_DIR}/bin"

mkdir -p "${RESULTS_DIR}" "${BIN_DIR}"
cd "${ANN_DIR}" || exit 1

ANALYZE_SRC="${SCRIPT_DIR}/analyze.cc"
BENCH_SRC="${SCRIPT_DIR}/bench_optlevel.cc"

g++ -O0 -S -o "${RESULTS_DIR}/analyze_O0.s" "${ANALYZE_SRC}" -std=c++11
g++ -O1 -S -o "${RESULTS_DIR}/analyze_O1.s" "${ANALYZE_SRC}" -std=c++11
g++ -O2 -S -o "${RESULTS_DIR}/analyze_O2.s" "${ANALYZE_SRC}" -std=c++11
g++ -O3 -S -o "${RESULTS_DIR}/analyze_O3.s" "${ANALYZE_SRC}" -std=c++11

echo "=== Auto-vectorization report (O2) ===" > "${RESULTS_DIR}/vec_report.txt"
g++ -O2 -fopt-info-vec-all -S -o /dev/null "${ANALYZE_SRC}" -std=c++11 2>> "${RESULTS_DIR}/vec_report.txt"
echo "" >> "${RESULTS_DIR}/vec_report.txt"
echo "=== Auto-vectorization report (O3) ===" >> "${RESULTS_DIR}/vec_report.txt"
g++ -O3 -fopt-info-vec-all -S -o /dev/null "${ANALYZE_SRC}" -std=c++11 2>> "${RESULTS_DIR}/vec_report.txt"

g++ -O2 -o "${BIN_DIR}/analyze" "${ANALYZE_SRC}" -std=c++11
objdump -d "${BIN_DIR}/analyze" > "${RESULTS_DIR}/analyze_objdump.txt"

echo "===== ip_distance_serial (O0) =====" > "${RESULTS_DIR}/asm_analysis.txt"
grep -A 80 "ip_distance_serial" "${RESULTS_DIR}/analyze_O0.s" | head -85 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== ip_distance_serial (O2) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 80 "ip_distance_serial" "${RESULTS_DIR}/analyze_O2.s" | head -85 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== ip_distance_simd (O0) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 120 "ip_distance_simd" "${RESULTS_DIR}/analyze_O0.s" | head -125 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== ip_distance_simd (O2) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 120 "ip_distance_simd" "${RESULTS_DIR}/analyze_O2.s" | head -125 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== sq_l2_distance_simd (O2) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 80 "sq_l2_distance_simd" "${RESULTS_DIR}/analyze_O2.s" | head -85 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== adc_distance (O2) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 50 "adc_distance" "${RESULTS_DIR}/analyze_O2.s" | head -55 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== dot_sub_simd (O2) =====" >> "${RESULTS_DIR}/asm_analysis.txt"
grep -A 50 "dot_sub_simd" "${RESULTS_DIR}/analyze_O2.s" | head -55 >> "${RESULTS_DIR}/asm_analysis.txt"
echo "" >> "${RESULTS_DIR}/asm_analysis.txt"

echo "===== NEON Instruction Statistics =====" > "${RESULTS_DIR}/neon_stats.txt"

for opt in O0 O1 O2 O3; do
    echo "" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "--- $opt ---" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "Total lines:" >> "${RESULTS_DIR}/neon_stats.txt"
    wc -l "${RESULTS_DIR}/analyze_${opt}.s" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "NEON float ops (fmla/fmul/fadd/fsub):" >> "${RESULTS_DIR}/neon_stats.txt"
    grep -ciE '(fmla|fmul|fadd|fsub)' "${RESULTS_DIR}/analyze_${opt}.s" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "NEON load/store (ld1/st1/ldr q/str q):" >> "${RESULTS_DIR}/neon_stats.txt"
    grep -ciE '(ld1|st1|ldr.*q|str.*q)' "${RESULTS_DIR}/analyze_${opt}.s" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "NEON integer ops (umull/uabd/uadalp/addv):" >> "${RESULTS_DIR}/neon_stats.txt"
    grep -ciE '(umull|uabd|uadalp|addv)' "${RESULTS_DIR}/analyze_${opt}.s" >> "${RESULTS_DIR}/neon_stats.txt"
    echo "Scalar float ops (fmul s|fadd s|fsub s):" >> "${RESULTS_DIR}/neon_stats.txt"
    grep -ciE '(fmul.*s[0-9]|fadd.*s[0-9]|fsub.*s[0-9])' "${RESULTS_DIR}/analyze_${opt}.s" >> "${RESULTS_DIR}/neon_stats.txt"
done

echo "===== Auto-vectorization of serial code =====" > "${RESULTS_DIR}/autovec_analysis.txt"
echo "--- O2 level ---" >> "${RESULTS_DIR}/autovec_analysis.txt"
echo "Did compiler auto-vectorize ip_distance_serial at O2?" >> "${RESULTS_DIR}/autovec_analysis.txt"
grep -c "fmla" "${RESULTS_DIR}/analyze_O2.s" >> "${RESULTS_DIR}/autovec_analysis.txt" 2>&1
echo "NEON instructions in serial function at O2:" >> "${RESULTS_DIR}/autovec_analysis.txt"
sed -n '/ip_distance_serial/,/^_Z/p' "${RESULTS_DIR}/analyze_O2.s" | grep -iE '(fmla|ld1|fadd.*v)' >> "${RESULTS_DIR}/autovec_analysis.txt" 2>&1
echo "" >> "${RESULTS_DIR}/autovec_analysis.txt"

echo "--- O3 level ---" >> "${RESULTS_DIR}/autovec_analysis.txt"
echo "Did compiler auto-vectorize ip_distance_serial at O3?" >> "${RESULTS_DIR}/autovec_analysis.txt"
sed -n '/ip_distance_serial/,/^_Z/p' "${RESULTS_DIR}/analyze_O3.s" | grep -iE '(fmla|ld1|fadd.*v)' >> "${RESULTS_DIR}/autovec_analysis.txt" 2>&1
echo "" >> "${RESULTS_DIR}/autovec_analysis.txt"

echo "--- Instruction count comparison (O2) ---" >> "${RESULTS_DIR}/autovec_analysis.txt"
echo "ip_distance_serial instruction count:" >> "${RESULTS_DIR}/autovec_analysis.txt"
sed -n '/ip_distance_serial/,/\.size/p' "${RESULTS_DIR}/analyze_O2.s" | grep -c '^\s' >> "${RESULTS_DIR}/autovec_analysis.txt"
echo "ip_distance_simd instruction count:" >> "${RESULTS_DIR}/autovec_analysis.txt"
sed -n '/ip_distance_simd/,/\.size/p' "${RESULTS_DIR}/analyze_O2.s" | grep -c '^\s' >> "${RESULTS_DIR}/autovec_analysis.txt"

echo "===== Performance at different optimization levels =====" > "${RESULTS_DIR}/optlevel_perf.txt"
for opt in O0 O1 O2 O3; do
    echo "" >> "${RESULTS_DIR}/optlevel_perf.txt"
    echo "--- $opt ---" >> "${RESULTS_DIR}/optlevel_perf.txt"
    g++ -${opt} -o "${BIN_DIR}/bench_${opt}" "${BENCH_SRC}" -std=c++11
    "${BIN_DIR}/bench_${opt}" >> "${RESULTS_DIR}/optlevel_perf.txt" 2>&1
done

{
    echo ""
    echo "=========================================="
    echo "     ALL ANALYSIS RESULTS"
    echo "=========================================="
    echo ""
    echo ">>> [1] NEON Instruction Statistics <<<"
    cat "${RESULTS_DIR}/neon_stats.txt"
    echo ""
    echo ">>> [2] Auto-vectorization Analysis <<<"
    cat "${RESULTS_DIR}/autovec_analysis.txt"
    echo ""
    echo ">>> [3] Vectorization Report (compiler) <<<"
    cat "${RESULTS_DIR}/vec_report.txt"
    echo ""
    echo ">>> [4] Assembly: Key Functions <<<"
    cat "${RESULTS_DIR}/asm_analysis.txt"
    echo ""
    echo ">>> [5] Performance at Different Optimization Levels <<<"
    cat "${RESULTS_DIR}/optlevel_perf.txt"
    echo ""
    echo ">>> [6] objdump: ip_distance_simd <<<"
    grep -A 60 "ip_distance_simd" "${RESULTS_DIR}/analyze_objdump.txt" | head -65
    echo ""
    echo ">>> [7] objdump: sq_l2_distance_simd <<<"
    grep -A 60 "sq_l2_distance_simd" "${RESULTS_DIR}/analyze_objdump.txt" | head -65
    echo ""
    echo "=========================================="
    echo "     ANALYSIS COMPLETE"
    echo "=========================================="
} | tee "${RESULTS_DIR}/all_analysis_output.txt"
