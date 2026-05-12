CXX ?= g++
BUILD_DIR ?= build
MAINS_DIR ?= mains

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

SRC_ALL := $(shell find $(MAINS_DIR) -name '*.cc' 2>/dev/null)
ifeq ($(PLATFORM),x86)
  SRC := $(filter-out $(MAINS_DIR)/simd/main_flatsimd.cc $(MAINS_DIR)/simd/main_sqsimd.cc $(MAINS_DIR)/simd/main_pqsimd.cc,$(SRC_ALL))
else
  SRC := $(filter-out $(MAINS_DIR)/win/%,$(SRC_ALL))
endif
TARGETS := $(patsubst $(MAINS_DIR)/%.cc,$(BUILD_DIR)/%,$(SRC))

.PHONY: all clean list

all: $(TARGETS)

$(BUILD_DIR)/%: $(MAINS_DIR)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $< -o $@ $(COMMON_FLAGS)

list:
	@printf '%s\n' $(SRC)

clean:
	rm -rf $(BUILD_DIR)/*
