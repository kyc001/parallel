#!/usr/bin/env python3
"""Generate matplotlib charts for the ANN pthread+omp report."""
import csv
import re
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 10,
    'figure.figsize': (6, 4),
    'figure.dpi': 150,
    'savefig.bbox': 'tight',
    'savefig.pad_inches': 0.05,
})

# CJK font
import matplotlib.font_manager as fm
cjk_fonts = [f.name for f in fm.fontManager.ttflist if any(k in f.name.lower() for k in ['simhei', 'simsun', 'microsoft yahei', 'noto sans cjk', 'wenquanyi'])]
if cjk_fonts:
    plt.rcParams['font.sans-serif'] = [cjk_fonts[0]] + plt.rcParams.get('font.sans-serif', [])
    plt.rcParams['axes.unicode_minus'] = False

BASE = Path(__file__).resolve().parent.parent
LOCAL_CSV = BASE / 'results' / 'local_summary.csv'
KUNPENG_TXT = BASE / 'results' / 'kunpeng' / 'arm_neon_results.txt'
OUT = BASE / 'report' / 'fig'


def load_local():
    rows = []
    with open(LOCAL_CSV, 'r', encoding='utf-8-sig') as f:
        for r in csv.DictReader(f):
            rows.append({
                'algo': r['algorithm'],
                'strategy': r['strategy'],
                'granularity': r['granularity'],
                'threads': int(r['threads']),
                'recall': float(r['recall']),
                'latency_us': float(r['latency_us']),
                'p': r.get('p', ''),
            })
    return rows


def load_kunpeng():
    rows = []
    with open(KUNPENG_TXT, 'r') as f:
        for line in f:
            m = re.match(r'RESULT (\S+) (\S+) t=(\d+) recall=([\d.]+) latency_us=([\d.]+)(.*)', line)
            if m:
                algo, strat, t, recall, lat, extra = m.groups()
                p_m = re.search(r'p=(\d+)', extra)
                rows.append({
                    'algo': algo, 'strategy': strat, 'threads': int(t),
                    'recall': float(recall), 'latency_us': float(lat),
                    'p': p_m.group(1) if p_m else '',
                })
    return rows


