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
PTFLAGS = -pthread

.PHONY: all clean run run_omp_inter run_omp_intra run_pthread_inter run_pthread_intra run_local_sweep

all: baseline flatsimd sqsimd pqsimd fastscan \
     omp_inter_flat omp_inter_sq omp_inter_pq omp_inter_fastscan \
     omp_intra_flat omp_intra_sq omp_intra_pq omp_intra_fastscan \
     pthread_dynamic_inter_flat pthread_dynamic_inter_sq pthread_dynamic_inter_pq pthread_dynamic_inter_fastscan \
     pthread_barrier_inter_flat pthread_barrier_inter_sq pthread_barrier_inter_pq pthread_barrier_inter_fastscan \
     pthread_pool_inter_flat pthread_pool_inter_sq pthread_pool_inter_pq pthread_pool_inter_fastscan \
     pthread_dynamic_intra_flat pthread_dynamic_intra_sq pthread_dynamic_intra_pq pthread_dynamic_intra_fastscan \
     pthread_barrier_intra_flat pthread_barrier_intra_sq pthread_barrier_intra_pq pthread_barrier_intra_fastscan \
     pthread_pool_intra_flat pthread_pool_intra_sq pthread_pool_intra_pq pthread_pool_intra_fastscan

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

omp_intra_flat: main_omp_intra_flat.cc ann_bench_common.h flat_scan_omp.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_intra_sq: main_omp_intra_sq.cc ann_bench_common.h sq_scan_omp.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_intra_pq: main_omp_intra_pq.cc ann_bench_common.h pq_scan_omp.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

omp_intra_fastscan: main_omp_intra_fastscan.cc ann_bench_common.h pq_fastscan_omp.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) -o $@ $<

pthread_dynamic_inter_flat: main_pthread_dynamic_inter_flat.cc ann_bench_common.h pthread_inter_dynamic.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_inter_sq: main_pthread_dynamic_inter_sq.cc ann_bench_common.h pthread_inter_dynamic.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_inter_pq: main_pthread_dynamic_inter_pq.cc ann_bench_common.h pthread_inter_dynamic.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_inter_fastscan: main_pthread_dynamic_inter_fastscan.cc ann_bench_common.h pthread_inter_dynamic.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_inter_flat: main_pthread_barrier_inter_flat.cc ann_bench_common.h pthread_inter_barrier.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_inter_sq: main_pthread_barrier_inter_sq.cc ann_bench_common.h pthread_inter_barrier.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_inter_pq: main_pthread_barrier_inter_pq.cc ann_bench_common.h pthread_inter_barrier.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_inter_fastscan: main_pthread_barrier_inter_fastscan.cc ann_bench_common.h pthread_inter_barrier.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_inter_flat: main_pthread_pool_inter_flat.cc ann_bench_common.h pthread_inter_pool.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_inter_sq: main_pthread_pool_inter_sq.cc ann_bench_common.h pthread_inter_pool.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_inter_pq: main_pthread_pool_inter_pq.cc ann_bench_common.h pthread_inter_pool.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_inter_fastscan: main_pthread_pool_inter_fastscan.cc ann_bench_common.h pthread_inter_pool.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_intra_flat: main_pthread_dynamic_intra_flat.cc ann_bench_common.h pthread_intra_dynamic.h flat_intra_kernel.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_intra_sq: main_pthread_dynamic_intra_sq.cc ann_bench_common.h pthread_intra_dynamic.h sq_intra_kernel.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_intra_pq: main_pthread_dynamic_intra_pq.cc ann_bench_common.h pthread_intra_dynamic.h pq_intra_kernel.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_dynamic_intra_fastscan: main_pthread_dynamic_intra_fastscan.cc ann_bench_common.h pthread_intra_dynamic.h pq_fastscan_intra_kernel.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_intra_flat: main_pthread_barrier_intra_flat.cc ann_bench_common.h pthread_intra_barrier.h flat_intra_kernel.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_intra_sq: main_pthread_barrier_intra_sq.cc ann_bench_common.h pthread_intra_barrier.h sq_intra_kernel.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_intra_pq: main_pthread_barrier_intra_pq.cc ann_bench_common.h pthread_intra_barrier.h pq_intra_kernel.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_barrier_intra_fastscan: main_pthread_barrier_intra_fastscan.cc ann_bench_common.h pthread_intra_barrier.h pq_fastscan_intra_kernel.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_intra_flat: main_pthread_pool_intra_flat.cc ann_bench_common.h pthread_intra_pool.h flat_intra_kernel.h flat_scan_dispatch.h flat_scan_avx2.h flat_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_intra_sq: main_pthread_pool_intra_sq.cc ann_bench_common.h pthread_intra_pool.h sq_intra_kernel.h sq_scan_dispatch.h sq_scan_avx2.h sq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_intra_pq: main_pthread_pool_intra_pq.cc ann_bench_common.h pthread_intra_pool.h pq_intra_kernel.h pq_scan_dispatch.h pq_scan_avx2.h pq_scan_simd.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

