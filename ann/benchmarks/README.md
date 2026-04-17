# Benchmark Scripts

Reusable benchmark code for the ANN SIMD report lives here.

- `bench_experiments.cc`: runs E1 alignment, E2 prefetch, and E3 scaling tests.
- `plot_tradeoff.py`: generates E4 latency-recall tradeoff figures from fixed SQ/PQ data.
- `run_android_termux_proot.sh`: runs E4 -> E1 -> E2 -> E3 for the Android tablet Termux + PRoot Ubuntu environment.

Build manually:

```bash
g++ benchmarks/bench_experiments.cc -I. -o benchmarks/bench_experiments -O2 -fopenmp -lpthread -std=c++11
```

Run one experiment manually:

```bash
benchmarks/bench_experiments e1 bench_results/android_termux_proot_ubuntu
benchmarks/bench_experiments e2 bench_results/android_termux_proot_ubuntu
benchmarks/bench_experiments e3 bench_results/android_termux_proot_ubuntu
```

Generate figures manually:

```bash
python3 benchmarks/plot_tradeoff.py --out-dir bench_results/android_termux_proot_ubuntu
```
