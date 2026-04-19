"""Summarize full-score bench outputs into tables for the report."""
import csv
import glob
import os
import statistics

root = "bench_results/windows_i9_13900h/full_score"


def read_csv(path):
    rows = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for r in csv.DictReader(f):
            rows.append(r)
    return rows


def stats(vals):
    if not vals: return None, None
    if len(vals) == 1: return vals[0], 0.0
    return statistics.mean(vals), statistics.stdev(vals)


print("=" * 70)
print("Core-5 config, 5x repeats (mean +/- std, us)")
print("=" * 70)
for fname, label in [
    ("core5_baseline.csv", "baseline"),
    ("core5_flat.csv", "flat_avx2"),
    ("core5_sq.csv", "sq_p100"),
    ("core5_pq.csv", "pq_p1000"),
    ("core5_fastscan.csv", "fastscan_p1000"),
]:
    p = os.path.join(root, fname)
    if not os.path.exists(p): continue
    rows = read_csv(p)
    lats = [float(r["latency_us"]) for r in rows]
    recs = [float(r["recall"]) for r in rows]
    m_l, s_l = stats(lats)
    m_r, s_r = stats(recs)
    print(f"  {label:18s}  latency = {m_l:9.2f} +/- {s_l:7.2f} us   recall = {m_r:.5f}")

print()
print("=" * 70)
print("Recall@k sweep (k = 1, 10, 100)")
print("=" * 70)
for method in ["flat", "sq", "pq", "fastscan"]:
    print(f"  {method}:")
    for k in [1, 10, 100]:
        p = os.path.join(root, f"recall_{method}_k{k}.csv")
        if not os.path.exists(p): continue
        rows = read_csv(p)
        if not rows: continue
        r = rows[-1]
        print(f"    k={k:3d}  recall = {float(r['recall']):.5f}  latency = {float(r['latency_us']):.2f} us")

print()
print("=" * 70)
print("Scale sweep (N) -- latency (us)")
print("=" * 70)
for N in [10000, 25000, 50000, 100000]:
    print(f"  N={N}:")
    for mode in ["baseline", "flat", "sq", "pq"]:
        p = os.path.join(root, f"scale_{mode}_N{N}.csv")
        if not os.path.exists(p): continue
        rows = read_csv(p)
        if not rows: continue
        r = rows[-1]
        print(f"    {mode:10s}  lat = {float(r['latency_us']):9.2f}   recall = {float(r['recall']):.5f}")

print()
print("=" * 70)
print("FastScan full p-sweep (P-core pinned)")
print("=" * 70)
p = os.path.join(root, "fastscan_full_p_pcore.csv")
if os.path.exists(p):
    for r in read_csv(p):
        print(f"  p={int(r['p']):<7d}  recall = {float(r['recall']):.5f}   latency = {float(r['latency_us']):9.2f} us")

print()
print("=" * 70)
print("Flat-blocked (cache tile) vs flat_avx2")
print("=" * 70)
p = os.path.join(root, "flat_blocked.csv")
if os.path.exists(p):
    rows = read_csv(p)
    lats = [float(r["latency_us"]) for r in rows]
    m, s = stats(lats)
    print(f"  flat_blocked  mean = {m:9.2f} +/- {s:7.2f} us")

print()
print("=" * 70)
print("Top-k: priority_queue vs fixed_array")
print("=" * 70)
p = os.path.join(root, "topk_pinned.csv")
if os.path.exists(p):
    rows = read_csv(p)
    by_variant = {}
    for r in rows:
        v = r["variant"]
        by_variant.setdefault(v, []).append(float(r["per_query_us"]))
    for v, vals in by_variant.items():
        m, s = stats(vals)
        print(f"  {v:20s}  mean = {m:9.2f} +/- {s:7.2f} us/query")

print()
print("=" * 70)
print("SoA + blocking vs AoS argmin (encoding stage)")
print("=" * 70)
p = os.path.join(root, "soa_vs_aos_pinned.csv")
if os.path.exists(p):
    rows = read_csv(p)
    by_variant = {}
    for r in rows:
        v = r["variant"]
        by_variant.setdefault(v, []).append(float(r["ms"]))
    for v, vals in by_variant.items():
        m, s = stats(vals[1:])  # drop first (warmup) for both variants
        print(f"  {v:15s}  mean = {m:8.3f} +/- {s:7.3f} ms")
    if "aos" in by_variant and "soa_blocked" in by_variant:
        a = statistics.mean(by_variant["aos"][1:])
        b = statistics.mean(by_variant["soa_blocked"][1:])
        print(f"  speedup: {a / b:.3f}x")

print()
print("=" * 70)
print("Gather vs Shuffle (ADC lookup cost)")
print("=" * 70)
p = os.path.join(root, "gather_vs_shuffle_pinned.csv")
if os.path.exists(p):
    rows = read_csv(p)
    by_variant = {}
    for r in rows:
        v = r["variant"]
        by_variant.setdefault(v, []).append(float(r["per_row_ns"]))
    for v, vals in by_variant.items():
        m, s = stats(vals[1:])
        print(f"  {v:10s}  mean = {m:7.2f} +/- {s:6.2f} ns/row")