pthread_pool_intra_fastscan: main_pthread_pool_intra_fastscan.cc ann_bench_common.h pthread_intra_pool.h pq_fastscan_intra_kernel.h pq_fastscan_simd.h pq_fastscan_avx2_safe.h pq_fastscan_neon.h
	$(CXX) $(CXXFLAGS) $(PTFLAGS) -o $@ $<

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

run_omp_intra: omp_intra_flat omp_intra_sq omp_intra_pq omp_intra_fastscan
	mkdir -p results/i9
	OMP_NUM_THREADS=1 ./omp_intra_flat > results/i9/omp_intra_flat_t1.log
	OMP_NUM_THREADS=2 ./omp_intra_flat > results/i9/omp_intra_flat_t2.log
	OMP_NUM_THREADS=4 ./omp_intra_flat > results/i9/omp_intra_flat_t4.log
	OMP_NUM_THREADS=8 ./omp_intra_flat > results/i9/omp_intra_flat_t8.log
	OMP_NUM_THREADS=12 ./omp_intra_flat > results/i9/omp_intra_flat_t12.log
	OMP_NUM_THREADS=1 ./omp_intra_sq > results/i9/omp_intra_sq_t1.log
	OMP_NUM_THREADS=2 ./omp_intra_sq > results/i9/omp_intra_sq_t2.log
	OMP_NUM_THREADS=4 ./omp_intra_sq > results/i9/omp_intra_sq_t4.log
	OMP_NUM_THREADS=8 ./omp_intra_sq > results/i9/omp_intra_sq_t8.log
	OMP_NUM_THREADS=12 ./omp_intra_sq > results/i9/omp_intra_sq_t12.log
	OMP_NUM_THREADS=1 ./omp_intra_pq > results/i9/omp_intra_pq_t1.log
	OMP_NUM_THREADS=2 ./omp_intra_pq > results/i9/omp_intra_pq_t2.log
	OMP_NUM_THREADS=4 ./omp_intra_pq > results/i9/omp_intra_pq_t4.log
	OMP_NUM_THREADS=8 ./omp_intra_pq > results/i9/omp_intra_pq_t8.log
	OMP_NUM_THREADS=12 ./omp_intra_pq > results/i9/omp_intra_pq_t12.log
	OMP_NUM_THREADS=1 ./omp_intra_fastscan > results/i9/omp_intra_fastscan_t1.log
	OMP_NUM_THREADS=2 ./omp_intra_fastscan > results/i9/omp_intra_fastscan_t2.log
	OMP_NUM_THREADS=4 ./omp_intra_fastscan > results/i9/omp_intra_fastscan_t4.log
	OMP_NUM_THREADS=8 ./omp_intra_fastscan > results/i9/omp_intra_fastscan_t8.log
	OMP_NUM_THREADS=12 ./omp_intra_fastscan > results/i9/omp_intra_fastscan_t12.log

