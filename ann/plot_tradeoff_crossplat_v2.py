# plot_tradeoff_crossplat_v2.py — 只替换图5、图6 两个函数
import matplotlib.pyplot as plt
import numpy as np

# ===== 数据 =====
SQ = {
    "i9 AVX2":      {"p":[100,200,500,1000,2000,5000,10000,50000,100000],
                     "lat":[427.01,469.31,609.16,808.63,1159.41,2368.87,4066.32,11572.16,18507.05],
                     "rec":[0.99995]*9},
    "Kunpeng NEON": {"p":[100,200,500,1000,2000,5000,10000,50000,100000],
                     "lat":[2422.68,2483.10,2701.90,2924.15,3257.93,5391.92,7726.07,27891.44,40260.66],
                     "rec":[0.99995]*9},
    "Tablet NEON":  {"p":[100,200,500,1000,2000,5000,10000,50000,100000],
                     "lat":[1087.87,1387.96,1856.89,2399.20,3449.92,5649.49,10148.25,25889.76,45187.62],
                     "rec":[0.99995]*9},
}
PQ = {
    "i9 AVX2":      {"p":[100,200,500,1000,2000,5000,10000,50000,100000],
                     "lat":[398.53,665.06,838.17,761.99,1640.21,3042.08,3344.43,13508.39,15893.12],
                     "rec":[0.70860,0.83360,0.94595,0.98330,0.99550,0.99965,0.99995,0.99995,0.99995]},
    "Kunpeng NEON": {"p":[100,500,1000,2000,5000,10000,100000],
                     "lat":[1256.66,1566.47,1984.35,2693.58,5273.58,7917.06,42163.42],
                     "rec":[0.83835,0.94740,0.98355,0.99550,0.99980,0.99995,0.99995]},
    "Tablet NEON":  {"p":[100,500,1000,2000,5000,10000,100000],
                     "lat":[842.05,1178.43,1520.52,2488.09,4180.43,7268.55,34630.02],
                     "rec":[0.70930,0.94740,0.98355,0.99550,0.99980,0.99995,0.99995]},
}
COLORS = {"i9 AVX2":"crimson", "Kunpeng NEON":"steelblue", "Tablet NEON":"seagreen"}
MARKERS = {"i9 AVX2":"o", "Kunpeng NEON":"s", "Tablet NEON":"^"}

# ===== 图5: SQ —— 改成单图 latency-vs-p，recall 作为 title annotation =====
def plot_sq_single():
    fig, ax = plt.subplots(figsize=(9, 5.5))
    for plat, d in SQ.items():
        ax.plot(d["p"], d["lat"], marker=MARKERS[plat], color=COLORS[plat],
                label=plat, linewidth=2, markersize=7)
    ax.set_xscale("log"); ax.set_yscale("log")
    ax.set_xlabel("rerank_p (log scale)"); ax.set_ylabel("Latency (μs, log scale)")
    ax.set_title("SQ-SIMD: Latency vs rerank_p across 3 platforms\n"
                 "(DEEP100K, k=10, 2000 queries — Recall ≡ 0.99995 on all configs)")
    ax.grid(True, which="both", alpha=0.3); ax.legend(loc="upper left")
    # 在图内右下角加说明框
    ax.text(0.98, 0.05,
            "Recall is constant (0.99995) across\nall p and all platforms —\nSQ quantization is near-lossless.",
            transform=ax.transAxes, ha="right", va="bottom",
            fontsize=9, bbox=dict(boxstyle="round", fc="lightyellow", ec="gray", alpha=0.85))
    plt.tight_layout()
    plt.savefig("sq_tradeoff_3platforms.png", dpi=150)
    plt.close()

# ===== 图6: PQ —— 每条曲线只标 2 个关键 p 点，且标签 offset 错开避免重叠 =====
def plot_pq_tradeoff():
    fig, ax = plt.subplots(figsize=(10, 6))
    # 每个平台只标 p=100 和 p=1000（甜点边界），用不同 offset
    LABEL_OFFSETS = {
        "i9 AVX2":      {100: (6, -14), 1000: (6, 6)},
        "Kunpeng NEON": {100: (-8, -18), 1000: (-8, 10)},
        "Tablet NEON":  {100: (6, 10), 1000: (-10, -16)},
    }
    for plat, d in PQ.items():
        ax.plot(d["lat"], d["rec"], marker=MARKERS[plat], color=COLORS[plat],
                label=plat, linewidth=2, markersize=8)
        for p, lat, rec in zip(d["p"], d["lat"], d["rec"]):
            if p in LABEL_OFFSETS[plat]:
                dx, dy = LABEL_OFFSETS[plat][p]
                ax.annotate(f"p={p}", (lat, rec), xytext=(dx, dy),
                            textcoords="offset points", fontsize=8.5,
                            color=COLORS[plat], fontweight="bold")
    ax.set_xscale("log")
    ax.set_xlabel("Latency (μs, log scale)"); ax.set_ylabel("Recall@10")
    ax.set_title("PQ-SIMD: Latency-Recall Tradeoff across 3 platforms (M=8, dsub=12)")
    ax.grid(True, which="both", alpha=0.3); ax.legend(loc="lower right")
    ax.set_ylim(0.68, 1.01)
    plt.tight_layout()
    plt.savefig("pq_tradeoff_3platforms.png", dpi=150)
    plt.close()

if __name__ == "__main__":
    plot_sq_single()
    plot_pq_tradeoff()
    print("done: sq_tradeoff_3platforms.png, pq_tradeoff_3platforms.png")