#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p bench_results/windows_i9_13900h/fastscan
mkdir -p bench_results/kunpeng_server/fastscan

cxx="${CXX:-g++}"
arch="$(uname -m)"
common_flags=(-O3 -std=c++17 -Wall -Wextra -Wno-unused-parameter)

case "$arch" in
  x86_64|amd64)
    arch_flags=(-mavx2 -mfma)
    ;;
  aarch64|arm64)
    arch_flags=(-mcpu=native)
    ;;
  *)
    echo "unsupported arch: $arch" >&2
    exit 1
    ;;
esac

"$cxx" main_fastscan.cc -o main_fastscan "${common_flags[@]}" "${arch_flags[@]}"
echo "build OK: ./main_fastscan ($arch)"
