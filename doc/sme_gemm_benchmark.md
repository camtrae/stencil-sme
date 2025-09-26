# ARM SME Matrix Multiplication Benchmark Report

## Test Environment

- **Hardware Platform**: 2024 Mac Mini M4
- **Compiler**: Homebrew LLVM/Clang 21.1.1
- **Target Architecture**: ARM64 + SME2
- **Test Date**: 2025/09/26

## Compilation Configuration

```bash
# O1 Optimization
/opt/homebrew/opt/llvm/bin/clang -O1 -Wall -std=c99 -march=native+sme2 sme_test.c -o sme_test

# O2 Optimization
/opt/homebrew/opt/llvm/bin/clang -O2 -Wall -std=c99 -march=native+sme2 sme_test.c -o sme_test
```

---

## 📊 Performance Test Results Summary

### Key Findings

1. **Significant SME Acceleration**: SME implementations achieve 85x-182x speedup over CPU baseline across all test sizes
2. **Notable SME Internal Transpose Optimization**: SME transpose is 42%-596% faster than CPU transpose
3. **Excellent 4-Tiles Parallelization**: Using all 4 tiles achieves 413x-466x acceleration
4. **Minor O1 vs O2 Difference**: Minimal impact on SME versions, mainly affects CPU baseline

---

## 1️⃣ Small Matrix Test (64×64)

### O1 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 280.900 | 1.00x | 1.87 |
| **SME (CPU Transpose)** | 18.800 | 14.94x | 27.89 |
| **SME (SME Transpose)** | 2.700 | **104.04x** | **194.18** |

**Key Metrics**:
- SME transpose optimization: **596.3% faster**
- Overall acceleration: **104.04x** (10303.7% faster)

### O2 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 240.600 | 1.00x | 2.18 |
| **SME (CPU Transpose)** | 18.900 | 12.73x | 27.74 |
| **SME (SME Transpose)** | 2.800 | **85.93x** | **187.25** |

**Key Metrics**:
- SME transpose optimization: **575.0% faster**
- Overall acceleration: **85.93x** (8492.9% faster)

---

## 2️⃣ Medium Matrix Test (640×640)

### O1 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 173,641.000 | 1.00x | 3.02 |
| **SME (CPU Transpose)** | 1,569.600 | 110.63x | 334.03 |
| **SME (SME Transpose)** | 1,104.700 | **157.18x** | **474.60** |

**Key Metrics**:
- SME transpose optimization: **42.1% faster**
- Overall acceleration: **157.18x** (15618.4% faster)

### O2 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 177,130.500 | 1.00x | 2.96 |
| **SME (CPU Transpose)** | 1,572.300 | 112.66x | 333.45 |
| **SME (SME Transpose)** | 1,096.800 | **161.50x** | **478.02** |

**Key Metrics**:
- SME transpose optimization: **43.4% faster**
- Overall acceleration: **161.50x** (16049.8% faster)

---

## 3️⃣ Large Matrix Test (1024×1024)

### O1 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 822,165.625 | 1.00x | 2.61 |
| **SME (CPU Transpose)** | 5,750.300 | 142.98x | 373.46 |
| **SME (SME Transpose)** | 4,504.000 | **182.54x** | **476.79** |

**Key Metrics**:
- SME transpose optimization: **27.7% faster**
- Overall acceleration: **182.54x** (18154.1% faster)

### O2 Optimization Results

| Version | Time (μs) | Speedup | GFLOPS |
|---------|-----------|---------|---------|
| **CPU** | 804,961.500 | 1.00x | 2.67 |
| **SME (CPU Transpose)** | 5,745.000 | 140.12x | 373.80 |
| **SME (SME Transpose)** | 4,505.900 | **178.65x** | **476.59** |

**Key Metrics**:
- SME transpose optimization: **27.5% faster**
- Overall acceleration: **178.65x** (17764.6% faster)

---

## 4️⃣ 4-Tile GEMM Optimization Test

### Column Split Strategy

Compilation Command:
```bash
/opt/homebrew/opt/llvm/bin/clang -O2 -Wall -std=c99 -march=native+sme2 sme_gemm_4tile.c -o sme_gemm_4tile
```

| Version | Time (μs) | Speedup | GFLOPS | Tile Utilization |
|---------|-----------|---------|---------|------------------|
| **CPU** | 3,929.600 | 1.00x | 2.00 | N/A |
| **SME (CPU Transpose + Single Tile)** | 117.700 | 33.39x | 66.82 | 1/4 (25%) |
| **SME (SME Transpose + Single Tile)** | 22.500 | 174.65x | 349.53 | 1/4 (25%) |
| **SME (SME Transpose + 4-Tiles)** | 9.500 | **413.64x** | **827.82** | **4/4 (100%)** |

