NVCC ?= nvcc
BUILD_DIR ?= build
GPU_HEADERS := $(wildcard gpu/*.cuh)

ifeq ($(OS),Windows_NT)
  TARGET ?= $(BUILD_DIR)/main.exe
  VCVARS ?= C:/BuildTools/VC/Auxiliary/Build/vcvars64.bat
  MKDIR_BUILD = if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
  RM_BUILD = if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
  ifneq ($(wildcard $(VCVARS)),)
    NVCC_COMPILE = cmd /C "call $(VCVARS) >nul && $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)"
  else
    NVCC_COMPILE = $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)
  endif
else
  TARGET ?= $(BUILD_DIR)/main
  MKDIR_BUILD = mkdir -p "$(BUILD_DIR)"
  RM_BUILD = rm -rf "$(BUILD_DIR)"
  NVCC_COMPILE = $(NVCC) $(NVCCFLAGS) $< -o $@ $(LDLIBS)
endif

NVCCFLAGS ?= -O3 -x cu
LDLIBS ?= -lcublas
ifeq ($(OS),Windows_NT)
  NVCCFLAGS += -Xcompiler=/utf-8
endif
CUDA_ARCH ?=
ifneq ($(strip $(CUDA_ARCH)),)
  NVCCFLAGS += -arch=$(CUDA_ARCH)
endif

.PHONY: all run clean

all: $(TARGET)

$(BUILD_DIR):
	$(MKDIR_BUILD)

$(TARGET): main.cc gpu_ann_search.cuh $(GPU_HEADERS) flat_scan.h | $(BUILD_DIR)
	$(NVCC_COMPILE)

run: $(TARGET)
	$(TARGET) gemm 2000

clean:
	$(RM_BUILD)
