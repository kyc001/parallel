"""Generate plots for the 15-point report update.

Outputs into ann/report/fig/:
  - scale_sweep.png      problem-size vs latency (log-log)
  - fastscan_full_p.png  full FastScan tradeoff incl. large p
  - recall_at_k.png      Recall@{1,10,100} bar chart
  - gather_vs_shuffle.png  gather/scalar/shuffle comparison
  - soa_vs_aos.png       SoA+blocking vs AoS encoding speedup
"""
import os
import matplotlib
matplotlib.rcParams['font.family'] = 'DejaVu Sans'
import matplotlib.pyplot as plt

FIG_DIR = "ann/report/fig"
os.makedirs(FIG_DIR, exist_ok=True)

# ---------------- 1. Scale sweep -----------------
scale_data = {
    # N: [baseline, flat, sq@100, pq@1000]   latency us
    10000:  (485.76,  104.00,  111.09, 529.60),
    25000:  (4096.51, 822.34,  335.90, 1757.78),
    50000:  (9620.94, 4066.99, 1592.38, 3457.70),
    100000: (17313.80, 9972.43, 783.31, 4746.57),
}
Ns = sorted(scale_data.keys())
bl = [scale_data[N][0] for N in Ns]
fl = [scale_data[N][1] for N in Ns]
sq = [scale_data[N][2] for N in Ns]
pq = [scale_data[N][3] for N in Ns]

fig, ax = plt.subplots(figsize=(6.2, 4.0), dpi=150)
ax.plot(Ns, bl, 'o-', label='baseline (serial)', color='#1f77b4', linewidth=1.8, markersize=7)
ax.plot(Ns, fl, 's-', label='Flat-AVX2',       color='#ff7f0e', linewidth=1.8, markersize=7)
ax.plot(Ns, sq, '^-', label='SQ-AVX2 (p=100)', color='#2ca02c', linewidth=1.8, markersize=7)
ax.plot(Ns, pq, 'd-', label='PQ-AVX2 (p=1000)', color='#d62728', linewidth=1.8, markersize=7)
# Reference: linear scaling through baseline@N=10K
ref = [bl[0] * N / Ns[0] for N in Ns]
ax.plot(Ns, ref, ':', color='gray', linewidth=1.2, label='O(N) reference')
ax.set_xscale('log'); ax.set_yscale('log')
ax.set_xlabel('N (base vectors)')
ax.set_ylabel('Latency (us / query)')
ax.set_title('Latency vs problem size (Windows i9-13900H AVX2, P-core)')
ax.grid(True, which='both', alpha=0.3)
ax.legend(loc='upper left', fontsize=8)
plt.tight_layout()
plt.savefig(f'{FIG_DIR}/scale_sweep.png', dpi=180, bbox_inches='tight')
plt.close()
print('saved scale_sweep.png')

# ---------------- 2. FastScan full p -----------------
fs_data = [  # (p, recall, latency_us) from this rerun
    (40,    0.51335, 916.78),
    (100,   0.70105, 2441.77),
    (500,   0.93200, 2457.31),
    (1000,  0.97525, 2431.11),
    (2000,  0.99260, 2412.96),
    (5000,  0.99870, 3004.55),
    (10000, 0.99980, 4125.51),
    (50000, 0.99995, 11949.38),
    (100000,0.99995, 10571.76),
]
# And the standard PQ curve from full_score run:
pq_data = [
    (100,   0.70860, 398.53),
    (200,   0.83360, 665.06),
    (500,   0.94595, 838.17),
    (1000,  0.98330, 761.99),
    (2000,  0.99550, 1640.21),
    (5000,  0.99965, 3042.08),
    (10000, 0.99995, 3344.43),
    (50000, 0.99995, 13508.39),
    (100000,0.99995, 15893.12),
]
fig, ax = plt.subplots(figsize=(6.2, 4.0), dpi=150)
r1 = [d[1] for d in pq_data]; l1 = [d[2] for d in pq_data]
r2 = [d[1] for d in fs_data]; l2 = [d[2] for d in fs_data]
ax.plot(r1, l1, 'o-', color='#1f77b4', label='PQ-AVX2',       linewidth=1.8, markersize=7)
ax.plot(r2, l2, 's-', color='#d62728', label='PQ-FastScan',    linewidth=1.8, markersize=7)
for p, r, l in fs_data:
    if p in (40, 1000, 10000, 100000):
        ax.annotate(f'p={p}', (r, l), textcoords='offset points',
                    xytext=(6, 4), fontsize=7, color='#d62728')