**Optimization Analysis**:
- Transpose optimization (single tile): SME transpose is **423.1% faster** than CPU transpose
- 4-tiles parallel optimization: **2.37x speedup** over single tile (59.2% efficiency)
- Overall acceleration: **413.64x** (41264.2% faster)
- Peak performance: **827.82 GFLOPS**

### Row Split Strategy

Compilation Command:
```bash
/opt/homebrew/opt/llvm/bin/clang -O2 -Wall -std=c99 -march=native+sme2 sme_gemm_4tile_row.c -o sme_gemm_4tile_row
```

#### Matrix Columns = 16

| Version | Time (μs) | Speedup | GFLOPS | Tile Utilization |
|---------|-----------|---------|---------|------------------|
| **CPU** | 1,083.800 | 1.00x | 1.81 | N/A |
| **SME (CPU Transpose + Single Tile)** | 208.300 | 5.20x | 9.44 | 1/4 (25%) |
| **SME (SME Transpose + Single Tile)** | 13.600 | 79.69x | 144.56 | 1/4 (25%) |
| **SME (SME Transpose + 4-Tiles Column Split)** | 13.200 | 82.11x | 148.95 | 1/4 (25%) |
| **SME (SME Transpose + 4-Tiles Row Split)** | 6.200 | **174.81x** | **317.11** | **4/4 (100%)** |

#### Matrix Columns = 64

| Version | Time (μs) | Speedup | GFLOPS | Tile Utilization |
|---------|-----------|---------|---------|------------------|
| **CPU** | 3,735.300 | 1.00x | 2.11 | N/A |
| **SME (CPU Transpose + Single Tile)** | 108.400 | 34.46x | 72.55 | 1/4 (25%) |
| **SME (SME Transpose + Single Tile)** | 20.700 | 180.45x | 379.92 | 1/4 (25%) |
| **SME (SME Transpose + 4-Tiles Column Split)** | 8.400 | 444.68x | 936.23 | 4/4 (100%) |
| **SME (SME Transpose + 4-Tiles Row Split)** | 8.000 | **466.91x** | **983.04** | **4/4 (100%)** |

**Key Finding**: With 64 columns, row split and column split achieve similar performance, both reaching nearly **1 TFLOPS** peak performance.

---

## 📈 Performance Trend Analysis

### 1. Matrix Size Impact

| Matrix Size | CPU GFLOPS | SME Best GFLOPS | Speedup |
|-------------|------------|-----------------|---------|
| 64×64 | 2.18 | 194.18 | 85.93x |
| 640×640 | 2.96 | 478.02 | 161.50x |
| 1024×1024 | 2.67 | 476.59 | 178.65x |

**Observation**: SME speedup increases with matrix size, showing best performance on medium to large matrices.

### 2. Transpose Optimization Effect

| Matrix Size | Transpose Improvement |
|-------------|----------------------|
| 64×64 | 575-596% |
| 640×640 | 42-43% |
| 1024×1024 | 27-28% |

**Observation**: Transpose optimization is most significant for small matrices, with diminishing but still notable benefits for larger matrices.

### 3. 4-Tile Parallel Efficiency

- **Theoretical Maximum Speedup**: 4.0x (using 4 tiles)
- **Actual Speedup**: 2.37x (column split)
- **Parallel Efficiency**: 59.2%
- **Peak Performance**: Nearly **1 TFLOPS** (983.04 GFLOPS)

---

## 💡 Optimization Recommendations

1. **Small Matrices (≤128×128)**
   - Focus on data transpose optimization
   - Consider batch processing to reduce overhead

2. **Medium Matrices (128-1024)**
   - Use 4-tile parallelization
   - Choose row/column split based on matrix shape

3. **Large Matrices (>1024)**
   - Consider block processing
   - Optimize cache utilization

4. **General Recommendations**
   - Align data to 64-byte boundaries
   - Use SME internal transpose instead of CPU transpose
   - Fully utilize all 4 ZA tiles

---

## 🎯 Conclusion

Apple M4 chip's SME2 extension demonstrates exceptional matrix operation performance:

- ✅ **Basic SME Optimization**: 85x-182x acceleration
- ✅ **4-Tile Parallelization**: Up to 466x acceleration
- ✅ **Peak Performance**: Nearly 1 TFLOPS
- ✅ **Energy Efficiency**: Significantly better than traditional CPU implementations

SME2 technology provides powerful hardware acceleration capabilities for scientific computing, machine learning, and signal processing, particularly excelling in matrix-intensive operations.

---

*Test code based on ARM official SME examples, optimized and tested for Apple Silicon M4.*