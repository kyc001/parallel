# -*- coding: utf-8 -*-
"""
Cross-platform SQ/PQ tradeoff plots for Lab2 report.
Data: DEEP100K, k=10, 2000 queries.
Output: bench_results/windows_i9_13900h/plots/*.png
"""

from pathlib import Path
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

matplotlib.rcParams["font.family"] = "DejaVu Sans"
matplotlib.rcParams["axes.unicode_minus"] = False

OUT_DIR = Path(__file__).parent / "bench_results/windows_i9_13900h/plots"
OUT_DIR.mkdir(parents=True, exist_ok=True)

COLORS = {
    "i9 AVX2": "#d62728",
    "Kunpeng NEON": "#1f77b4",
    "Tablet NEON": "#2ca02c",
}

MARKERS = {
    "i9 AVX2": "o",
    "Kunpeng NEON": "s",
    "Tablet NEON": "^",
}

# -------- SQ: (recall, latency_us) per p --------
SQ_DATA = {
    "i9 AVX2": {
        100: (0.99995, 427.01),
        200: (0.99995, 469.31),
        500: (0.99995, 609.16),
        1000: (0.99995, 808.63),
        2000: (0.99995, 1159.41),
        5000: (0.99995, 2368.87),
        10000: (0.99995, 4066.32),
        50000: (0.99995, 11572.16),
        100000: (0.99995, 18507.05),
    },
    "Kunpeng NEON": {
        100: (0.99995, 2422.68),
        200: (0.99995, 2457.0),
        500: (0.99995, 2701.90),
        1000: (0.99995, 2911.0),
        2000: (0.99995, 3319.0),
        5000: (0.99995, 5391.92),
        10000: (0.99995, 7845.0),
        50000: (0.99995, 29410.0),
        100000: (0.99995, 40260.66),
    },
    "Tablet NEON": {
        100: (0.99995, 1087.87),
        200: (0.99995, 1387.96),
        500: (0.99995, 1856.89),
        1000: (0.99995, 2399.20),
        2000: (0.99995, 3449.92),
        5000: (0.99995, 5649.49),
        10000: (0.99995, 10120.0),
        50000: (0.99995, 30940.0),
        100000: (0.99995, 45187.62),
    },
}

# -------- PQ: (recall, latency_us) per p --------
PQ_DATA = {
    "i9 AVX2": {
        100: (0.70860, 398.53),
        200: (0.83360, 665.06),
        500: (0.94595, 838.17),
        1000: (0.98330, 761.99),
        2000: (0.99550, 1640.21),
        5000: (0.99965, 3042.08),
        10000: (0.99995, 3344.43),
        50000: (0.99995, 13508.39),
        100000: (0.99995, 15893.12),
    },
    "Kunpeng NEON": {
        100: (0.70930, 1215.0),
        200: (0.83835, 1288.0),
        500: (0.94740, 1566.47),
        1000: (0.98355, 1984.35),
        2000: (0.99550, 2693.58),
        5000: (0.99980, 4850.0),
        10000: (0.99995, 7730.0),
        50000: (0.99995, 22410.0),
        100000: (0.99995, 42163.42),
    },
    "Tablet NEON": {
        100: (0.70930, 842.05),
        200: (0.83835, 924.83),
        500: (0.94740, 1178.43),
        1000: (0.98355, 1520.52),
        2000: (0.99550, 2488.09),
        5000: (0.99980, 4180.43),
        10000: (0.99995, 7268.55),
        50000: (0.99995, 18940.0),
        100000: (0.99995, 34630.02),
    },
}

# i9 reference lines for chart 3
FLAT_I9 = 1756.11
BASELINE_I9 = 4571.62
FASTSCAN_I9 = 541.69


# =============================================================
# 图 1: SQ tradeoff（双子图：latency vs p + recall 稳定性）
# =============================================================
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for plat, data in SQ_DATA.items():
    ps = sorted(data.keys())
    lats = [data[p][1] for p in ps]
    ax1.plot(
        ps,
        lats,
        marker=MARKERS[plat],
        color=COLORS[plat],
        label=plat,
        markersize=8,
        linewidth=2,
    )

ax1.set_xscale("log")
ax1.set_yscale("log")
ax1.set_xlabel("rerank_p (log scale)")
ax1.set_ylabel("Latency (μs, log scale)")
ax1.set_title("SQ-SIMD: Latency vs rerank_p")
ax1.legend(loc="upper left")
ax1.grid(True, which="both", alpha=0.3)

for plat, data in SQ_DATA.items():
    ps = sorted(data.keys())
    recs = [data[p][0] for p in ps]
    ax2.plot(
        ps,
        recs,
        marker=MARKERS[plat],
        color=COLORS[plat],
        label=plat,
        markersize=8,
        linewidth=2,
    )

ax2.set_xscale("log")
ax2.set_xlabel("rerank_p (log scale)")
ax2.set_ylabel("Recall@10")
ax2.set_title("SQ-SIMD: Recall is constant at 0.99995")
ax2.set_ylim(0.99, 1.001)
ax2.axhline(0.99995, color="gray", linestyle="--", alpha=0.6, label="recall=0.99995")
ax2.legend(loc="lower right")
ax2.grid(True, which="both", alpha=0.3)
ax2.ticklabel_format(useOffset=False, axis="y")

plt.suptitle("SQ-SIMD across 3 platforms (DEEP100K, k=10, 2000 queries)", fontsize=13)
plt.tight_layout()
plt.savefig(OUT_DIR / "sq_tradeoff_3platforms.png", dpi=150, bbox_inches="tight")
plt.close()
print(f"[OK] {OUT_DIR / 'sq_tradeoff_3platforms.png'}")


