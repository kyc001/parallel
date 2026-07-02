from __future__ import annotations

import csv
from pathlib import Path

try:
    import matplotlib.pyplot as plt
except ModuleNotFoundError:  # Keep report generation usable on bare Python.
    plt = None


ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"
FIG = ROOT / "fig"


def read_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def read_opq_rows() -> list[dict[str, str]]:
    rows = read_rows(RESULTS / "opq_ivfpq_rerun.csv")
    rows.extend(read_rows(RESULTS / "opq_ivfpq_m_sweep_rerun.csv"))
    if not rows:
        rows = read_rows(RESULTS / "opq_ivfpq.csv")
        rows.extend(read_rows(RESULTS / "opq_ivfpq_m_sweep.csv"))
    return rows


def as_float(row: dict[str, str], key: str, default: float = 0.0) -> float:
    try:
        value = row.get(key, "")
        return float(value) if value not in ("", None) else default
    except ValueError:
        return default


def online_latency_us(row: dict[str, str]) -> float:
    latency = as_float(row, "latency_us")
    scan = as_float(row, "scan_ms")
    rerank = as_float(row, "rerank_ms")
    query_n = as_float(row, "query_n")
    if scan > 0 and rerank > 0 and query_n > 0:
        derived = (scan + rerank) * 1000.0 / query_n
        # New rerun CSV already writes this value into latency_us; old CSV needs
        # the derived steady online latency for plotting.
        if abs(derived - latency) > max(5.0, latency * 0.05):
            return derived
    return latency


def write_opq_steady_csv(rows: list[dict[str, str]]) -> None:
    if not rows:
        return
    out = RESULTS / "opq_ivfpq_steady.csv"
    fields = [
        "method", "query_n", "nlist", "nprobe", "M", "rerank_p",
        "recall_at_10", "recall_at_100", "online_latency_us",
        "wall_latency_us", "build_ms", "train_ms", "rotate_ms",
        "scan_ms", "rerank_ms", "index_bytes", "repeat_count", "warmup_n",
    ]
    with out.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for r in rows:
            writer.writerow({
                "method": r.get("method", ""),
                "query_n": r.get("query_n", ""),
                "nlist": r.get("nlist", ""),
                "nprobe": r.get("nprobe", ""),
                "M": r.get("M", ""),
                "rerank_p": r.get("rerank_p", ""),
                "recall_at_10": r.get("recall_at_10", ""),
                "recall_at_100": r.get("recall_at_100", ""),
                "online_latency_us": f"{online_latency_us(r):.5f}",
                "wall_latency_us": r.get("wall_latency_us", r.get("latency_us", "")),
                "build_ms": r.get("build_ms", ""),
                "train_ms": r.get("train_ms", ""),
                "rotate_ms": r.get("rotate_ms", ""),
                "scan_ms": r.get("scan_ms", ""),
                "rerank_ms": r.get("rerank_ms", ""),
                "index_bytes": r.get("index_bytes", ""),
                "repeat_count": r.get("repeat_count", ""),
                "warmup_n": r.get("warmup_n", ""),
            })


def plot_unified_tradeoff() -> None:
    rows = read_rows(RESULTS / "unified_existing_results.csv")
    points = [
        r
        for r in rows
        if as_float(r, "latency_us") > 0 and as_float(r, "recall_at_10") > 0
    ]
    if not points:
        return
    FIG.mkdir(parents=True, exist_ok=True)
    with (FIG / "unified_latency_recall_points.tex").open("w", encoding="utf-8") as f:
        f.write("% latency recall label\n")
        for r in points:
            f.write(
                f"{as_float(r, 'latency_us'):.5f} "
                f"{as_float(r, 'recall_at_10'):.5f} "
                f"{{{r['method']}}}\n"
            )
    if plt is None:
        return
    label_offsets = {
        "GPU-cublas-tree": (-78, -18),
        "MPI-Block-HNSW-8x2": (-72, -16),
        "SQ-AVX2-p100": (-36, 17),
        "GPU-CPU-hybrid-p100": (-38, -30),
        "Flat-AVX2": (8, -8),
        "Flat-serial": (5, -12),
        "IVF-PQ-MPI-4x2": (6, 8),
        "IVF-PQ-adaptive": (7, -16),
        "HNSW-baseline": (6, -12),
    }
    plt.figure(figsize=(6.8, 4.1))
    for r in points:
        recall = as_float(r, "recall_at_10")
        latency = as_float(r, "latency_us")
        plt.scatter(latency, recall, s=46)
        dx, dy = label_offsets.get(r["method"], (5, 4))
        plt.annotate(
            r["method"],
            (latency, recall),
            textcoords="offset points",
            xytext=(dx, dy),
            fontsize=7,
            bbox={"boxstyle": "round,pad=0.15", "fc": "white", "ec": "none", "alpha": 0.82},
        )
    plt.xscale("log")
    plt.xlabel("Latency (us/query, log scale)")
    plt.ylabel("Recall@10")
    plt.ylim(0.957, 1.006)
    plt.grid(True, which="both", alpha=0.28)
    plt.tight_layout()
    plt.savefig(FIG / "unified_latency_recall.pdf")
    plt.close()