run_pthread_inter: pthread_dynamic_inter_flat pthread_dynamic_inter_sq pthread_dynamic_inter_pq pthread_dynamic_inter_fastscan \
                   pthread_barrier_inter_flat pthread_barrier_inter_sq pthread_barrier_inter_pq pthread_barrier_inter_fastscan \
                   pthread_pool_inter_flat pthread_pool_inter_sq pthread_pool_inter_pq pthread_pool_inter_fastscan
	mkdir -p results/i9
	for paradigm in dynamic barrier pool; do \
	  for method in flat sq pq fastscan; do \
	    for t in 1 2 4 8 12; do \
	      PTHREAD_NUM_THREADS=$$t ./pthread_$${paradigm}_inter_$${method} > results/i9/pthread_$${paradigm}_inter_$${method}_t$${t}.log; \
	    done; \
	  done; \
	done

run_pthread_intra: pthread_dynamic_intra_flat pthread_dynamic_intra_sq pthread_dynamic_intra_pq pthread_dynamic_intra_fastscan \
                   pthread_barrier_intra_flat pthread_barrier_intra_sq pthread_barrier_intra_pq pthread_barrier_intra_fastscan \
                   pthread_pool_intra_flat pthread_pool_intra_sq pthread_pool_intra_pq pthread_pool_intra_fastscan
	mkdir -p results/i9
	for paradigm in dynamic barrier pool; do \
	  for method in flat sq pq fastscan; do \
	    for t in 1 2 4 8 12; do \
	      PTHREAD_NUM_THREADS=$$t ./pthread_$${paradigm}_intra_$${method} > results/i9/pthread_$${paradigm}_intra_$${method}_t$${t}.log; \
	    done; \
	  done; \
	done

run_local_sweep:
	powershell -ExecutionPolicy Bypass -File run_local_sweep.ps1

clean:
	rm -f baseline baseline.exe flatsimd flatsimd.exe sqsimd sqsimd.exe
	rm -f pqsimd pqsimd.exe fastscan fastscan.exe
	rm -f omp_inter_flat omp_inter_flat.exe omp_inter_sq omp_inter_sq.exe
	rm -f omp_inter_pq omp_inter_pq.exe omp_inter_fastscan omp_inter_fastscan.exe
	rm -f omp_intra_flat omp_intra_flat.exe omp_intra_sq omp_intra_sq.exe
	rm -f omp_intra_pq omp_intra_pq.exe omp_intra_fastscan omp_intra_fastscan.exe
	rm -f pthread_dynamic_inter_flat pthread_dynamic_inter_flat.exe pthread_dynamic_inter_sq pthread_dynamic_inter_sq.exe
	rm -f pthread_dynamic_inter_pq pthread_dynamic_inter_pq.exe pthread_dynamic_inter_fastscan pthread_dynamic_inter_fastscan.exe
	rm -f pthread_barrier_inter_flat pthread_barrier_inter_flat.exe pthread_barrier_inter_sq pthread_barrier_inter_sq.exe
	rm -f pthread_barrier_inter_pq pthread_barrier_inter_pq.exe pthread_barrier_inter_fastscan pthread_barrier_inter_fastscan.exe
	rm -f pthread_pool_inter_flat pthread_pool_inter_flat.exe pthread_pool_inter_sq pthread_pool_inter_sq.exe
	rm -f pthread_pool_inter_pq pthread_pool_inter_pq.exe pthread_pool_inter_fastscan pthread_pool_inter_fastscan.exe
	rm -f pthread_dynamic_intra_flat pthread_dynamic_intra_flat.exe pthread_dynamic_intra_sq pthread_dynamic_intra_sq.exe
	rm -f pthread_dynamic_intra_pq pthread_dynamic_intra_pq.exe pthread_dynamic_intra_fastscan pthread_dynamic_intra_fastscan.exe
	rm -f pthread_barrier_intra_flat pthread_barrier_intra_flat.exe pthread_barrier_intra_sq pthread_barrier_intra_sq.exe
	rm -f pthread_barrier_intra_pq pthread_barrier_intra_pq.exe pthread_barrier_intra_fastscan pthread_barrier_intra_fastscan.exe
	rm -f pthread_pool_intra_flat pthread_pool_intra_flat.exe pthread_pool_intra_sq pthread_pool_intra_sq.exe
	rm -f pthread_pool_intra_pq pthread_pool_intra_pq.exe pthread_pool_intra_fastscan pthread_pool_intra_fastscan.exe
