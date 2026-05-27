"""
生成实验结果图表 — 用于幻灯片和报告
输出 PNG 文件到 fig/ 目录
数据来源：2026-05-27 本机实测，每项 5 次重复
"""
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False

import os
os.makedirs('fig', exist_ok=True)

# ==================== 数据 ====================

# 10K I/O 任务耗时 (秒) - mean ± std
io_labels = [
    'Python\nthreading',
    'Python\nasyncio',
    'Go\ngoroutine',
    'Java\nplatform',
    'Java\nvirtual',
]
io_means = [3.130, 0.446, 0.116, 5.458, 0.235]
io_stds  = [0.426, 0.012, 0.020, 0.013, 0.173]
io_colors = ['#e74c3c', '#2ecc71', '#3498db', '#95a5a6', '#8e44ad']

# 内存对比 (MB) - 三语言
mem_labels = ['Python\nthreading', 'Python\nasyncio', 'Go\ngoroutine', 'Java\nvirtual']
mem_means = [21.1, 14.1, 106.5, 246.0]
mem_stds  = [0.4, 0.5, 0.0, 0.0]  # Go/Java 只有单次采样
mem_colors = ['#e74c3c', '#2ecc71', '#3498db', '#8e44ad']
# 标注数据来源
mem_notes = ['peak WS', 'peak WS', 'MemStats.Sys', 'heap+nonHeap']

# CPU 密集型耗时 (秒, N=1000 tasks) - mean ± std
cpu_labels = [
    'Python\nthreading',
    'Python\nasyncio',
    'Go\ngoroutine',
    'Java\nplatform',
    'Java\nvirtual',
]
cpu_means = [9.521, 7.647, 0.039, 0.034, 0.040]
cpu_stds  = [1.591, 0.293, 0.010, 0.002, 0.013]
cpu_colors = ['#e74c3c', '#f39c12', '#2ecc71', '#95a5a6', '#8e44ad']

# 上下文切换开销 (ns/次) - mean ± std
switch_labels = ['Python\nthreading', 'Python\nasyncio', 'Go\ngoroutine', 'Java\nvirtual']
switch_ns     = [5000, 2494, 1220, 750]
switch_stds   = [0, 144, 150, 320]  # Python threading 为经验量级
switch_colors = ['#e74c3c', '#f39c12', '#2ecc71', '#8e44ad']

# ==================== 图1: I/O 吞吐对比 ====================
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(io_labels, io_means, yerr=io_stds, color=io_colors, width=0.6,
              edgecolor='white', linewidth=1.2, capsize=5, error_kw={'linewidth': 1.5})
ax.set_ylabel('耗时 (秒)', fontsize=13)
ax.set_title('I/O 密集型任务: 10K 并发 sleep(0.1s) 耗时对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(io_means) * 1.35)
for bar, t, s in zip(bars, io_means, io_stds):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + s + 0.05,
            f'{t:.3f}s', ha='center', va='bottom', fontsize=11, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/io_throughput.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/io_throughput.png")

# ==================== 图2: 内存占用对比 ====================
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(mem_labels, mem_means, yerr=mem_stds, color=mem_colors, width=0.6,
              edgecolor='white', linewidth=1.2, capsize=5, error_kw={'linewidth': 1.5})
ax.set_ylabel('内存 (MB)', fontsize=13)
ax.set_title('各语言 I/O 并发任务内存使用对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(mem_means) * 1.25)
for bar, m, note in zip(bars, mem_means, mem_notes):
    label = f'{m:.0f}MB'
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 3,
            f'{label}\n({note})', ha='center', va='bottom', fontsize=9, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
# 添加注释说明测量方法不同
ax.annotate('注: Python 为峰值工作集, Go 为 MemStats.Sys, Java 为 heap+nonHeap\n跨语言对比仅作参考',
            xy=(0.5, 0.02), xycoords='axes fraction', ha='center', fontsize=8, color='gray')
plt.tight_layout()
plt.savefig('fig/memory_usage.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/memory_usage.png")

# ==================== 图3: CPU 密集型对比 ====================
fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(cpu_labels, cpu_means, yerr=cpu_stds, color=cpu_colors, width=0.5,
              edgecolor='white', linewidth=1.2, capsize=5, error_kw={'linewidth': 1.5})
ax.set_ylabel('耗时 (秒)', fontsize=13)
ax.set_title('CPU 密集型任务: 1K 并发 fib(25) 耗时对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(cpu_means) * 1.35)
for bar, t, s in zip(bars, cpu_means, cpu_stds):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + s + 0.03,
            f'{t:.3f}s', ha='center', va='bottom', fontsize=11, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/cpu_benchmark.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/cpu_benchmark.png")

# ==================== 图4: 切换开销对比 ====================
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(switch_labels, switch_ns, yerr=switch_stds, color=switch_colors, width=0.5,
              edgecolor='white', linewidth=1.2, capsize=5, error_kw={'linewidth': 1.5})
ax.set_ylabel('切换开销 (ns)', fontsize=13)
ax.set_title('上下文切换开销对比', fontsize=14, fontweight='bold')
ax.set_yscale('log')
ax.set_ylim(100, 20000)
for bar, ns, s in zip(bars, switch_ns, switch_stds):
    label = f'{ns}ns' if s == 0 else f'{ns}±{s}ns'
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() * 1.3,
            label, ha='center', va='bottom', fontsize=10, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.annotate('注: 各语言微基准不完全等价，仅用于量级比较',
            xy=(0.5, 0.02), xycoords='axes fraction', ha='center', fontsize=8, color='gray')
plt.tight_layout()
plt.savefig('fig/switch_overhead.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/switch_overhead.png")

print("\n所有图表已生成到 fig/ 目录!")
