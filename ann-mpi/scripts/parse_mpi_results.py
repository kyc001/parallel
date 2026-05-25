#!/usr/bin/env python3
"""Parse ANN MPI text logs and generate report CSVs/figures."""
from __future__ import annotations

import csv
import re
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.font_manager as fm
import matplotlib.pyplot as plt


BASE = Path(__file__).resolve().parent.parent
RESULTS = BASE / "results"
FIG = BASE / "report" / "fig"


RUN_RE = re.compile(
    r"^(?P<label>[a-zA-Z0-9_+-]+), (?P<params>.*mpi_procs=(?P<mpi>\d+).*)$"
)


def read_log_text(path: Path) -> str:
    data = path.read_bytes()
    if b"\x00" in data[:4096]:
        return data.decode("utf-16", errors="ignore")
    return data.decode("utf-8-sig", errors="ignore")


def setup_style() -> None:
    fonts = [
        f.name
        for f in fm.fontManager.ttflist
        if any(k in f.name.lower() for k in ["microsoft yahei", "simhei", "simsun", "noto sans cjk"])
    ]
    if fonts:
        plt.rcParams["font.sans-serif"] = [fonts[0]]
    plt.rcParams.update(
        {
            "font.size": 9,
            "axes.unicode_minus": False,
            "figure.dpi": 150,
            "savefig.pad_inches": 0.08,
        }
    )


def unique_by(
    rows: list[dict[str, str]],
    key_fn,
    keep: str = "first",
) -> list[dict[str, str]]:
    out: dict[object, dict[str, str]] = {}
    order: list[object] = []
    for row in rows:
        key = key_fn(row)
        if key not in out:
            order.append(key)
            out[key] = row
        elif keep == "last":
            out[key] = row
    return [out[key] for key in order]


def parameter_sweep_rows(
    rows: list[dict[str, str]],
    algo: str,
    param: str,
    platform: str,
    fixed_key: str = "",
    fixed_value: str = "",
    keep: str = "first",
) -> list[dict[str, str]]:
    selected = [
        r
        for r in rows
        if r["algorithm"] == algo
        and r["platform"] == platform
        and r.get("experiment") == "parameter"
        and (not fixed_key or r.get(fixed_key) == fixed_value)
    ]
    selected = unique_by(selected, lambda r: r.get(param, ""), keep=keep)
    return sorted(selected, key=lambda r: float(r.get(param, "0")))


def format_axis_common(ax, xlabel: str, ylabel: str) -> None:
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.grid(alpha=0.25)


def annotate_points(ax, rows: list[dict[str, str]], param: str) -> None:
    offsets = [(5, 7), (5, -11), (5, 7), (5, -11), (5, 7)]
    for idx, row in enumerate(rows):
        ax.annotate(
            row.get(param, ""),
            (f(row, "latency_us"), f(row, "recall")),
            xytext=offsets[idx % len(offsets)],
            textcoords="offset points",
            fontsize=7,
        )


