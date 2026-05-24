CXX = mpic++
LOCAL_CXX ?= g++
BUILD_DIR ?= build
TARGET ?= main

ifeq ($(OS),Windows_NT)
  MKDIR_BUILD = if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
  RM_OUTPUTS = if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)" & if exist "$(TARGET)" del /q "$(TARGET)"
else
  MKDIR_BUILD = mkdir -p "$(BUILD_DIR)"
  RM_OUTPUTS = rm -rf "$(BUILD_DIR)"/* "$(TARGET)"
endif

UNAME_M := $(shell uname -m 2>/dev/null)
ifeq ($(UNAME_M),aarch64)
  PLATFORM := arm
else ifeq ($(UNAME_M),arm64)
  PLATFORM := arm
else
  PLATFORM := x86
endif

COMMON_FLAGS := -O2 -std=c++11 -I. -fopenmp -lpthread
ifeq ($(PLATFORM),x86)
  COMMON_FLAGS += -mavx2 -mfma
endif

.PHONY: all mpi local clean

all: mpi

mpi: $(TARGET)

$(TARGET): main.cc
	$(CXX) $< -o $@ $(COMMON_FLAGS)

local: $(BUILD_DIR)/main_no_mpi

$(BUILD_DIR)/main_no_mpi: main.cc
	@$(MKDIR_BUILD)
	$(LOCAL_CXX) $< -o $@ $(COMMON_FLAGS) -DANN_NO_MPI

clean:
	$(RM_OUTPUTS)
