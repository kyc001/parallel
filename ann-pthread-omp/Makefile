CXX = g++
ARCH := $(shell uname -m)

ifeq ($(ARCH),x86_64)
  ARCHFLAGS = -mavx2 -mfma
endif
ifneq ($(filter aarch64 arm64,$(ARCH)),)
  ARCHFLAGS = -mcpu=native
endif

CXXFLAGS = -O3 -std=c++17 -Wall $(ARCHFLAGS)

.PHONY: all clean run

all: baseline flatsimd sqsimd pqsimd fastscan

baseline: main_baseline.cc ann_bench_common.h flat_scan.h
	$(CXX) $(CXXFLAGS) -o $@ $<

flatsimd: main_flatsimd.cc ann_bench_common.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) -o $@ $<

sqsimd: main_sqsimd.cc ann_bench_common.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) -o $@ $<

pqsimd: main_pqsimd.cc ann_bench_common.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) -o $@ $<

fastscan: main_fastscan.cc ann_bench_common.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) -o $@ $<

run: all
	mkdir -p results/i9
	./baseline > results/i9/serial_flat_baseline.log
	./flatsimd > results/i9/serial_flat_simd.log
	./sqsimd > results/i9/serial_sq_simd.log
	./pqsimd > results/i9/serial_pq_simd.log
	./fastscan > results/i9/serial_fastscan.log

clean:
	rm -f baseline baseline.exe flatsimd flatsimd.exe sqsimd sqsimd.exe
	rm -f pqsimd pqsimd.exe fastscan fastscan.exe