def parse_params(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for part in text.split(","):
        if "=" in part:
            key, value = part.split("=", 1)
            out[key.strip()] = value.strip()
    return out


def algorithm_from_label(label: str) -> str:
    if label.startswith("ivfpq"):
        return "IVF-PQ"
    if label.startswith("block_hnsw"):
        return "Block-HNSW"
    if label.startswith("ivf_hnsw"):
        return "IVF+HNSW"
    if label.startswith("hnsw_on_hnsw"):
        return "HNSW-on-HNSW"
    return label


def parse_log(path: Path, experiment: str, platform: str) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    current: dict[str, str] | None = None
    current_case = ""
    current_experiment = experiment
    current_comm_mode = ""
    for raw in read_log_text(path).splitlines():
        line = raw.strip()
        if line.startswith("CASE:"):
            current_case = line.split(":", 1)[1].strip()
            if current_case.startswith("parameter"):
                current_experiment = "parameter"
            elif current_case.startswith("scalability"):
                current_experiment = "scalability"
            elif current_case.startswith("blocking") or current_case.startswith("nonblocking"):
                current_experiment = "comm"
                current_comm_mode = current_case.split()[0]
            continue
        if line.startswith("comm_mode="):
            current_comm_mode = line.split("=", 1)[1].strip()
            continue
        m = RUN_RE.match(line)
        if m:
            if current:
                rows.append(current)
            params = parse_params(m.group("params"))
            label = m.group("label")
            current = {
                "source_file": path.name,
                "platform": platform,
                "experiment": current_experiment,
                "case": current_case,
                "comm_mode": current_comm_mode,
                "label": label,
                "algorithm": algorithm_from_label(label),
            }
            current.update(params)
            continue
        if current is None:
            continue
        if line.startswith("average recall:"):
            current["recall"] = line.split(":", 1)[1].strip()
        elif line.startswith("average latency (us):"):
            current["latency_us"] = line.split(":", 1)[1].strip()
        elif line.startswith("max local search latency (us):"):
            current["max_local_us"] = line.split(":", 1)[1].strip()
        elif line.startswith("comm+merge latency (us):"):
            current["comm_merge_us"] = line.split(":", 1)[1].strip()
        elif line.startswith("per-rank search latency (us):"):
            current["per_rank_us"] = line.split(":", 1)[1].strip()
            vals = [float(v) for v in re.findall(r"rank\d+=([0-9.]+)", line)]
            if vals:
                avg = sum(vals) / len(vals)
                current["rank_min_us"] = f"{min(vals):.5f}"
                current["rank_max_us"] = f"{max(vals):.5f}"
                current["rank_mean_us"] = f"{avg:.5f}"
                current["imbalance"] = f"{(max(vals) / avg if avg else 0.0):.5f}"
    if current:
        rows.append(current)
    return rows


def write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    fields = [
        "source_file",
        "platform",
        "experiment",
        "case",
        "comm_mode",
        "algorithm",
        "label",
        "mpi_procs",
        "nthreads",
        "nlist",
        "local_nlist",
        "nprobe",
        "nblocks",
        "hnsw_m",
        "ef",
        "p",
        "query_n",
        "mode",
        "recall",
        "latency_us",
        "max_local_us",
        "comm_merge_us",
        "rank_min_us",
        "rank_max_us",
        "rank_mean_us",
        "imbalance",
        "per_rank_us",
    ]
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file))


def f(row: dict[str, str], key: str) -> float:
    return float(row.get(key, "nan"))


def by_algorithm(rows: list[dict[str, str]], algo: str) -> list[dict[str, str]]:
    return [r for r in rows if r["algorithm"] == algo]


def plot_parameter_tradeoffs(rows: list[dict[str, str]]) -> None:
    specs = [
        ("IVF-PQ", "nprobe", "nlist", "16", "IVF-PQ nprobe"),
        ("Block-HNSW", "ef", "", "", "Block-HNSW ef"),
        ("IVF+HNSW", "nprobe", "", "", "IVF+HNSW nprobe"),
        ("HNSW-on-HNSW", "nprobe", "", "", "HNSW-on-HNSW blocks"),
    ]
    fig, axes = plt.subplots(2, 2, figsize=(10.2, 7.2), constrained_layout=True)
    colors = ["#3274A1", "#E1812C", "#3A923A", "#C03D3E"]
    for ax, (algo, param, fixed_key, fixed_value, title), color in zip(axes.ravel(), specs, colors):
        selected = parameter_sweep_rows(
            rows,
            algo,
            param,
            "Windows MS-MPI",
            fixed_key=fixed_key,
            fixed_value=fixed_value,
            keep="first",
        )
        ax.plot([f(r, "latency_us") for r in selected], [f(r, "recall") for r in selected],
                marker="o", color=color, linewidth=1.8)
        annotate_points(ax, selected, param)
        ax.axhline(0.95, color="0.35", linestyle="--", linewidth=0.9)
        ax.set_title(title)
        format_axis_common(ax, "Latency / us", "Recall@10")
        if algo == "HNSW-on-HNSW":
            ax.set_ylim(0.0, 1.05)
        elif algo == "Block-HNSW":
            ax.set_ylim(0.947, 1.003)
        else:
            ax.set_ylim(0.72, 1.02)
    fig.suptitle("Windows MS-MPI parameter recall-latency trade-offs", fontsize=11)
    fig.savefig(FIG / "mpi_parameter_tradeoffs.pdf")
    plt.close(fig)


