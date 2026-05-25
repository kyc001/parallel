#!/usr/bin/env python3
"""Generate compact report-only figures from measured CSV files."""
from __future__ import annotations

import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.font_manager as fm
import matplotlib.pyplot as plt
import numpy as np

BASE = Path(__file__).resolve().parent.parent
RESULTS = BASE / "results"
OUT = BASE / "report" / "fig"


def setup_style() -> None:
    fonts = [
        f.name
        for f in fm.fontManager.ttflist
        if any(
            key in f.name.lower()
            for key in ["microsoft yahei", "simhei", "simsun", "noto sans cjk", "wenquanyi"]
        )
    ]
    if fonts:
        plt.rcParams["font.sans-serif"] = [fonts[0]]
    plt.rcParams.update(
        {
            "font.size": 9,
            "axes.unicode_minus": False,
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.04,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def f(row: dict[str, str], key: str) -> float:
    return float(row[key])


def require_rows(rows: list[dict[str, str]], context: str) -> list[dict[str, str]]:
    if not rows:
        raise ValueError(f"missing rows for {context}")
    return rows


def plot_scheduler_compact(local_rows: list[dict[str, str]]) -> None:
    algos = [
        ("flat", "Flat"),
        ("sq", "SQ"),
        ("pq", "PQ"),
        ("fastscan", "FastScan"),
        ("ivf", "IVF"),
        ("ivfpq_local", "IVF-PQ"),
    ]
    strategies = [
        ("omp_inter", "OMP"),
        ("pthread_static_inter", "Static"),
        ("pthread_dynamic_inter", "Dynamic"),
        ("pthread_pool_inter", "Pool"),
    ]

    fig, ax = plt.subplots(figsize=(7.4, 3.2))
    x = np.arange(len(algos))
    width = 0.18
    colors = ["#4C72B0", "#55A868", "#C44E52", "#8172B2"]

    for idx, (strategy, label) in enumerate(strategies):
        values: list[float] = []
        for algo, _ in algos:
            rows = [
                r
                for r in local_rows
                if r["algorithm"] == algo
                and r["granularity"] == "inter"
                and int(r["threads"]) == 16
                and r["strategy"] == strategy
                and f(r, "recall") >= 0.95
            ]
            rows = require_rows(rows, f"scheduler {algo}/{strategy}/t16")
            values.append(min((f(r, "latency_us") for r in rows), default=np.nan))
        ax.bar(x + (idx - 1.5) * width, values, width, label=label, color=colors[idx])

    ax.set_ylabel("Latency / us")
    ax.set_xticks(x)
    ax.set_xticklabels([label for _, label in algos])
    ax.set_title("16-thread inter-query scheduler comparison on i9-13900H")
    ax.grid(True, axis="y", alpha=0.25)
    ax.legend(ncol=4, frameon=False, loc="upper right")
    fig.savefig(OUT / "scheduler_compact.pdf")
    plt.close(fig)


def plot_speedup_compact(local_rows: list[dict[str, str]]) -> None:
    algos = ["flat", "sq", "pq", "fastscan", "ivf", "ivfpq_local"]
    labels = ["Flat", "SQ", "PQ", "FastScan", "IVF", "IVF-PQ"]
    fig, ax = plt.subplots(figsize=(6.8, 3.2))
    colors = plt.cm.tab10(np.linspace(0, 1, len(algos)))

    for algo, label, color in zip(algos, labels, colors):
        by_thread: dict[int, list[dict[str, str]]] = {}
        for r in local_rows:
            if (
                r["algorithm"] == algo
                and r["granularity"] == "inter"
                and f(r, "recall") >= 0.95
            ):
                by_thread.setdefault(int(r["threads"]), []).append(r)
        if 1 not in by_thread:
            raise ValueError(f"missing speedup baseline for {algo}")
        best = {t: min(rows, key=lambda r: f(r, "latency_us")) for t, rows in by_thread.items()}
        base = f(best[1], "latency_us")
        threads = sorted(t for t in best if t in {1, 2, 4, 8, 16})
        speedup = [base / f(best[t], "latency_us") for t in threads]
        ax.plot(threads, speedup, marker="o", linewidth=1.5, label=label, color=color)

    ax.plot([1, 2, 4, 8, 16], [1, 2, 4, 8, 16], "k--", alpha=0.35, label="Ideal")
    ax.set_xscale("log", base=2)
    ax.set_xticks([1, 2, 4, 8, 16])
    ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.set_xlabel("Threads")
    ax.set_ylabel("Speedup vs best 1T")
    ax.set_title("Inter-query scaling on i9-13900H")
    ax.grid(True, alpha=0.25)
    ax.legend(ncol=3, frameon=False, fontsize=8)
    fig.savefig(OUT / "speedup_compact.pdf")
    plt.close(fig)


def plot_inter_intra_compact(local_rows: list[dict[str, str]]) -> None:
    algos = ["flat", "sq", "pq", "fastscan", "ivf", "ivfpq_local"]
    labels = ["Flat", "SQ", "PQ", "FastScan", "IVF", "IVF-PQ"]
    inter_values: list[float] = []
    intra_values: list[float] = []
    for algo in algos:
        inter = [
            r
            for r in local_rows
            if r["algorithm"] == algo
            and r["granularity"] == "inter"
            and int(r["threads"]) == 16
            and f(r, "recall") >= 0.95
        ]
        inter = require_rows(inter, f"inter/intra inter {algo}/t16")
        intra = [
            r
            for r in local_rows
            if r["algorithm"] == algo
            and r["granularity"] == "intra"
            and int(r["threads"]) == 16
            and f(r, "recall") >= 0.95
        ]
        intra = require_rows(intra, f"inter/intra intra {algo}/t16")
        inter_values.append(min((f(r, "latency_us") for r in inter), default=np.nan))
        intra_values.append(min((f(r, "latency_us") for r in intra), default=np.nan))

    fig, ax = plt.subplots(figsize=(6.8, 3.0))
    x = np.arange(len(algos))
    w = 0.35
    bars1 = ax.bar(x - w / 2, inter_values, w, label="Inter-query", color="#4C72B0")
    bars2 = ax.bar(x + w / 2, intra_values, w, label="Intra-query", color="#DD8452")
    for bar in bars1:
        h = bar.get_height()
        if np.isfinite(h):
            ax.text(bar.get_x() + bar.get_width() / 2, h * 1.04, f"{h:.0f}", ha="center", va="bottom", fontsize=7)
    for bar in bars2:
        h = bar.get_height()
        if np.isfinite(h):
            ax.text(bar.get_x() + bar.get_width() / 2, h * 1.04, f"{h:.0f}", ha="center", va="bottom", fontsize=7)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Latency / us")
    ax.set_yscale("log")
    ax.set_ylim(40, 8000)
    ax.set_title("Best 16-thread inter-query vs intra-query latency (log scale)")
    ax.grid(True, axis="y", which="both", alpha=0.25)
    ax.legend(frameon=False)
    fig.savefig(OUT / "inter_intra_compact.pdf")
    plt.close(fig)


def plot_cross_platform_compact(
    local_rows: list[dict[str, str]], arm_rows: list[dict[str, str]]
) -> None:
    specs = [
        ("flat", "flat", "Flat"),
        ("sq", "sq", "SQ"),
        ("pq", "pq", "PQ"),
        ("fastscan", "fastscan", "FastScan"),
        ("ivf", "ivf", "IVF"),
        ("ivfpq_local", "ivfpq_local", "IVF-PQ"),
    ]
    x86: list[float] = []
    arm: list[float] = []
    labels: list[str] = []
    for local_algo, arm_algo, label in specs:
        lrows = [
            r
            for r in local_rows
            if r["algorithm"] == local_algo
            and r["granularity"] == "inter"
            and int(r["threads"]) == 16
            and f(r, "recall") >= 0.95
            and (local_algo != "ivfpq_local" or r.get("mode", "") in ("local", "", None))
        ]
        arows = [
            r
            for r in arm_rows
            if r["algo"] == arm_algo
            and r["strategy"].endswith("_inter")
            and int(r["threads"]) == 16
            and f(r, "recall") >= 0.95
        ]
        if not lrows or not arows:
            continue
        x86.append(min(f(r, "latency_us") for r in lrows))
        arm.append(min(f(r, "latency_us") for r in arows))
        labels.append(label)

    fig, ax = plt.subplots(figsize=(7.2, 3.2))
    x = np.arange(len(labels))
    w = 0.35
    ax.bar(x - w / 2, x86, w, label="x86 AVX2", color="#4C72B0")
    ax.bar(x + w / 2, arm, w, label="ARM NEON", color="#DD8452")
    for i, (lx, la) in enumerate(zip(x86, arm)):
        ax.annotate(f"{la / lx:.1f}x", (x[i], max(lx, la)), ha="center", va="bottom", fontsize=8)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Latency / us")
    ax.set_title("16-thread inter-query cross-platform latency")
    ax.grid(True, axis="y", alpha=0.25)
    ax.legend(frameon=False)
    fig.savefig(OUT / "cross_platform_compact.pdf")
    plt.close(fig)


def plot_tradeoff_curves(tradeoff_rows: list[dict[str, str]]) -> None:
    # PQ sweep was produced during the high-recall rerun; these values are also
    # recorded in profiling/clock_and_assembly_analysis.md.
    pq_points = [
        (100, 0.70780, 85.43275),
        (300, 0.89185, 99.45),
        (500, 0.94575, 101.70),
        (1000, 0.98335, 136.47185),
        (2000, 0.99560, 183.35245),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(10.2, 3.0))

    ax = axes[0]
    ax.plot([p[2] for p in pq_points], [p[1] for p in pq_points], marker="o", color="#4C72B0")
    for p, recall, latency in pq_points:
        ax.annotate(f"p={p}", (latency, recall), fontsize=7, xytext=(3, 3), textcoords="offset points")
    ax.axhline(0.95, color="#C44E52", linestyle="--", linewidth=1)
    ax.set_title("PQ top-p sweep")
    ax.set_xlabel("Latency / us")
    ax.set_ylabel("Recall@10")
    ax.grid(True, alpha=0.25)

    ax = axes[1]
    ivf_rows = sorted(
        [r for r in tradeoff_rows if r["algorithm"] == "ivf"], key=lambda r: int(r["nprobe"])
    )
    ax.plot(
        [f(r, "latency_us") for r in ivf_rows],
        [f(r, "recall") for r in ivf_rows],
        marker="o",
        color="#55A868",
    )
    for r in ivf_rows:
        ax.annotate(
            f"np={r['nprobe']}",
            (f(r, "latency_us"), f(r, "recall")),
            fontsize=7,
            xytext=(3, 3),
            textcoords="offset points",
        )
    ax.axhline(0.95, color="#C44E52", linestyle="--", linewidth=1)
    ax.set_title("IVF nprobe sweep")
    ax.set_xlabel("Latency / us")
    ax.grid(True, alpha=0.25)

    ax = axes[2]
    for mode, color, ls in [("global", "#8172B2", "--"), ("local", "#DD8452", "-")]:
        rows = sorted(
            [r for r in tradeoff_rows if r["algorithm"] == "ivfpq" and r["mode"] == mode],
            key=lambda r: int(r["nprobe"]),
        )
        ax.plot(
            [f(r, "latency_us") for r in rows],
            [f(r, "recall") for r in rows],
            marker="o",
            label=mode,
            color=color,
            linestyle=ls,
            linewidth=1.8,
        )
        for r in rows:
            ax.annotate(
                f"np={r['nprobe']}",
                (f(r, "latency_us"), f(r, "recall")),
                fontsize=7,
                xytext=(3, 3),
                textcoords="offset points",
            )
    ax.axhline(0.95, color="#C44E52", linestyle="--", linewidth=1)
    ax.set_title("IVF-PQ nprobe sweep")
    ax.set_xlabel("Latency / us")
    ax.legend(frameon=False)
    ax.grid(True, alpha=0.25)

    fig.suptitle("Recall-latency trade-off curves", y=1.04)
    fig.savefig(OUT / "tradeoff_curves.pdf")
    plt.close(fig)


def plot_hnsw_ef_sweep() -> None:
    def load_ef(path):
        data = []
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                kv = {}
                for part in line.split(","):
                    if "=" in part:
                        k, v = part.split("=", 1)
                        kv[k.strip()] = v.strip()
                if "ef" in kv and "recall" in kv and "latency_us" in kv:
                    data.append((int(kv["ef"]), float(kv["recall"]), float(kv["latency_us"])))
        return data

    i9_data = load_ef(RESULTS / "hnsw_ef_sweep.txt")
    arm_path = RESULTS / "kunpeng" / "hnsw_ef_sweep.txt"
    arm_data = load_ef(arm_path) if arm_path.exists() else []

    fig, ax = plt.subplots(figsize=(5.5, 3.2))
    ax.plot([d[2] for d in i9_data], [d[1] for d in i9_data],
            marker="o", color="#4C72B0", linewidth=1.5, label="i9-13900H")
    for ef, recall, lat in i9_data:
        ax.annotate(f"ef={ef}", (lat, recall), fontsize=7, xytext=(4, 4), textcoords="offset points")
    if arm_data:
        ax.plot([d[2] for d in arm_data], [d[1] for d in arm_data],
                marker="s", color="#DD8452", linewidth=1.5, label="Kunpeng 920")
        for ef, recall, lat in arm_data:
            ax.annotate(f"ef={ef}", (lat, recall), fontsize=7, xytext=(4, -10), textcoords="offset points")
    ax.axhline(0.95, color="#C44E52", linestyle="--", linewidth=1, alpha=0.7)
    ax.set_xlabel("Latency / us")
    ax.set_ylabel("Recall@10")
    ax.set_title("HNSW ef sweep (single thread)")
    ax.grid(True, alpha=0.25)
    ax.legend(frameon=False)
    fig.savefig(OUT / "hnsw_ef_curve.pdf")
    plt.close(fig)


def main() -> None:
    setup_style()
    OUT.mkdir(parents=True, exist_ok=True)
    local_rows = read_csv(RESULTS / "local_summary.csv")
    arm_rows = read_csv(RESULTS / "kunpeng" / "arm_neon_summary.csv")
    tradeoff_rows = read_csv(RESULTS / "local_tradeoff.csv")
    plot_scheduler_compact(local_rows)
    plot_speedup_compact(local_rows)
    plot_inter_intra_compact(local_rows)
    plot_cross_platform_compact(local_rows, arm_rows)
    plot_tradeoff_curves(tradeoff_rows)
    plot_hnsw_ef_sweep()
    print("generated compact report figures")


if __name__ == "__main__":
    main()
