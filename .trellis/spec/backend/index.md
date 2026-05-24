# Backend Development Guidelines

> Project-specific guidance for the C++ benchmark and algorithm layer.

This repository is a parallel-programming coursework workspace, not a web
service. In this spec layer, "backend" means the runnable systems code:
C++ kernels, ANN search variants, profiling drivers, build scripts, and
benchmark data handling.

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Where lab code, ANN variants, scripts, results, and reports live | Filled |
| [Data and Build Guidelines](./data-and-build-guidelines.md) | Dataset paths, compiler flags, platform switches, and benchmark outputs | Filled |
| [Error Handling](./error-handling.md) | How command-line tools report failures and platform limitations | Filled |
| [Logging Guidelines](./logging-guidelines.md) | Console/result-file output formats for reproducible experiments | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Review, testing, benchmark, and portability expectations | Filled |

## Pre-Development Checklist

- Identify the lab or experiment directory first: `lab1-CPU架构编程/`,
  `ann-SIMD/`, `ann-pthread-omp/`, `OT-协程技术调研/`, or `ann_original/`.
- Search for the existing variant closest to the requested change before
  creating a new kernel, script, or result format.
- Preserve the course entry points unless the task explicitly changes them:
  `main.cc`, `test.sh`, `qsub.sh`, `Makefile`, and report source files.
- Check platform assumptions before editing: Windows PowerShell, Linux Bash,
  x86 AVX2/FMA, ARM NEON, Kunpeng `/anndata/`, or local `../files/`.
- Keep generated build/profiling noise out of source changes; `.gitignore`
  already ignores common C/C++, Python, LaTeX, and profiling artifacts.

## Non-Applicable Template Areas

There is no backend database, web routing layer, HTTP API, ORM, or server-side
framework in the current repository. Do not introduce those concepts into task
plans unless a future task actually adds them.