def plot_opq_tradeoff() -> None:
    rows = read_opq_rows()
    if not rows:
        return
    write_opq_steady_csv(rows)
    FIG.mkdir(parents=True, exist_ok=True)
    for methods, out_name in [
        ({"PQ", "OPQ"}, "opq_tradeoff_points.tex"),
        ({"IVF-PQ", "IVF-OPQ"}, "ivfopq_tradeoff_points.tex"),
    ]:
        with (FIG / out_name).open("w", encoding="utf-8") as f:
            f.write("% method latency recall100\n")
            for method in sorted(methods):
                sub = [r for r in rows if r.get("method") == method and r.get("M") == "8"]
                sub.sort(key=online_latency_us)
                for r in sub:
                    f.write(
                        f"{method} {online_latency_us(r):.5f} "
                        f"{as_float(r, 'recall_at_100'):.5f}\n"
                    )
    if plt is None:
        return
    for methods, out_name in [
        ({"PQ", "OPQ"}, "opq_tradeoff.pdf"),
        ({"IVF-PQ", "IVF-OPQ"}, "ivfopq_tradeoff.pdf"),
    ]:
        plt.figure(figsize=(6.0, 3.8))
        plotted = False
        for method in sorted(methods):
            sub = [r for r in rows if r.get("method") == method and r.get("M") == "8"]
            sub.sort(key=online_latency_us)
            if not sub:
                continue
            plotted = True
            xs = [online_latency_us(r) for r in sub]
            ys = [as_float(r, "recall_at_100") for r in sub]
            plt.plot(xs, ys, marker="o", linewidth=1.4, label=method)
        if plotted:
            plt.xlabel("Latency (us/query)")
            plt.ylabel("Recall@100")
            plt.grid(True, alpha=0.28)
            plt.legend()
            plt.tight_layout()
            plt.savefig(FIG / out_name)
        plt.close()


def plot_opq_m_sweep() -> None:
    rows = read_opq_rows()
    if not rows:
        return
    FIG.mkdir(parents=True, exist_ok=True)
    if plt is None:
        with (FIG / "opq_m_sweep_points.tex").open("w", encoding="utf-8") as f:
            f.write("% method M nprobe p recall100 latency\n")
            for r in rows:
                if r.get("rerank_p") != "1500":
                    continue
                if r.get("method") in {"PQ", "OPQ"} or (
                    r.get("method") in {"IVF-PQ", "IVF-OPQ"} and r.get("nprobe") == "8"
                ):
                    f.write(
                        f"{r.get('method')} {r.get('M')} {r.get('nprobe')} "
                        f"{r.get('rerank_p')} {as_float(r, 'recall_at_100'):.5f} "
                        f"{online_latency_us(r):.5f}\n"
                    )
        return

    series = [
        ("PQ", "PQ"),
        ("OPQ", "OPQ"),
        ("IVF-PQ", "IVF-PQ nprobe=8"),
        ("IVF-OPQ", "IVF-OPQ nprobe=8"),
    ]
    plt.figure(figsize=(6.2, 3.8))
    plotted = False
    for method, label in series:
        sub = [
            r
            for r in rows
            if r.get("method") == method
            and r.get("rerank_p") == "1500"
            and (method in {"PQ", "OPQ"} or r.get("nprobe") == "8")
        ]
        sub.sort(key=lambda r: as_float(r, "M"))
        if not sub:
            continue
        plotted = True
        plt.plot(
            [as_float(r, "M") for r in sub],
            [as_float(r, "recall_at_100") for r in sub],
            marker="o",
            linewidth=1.4,
            label=label,
        )
    if plotted:
        plt.xlabel("PQ subspaces M")
        plt.ylabel("Recall@100 (p=1500)")
        plt.xticks([8, 12, 16])
        plt.grid(True, alpha=0.28)
        plt.legend(fontsize=8)
        plt.tight_layout()
        plt.savefig(FIG / "opq_m_sweep.pdf")
    plt.close()


