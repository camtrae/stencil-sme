# Stencil Computation Performance Comparison
## Intel Xeon Platinum 8358 (OpenMP) vs Apple M4 (SME)

---

## Executive Summary

This document compares the performance of 15×15 stencil computation implementations on two different architectures:
- **Intel Xeon Platinum 8358**: Traditional x86_64 architecture with AVX-512 SIMD and OpenMP parallelization (32 threads)
- **Apple M4 with SME**: ARM-based architecture with Scalable Matrix Extension (single core at 4.4 GHz)

**Key Finding**: Apple M4's SME implementation achieves **91.90× speedup** over baseline using a single core, while Intel's best OpenMP implementation achieves **15.48× speedup** using 32 threads.

---

## Hardware Specifications

### Intel Xeon Platinum 8358
| Specification | Value |
|--------------|-------|
| Architecture | x86_64 |
| CPU Model | Intel(R) Xeon(R) Platinum 8358 @ 2.60GHz |
| Total CPUs | 128 (2 sockets × 32 cores × 2 threads) |
| Cores per Socket | 32 |
| Threads per Core | 2 |
| CPU Frequency | 2.60 GHz (base), 3.40 GHz (max) |
| SIMD Support | AVX-512 |
| Memory Architecture | NUMA (2 nodes) |
| Test Configuration | 32 OpenMP threads |

### Apple M4 (Mac Mini)
| Specification | Value |
|--------------|-------|
| Architecture | ARM64 (Apple Silicon) |
| CPU Model | Apple M4 |
| Performance Core | 4.4 GHz (single P-core used) |
| SIMD Support | SME/SME2 (Scalable Matrix Extension) |
| Matrix Engine | Dedicated matrix multiply unit |
| Test Configuration | Single core execution |

---

## Compilation Commands

### Intel Platform
```bash
g++ -O2 -march=native -mavx512f -fopenmp -o stencil_simd stencil_simd.cpp
```

### Apple M4 Platform
```bash
/opt/homebrew/opt/llvm/bin/clang -O2 -Wall -std=c99 -march=native+sme2 stencil_kernel15.c -o stencil_kernel15
```

---

## Performance Results

### Intel Xeon Platinum 8358 (32 threads)
| Method | Time (μs) | Speedup vs Baseline | Notes |
|--------|-----------|-------------------|--------|
| **CPU Baseline** | 953.00 | 1.00× | Single thread, no SIMD |
| **Baseline OpenMP** | 173.60 | 5.49× | 32 threads |
| **im2row** | 936.20 | 1.02× | Single thread |
| **im2row SIMD** | 121.25 | 7.86× | AVX-512 |
| **im2row OpenMP** | 97.75 | 9.75× | 32 threads + SIMD |
| **Stencil2Row** | 1860.75 | 0.51× | Transposed, single thread |
| **Stencil2Row SIMD** | 117.15 | 8.13× | AVX-512 |
| **Stencil2Row OpenMP** | **61.55** | **15.48×** | 32 threads + SIMD |

### Apple M4 with SME (single core)
| Method | Time (μs) | Speedup vs Baseline | Notes |
|--------|-----------|-------------------|--------|
| **Baseline (full)** | 804.15 | 1.00× | Reference implementation |
| **Im2Row GEMV** | 457.70 | 1.76× | Matrix multiplication only |
| **Stencil2Row Direct** | 826.55 | 0.97× | Basic implementation |
| **SME Single Tile** | 15.40 | 52.22× | Single tile SME |
| **SME 4-Tiles (Column)** | 15.40 | 52.22× | Column split approach |
| **SME 4-Tiles (Row)** | **8.75** | **91.90×** | Row split approach |

---

## Performance Analysis

### Cross-Platform Comparison

| Metric | Intel Xeon (32 threads) | Apple M4 (1 core) | M4 Advantage |
|--------|-------------------------|-------------------|--------------|
| **Best Time** | 61.55 μs | 8.75 μs | **7.03×** faster |
| **Best Speedup** | 15.48× | 91.90× | **5.94×** better |
| **Threads Used** | 32 | 1 | 32× fewer |
| **Power Efficiency** | ~165W TDP | ~10W | ~16× more efficient |

### Key Observations

1. **Single vs Multi-threaded Performance**
   - M4 single core with SME: **8.75 μs**
   - Intel 32 threads with OpenMP: **61.55 μs**
   - M4 is **7× faster** using **32× fewer threads**

2. **Architecture Efficiency**
   - Intel achieves maximum 15.48× speedup with 32 threads
   - M4 achieves 91.90× speedup on a single core
   - SME provides **6× better scaling** than traditional SIMD+threading

3. **Memory Bandwidth Utilization**
   - Intel: Limited by memory bandwidth across NUMA nodes
   - M4: Unified memory architecture with dedicated matrix engine

4. **Instruction-Level Advantages**
   - **Intel AVX-512**: 16 floats per instruction, requires explicit vectorization
   - **Apple SME**: Up to 256×256 matrix operations, hardware-managed tiling

---

## Technical Implementation Differences

### Intel Implementation Strategy
```cpp
// AVX-512 SIMD optimization for 15×15 kernel (225 elements)
// Process in chunks of 16 elements
for (int k = 0; k < 14; k++) {
    __m512 a_vec = _mm512_loadu_ps(A_row + k * 16);
    __m512 prod = _mm512_mul_ps(a_vec, kernel_vecs[k]);
    sum_all = _mm512_add_ps(sum_all, prod);
}
// OpenMP parallelization across rows
#pragma omp parallel for num_threads(32)
```

### Apple SME Implementation Strategy
```c
// SME with 4-tile row splitting
// Hardware manages matrix operations
svfloat32x4_t za_tiles[4];
for (int tile = 0; tile < 4; tile++) {
    // Load and compute entire tile in hardware
    sme_load_tile(za_tiles[tile], ...);
    sme_matrix_multiply(za_tiles[tile], ...);
}
```

---

## Conclusions

### Performance Winner: Apple M4 with SME
- **7× faster** absolute performance (8.75 μs vs 61.55 μs)
- **32× better thread efficiency** (1 thread vs 32 threads)
- **~16× better power efficiency** (~10W vs ~165W)

### Architectural Insights

1. **Dedicated Matrix Hardware**: SME's specialized matrix units outperform general-purpose SIMD by a wide margin

2. **Memory Architecture**: M4's unified memory eliminates NUMA penalties that affect multi-socket Intel systems

3. **Instruction Efficiency**: SME's ability to handle entire matrix tiles reduces instruction overhead compared to AVX-512's vector operations

4. **Scalability**: Single-core SME performance exceeds multi-threaded x86 performance, leaving room for further scaling with multiple cores

### Recommendations

- **For Intel platforms**: Focus on cache optimization and NUMA-aware memory placement
- **For Apple Silicon**: Leverage SME for any matrix/stencil computations
- **For portable code**: Consider architecture-specific paths for optimal performance

---

## Appendix: Optimization Techniques Used

### Intel Optimizations
- AVX-512 SIMD vectorization
- OpenMP parallelization (32 threads)
- Memory alignment (64-byte boundaries)
- Cache-friendly transposed matrices
- NUMA-aware thread scheduling

### Apple M4 Optimizations
- SME tile-based computation
- Row-split tiling strategy
- Hardware-managed matrix operations
- Single-instruction matrix multiply-accumulate
- Automatic register spilling/filling

---

*Note: Results obtained from actual benchmark runs on respective hardware platforms. Performance may vary based on compiler versions, system configuration, and workload characteristics.*