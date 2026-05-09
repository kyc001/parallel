CXX = g++
ARCH := $(shell uname -m)

ifeq ($(ARCH),x86_64)
  ARCHFLAGS = -mavx2 -mfma
endif
ifneq ($(filter aarch64 arm64,$(ARCH)),)
  ARCHFLAGS = -mcpu=native
endif

CXXFLAGS = -O3 -std=c++17 -Wall $(ARCHFLAGS)
OMPFLAGS = -fopenmp

.PHONY: all clean run run_omp_inter

all: baseline flatsimd sqsimd pqsimd fastscan \
     omp_inter_flat omp_inter_sq omp_inter_pq omp_inter_fastscan

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

omp_inter_flat: main_omp_inter_flat.cc ann_bench_common.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_inter_sq: main_omp_inter_sq.cc ann_bench_common.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_inter_pq: main_omp_inter_pq.cc ann_bench_common.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_inter_fastscan: main_omp_inter_fastscan.cc ann_bench_common.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

run: all
	mkdir -p results/i9
	./baseline > results/i9/serial_flat_baseline.log
	./flatsimd > results/i9/serial_flat_simd.log
	./sqsimd > results/i9/serial_sq_simd.log
	./pqsimd > results/i9/serial_pq_simd.log
	./fastscan > results/i9/serial_fastscan.log

run_omp_inter: omp_inter_flat omp_inter_sq omp_inter_pq omp_inter_fastscan
	mkdir -p results/i9
	OMP_NUM_THREADS=1 ./omp_inter_flat > results/i9/omp_inter_flat_t1.log
	OMP_NUM_THREADS=2 ./omp_inter_flat > results/i9/omp_inter_flat_t2.log
	OMP_NUM_THREADS=4 ./omp_inter_flat > results/i9/omp_inter_flat_t4.log
	OMP_NUM_THREADS=8 ./omp_inter_flat > results/i9/omp_inter_flat_t8.log
	OMP_NUM_THREADS=12 ./omp_inter_flat > results/i9/omp_inter_flat_t12.log
	OMP_NUM_THREADS=1 ./omp_inter_sq > results/i9/omp_inter_sq_t1.log
	OMP_NUM_THREADS=2 ./omp_inter_sq > results/i9/omp_inter_sq_t2.log
	OMP_NUM_THREADS=4 ./omp_inter_sq > results/i9/omp_inter_sq_t4.log
	OMP_NUM_THREADS=8 ./omp_inter_sq > results/i9/omp_inter_sq_t8.log
	OMP_NUM_THREADS=12 ./omp_inter_sq > results/i9/omp_inter_sq_t12.log
	OMP_NUM_THREADS=1 ./omp_inter_pq > results/i9/omp_inter_pq_t1.log
	OMP_NUM_THREADS=2 ./omp_inter_pq > results/i9/omp_inter_pq_t2.log
	OMP_NUM_THREADS=4 ./omp_inter_pq > results/i9/omp_inter_pq_t4.log
	OMP_NUM_THREADS=8 ./omp_inter_pq > results/i9/omp_inter_pq_t8.log
	OMP_NUM_THREADS=12 ./omp_inter_pq > results/i9/omp_inter_pq_t12.log
	OMP_NUM_THREADS=1 ./omp_inter_fastscan > results/i9/omp_inter_fastscan_t1.log
	OMP_NUM_THREADS=2 ./omp_inter_fastscan > results/i9/omp_inter_fastscan_t2.log
	OMP_NUM_THREADS=4 ./omp_inter_fastscan > results/i9/omp_inter_fastscan_t4.log
	OMP_NUM_THREADS=8 ./omp_inter_fastscan > results/i9/omp_inter_fastscan_t8.log
	OMP_NUM_THREADS=12 ./omp_inter_fastscan > results/i9/omp_inter_fastscan_t12.log

clean:
	rm -f baseline baseline.exe flatsimd flatsimd.exe sqsimd sqsimd.exe
	rm -f pqsimd pqsimd.exe fastscan fastscan.exe
	rm -f omp_inter_flat omp_inter_flat.exe omp_inter_sq omp_inter_sq.exe
	rm -f omp_inter_pq omp_inter_pq.exe omp_inter_fastscan omp_inter_fastscan.exe
