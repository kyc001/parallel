"""
生成实验结果图表 — 用于幻灯片和报告
输出 PNG 文件到 fig/ 目录
"""
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False

import os
os.makedirs('fig', exist_ok=True)

# ==================== 数据 ====================
# 请根据实际实验结果修改这些数据

# 10K I/O 任务耗时 (秒) - 2026-05-25 本机实测
io_labels = [
    'Python\nthreading',
    'Python\nasyncio',
    'Go\ngoroutine',
    'Java\nplatform',
    'Java\nvirtual',
]
io_times = [5.524, 0.601, 0.156, 5.447, 0.190]
io_colors = ['#e74c3c', '#2ecc71', '#3498db', '#95a5a6', '#8e44ad']

# Python benchmark 期间的峰值工作集记录值。跨语言峰值内存未统一采样，报告中不作严格对比。
mem_labels = ['Python\nthreading', 'Python\nasyncio']
mem_values = [21.4, 15.0]
mem_colors = ['#e74c3c', '#2ecc71']

# CPU 密集型耗时 (秒, N=1000 tasks) - 2026-05-25 本机实测
cpu_labels = [
    'Python\nthreading',
    'Python\nasyncio',
    'Go\ngoroutine',
    'Java\nplatform',
    'Java\nvirtual',
]
cpu_times = [20.805, 15.419, 0.053, 0.032, 0.062]
cpu_colors = ['#e74c3c', '#f39c12', '#2ecc71', '#95a5a6', '#8e44ad']

# ==================== 图1: I/O 吞吐对比 ====================
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(io_labels, io_times, color=io_colors, width=0.6, edgecolor='white', linewidth=1.2)
ax.set_ylabel('耗时 (秒)', fontsize=13)
ax.set_title('I/O 密集型任务: 10K 并发 sleep(0.1s) 耗时对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(io_times) * 1.3)
for bar, t in zip(bars, io_times):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            f'{t:.2f}s', ha='center', va='bottom', fontsize=11, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/io_throughput.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/io_throughput.png")

# ==================== 图2: 内存占用对比 ====================
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(mem_labels, mem_values, color=mem_colors, width=0.6, edgecolor='white', linewidth=1.2)
ax.set_ylabel('峰值工作集 (MB)', fontsize=13)
ax.set_title('Python 10K I/O 并发任务峰值工作集对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(mem_values) * 1.2)
for bar, m in zip(bars, mem_values):
    label = f'{m:.0f}MB' if m < 1000 else f'{m/1000:.1f}GB'
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(mem_values) * 0.03,
            label, ha='center', va='bottom', fontsize=11, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/memory_usage.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/memory_usage.png")

# ==================== 图3: CPU 密集型对比 ====================
fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(cpu_labels, cpu_times, color=cpu_colors, width=0.5, edgecolor='white', linewidth=1.2)
ax.set_ylabel('耗时 (秒)', fontsize=13)
ax.set_title('CPU 密集型任务: 1K 并发 fib(25) 耗时对比', fontsize=14, fontweight='bold')
ax.set_ylim(0, max(cpu_times) * 1.3)
for bar, t in zip(bars, cpu_times):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.03,
            f'{t:.2f}s', ha='center', va='bottom', fontsize=11, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/cpu_benchmark.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/cpu_benchmark.png")

# ==================== 图4: 切换开销对比 ====================
# 上下文切换/创建开销 - 2026-05-25 本机实测/参考数据
# Python asyncio: 1M yields in 7.824s => ~7824ns/yield
# Go goroutine: 100k channel interactions in 122.904ms => ~1229ns/switch
# Java virtual: 100k Thread.sleep(0) tasks in 124ms => ~1240ns/task
switch_labels = ['Python\nthreading', 'Python\nasyncio', 'Go\ngoroutine', 'Java\nvirtual']
switch_ns = [5000, 7824, 1229, 1240]  # Python threading 为经验量级

fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(switch_labels, switch_ns, color=['#e74c3c', '#f39c12', '#2ecc71', '#9b59b6'],
              width=0.5, edgecolor='white', linewidth=1.2)
ax.set_ylabel('切换开销 (ns)', fontsize=13)
ax.set_title('上下文切换开销对比', fontsize=14, fontweight='bold')
ax.set_yscale('log')
ax.set_ylim(10, 20000)
for bar, ns in zip(bars, switch_ns):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() * 1.3,
            f'{ns}ns', ha='center', va='bottom', fontsize=10, fontweight='bold')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('fig/switch_overhead.png', dpi=150, bbox_inches='tight')
plt.close()
print("已生成 fig/switch_overhead.png")

print("\n所有图表已生成到 fig/ 目录!")
