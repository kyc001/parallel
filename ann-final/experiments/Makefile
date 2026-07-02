CXX ?= g++
NVCC ?= nvcc
BUILD_DIR ?= build

CXXFLAGS ?= -O3 -std=c++11 -I. -fopenmp -mavx2 -mfma
LDFLAGS ?= -lpthread

NVCCFLAGS ?= -O3 -std=c++11 -x cu -I.
LDLIBS ?= -lcublas

ifeq ($(OS),Windows_NT)
  EXE := .exe
  MKDIR_BUILD = if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
  RM_BUILD = if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
  VCVARS ?= C:/BuildTools/VC/Auxiliary/Build/vcvars64.bat
  NVCCFLAGS += -Xcompiler=/utf-8
  ifneq ($(wildcard $(VCVARS)),)
    NVCC_COMPILE = cmd /C "call $(VCVARS) >nul && $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)"
  else
    NVCC_COMPILE = $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)
  endif
else
  EXE :=
  MKDIR_BUILD = mkdir -p "$(BUILD_DIR)"
  RM_BUILD = rm -rf "$(BUILD_DIR)"
  NVCC_COMPILE = $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)
endif

CUDA_ARCH ?=
ifneq ($(strip $(CUDA_ARCH)),)
  NVCCFLAGS += -arch=$(CUDA_ARCH)
endif

.PHONY: all cpu gpu clean

all: cpu gpu

cpu: $(BUILD_DIR)/opq_ivfpq$(EXE) $(BUILD_DIR)/adaptive_ivfpq$(EXE)

gpu: $(BUILD_DIR)/gpu_hybrid$(EXE)

$(BUILD_DIR):
	$(MKDIR_BUILD)

$(BUILD_DIR)/opq_ivfpq$(EXE): opq_ivfpq.cc simd/*.h ivf/*.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

$(BUILD_DIR)/adaptive_ivfpq$(EXE): adaptive_ivfpq.cc simd/*.h ivf/*.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

$(BUILD_DIR)/gpu_hybrid$(EXE): gpu_hybrid.cu gpu_ann_search.cuh flat_scan.h gpu/*.cuh | $(BUILD_DIR)
	$(NVCC_COMPILE)

clean:
	$(RM_BUILD)