def plot_cross_platform_parameter(rows: list[dict[str, str]]) -> None:
    specs = [
        ("IVF-PQ", "nprobe", "nlist", "16", "IVF-PQ nprobe"),
        ("Block-HNSW", "ef", "", "", "Block-HNSW ef"),
        ("IVF+HNSW", "nprobe", "", "", "IVF+HNSW nprobe"),
        ("HNSW-on-HNSW", "nprobe", "", "", "HNSW-on-HNSW blocks"),
    ]
    fig, axes = plt.subplots(2, 2, figsize=(10.2, 7.2), constrained_layout=True)
    for ax, (algo, param, fixed_key, fixed_value, title) in zip(axes.ravel(), specs):
        for platform, marker, color in [
            ("Windows MS-MPI", "o", "#3274A1"),
            ("Kunpeng PBS", "s", "#E1812C"),
        ]:
            selected = parameter_sweep_rows(
                rows,
                algo,
                param,
                platform,
                fixed_key=fixed_key,
                fixed_value=fixed_value,
                keep="first",
            )
            ax.plot(
                [f(r, "latency_us") for r in selected],
                [f(r, "recall") for r in selected],
                marker=marker,
                color=color,
                linewidth=1.5,
                label=platform,
            )
        ax.axhline(0.95, color="0.35", linestyle="--", linewidth=0.9)
        ax.set_title(title)
        format_axis_common(ax, "Latency / us", "Recall@10")
        if algo == "HNSW-on-HNSW":
            ax.set_ylim(0.0, 1.05)
        elif algo == "Block-HNSW":
            ax.set_ylim(0.947, 1.003)
        else:
            ax.set_ylim(0.72, 1.02)
        ax.legend(frameon=False, fontsize=8)
    fig.suptitle("Windows vs Kunpeng PBS parameter trade-offs", fontsize=11)
    fig.savefig(FIG / "mpi_cross_platform_tradeoffs.pdf")
    plt.close(fig)


def plot_ivfpq_nlist(rows: list[dict[str, str]]) -> None:
    selected = parameter_sweep_rows(
        rows,
        "IVF-PQ",
        "nlist",
        "Windows MS-MPI",
        fixed_key="nprobe",
        fixed_value="4",
        keep="last",
    )
    fig, ax1 = plt.subplots(figsize=(7.2, 4.0), constrained_layout=True)
    x = [int(r["nlist"]) for r in selected]
    l1 = ax1.plot(x, [f(r, "latency_us") for r in selected], marker="o", color="#3274A1", label="Latency")
    ax1.set_xlabel("nlist")
    ax1.set_ylabel("Latency / us", color="#3274A1")
    ax1.tick_params(axis="y", labelcolor="#3274A1")
    ax1.set_xscale("log", base=2)
    ax1.set_xticks(x)
    ax1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax2 = ax1.twinx()
    l2 = ax2.plot(x, [f(r, "recall") for r in selected], marker="s", color="#C03D3E", label="Recall")
    ax2.set_ylabel("Recall@10", color="#C03D3E")
    ax2.tick_params(axis="y", labelcolor="#C03D3E")
    ax1.grid(alpha=0.25)
    ax1.legend(l1 + l2, ["Latency", "Recall"], loc="best", frameon=False)
    ax1.set_title("IVF-PQ nlist sweep at nprobe=4")
    fig.savefig(FIG / "mpi_ivfpq_nlist_sweep.pdf")
    plt.close(fig)


