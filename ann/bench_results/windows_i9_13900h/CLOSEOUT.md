# Windows i9-13900H AVX2 Closeout

This file summarizes the final cleanup/commit pass for the Windows AVX2
experiment.

## Step 1 Read-Only Check

Command: `ls -la bench_results/windows_i9_13900h/`

```text
total 248
drwxr-xr-x 1 kyc 197609     0  4月 18 00:04 .
drwxr-xr-x 1 kyc 197609     0  4月 17 23:18 ..
-rw-r--r-- 1 kyc 197609   120  4月 18 00:04 baseline_flat.csv
-rw-r--r-- 1 kyc 197609   289  4月 18 00:04 pq_avx2.csv
drwxr-xr-x 1 kyc 197609     0  4月 17 23:44 raw
-rw-r--r-- 1 kyc 197609  3160  4月 17 23:24 RESULTS.md
-rw-r--r-- 1 kyc 197609   309  4月 17 23:19 speed_baseline.txt
-rw-r--r-- 1 kyc 197609   271  4月 17 23:19 speed_flat.txt
-rw-r--r-- 1 kyc 197609   287  4月 17 23:21 speed_pq.txt
-rw-r--r-- 1 kyc 197609   281  4月 17 23:19 speed_sq.txt
-rw-r--r-- 1 kyc 197609   158  4月 17 23:21 speed_summary.csv
-rw-r--r-- 1 kyc 197609   289  4月 18 00:04 sq_avx2.csv
-rw-r--r-- 1 kyc 197609  1281  4月 17 23:29 vtune_hotspots_flat.txt
-rw-r--r-- 1 kyc 197609  7455  4月 17 23:29 vtune_hotspots_flat_collect.log
-rw-r--r-- 1 kyc 197609  1028  4月 18 00:06 vtune_hotspots_flat_pcore_collect.log
-rw-r--r-- 1 kyc 197609   796  4月 17 23:29 vtune_hotspots_flat_report.log
-rw-r--r-- 1 kyc 197609  3176  4月 17 23:32 vtune_mem_flat.txt
-rw-r--r-- 1 kyc 197609 24238  4月 17 23:31 vtune_mem_flat_collect.log
-rw-r--r-- 1 kyc 197609   791  4月 17 23:32 vtune_mem_flat_report.log
-rw-r--r-- 1 kyc 197609 19849  4月 17 23:30 vtune_uarch_flat.txt
-rw-r--r-- 1 kyc 197609 37212  4月 17 23:30 vtune_uarch_flat_collect.log
-rw-r--r-- 1 kyc 197609   793  4月 17 23:30 vtune_uarch_flat_report.log
-rw-r--r-- 1 kyc 197609 12159  4月 17 23:33 vtune_uarch_pq.txt
-rw-r--r-- 1 kyc 197609 29424  4月 17 23:33 vtune_uarch_pq_collect.log
-rw-r--r-- 1 kyc 197609   791  4月 17 23:33 vtune_uarch_pq_report.log
-rw-r--r-- 1 kyc 197609 15962  4月 17 23:32 vtune_uarch_sq.txt
-rw-r--r-- 1 kyc 197609 31462  4月 17 23:32 vtune_uarch_sq_collect.log
-rw-r--r-- 1 kyc 197609   791  4月 17 23:32 vtune_uarch_sq_report.log
-rw-r--r-- 1 kyc 197609  1965  4月 18 00:00 win_avx2_summary.txt
```

Command: `ls -la bench_results/windows_i9_13900h/raw/ | head -25`

```text
total 92
drwxr-xr-x 1 kyc 197609    0  4月 17 23:44 .
drwxr-xr-x 1 kyc 197609    0  4月 18 00:04 ..
-rw-r--r-- 1 kyc 197609 1302  4月 17 23:40 baseline.txt
-rw-r--r-- 1 kyc 197609 1280  4月 17 23:41 flat_avx2.txt
-rw-r--r-- 1 kyc 197609 1960  4月 17 23:42 pq_p100.txt
-rw-r--r-- 1 kyc 197609 1962  4月 17 23:43 pq_p1000.txt
-rw-r--r-- 1 kyc 197609 1966  4月 17 23:43 pq_p10000.txt
-rw-r--r-- 1 kyc 197609 1970  4月 17 23:45 pq_p100000.txt
-rw-r--r-- 1 kyc 197609 1960  4月 17 23:42 pq_p200.txt
-rw-r--r-- 1 kyc 197609 1964  4月 17 23:43 pq_p2000.txt
-rw-r--r-- 1 kyc 197609 1960  4月 17 23:42 pq_p500.txt
-rw-r--r-- 1 kyc 197609 1964  4月 17 23:43 pq_p5000.txt
-rw-r--r-- 1 kyc 197609 1968  4月 17 23:44 pq_p50000.txt
-rw-r--r-- 1 kyc 197609 1268  4月 17 23:41 sq_p100.txt
-rw-r--r-- 1 kyc 197609 1270  4月 17 23:41 sq_p1000.txt
-rw-r--r-- 1 kyc 197609 1274  4月 17 23:41 sq_p10000.txt
-rw-r--r-- 1 kyc 197609 1278  4月 17 23:42 sq_p100000.txt
-rw-r--r-- 1 kyc 197609 1268  4月 17 23:41 sq_p200.txt
-rw-r--r-- 1 kyc 197609 1272  4月 17 23:41 sq_p2000.txt
-rw-r--r-- 1 kyc 197609 1268  4月 17 23:41 sq_p500.txt
-rw-r--r-- 1 kyc 197609 1272  4月 17 23:41 sq_p5000.txt
-rw-r--r-- 1 kyc 197609 1276  4月 17 23:41 sq_p50000.txt
```

Command: `git status`

```text
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  modified:   ../.gitignore

Untracked files:
  bench_results/windows_i9_13900h/
  flat_scan_avx2.h
  main_win_avx2.cc
  parse_win_results.ps1
  pq_scan_avx2.h
  run_vtune_flat_pcore.ps1
  run_vtune_flat_pcore.sh
  run_vtune_windows_admin.sh
  sq_scan_avx2.h

no changes added to commit
```

Command: `git log --oneline -5`

```text
ee3e7df chore: organize Kunpeng results, update README, cleanup
60f32b9 添加多个新文件和更新现有文件以支持不同版本的 ANN 算法，包括基线、SIMD 和 PQ 索引实现，同时更新构建和运行脚本以优化测试流程
43321e8 更新 .gitignore 文件，添加对 ann 目录下的额外文件类型的忽略规则
4cbe535 更新 .gitignore 文件以忽略 eg/ 目录
ac86051 更新 .gitignore 文件以忽略 eg/ 目录，并更新子项目的提交状态
```

## Inventory Notes

- `raw/` contains 20 txt files.
- The initial top-level result directory had 5 VTune txt reports. The 3 P-core
  VTune txt reports were missing, but the corresponding VTune result
  directories existed and were exported successfully during this pass.
- Root `.gitignore` contains `ann/files/`; this pass also added explicit
  `ann/main_win_avx2.exe`.
- `run_vtune_flat_pcore.sh` was an extra untracked helper not listed in the
  requested git add list.

## Final Commit

- Commit hash: see `git log --oneline -1` after the final commit. The exact
  hash is reported in the task response.