def plot_gpu_hybrid() -> None:
    all_rows = read_rows(RESULTS / "gpu_hybrid.csv")
    rows = [r for r in all_rows if r.get("method") == "gpu_cublas_coarse_cpu_avx2_rerank"]
    if not all_rows:
        return
    FIG.mkdir(parents=True, exist_ok=True)
    if plt is None:
        with (FIG / "gpu_hybrid_points.tex").open("w", encoding="utf-8") as f:
            f.write("% query_n candidate_p latency recall10 recall100\n")
            for r in rows:
                f.write(
                    f"{r.get('query_n', '0')} {r.get('candidate_p', '0')} "
                    f"{as_float(r, 'online_latency_us'):.5f} "
                    f"{as_float(r, 'recall_at_10'):.5f} "
                    f"{as_float(r, 'recall_at_100'):.5f}\n"
                )
        return
    q2000 = [r for r in rows if r.get("query_n") == "2000"]
    if q2000:
        q2000.sort(key=lambda r: as_float(r, "candidate_p"))
        plt.figure(figsize=(6.0, 3.8))
        plt.plot(
            [as_float(r, "candidate_p") for r in q2000],
            [as_float(r, "online_latency_us") for r in q2000],
            marker="o",
            label="latency",
        )
        plt.xlabel("GPU coarse candidate p")
        plt.ylabel("Online latency (us/query)")
        plt.grid(True, alpha=0.28)
        plt.tight_layout()
        plt.savefig(FIG / "gpu_hybrid_tradeoff.pdf")
        plt.close()

        p = min(q2000, key=lambda r: abs(as_float(r, "candidate_p") - 500.0))
        labels = ["H2D", "GEMM", "Score D2H", "Select", "CPU rerank"]
        values = [
            as_float(p, "h2d_ms"),
            as_float(p, "score_ms"),
            as_float(p, "score_d2h_ms"),
            as_float(p, "candidate_select_ms"),
            as_float(p, "cpu_rerank_ms"),
        ]
        plt.figure(figsize=(6.0, 3.3))
        plt.bar(labels, values)
        plt.ylabel("Total time (ms)")
        plt.xticks(rotation=18, ha="right")
        plt.tight_layout()
        plt.savefig(FIG / "gpu_hybrid_timeline.pdf")
        plt.close()

    gpu_only = [r for r in all_rows if r.get("method") == "gpu_cublas_tree_top10"]
    hybrid_p100 = [
        r
        for r in rows
        if r.get("candidate_p") == "100"
    ]
    if gpu_only and hybrid_p100:
        gpu_only.sort(key=lambda r: as_float(r, "query_n"))
        hybrid_p100.sort(key=lambda r: as_float(r, "query_n"))
        plt.figure(figsize=(6.0, 3.8))
        plt.plot(
            [as_float(r, "query_n") for r in gpu_only],
            [as_float(r, "online_latency_us") for r in gpu_only],
            marker="o",
            linewidth=1.4,
            label="GPU-only",
        )
        plt.plot(
            [as_float(r, "query_n") for r in hybrid_p100],
            [as_float(r, "online_latency_us") for r in hybrid_p100],
            marker="o",
            linewidth=1.4,
            label="GPU+CPU p=100",
        )
        plt.xscale("log")
        plt.yscale("log")
        plt.xlabel("Query batch size")
        plt.ylabel("Online latency (us/query)")
        plt.grid(True, which="both", alpha=0.28)
        plt.legend()
        plt.tight_layout()
        plt.savefig(FIG / "gpu_hybrid_batch.pdf")
        plt.close()


def plot_roofline_points() -> None:
    rows = read_rows(RESULTS / "roofline_points.csv")
    if not rows:
        return
    FIG.mkdir(parents=True, exist_ok=True)
    if plt is None:
        with (FIG / "roofline_points.tex").open("w", encoding="utf-8") as f:
            f.write("% intensity gflops label\n")
            for r in rows:
                f.write(
                    f"{as_float(r, 'arithmetic_intensity'):.5f} "
                    f"{as_float(r, 'performance_gflops'):.5f} "
                    f"{{{r['kernel']}}}\n"
                )
        return
    cpu_bw_gbs = 65.0
    cpu_peak_gflops = 650.0
    gpu_bw_gbs = 250.0
    gpu_peak_gflops = 8500.0
    xs_roof = [0.12, 0.2, 0.4, 0.8, 1.6, 3.2, 6.4, 12.8, 25.6, 40.0]

    plt.figure(figsize=(6.2, 4.0))
    plt.plot(
        xs_roof,
        [min(cpu_peak_gflops, cpu_bw_gbs * x) for x in xs_roof],
        linestyle="--",
        linewidth=1.1,
        color="black",
        alpha=0.75,
        label="CPU roof (STREAM/peak est.)",
    )
    plt.plot(
        xs_roof,
        [min(gpu_peak_gflops, gpu_bw_gbs * x) for x in xs_roof],
        linestyle=":",
        linewidth=1.3,
        color="black",
        alpha=0.75,
        label="GPU roof (spec est.)",
    )
    for r in rows:
        x = as_float(r, "arithmetic_intensity")
        y = as_float(r, "performance_gflops")
        if x <= 0 or y <= 0:
            continue
        plt.scatter(x, y, s=42)
        plt.annotate(r["kernel"], (x, y), textcoords="offset points", xytext=(5, 4), fontsize=7)
    plt.xscale("log")
    plt.yscale("log")
    plt.xlabel("Arithmetic intensity (FLOP/Byte)")
    plt.ylabel("Observed/estimated performance (GFLOP/s)")
    plt.grid(True, which="both", alpha=0.28)
    plt.legend(fontsize=7, loc="lower right")
    plt.tight_layout()
    plt.savefig(FIG / "roofline.pdf")
    plt.close()


def main() -> None:
    plot_unified_tradeoff()
    plot_opq_tradeoff()
    plot_opq_m_sweep()
    plot_gpu_hybrid()
    plot_roofline_points()


if __name__ == "__main__":
    main()