def plot_scalability(rows: list[dict[str, str]]) -> None:
    selected = [
        r
        for r in rows
        if r.get("experiment") == "scalability" and r.get("platform") == "Windows MS-MPI"
    ]
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    fig, axes = plt.subplots(1, 2, figsize=(9.8, 3.9), constrained_layout=True)
    for algo in algos:
        data = sorted(by_algorithm(selected, algo), key=lambda r: int(r["mpi_procs"]))
        if not data:
            continue
        base = f(data[0], "latency_us")
        x = [int(r["mpi_procs"]) for r in data]
        speedup = [base / f(r, "latency_us") for r in data]
        efficiency = [s / p for s, p in zip(speedup, x)]
        axes[0].plot(x, speedup, marker="o", label=algo)
        axes[1].plot(x, efficiency, marker="o", label=algo)
    axes[0].plot([1, 2, 4, 8], [1, 2, 4, 8], "k--", alpha=0.35, label="Ideal")
    for ax, ylabel in [(axes[0], "Speedup vs np=1"), (axes[1], "Parallel efficiency")]:
        ax.set_xscale("log", base=2)
        ax.set_xticks([1, 2, 4, 8])
        ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
        ax.set_xlabel("MPI processes")
        ax.set_ylabel(ylabel)
        ax.grid(alpha=0.25)
    axes[0].legend(fontsize=8, frameon=False)
    axes[1].legend(fontsize=8, frameon=False)
    fig.suptitle("Windows MS-MPI strong scaling", fontsize=11)
    fig.savefig(FIG / "mpi_scalability.pdf")
    plt.close(fig)


def plot_cross_platform_scalability(rows: list[dict[str, str]]) -> None:
    selected = [r for r in rows if r.get("experiment") == "scalability"]
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    fig, axes = plt.subplots(2, 2, figsize=(10.2, 7.0), sharex=True, constrained_layout=True)
    for idx, (ax, algo) in enumerate(zip(axes.ravel(), algos)):
        for platform, marker, color in [
            ("Windows MS-MPI", "o", "#3274A1"),
            ("Kunpeng PBS", "s", "#E1812C"),
        ]:
            data = sorted(
                [r for r in selected if r["algorithm"] == algo and r["platform"] == platform],
                key=lambda r: int(r["mpi_procs"]),
            )
            if not data:
                continue
            ax.plot(
                [int(r["mpi_procs"]) for r in data],
                [f(r, "latency_us") for r in data],
                marker=marker,
                color=color,
                linewidth=1.5,
                label=platform,
            )
        ax.set_title(algo)
        ax.set_xscale("log", base=2)
        ax.set_xticks([1, 2, 4, 8])
        ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
        ax.set_xlabel("MPI processes" if idx >= 2 else "")
        ax.set_ylabel("Latency / us")
        ax.grid(alpha=0.25)
        ax.legend(frameon=False, fontsize=8)
    fig.suptitle("Windows vs Kunpeng PBS strong scaling latency", fontsize=11)
    fig.savefig(FIG / "mpi_cross_platform_scalability.pdf")
    plt.close(fig)


