CXX := g++
CXXFLAGS := -std=c++17 -O3 -march=native -fno-tree-vectorize -fno-tree-slp-vectorize -Wall -Wextra -Wpedantic
LDFLAGS :=

SRC_DIR := src
BIN_DIR := bin
RESULT_DIR := results
TARGET := $(BIN_DIR)/lab1_benchmark

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(SRC_DIR)/lab1_benchmark.cpp | $(BIN_DIR) $(RESULT_DIR)
	$(CXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(RESULT_DIR):
	mkdir -p $(RESULT_DIR)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BIN_DIR) $(RESULT_DIR)
