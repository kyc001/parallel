"""Generate FastScan tradeoff plot for main.tex."""
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['font.family'] = 'DejaVu Sans'

# Windows i9-13900H (P-core bound)
i9_pq = {
    'p':      [100,     200,     500,     1000,    2000,     5000],
    'recall': [0.70860, 0.83360, 0.94595, 0.98330, 0.99550,  0.99965],
    'lat':    [398.53,  665.06,  838.17,  761.99,  1640.21,  3042.08],
}
i9_fs = {
    'p':      [40,      100,     500,     1000,    2000,    5000],
    'recall': [0.51400, 0.70075, 0.93205, 0.97535, 0.99265, 0.99875],
    'lat':    [536.447, 529.995, 526.872, 541.689, 571.850, 674.161],
}

# Kunpeng 920
kp_pq = {
    'p':      [100,     200,     500,     1000,    2000,    5000],
    'recall': [0.70940, 0.83845, 0.94755, 0.98370, 0.99550, 0.99980],
    'lat':    [1225.50, 1314.01, 1592.37, 2032.72, 2875.91, 4892.23],
}
kp_fs = {
    'p':      [500,      1000,     5000],
    'recall': [0.932005, 0.975253, 0.998700],
    'lat':    [1239.10,  1339.75,  1925.50],
}

fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), dpi=150)

ax = axes[0]
ax.plot(i9_pq['recall'], i9_pq['lat'], marker='o', color='#1f77b4',
        linewidth=1.8, markersize=7, label='PQ-AVX2 (standard)')
ax.plot(i9_fs['recall'], i9_fs['lat'], marker='s', color='#d62728',
        linewidth=1.8, markersize=7, label='PQ-FastScan (4-bit)')
for p, r, l in zip(i9_fs['p'], i9_fs['recall'], i9_fs['lat']):
    ax.annotate(f'p={p}', (r, l), textcoords='offset points',
                xytext=(5, 5), fontsize=7, color='#d62728')
ax.set_xlabel('Recall@10')
ax.set_ylabel('Latency (us)')
ax.set_title('Windows i9-13900H AVX2 (P-core bound)')
ax.set_xlim(0.5, 1.005)
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=9)

ax = axes[1]
ax.plot(kp_pq['recall'], kp_pq['lat'], marker='o', color='#1f77b4',
        linewidth=1.8, markersize=7, label='PQ-SIMD (standard)')
ax.plot(kp_fs['recall'], kp_fs['lat'], marker='s', color='#d62728',
        linewidth=1.8, markersize=7, label='PQ-FastScan (4-bit)')
for p, r, l in zip(kp_fs['p'], kp_fs['recall'], kp_fs['lat']):
    ax.annotate(f'p={p}', (r, l), textcoords='offset points',
                xytext=(5, 5), fontsize=7, color='#d62728')
ax.set_xlabel('Recall@10')
ax.set_ylabel('Latency (us)')
ax.set_title('Kunpeng 920 NEON (test.sh submit)')
ax.set_xlim(0.6, 1.005)
ax.grid(True, alpha=0.3)
ax.legend(loc='upper left', fontsize=9)

plt.tight_layout()
out = 'fastscan_tradeoff.png'
plt.savefig(out, bbox_inches='tight', dpi=180)
print(f'saved {out}')