def plot_comm_and_balance(rows: list[dict[str, str]]) -> None:
    selected = [r for r in rows if r.get("experiment") == "scalability"]
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    platforms = ["Windows MS-MPI", "Kunpeng PBS"]
    fig, axes = plt.subplots(2, 2, figsize=(10.2, 6.6), sharex=True, constrained_layout=True)
    for row_idx, platform in enumerate(platforms):
        platform_rows = [r for r in selected if r["platform"] == platform]
        for algo in algos:
            data = sorted(by_algorithm(platform_rows, algo), key=lambda r: int(r["mpi_procs"]))
            axes[row_idx, 0].plot(
                [int(r["mpi_procs"]) for r in data],
                [f(r, "comm_merge_us") for r in data],
                marker="o",
                label=algo,
            )
            axes[row_idx, 1].plot(
                [int(r["mpi_procs"]) for r in data],
                [f(r, "imbalance") for r in data],
                marker="o",
                label=algo,
            )
        axes[row_idx, 0].set_title(f"{platform}: comm+merge")
        axes[row_idx, 1].set_title(f"{platform}: load balance")
        axes[row_idx, 0].set_ylabel("Comm+merge / us")
        axes[row_idx, 1].set_ylabel("max(rank) / mean(rank)")
    for idx, ax in enumerate(axes.ravel()):
        ax.set_xscale("log", base=2)
        ax.set_xticks([1, 2, 4, 8])
        ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
        ax.set_xlabel("MPI processes" if idx >= 2 else "")
        ax.grid(alpha=0.25)
    axes[0, 0].legend(fontsize=7, frameon=False)
    fig.suptitle("Communication and load-balance diagnostics", fontsize=11)
    fig.savefig(FIG / "mpi_comm_balance.pdf")
    plt.close(fig)


def plot_comm_modes(rows: list[dict[str, str]]) -> None:
    selected = [r for r in rows if r.get("experiment") == "comm"]
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    blocking = []
    nonblocking = []
    for algo in algos:
        b = next(r for r in selected if r["algorithm"] == algo and r["comm_mode"] == "blocking")
        nb = next(r for r in selected if r["algorithm"] == algo and r["comm_mode"] == "nonblocking")
        blocking.append(f(b, "latency_us"))
        nonblocking.append(f(nb, "latency_us"))
    fig, ax = plt.subplots(figsize=(8.0, 3.8), constrained_layout=True)
    x = range(len(algos))
    width = 0.36
    ax.bar([i - width / 2 for i in x], blocking, width, label="Blocking", color="#3274A1")
    ax.bar([i + width / 2 for i in x], nonblocking, width, label="Non-blocking", color="#E1812C")
    ax.set_xticks(list(x))
    ax.set_xticklabels(algos)
    ax.set_ylabel("Latency / us")
    ax.set_title("Kunpeng PBS blocking vs non-blocking MPI")
    ax.grid(axis="y", alpha=0.25)
    ax.legend(frameon=False)
    ax.set_ylim(0, max(blocking + nonblocking) * 1.12)
    for i, (b, nb) in enumerate(zip(blocking, nonblocking)):
        delta = (nb - b) / b * 100.0
        ax.annotate(f"{delta:+.1f}%", (i, max(b, nb)), ha="center", va="bottom", fontsize=8)
    fig.savefig(FIG / "mpi_comm_modes.pdf")
    plt.close(fig)


def plot_hybrid_layout(rows: list[dict[str, str]]) -> None:
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    colors = {8: "#3274A1", 16: "#E1812C"}
    fig, axes = plt.subplots(2, 2, figsize=(10.4, 6.8), constrained_layout=True)
    for ax, algo in zip(axes.ravel(), algos):
        algo_rows = [r for r in rows if r["algorithm"] == algo]
        for budget in [8, 16]:
            data = [r for r in algo_rows if int(r["worker_budget"]) == budget]
            data.sort(key=lambda r: int(r["np"]))
            labels = [r["layout"].replace("x", r"$\times$") for r in data]
            ax.plot(
                labels,
                [f(r, "latency_us") for r in data],
                marker="o",
                linewidth=1.6,
                color=colors[budget],
                label=f"{budget} workers",
            )
            for label, row in zip(labels, data):
                ax.annotate(
                    f'{f(row, "latency_us"):.0f}',
                    (label, f(row, "latency_us")),
                    textcoords="offset points",
                    xytext=(0, 6),
                    ha="center",
                    fontsize=7,
                )
        ax.set_title(algo)
        ax.set_xlabel("MPI processes x OpenMP threads")
        ax.set_ylabel("Latency / us")
        ax.grid(axis="y", alpha=0.25)
        ax.legend(frameon=False, fontsize=8)
    fig.suptitle("Windows MS-MPI hybrid layout sweep", fontsize=11)
    fig.savefig(FIG / "mpi_hybrid_layout.pdf")
    plt.close(fig)


