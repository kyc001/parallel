CXX := g++
CXXFLAGS := -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize -Wall -Wextra -Wpedantic
LDFLAGS :=
GXX_MAJOR := $(shell $(CXX) -dumpfullversion -dumpversion | cut -d. -f1)

ifeq ($(shell [ "$(GXX_MAJOR)" -lt 9 ] && echo yes),yes)
LDFLAGS += -lstdc++fs
endif

SRC_DIR := src
BIN_DIR := bin
RESULT_DIR := results
OBJ_DIR := $(BIN_DIR)/obj
TARGET := $(BIN_DIR)/lab1_benchmark
SRCS := $(wildcard $(SRC_DIR)/*.cpp)
OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

.PHONY: all clean run asm

all: $(TARGET)

$(TARGET): $(OBJS) | $(BIN_DIR) $(RESULT_DIR)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@ $(LDFLAGS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(OBJ_DIR): | $(BIN_DIR)
	mkdir -p $(OBJ_DIR)

$(RESULT_DIR):
	mkdir -p $(RESULT_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET)

asm: $(TARGET) | $(RESULT_DIR)
	objdump -Cd -Mintel $(TARGET) | rg -n -C 12 "sum_naive|sum_superscalar2|sum_superscalar4|sum_pairwise|matrix_dot_naive|matrix_dot_row_major|matrix_dot_row_major_unrolled4" > $(RESULT_DIR)/assembly_excerpt.txt

clean:
	rm -rf $(BIN_DIR) $(RESULT_DIR)
