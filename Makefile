# Makefile for ARM SME Stencil Computation on Mac M4
# Optimized for macOS with Homebrew LLVM/Clang

# Compiler - using Homebrew LLVM/Clang
CC = /opt/homebrew/opt/llvm/bin/clang
CXX = /opt/homebrew/opt/llvm/bin/clang++

# Compiler flags
# -O2: Optimization level (you can change to -O3 for more aggressive optimization)
# -Wall: Enable all warnings
# -std=c99: C99 standard (change to -std=c11 if needed)
# -march=native+sme2: Target native architecture with SME2 extensions
CFLAGS = -O2 -Wall -std=c99 -march=native+sme2
LDFLAGS = -lm

# Target executable and source
TARGET = stencil_kernel15
SOURCES = stencil_15x15_sme_optimized.c

# Build directory structure
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

# Object files
OBJECTS = $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

# Default target
all: $(BIN_DIR)/$(TARGET)

# Create directories
$(BUILD_DIR) $(OBJ_DIR) $(BIN_DIR):
	@mkdir -p $@

# Build executable
$(BIN_DIR)/$(TARGET): $(OBJECTS) | $(BIN_DIR)
	@echo "🔗 Linking $@..."
	@$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "✅ Build complete: $@"

# Compile source files
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR)
	@echo "🔨 Compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

# Debug build with symbols and sanitizers
debug: CFLAGS += -g -DDEBUG -fsanitize=address -fsanitize=undefined
debug: LDFLAGS += -fsanitize=address -fsanitize=undefined
debug: clean all

# Optimized build with O3
optimize: CFLAGS = -O3 -Wall -std=c99 -march=native+sme2 -flto
optimize: LDFLAGS += -flto
optimize: clean all

# Fast math optimizations (use with caution)
fast: CFLAGS = -Ofast -Wall -std=c99 -march=native+sme2 -flto -ffast-math
fast: LDFLAGS += -flto
fast: clean all

# Run the program
run: all
	@echo "🚀 Running $(TARGET)..."
	@$(BIN_DIR)/$(TARGET)

# Run with time measurement
time-run: all
	@echo "⏱️  Running with time measurement..."
	@time $(BIN_DIR)/$(TARGET)

# Run with macOS instruments (requires Xcode)
instruments-run: all
	@echo "📊 Running with Instruments..."
	@if command -v xcrun >/dev/null 2>&1; then \
		xcrun xctrace record --template "Time Profiler" --launch $(BIN_DIR)/$(TARGET); \
	else \
		echo "⚠️  Xcode Command Line Tools not installed"; \
		echo "  Install with: xcode-select --install"; \
	fi

# Check SME support on Apple Silicon
check-sme:
	@echo "🔍 Checking SME support on Apple Silicon..."
	@echo "System Information:"
	@sysctl -n machdep.cpu.brand_string
	@echo ""
	@echo "Architecture Features:"
	@sysctl -a | grep -E "hw.optional.(arm|neon|armv)" | sort
	@echo ""
	@echo "Note: M4 chip should support SME2 extensions"
	@echo "If the program runs without errors, SME is working correctly"

# Assembly output for inspection
asm: $(SOURCES)
	@echo "📄 Generating assembly output..."
	@$(CC) $(CFLAGS) -S $< -o $(BUILD_DIR)/$(basename $(SOURCES)).s
	@echo "Assembly saved to: $(BUILD_DIR)/$(basename $(SOURCES)).s"

# Check compiler version and capabilities
compiler-info:
	@echo "ℹ️  Compiler Information:"
	@$(CC) --version
	@echo ""
	@echo "Target CPU Features:"
	@$(CC) -march=native -dM -E - < /dev/null | grep -E "__ARM|__aarch64|SME" | sort

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f *.dSYM  # Remove debug symbols if present

# Deep clean (including profile data)
distclean: clean
	@echo "🧹 Deep cleaning..."
	@rm -f *.gcda *.gcno  # Remove profile data
	@rm -rf .cache

# Install (optional)
PREFIX ?= /usr/local
install: all
	@echo "📦 Installing to $(PREFIX)/bin..."
	@install -d $(PREFIX)/bin
	@install -m 755 $(BIN_DIR)/$(TARGET) $(PREFIX)/bin/$(TARGET)

# Uninstall
uninstall:
	@echo "🗑️  Removing from $(PREFIX)/bin..."
	@rm -f $(PREFIX)/bin/$(TARGET)

# Development helpers
format:
	@echo "🎨 Formatting code..."
	@if command -v clang-format >/dev/null 2>&1; then \
		clang-format -i $(SOURCES); \
		echo "Code formatted"; \
	else \
		echo "clang-format not found, skipping"; \
	fi

# Static analysis with clang-tidy (if available)
analyze:
	@echo "🔍 Running static analysis..."
	@if command -v /opt/homebrew/opt/llvm/bin/clang-tidy >/dev/null 2>&1; then \
		/opt/homebrew/opt/llvm/bin/clang-tidy $(SOURCES) -- $(CFLAGS); \
	else \
		echo "clang-tidy not found in LLVM installation"; \
	fi

# Help
help:
	@echo "ARM SME Stencil Computation - Mac M4 Build Options"
	@echo "=================================================="
	@echo "Build targets:"
	@echo "  make              - Build with O2 optimization"
	@echo "  make optimize     - Build with O3 optimization + LTO"
	@echo "  make fast         - Build with Ofast + fast-math (less precise)"
	@echo "  make debug        - Build with debug symbols and sanitizers"
	@echo ""
	@echo "Run targets:"
	@echo "  make run          - Build and run the program"
	@echo "  make time-run     - Run with time measurement"
	@echo "  make instruments-run - Profile with Instruments (requires Xcode)"
	@echo ""
	@echo "Analysis targets:"
	@echo "  make check-sme    - Check SME support on this system"
	@echo "  make compiler-info - Show compiler and CPU feature information"
	@echo "  make asm          - Generate assembly output"
	@echo "  make analyze      - Run static analysis (if available)"
	@echo ""
	@echo "Maintenance targets:"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make distclean    - Deep clean including profile data"
	@echo "  make format       - Format source code"
	@echo "  make install      - Install to system (PREFIX=$(PREFIX))"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Compiler: $(CC)"

# Phony targets (not files)
.PHONY: all clean distclean debug optimize fast run time-run instruments-run \
        check-sme compiler-info asm analyze format install uninstall help

# Shortcuts
.PHONY: o3 ofast
o3: optimize
ofast: fast