def plot_latency_vs_threads(rows, algos, title, filename, strategies=None):
    """Line chart: latency vs thread count for selected algorithms."""
    fig, ax = plt.subplots()
    markers = ['o', 's', '^', 'D', 'v', 'P', '*', 'X']
    colors = plt.cm.tab10(np.linspace(0, 1, 10))

    idx = 0
    for algo in algos:
        algo_rows = [r for r in rows if r['algo'] == algo and r['granularity'] == 'inter']
        if strategies:
            algo_rows = [r for r in algo_rows if r['strategy'] in strategies]
        else:
            # Pick best strategy per thread count
            pass

        strats = sorted(set(r['strategy'] for r in algo_rows))
        for strat in strats:
            data = sorted([r for r in algo_rows if r['strategy'] == strat], key=lambda x: x['threads'])
            if len(data) < 2:
                continue
            ts = [r['threads'] for r in data]
            lats = [r['latency_us'] for r in data]
            label = f"{algo}_{strat}" if len(algos) > 1 else strat
            ax.plot(ts, lats, marker=markers[idx % len(markers)], color=colors[idx % len(colors)],
                    label=label, linewidth=1.5, markersize=5)
            idx += 1

    ax.set_xlabel('线程数')
    ax.set_ylabel('平均延迟 / μs')
    ax.set_title(title)
    ax.set_xscale('log', base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend(fontsize=7, loc='best')
    ax.grid(True, alpha=0.3)
    fig.savefig(OUT / filename)
    plt.close(fig)
    print(f"  saved {filename}")


def plot_recall_vs_latency(rows, algo, filename, p_values=None):
    """Scatter: recall vs latency for different p values."""
    fig, ax = plt.subplots()
    markers = ['o', 's', '^', 'D', 'v']
    colors = plt.cm.tab10(np.linspace(0, 1, 10))

    algo_rows = [r for r in rows if r['algo'] == algo and r['threads'] == 16 and r['granularity'] == 'inter']
    if p_values:
        groups = defaultdict(list)
        for r in algo_rows:
            if r['p'] and int(r['p']) in p_values:
                groups[int(r['p'])].append(r)
    else:
        groups = {0: algo_rows}

    for i, (p, data) in enumerate(sorted(groups.items())):
        data = sorted(data, key=lambda x: x['latency_us'])
        recs = [r['recall'] for r in data]
        lats = [r['latency_us'] for r in data]
        label = f"p={p}" if p else algo
        ax.scatter(lats, recs, marker=markers[i % len(markers)], color=colors[i % len(colors)],
                   label=label, s=40, zorder=3)
        ax.plot(lats, recs, color=colors[i % len(colors)], alpha=0.5, linewidth=1)

    ax.set_xlabel('平均延迟 / μs')
    ax.set_ylabel('Recall@10')
    ax.set_title(f'{algo} Recall-Latency Trade-off (16 threads)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    fig.savefig(OUT / filename)
    plt.close(fig)
    print(f"  saved {filename}")


def plot_cross_platform(local_rows, kunpeng_rows, filename):
    """Grouped bar chart: x86 vs ARM latency for key algorithms."""
    fig, ax = plt.subplots(figsize=(8, 5))

    comparisons = [
        ('flat', 'pthread_dynamic_inter', 'Flat'),
        ('sq', 'pthread_pool_inter', 'SQ'),
        ('pq', 'pthread_dynamic_inter', 'PQ'),
        ('fastscan', 'pthread_dynamic_inter', 'FastScan'),
        ('ivf', 'pthread_pool_inter', 'IVF'),
    ]

    x86_lats = []
    arm_lats = []
    labels = []

    for algo, strat, label in comparisons:
        x86 = [r for r in local_rows if r['algo'] == algo and r['strategy'] == strat and r['threads'] == 16 and r['granularity'] == 'inter']
        arm = [r for r in kunpeng_rows if r['algo'] == algo and r['strategy'] == strat and r['threads'] == 16]
        if x86 and arm:
            x86_lats.append(x86[0]['latency_us'])
            arm_lats.append(arm[0]['latency_us'])
            labels.append(label)

    x = np.arange(len(labels))
    w = 0.35
    bars1 = ax.bar(x - w/2, x86_lats, w, label='x86 AVX2 (i9-13900H)', color='#4C72B0')
    bars2 = ax.bar(x + w/2, arm_lats, w, label='ARM NEON (鲲鹏 920)', color='#DD8452')

    ax.set_ylabel('平均延迟 / μs')
    ax.set_title('跨平台延迟对比 (16 threads, inter-query)')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Add ratio labels
    for i, (x86, arm) in enumerate(zip(x86_lats, arm_lats)):
        ratio = arm / x86
        ax.annotate(f'{ratio:.1f}×', xy=(x[i], max(x86, arm) * 1.05),
                    ha='center', fontsize=8, color='red')

    fig.savefig(OUT / filename)
    plt.close(fig)
    print(f"  saved {filename}")


def plot_scheduler_comparison(rows, algo, filename):
    """Bar chart: scheduler comparison at t=16."""
    fig, ax = plt.subplots()

    strats = ['omp_inter', 'pthread_static_inter', 'pthread_dynamic_inter', 'pthread_pool_inter']
    labels = ['OMP', 'Static', 'Dynamic', 'Pool']

    data = []
    valid_labels = []
    valid_colors = []
    colors = ['#4C72B0', '#55A868', '#C44E52', '#8172B2']
    for strat, label, color in zip(strats, labels, colors):
        matches = [r for r in rows if r['algo'] == algo and r['strategy'] == strat and r['threads'] == 16 and r['granularity'] == 'inter']
        if matches:
            data.append(matches[0]['latency_us'])
            valid_labels.append(label)
            valid_colors.append(color)

    bars = ax.bar(valid_labels, data, color=valid_colors)

    ax.set_ylabel('平均延迟 / μs')
    ax.set_title(f'{algo.upper()} 调度策略对比 (16 threads, inter-query)')
    ax.grid(True, alpha=0.3, axis='y')

    # Mark best
    non_zero = [d for d in data if d > 0]
    if non_zero:
        best_idx = data.index(min(non_zero))
        bars[best_idx].set_edgecolor('red')
        bars[best_idx].set_linewidth(2)

    fig.savefig(OUT / filename)
    plt.close(fig)
    print(f"  saved {filename}")


def plot_speedup(rows, algos, filename):
    """Line chart: speedup vs thread count."""
    fig, ax = plt.subplots()
    markers = ['o', 's', '^', 'D', 'v']
    colors = plt.cm.tab10(np.linspace(0, 1, 10))

    for i, algo in enumerate(algos):
        algo_rows = [r for r in rows if r['algo'] == algo and r['granularity'] == 'inter']
        # Pick best strategy per thread count
        by_t = defaultdict(list)
        for r in algo_rows:
            by_t[r['threads']].append(r)
        best_per_t = {}
        for t, rs in by_t.items():
            best = min(rs, key=lambda x: x['latency_us'])
            best_per_t[t] = best

        if 1 not in best_per_t:
            continue
        base_lat = best_per_t[1]['latency_us']

        ts = sorted(best_per_t.keys())
        speedups = [base_lat / best_per_t[t]['latency_us'] for t in ts]

        ax.plot(ts, speedups, marker=markers[i % len(markers)], color=colors[i % len(colors)],
                label=algo.upper(), linewidth=1.5, markersize=5)

    # Ideal line
    ts = [1, 2, 4, 8, 16]
    ax.plot(ts, ts, 'k--', alpha=0.3, label='理想线性')

    ax.set_xlabel('线程数')
    ax.set_ylabel('加速比')
    ax.set_title('各算法多线程加速比')
    ax.set_xscale('log', base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    fig.savefig(OUT / filename)
    plt.close(fig)
    print(f"  saved {filename}")


def main():
    print("Loading data...")
    local = load_local()
    kunpeng = load_kunpeng()

    print("Generating charts...")

    # 1. Flat latency vs threads
    plot_latency_vs_threads(local, ['flat'], 'Flat 延迟 vs 线程数', 'flat_scaling.pdf')

    # 2. All algorithms speedup
    plot_speedup(local, ['flat', 'sq', 'pq', 'fastscan', 'ivf'], 'speedup_all.pdf')

    # 3. Scheduler comparison for each algo
    for algo in ['flat', 'sq', 'pq', 'fastscan', 'ivf']:
        plot_scheduler_comparison(local, algo, f'scheduler_{algo}.pdf')

    # 4. Recall vs latency for PQ
    plot_recall_vs_latency(local, 'pq', 'recall_latency_pq.pdf', p_values=[100, 500, 1000])

    # 5. Recall vs latency for IVF-PQ
    plot_recall_vs_latency(local, 'ivfpq', 'recall_latency_ivfpq.pdf')

    # 6. Cross-platform comparison
    plot_cross_platform(local, kunpeng, 'cross_platform.pdf')

    # 7. Inter vs Intra comparison
    fig, ax = plt.subplots()
    algos = ['flat', 'sq', 'pq', 'fastscan', 'ivf']
    inter_lats = []
    intra_lats = []
    for algo in algos:
        inter = [r for r in local if r['algo'] == algo and r['granularity'] == 'inter' and r['threads'] == 16]
        intra = [r for r in local if r['algo'] == algo and r['granularity'] == 'intra' and r['threads'] == 16]
        if inter and intra:
            best_inter = min(inter, key=lambda x: x['latency_us'])
            best_intra = min(intra, key=lambda x: x['latency_us'])
            inter_lats.append(best_inter['latency_us'])
            intra_lats.append(best_intra['latency_us'])
        else:
            inter_lats.append(0)
            intra_lats.append(0)

    x = np.arange(len(algos))
    w = 0.35
    ax.bar(x - w/2, inter_lats, w, label='Inter-query', color='#4C72B0')
    ax.bar(x + w/2, intra_lats, w, label='Intra-query', color='#DD8452')
    ax.set_ylabel('最优延迟 / μs')
    ax.set_title('Inter vs Intra 最优延迟对比 (16 threads)')
    ax.set_xticks(x)
    ax.set_xticklabels([a.upper() for a in algos])
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')
    fig.savefig(OUT / 'inter_vs_intra.pdf')
    plt.close(fig)
    print(f"  saved inter_vs_intra.pdf")

    print("Done!")


if __name__ == '__main__':
    main()
