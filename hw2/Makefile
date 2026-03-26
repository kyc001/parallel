CXX := g++
CXXFLAGS := -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize -Wall -Wextra -Wpedantic
PERF_CXXFLAGS := $(CXXFLAGS) -g -fno-omit-frame-pointer
LDFLAGS :=
GXX_MAJOR := $(shell $(CXX) -dumpfullversion -dumpversion | cut -d. -f1)

ifeq ($(shell [ "$(GXX_MAJOR)" -lt 9 ] && echo yes),yes)
LDFLAGS += -lstdc++fs
endif

SRC_DIR := src
BIN_DIR := bin
RESULT_DIR := results
OBJ_DIR := $(BIN_DIR)/obj
PERF_OBJ_DIR := $(BIN_DIR)/obj_perf
TARGET := $(BIN_DIR)/lab1_benchmark
PERF_TARGET := $(BIN_DIR)/lab1_perf

COMMON_SRCS := \
	$(SRC_DIR)/benchmark.cpp \
	$(SRC_DIR)/data_utils.cpp \
	$(SRC_DIR)/environment.cpp \
	$(SRC_DIR)/matrix_experiment.cpp \
	$(SRC_DIR)/profile.cpp \
	$(SRC_DIR)/sum_experiment.cpp

COMMON_OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(COMMON_SRCS))
MAIN_OBJS := $(COMMON_OBJS) $(OBJ_DIR)/main.o
PERF_COMMON_OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(PERF_OBJ_DIR)/%.o,$(COMMON_SRCS))
PERF_OBJS := $(PERF_COMMON_OBJS) $(PERF_OBJ_DIR)/perf_driver.o

.PHONY: all clean run asm perf

all: $(TARGET)

$(TARGET): $(MAIN_OBJS) | $(BIN_DIR) $(RESULT_DIR)
	$(CXX) $(CXXFLAGS) $(MAIN_OBJS) -o $@ $(LDFLAGS)

$(PERF_TARGET): $(PERF_OBJS) | $(BIN_DIR) $(RESULT_DIR)
	$(CXX) $(PERF_CXXFLAGS) $(PERF_OBJS) -o $@ $(LDFLAGS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(OBJ_DIR): | $(BIN_DIR)
	mkdir -p $(OBJ_DIR)

$(PERF_OBJ_DIR): | $(BIN_DIR)
	mkdir -p $(PERF_OBJ_DIR)

$(RESULT_DIR):
	mkdir -p $(RESULT_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(PERF_OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(PERF_OBJ_DIR)
	$(CXX) $(PERF_CXXFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET)

asm: $(TARGET) | $(RESULT_DIR)
	objdump -Cd -Mintel $(TARGET) | rg -n -C 12 "sum_naive|sum_superscalar2|sum_superscalar4|sum_pairwise|matrix_dot_naive|matrix_dot_row_major|matrix_dot_row_major_unrolled4" > $(RESULT_DIR)/assembly_excerpt.txt

perf: $(PERF_TARGET)

clean:
	rm -rf $(BIN_DIR) $(RESULT_DIR)