ax.set_xlabel('Recall@10'); ax.set_ylabel('Latency (us)')
ax.set_xlim(0.4, 1.005)
ax.set_yscale('log')
ax.set_title('Full tradeoff: PQ-AVX2 vs FastScan (Windows i9-13900H, P-core)')
ax.grid(True, which='both', alpha=0.3); ax.legend(loc='upper left', fontsize=9)
plt.tight_layout()
plt.savefig(f'{FIG_DIR}/fastscan_full_p.png', dpi=180, bbox_inches='tight')
plt.close()
print('saved fastscan_full_p.png')

# ---------------- 3. Recall@k -----------------
methods = ['Flat', 'SQ (p=100)', 'PQ (p=1000)', 'FastScan (p=1000)']
recall_k1   = [1.00000, 1.00000, 0.99400, 0.99350]
recall_k10  = [0.99995, 0.99995, 0.98315, 0.97525]
recall_k100 = [0.99999, 0.94019, 0.92512, 0.89219]
import numpy as np
x = np.arange(len(methods))
w = 0.26
fig, ax = plt.subplots(figsize=(7, 4.0), dpi=150)
ax.bar(x - w, recall_k1,   w, label='Recall@1',   color='#1f77b4')
ax.bar(x,     recall_k10,  w, label='Recall@10',  color='#ff7f0e')
ax.bar(x + w, recall_k100, w, label='Recall@100', color='#2ca02c')
ax.set_ylim(0.85, 1.005)
ax.set_xticks(x); ax.set_xticklabels(methods, fontsize=9)
ax.set_ylabel('Recall')
ax.set_title('Recall sensitivity to top-k (Windows i9-13900H)')
ax.grid(True, axis='y', alpha=0.3); ax.legend(fontsize=9)
plt.tight_layout()
plt.savefig(f'{FIG_DIR}/recall_at_k.png', dpi=180, bbox_inches='tight')
plt.close()
print('saved recall_at_k.png')

# ---------------- 4. Gather vs Shuffle -----------------
labels = ['scalar', 'gather (AVX2)', 'shuffle (FastScan)']
vals = [13.55, 52.73, 13.40]
stds = [0.89, 3.65, 3.08]
fig, ax = plt.subplots(figsize=(5.6, 3.6), dpi=150)
colors = ['#808080', '#d62728', '#2ca02c']
bars = ax.bar(labels, vals, yerr=stds, capsize=5, color=colors)
for b, v in zip(bars, vals):
    ax.text(b.get_x() + b.get_width() / 2, v + 2, f'{v:.1f}', ha='center', fontsize=9)
ax.set_ylabel('ns / row')
ax.set_title('ADC lookup cost: scalar vs gather vs shuffle (100K rows)')
ax.grid(True, axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig(f'{FIG_DIR}/gather_vs_shuffle.png', dpi=180, bbox_inches='tight')
plt.close()
print('saved gather_vs_shuffle.png')

# ---------------- 5. SoA vs AoS -----------------
fig, ax = plt.subplots(figsize=(5.6, 3.6), dpi=150)
labels = ['AoS baseline', 'SoA + blocking']
vals = [151.141, 43.056]
stds = [13.712, 1.919]
colors = ['#808080', '#2ca02c']
bars = ax.bar(labels, vals, yerr=stds, capsize=5, color=colors)
for b, v in zip(bars, vals):
    ax.text(b.get_x() + b.get_width() / 2, v + 5, f'{v:.1f} ms', ha='center', fontsize=9)
ax.set_ylabel('encoding pass (ms)')
ax.set_title('PQ encoding argmin: AoS vs SoA+blocking (100K x 256 cent)')
ax.grid(True, axis='y', alpha=0.3)
ax.annotate('3.51x speedup', xy=(1, 43.056), xytext=(0.45, 110),
            arrowprops=dict(arrowstyle='->'), fontsize=10, color='#2ca02c')
plt.tight_layout()
plt.savefig(f'{FIG_DIR}/soa_vs_aos.png', dpi=180, bbox_inches='tight')
plt.close()
print('saved soa_vs_aos.png')