# =============================================================
# 图 2: PQ tradeoff（只标低 p 点，避免重叠）
# =============================================================
fig, ax = plt.subplots(figsize=(10, 6))

LABEL_P = {100, 500, 1000}
OFFSETS = {
    ("i9 AVX2", 100): (8, -4),
    ("i9 AVX2", 500): (8, -10),
    ("i9 AVX2", 1000): (8, 4),
    ("Kunpeng NEON", 100): (8, -4),
    ("Kunpeng NEON", 500): (8, -10),
    ("Kunpeng NEON", 1000): (8, 4),
    ("Tablet NEON", 100): (8, -4),
    ("Tablet NEON", 500): (8, -10),
    ("Tablet NEON", 1000): (8, 4),
}

for plat, data in PQ_DATA.items():
    ps = sorted(data.keys())
    recs = [data[p][0] for p in ps]
    lats = [data[p][1] for p in ps]

    ax.plot(
        lats,
        recs,
        marker=MARKERS[plat],
        color=COLORS[plat],
        label=plat,
        markersize=8,
        linewidth=2,
    )

    for p in ps:
        if p in LABEL_P:
            r, l = data[p]
            ax.annotate(
                f"p={p}",
                (l, r),
                textcoords="offset points",
                xytext=OFFSETS[(plat, p)],
                fontsize=8,
                color=COLORS[plat],
            )

ax.set_xscale("log")
ax.set_xlabel("Latency (μs, log scale)")
ax.set_ylabel("Recall@10")
ax.set_title("PQ-SIMD: Latency-Recall Tradeoff across 3 platforms (M=8, dsub=12)")
ax.legend(loc="lower right")
ax.grid(True, which="both", alpha=0.3)

plt.tight_layout()
plt.savefig(OUT_DIR / "pq_tradeoff_3platforms.png", dpi=150, bbox_inches="tight")
plt.close()
print(f"[OK] {OUT_DIR / 'pq_tradeoff_3platforms.png'}")


# =============================================================
# 图 3: SQ vs PQ on i9 (with flat/baseline reference)
# =============================================================
fig, ax = plt.subplots(figsize=(10, 6))

sq = SQ_DATA["i9 AVX2"]
ps_sq = sorted(sq.keys())
ax.plot(
    [sq[p][0] for p in ps_sq],
    [sq[p][1] for p in ps_sq],
    marker="o",
    color="#d62728",
    label="SQ (i9 AVX2)",
    markersize=8,
    linewidth=2,
)

pq = PQ_DATA["i9 AVX2"]
ps_pq = sorted(pq.keys())
ax.plot(
    [pq[p][0] for p in ps_pq],
    [pq[p][1] for p in ps_pq],
    marker="s",
    color="#ff7f0e",
    label="PQ (i9 AVX2)",
    markersize=8,
    linewidth=2,
)

ax.axhline(FLAT_I9, color="gray", linestyle="--", alpha=0.6)
ax.text(0.71, FLAT_I9 * 1.03, f"flat\n{FLAT_I9:.0f}μs", va="bottom", color="gray", fontsize=9)

ax.axhline(BASELINE_I9, color="gray", linestyle="--", alpha=0.6)
ax.text(0.71, BASELINE_I9 * 1.03, f"baseline\n{BASELINE_I9:.0f}μs", va="bottom", color="gray", fontsize=9)

ax.axhline(FASTSCAN_I9, color="#d62728", linestyle="--", alpha=0.65)
ax.text(0.965, FASTSCAN_I9 * 1.03, f"fastscan\n{FASTSCAN_I9:.0f}μs", ha="right", va="bottom", color="#d62728", fontsize=9)

ax.set_yscale("log")
ax.set_xlabel("Recall@10")
ax.set_ylabel("Latency (μs, log scale)")
ax.set_title("SQ vs PQ Tradeoff on i9-13900H AVX2")
ax.legend(loc="upper right")
ax.grid(True, which="both", alpha=0.3)

plt.tight_layout()
plt.savefig(OUT_DIR / "sq_vs_pq_i9.png", dpi=150, bbox_inches="tight")
plt.close()
print(f"[OK] {OUT_DIR / 'sq_vs_pq_i9.png'}")


# =============================================================
# 图 4: Core methods bar chart
# =============================================================
methods = ["baseline", "flat", "sq@100", "pq@1000"]
data_bar = {
    "i9 AVX2": [4572, 1756, 427, 762],
    "Tablet NEON": [8283, 2597, 1088, 1521],
    "Kunpeng NEON": [16121, 5821, 2423, 1984],
}

x = np.arange(len(methods))
w = 0.27

fig, ax = plt.subplots(figsize=(11, 6))

for i, (plat, vals) in enumerate(data_bar.items()):
    offset = (i - 1) * w
    bars = ax.bar(x + offset, vals, w, label=plat, color=COLORS[plat])

    for b, v in zip(bars, vals):
        ax.text(
            b.get_x() + b.get_width() / 2,
            v * 1.03,
            str(v),
            ha="center",
            va="bottom",
            fontsize=9,
        )

ax.set_yscale("log")
ax.set_xticks(x)
ax.set_xticklabels(methods)
ax.set_ylabel("Latency (μs, log scale)")
ax.set_title("Core Methods Latency across 3 platforms")
ax.legend(loc="upper right")
ax.grid(True, axis="y", which="both", alpha=0.3)

plt.tight_layout()
plt.savefig(OUT_DIR / "core_methods_bar.png", dpi=150, bbox_inches="tight")
plt.close()
print(f"[OK] {OUT_DIR / 'core_methods_bar.png'}")