def plot_affinity(rows: list[dict[str, str]]) -> None:
    algos = ["IVF-PQ", "Block-HNSW", "IVF+HNSW", "HNSW-on-HNSW"]
    order = ["default", "p_only", "e_only", "p_e_all"]
    labels = ["default", "P only", "E only", "P+E"]
    colors = ["#4C72B0", "#55A868", "#C44E52", "#8172B3"]
    fig, axes = plt.subplots(2, 2, figsize=(10.4, 6.8), constrained_layout=True)
    for ax, algo in zip(axes.ravel(), algos):
        algo_rows = {r["affinity_mode"]: r for r in rows if r["algorithm"] == algo}
        values = [f(algo_rows[mode], "latency_us") for mode in order]
        bars = ax.bar(labels, values, color=colors, width=0.62)
        baseline = values[0]
        for bar, value in zip(bars, values):
            delta = (value - baseline) / baseline * 100.0 if baseline else 0.0
            ax.annotate(
                f"{value:.0f}\n{delta:+.0f}%",
                (bar.get_x() + bar.get_width() / 2, value),
                ha="center",
                va="bottom",
                fontsize=7,
            )
        ax.set_title(algo)
        ax.set_ylabel("Latency / us")
        ax.grid(axis="y", alpha=0.25)
        ax.set_ylim(0, max(values) * 1.22)
    fig.suptitle("Windows MS-MPI affinity comparison (np=4, threads=2)", fontsize=11)
    fig.savefig(FIG / "mpi_affinity.pdf")
    plt.close(fig)


def main() -> None:
    setup_style()
    FIG.mkdir(parents=True, exist_ok=True)
    parameter_rows = parse_log(RESULTS / "parameter_sweep_20260525_141037.txt", "parameter", "Windows MS-MPI")
    scalability_rows = parse_log(RESULTS / "scalability_20260525_145526.txt", "scalability", "Windows MS-MPI")
    kunpeng_rows = parse_log(RESULTS / "kunpeng_pbs_sweep_20260525_153105.txt", "parameter", "Kunpeng PBS")
    comm_rows = parse_log(RESULTS / "kunpeng_pbs_comm_modes_20260525_154940.txt", "comm", "Kunpeng PBS")
    hybrid_rows = read_csv(RESULTS / "hybrid_layout_20260525_205224.csv")
    affinity_rows = read_csv(RESULTS / "affinity_20260525_205832.csv")
    write_csv(RESULTS / "parameter_sweep_20260525_141037.csv", parameter_rows)
    write_csv(RESULTS / "scalability_20260525_145526.csv", scalability_rows)
    write_csv(RESULTS / "kunpeng_pbs_sweep_20260525_153105.csv", kunpeng_rows)
    write_csv(RESULTS / "kunpeng_pbs_comm_modes_20260525_154940.csv", comm_rows)
    rows = parameter_rows + scalability_rows + kunpeng_rows + comm_rows
    plot_parameter_tradeoffs(rows)
    plot_cross_platform_parameter(rows)
    plot_ivfpq_nlist(rows)
    plot_scalability(rows)
    plot_cross_platform_scalability(rows)
    plot_comm_and_balance(rows)
    plot_comm_modes(rows)
    plot_hybrid_layout(hybrid_rows)
    plot_affinity(affinity_rows)
    print(f"parsed {len(parameter_rows)} parameter rows")
    print(f"parsed {len(scalability_rows)} scalability rows")
    print(f"parsed {len(kunpeng_rows)} kunpeng pbs rows")
    print(f"parsed {len(comm_rows)} kunpeng comm rows")
    print(f"loaded {len(hybrid_rows)} hybrid layout rows")
    print(f"loaded {len(affinity_rows)} affinity rows")
    print(f"figures written to {FIG}")


if __name__ == "__main__":
    main()
