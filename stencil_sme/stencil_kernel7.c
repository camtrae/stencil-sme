/**
 * @file stencil_3x3_sme_optimized.c
 * @brief ARM SME optimized 3×3 stencil computation with multiple optimization strategies
 * @author ZHANGFAN (modified)
 * @date 2025/9/26 (modified)
 * 
 * This implementation demonstrates various optimization techniques for stencil computation:
 * - Baseline direct convolution
 * - Im2Row transformation with GEMV
 * - Stencil2Row with direct matrix multiplication
 * - SME single-tile acceleration
 * - SME 4-tiles parallel processing (column-split and row-split)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <arm_sme.h>

// ============================================================================
// Configuration Parameters
// ============================================================================
#define KERNEL_SIZE 7
#define KERNEL_RADIUS (KERNEL_SIZE / 2)
#define KERNEL_ELEMENTS (KERNEL_SIZE * KERNEL_SIZE)  // 9

#define ORIGINAL_SIZE 256
#define PADDING KERNEL_RADIUS  // For 3×3 kernel
#define INPUT_SIZE (ORIGINAL_SIZE + 2 * PADDING)
#define OUTPUT_SIZE ORIGINAL_SIZE

// Performance test configuration
#define WARMUP_ITERATIONS 5
#define TEST_ITERATIONS 20

// SME configuration
#define SME_TILE_SIZE 16
#define GROUPSIZE (KERNEL_SIZE + 1)  // 4 for 3×3 kernel
#define WEIGHT_COLS GROUPSIZE  // Weight matrix is 9×4
#define PADDED_WEIGHT_COLS 16  // Padded to 16 for SME
#define PADDED_STENCIL_COLS 64  // Padded to multiple of 16 for SME alignment

// Utility macros
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

// ============================================================================
// Data Structures
// ============================================================================
typedef struct {
    double mean;
    double std_dev;
    double min;
    double max;
} PerfStats;

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * @brief Get current time in microseconds
 * @return Current time in microseconds
 */
double get_time_us() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000000.0 + ts.tv_nsec / 1000.0;
}

/**
 * @brief Calculate performance statistics from timing data
 * @param times Array of timing measurements
 * @param n Number of measurements
 * @return Performance statistics (mean, std_dev, min, max)
 */
PerfStats calculate_stats(double* times, int n) {
    PerfStats stats;
    stats.mean = 0;
    stats.min = times[0];
    stats.max = times[0];
    
    // Calculate mean, min, max
    for (int i = 0; i < n; i++) {
        stats.mean += times[i];
        if (times[i] < stats.min) stats.min = times[i];
        if (times[i] > stats.max) stats.max = times[i];
    }
    stats.mean /= n;
    
    // Calculate standard deviation
    stats.std_dev = 0;
    for (int i = 0; i < n; i++) {
        double diff = times[i] - stats.mean;
        stats.std_dev += diff * diff;
    }
    stats.std_dev = sqrt(stats.std_dev / n);
    
    return stats;
}

/**
 * @brief Initialize input data and kernel
 * @param input Input matrix with padding (output)
 * @param kernel Convolution kernel (output)
 * @param original_data Original data before padding (output)
 */
void initialize_data(float* input, float* kernel, float* original_data) {
    // Initialize original data with test pattern
    for (int i = 0; i < ORIGINAL_SIZE; i++) {
        for (int j = 0; j < ORIGINAL_SIZE; j++) {
            original_data[i * ORIGINAL_SIZE + j] = (i + j) % 100 + 1;
        }
    }
    
    // Clear input and add padding
    memset(input, 0, INPUT_SIZE * INPUT_SIZE * sizeof(float));
    for (int i = 0; i < ORIGINAL_SIZE; i++) {
        for (int j = 0; j < ORIGINAL_SIZE; j++) {
            input[(i + PADDING) * INPUT_SIZE + (j + PADDING)] = 
                original_data[i * ORIGINAL_SIZE + j];
        }
    }
    
    // Initialize kernel as averaging filter (3×3)
    for (int i = 0; i < KERNEL_ELEMENTS; i++) {
        kernel[i] = 1.0f / KERNEL_ELEMENTS;
    }
}

/**
 * @brief Verify results between two implementations
 * @param result1 First result array
 * @param result2 Second result array
 * @param size Number of elements to compare
 * @param name1 Name of first implementation
 * @param name2 Name of second implementation
 * @return 1 if results match within tolerance, 0 otherwise
 */
int verify_results(const float* result1, const float* result2, int size, 
                   const char* name1, const char* name2) {
    const float TOLERANCE = 1e-3f;
    float max_diff = 0.0f;
    int diff_count = 0;
    
    for (int i = 0; i < size; i++) {
        float diff = fabs(result1[i] - result2[i]);
        if (diff > max_diff) max_diff = diff;
        if (diff > TOLERANCE) diff_count++;
    }
    
    printf("Verify %s vs %s:\n", name1, name2);
    printf("  Max difference: %.9e\n", max_diff);
    printf("  Different points: %d / %d\n", diff_count, size);
    
    return max_diff < TOLERANCE;
}

// ============================================================================
// Traditional CPU Baseline (Direct Convolution)
// ============================================================================

/**
 * @brief CPU baseline implementation using direct convolution
 * @param input Input matrix with padding
 * @param output Output matrix
 * @param kernel Convolution kernel
 */
void cpu_stencil_baseline(const float* input, float* output, const float* kernel) {
    for (int row = 0; row < OUTPUT_SIZE; row++) {
        for (int col = 0; col < OUTPUT_SIZE; col++) {
            float sum = 0.0f;
            
            // Apply convolution kernel
            for (int ki = 0; ki < KERNEL_SIZE; ki++) {
                for (int kj = 0; kj < KERNEL_SIZE; kj++) {
                    int in_row = row + ki;
                    int in_col = col + kj;
                    
                    sum += kernel[ki * KERNEL_SIZE + kj] * 
                           input[in_row * INPUT_SIZE + in_col];
                }
            }
            
            output[row * OUTPUT_SIZE + col] = sum;
        }
    }
}

// ============================================================================
// Im2Row Implementation
// ============================================================================

/**
 * @brief Transform input to row format for matrix multiplication
 * @param input Input matrix with padding
 * @param row_matrix Output row matrix
 */
void im2row(const float* input, float* row_matrix) {
    int row_idx = 0;
    
    for (int out_row = 0; out_row < OUTPUT_SIZE; out_row++) {
        for (int out_col = 0; out_col < OUTPUT_SIZE; out_col++) {
            int col_idx = 0;
            for (int ki = 0; ki < KERNEL_SIZE; ki++) {
                for (int kj = 0; kj < KERNEL_SIZE; kj++) {
                    int in_row = out_row + ki;
                    int in_col = out_col + kj;
                    
                    row_matrix[row_idx * KERNEL_ELEMENTS + col_idx] = 
                        input[in_row * INPUT_SIZE + in_col];
                    col_idx++;
                }
            }
            row_idx++;
        }
    }
}

/**
 * @brief CPU matrix-vector multiplication after Im2Row transformation
 * @param row_matrix Row matrix from Im2Row
 * @param kernel Kernel as vector
 * @param output Output vector
 * @return Execution time in microseconds
 */
double cpu_im2row_gemv(const float* row_matrix, const float* kernel, float* output) {
    int m = OUTPUT_SIZE * OUTPUT_SIZE;
    int n = KERNEL_ELEMENTS;
    
    double t1 = get_time_us();
    
    // Matrix-vector multiplication: output = row_matrix * kernel
    for (int i = 0; i < m; i++) {
        float sum = 0.0f;
        for (int j = 0; j < n; j++) {
            sum += row_matrix[i * n + j] * kernel[j];
        }
        output[i] = sum;
    }
    
    double t2 = get_time_us();
    return t2 - t1;
}

// ============================================================================
// Stencil2Row Implementation
// ============================================================================

/**
 * @brief Extract stencil from input at specified position
 * @param input Input matrix with padding
 * @param row Row position
 * @param col Column position
 * @param stencil Output stencil array
 */
void getStencil(const float* input, int row, int col, float* stencil) {
    memset(stencil, 0, KERNEL_ELEMENTS * sizeof(float));
    
    if (row >= KERNEL_RADIUS && row < INPUT_SIZE - KERNEL_RADIUS && 
        col >= KERNEL_RADIUS && col < INPUT_SIZE - KERNEL_RADIUS) {
        
        int base_row = row - KERNEL_RADIUS;
        int base_col = col - KERNEL_RADIUS;
        
        for (int i = 0; i < KERNEL_SIZE; i++) {
            for (int j = 0; j < KERNEL_SIZE; j++) {
                int kernel_row = base_row + i;
                int kernel_col = base_col + j;
                stencil[i * KERNEL_SIZE + j] = input[kernel_row * INPUT_SIZE + kernel_col];
            }
        }
    }
}

/**
 * @brief Transform input to stencil2row format
 * @param input Input matrix with padding
 * @param matrix_A_out First output matrix (allocated inside)
 * @param matrix_B_out Second output matrix (allocated inside)
 * @param out_rows Number of output rows
 * @param out_cols Number of output columns
 */
void stencil2row(const float* input, float** matrix_A_out, float** matrix_B_out, 
                 int* out_rows, int* out_cols) {
    int groupsize = GROUPSIZE;  // 4 for 3×3 kernel
    
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    
    // Calculate total groups
    int total_groups = 0;
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            total_groups++;
        }
    }
    
    *out_rows = total_groups;
    *out_cols = KERNEL_ELEMENTS;  // 9
    
    // Allocate matrices
    float* matrix_A = (float*)malloc((*out_rows) * (*out_cols) * sizeof(float));
    float* matrix_B = (float*)malloc((*out_rows) * (*out_cols) * sizeof(float));
    
    if (!matrix_A || !matrix_B) {
        fprintf(stderr, "Error: stencil2row memory allocation failed\n");
        if (matrix_A) free(matrix_A);
        if (matrix_B) free(matrix_B);
        *matrix_A_out = NULL;
        *matrix_B_out = NULL;
        return;
    }
    
    memset(matrix_A, 0, (*out_rows) * (*out_cols) * sizeof(float));
    memset(matrix_B, 0, (*out_rows) * (*out_cols) * sizeof(float));
    
    int matrix_row = 0;
    
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            int group_start = j;
            int group_end = MIN(j + groupsize - 1, valid_end - 1);
            
            getStencil(input, i, group_start, &matrix_A[matrix_row * (*out_cols)]);
            getStencil(input, i, group_end, &matrix_B[matrix_row * (*out_cols)]);
            
            matrix_row++;
        }
    }
    
    *matrix_A_out = matrix_A;
    *matrix_B_out = matrix_B;
}

/**
 * @brief Transform kernel to column format for stencil2row
 * @param kernel Input kernel
 * @param weight_A First weight matrix (output)
 * @param weight_B Second weight matrix (output)
 */
void kernel2col(const float* kernel, float* weight_A, float* weight_B) {
    memset(weight_A, 0, KERNEL_ELEMENTS * WEIGHT_COLS * sizeof(float));
    memset(weight_B, 0, KERNEL_ELEMENTS * WEIGHT_COLS * sizeof(float));
    
    for (int row = 0; row < KERNEL_SIZE * KERNEL_SIZE; row++) {
        int kernel_i = row / KERNEL_SIZE;
        int kernel_j = row % KERNEL_SIZE;
        
        for (int col = 0; col < WEIGHT_COLS; col++) {
            if (kernel_j >= col) {
                weight_A[row * WEIGHT_COLS + col] = 
                    kernel[kernel_i * KERNEL_SIZE + (kernel_j - col)];
            }
            
            if (kernel_j < col) {
                weight_B[row * WEIGHT_COLS + col] = 
                    kernel[kernel_i * KERNEL_SIZE + (kernel_j + KERNEL_SIZE - col)];
            }
        }
    }
}

/**
 * @brief CPU stencil2row with direct matrix multiplication
 * @param matrix_A First stencil matrix
 * @param matrix_B Second stencil matrix
 * @param weight_A First weight matrix
 * @param weight_B Second weight matrix
 * @param result_combined Combined result output
 * @param stencil_rows Number of rows
 * @param stencil_cols Number of columns
 * @return Execution time in microseconds
 */
double cpu_stencil2row_direct(const float* matrix_A, const float* matrix_B,
                              const float* weight_A, const float* weight_B,
                              float* result_combined,
                              int stencil_rows, int stencil_cols) {
    float* result_A = (float*)malloc(stencil_rows * WEIGHT_COLS * sizeof(float));
    float* result_B = (float*)malloc(stencil_rows * WEIGHT_COLS * sizeof(float));
    
    if (!result_A || !result_B) {
        fprintf(stderr, "Error: Result allocation failed\n");
        if (result_A) free(result_A);
        if (result_B) free(result_B);
        return 0;
    }
    
    memset(result_A, 0, stencil_rows * WEIGHT_COLS * sizeof(float));
    memset(result_B, 0, stencil_rows * WEIGHT_COLS * sizeof(float));
    
    double t1 = get_time_us();
    
    // Matrix multiplication: result = matrix * weight
    for (int i = 0; i < stencil_rows; i++) {
        for (int j = 0; j < WEIGHT_COLS; j++) {
            float sum_a = 0.0f;
            float sum_b = 0.0f;
            for (int k = 0; k < stencil_cols; k++) {
                sum_a += matrix_A[i * stencil_cols + k] * weight_A[k * WEIGHT_COLS + j];
                sum_b += matrix_B[i * stencil_cols + k] * weight_B[k * WEIGHT_COLS + j];
            }
            result_A[i * WEIGHT_COLS + j] = sum_a;
            result_B[i * WEIGHT_COLS + j] = sum_b;
        }
    }
    
    // Combine results
    for (int i = 0; i < stencil_rows * WEIGHT_COLS; i++) {
        result_combined[i] = result_A[i] + result_B[i];
    }
    
    double t2 = get_time_us();
    
    free(result_A);
    free(result_B);
    
    return t2 - t1;
}

/**
 * @brief Reorganize stencil2row output to final format
 * @param result_combined Combined stencil2row result
 * @param output Final output matrix
 * @param weight_cols Number of weight columns
 */
void reorganize_stencil2row_output(const float* result_combined, float* output, int weight_cols) {
    int groupsize = GROUPSIZE;  // 4 for 3×3 kernel
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    
    memset(output, 0, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    
    int result_idx = 0;
    for (int i = 0; i < OUTPUT_SIZE; i++) {
        int out_col = 0;
        for (int j = valid_start; j < valid_end && out_col < OUTPUT_SIZE; j += groupsize) {
            int group_size_actual = MIN(groupsize, valid_end - j);
            
            for (int k = 0; k < group_size_actual && out_col < OUTPUT_SIZE; k++) {
                output[i * OUTPUT_SIZE + out_col] = result_combined[result_idx * weight_cols + k];
                out_col++;
            }
            result_idx++;
        }
    }
}

// ============================================================================
// SME Functions - Enhanced with 4-tiles optimization
// ============================================================================

/**
 * @brief Preprocess left matrix for SME kernel
 * Rearranges data for optimal SME tile access patterns
 */
void preprocess_left_matrix_sme_kernel(const float *A, float *A_mod, 
                                       uint64_t M, uint64_t K, uint64_t SVL) 
                                       __arm_streaming __arm_inout("za") {
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    
    for (uint64_t row = 0; row < M; row += SVL) {
        svbool_t pMDim = svwhilelt_b32(row, M);
        
        for (uint64_t col = 0; col < K; col += 2 * SVL) {
            svcount_t pKDim = svwhilelt_c32(col, K, 2);
            
            // Load and transpose data into ZA tiles
            for (uint64_t trow = 0; trow < SVL; trow += 4) {
                svcount_t p0 = svpsel_lane_c32(pKDim, pMDim, trow + 0);
                svcount_t p1 = svpsel_lane_c32(pKDim, pMDim, trow + 1);
                svcount_t p2 = svpsel_lane_c32(pKDim, pMDim, trow + 2);
                svcount_t p3 = svpsel_lane_c32(pKDim, pMDim, trow + 3);
                
                const uint64_t tile_UL_corner = (row + trow) * K + col;
                
                svfloat32x2_t zp0 = svld1_x2(p0, &A[tile_UL_corner + 0 * K]);
                svfloat32x2_t zp1 = svld1_x2(p1, &A[tile_UL_corner + 1 * K]);
                svfloat32x2_t zp2 = svld1_x2(p2, &A[tile_UL_corner + 2 * K]);
                svfloat32x2_t zp3 = svld1_x2(p3, &A[tile_UL_corner + 3 * K]);
                
                svfloat32x4_t zq0 = svcreate4(svget2(zp0, 0), svget2(zp1, 0),
                                              svget2(zp2, 0), svget2(zp3, 0));
                svfloat32x4_t zq1 = svcreate4(svget2(zp0, 1), svget2(zp1, 1),
                                              svget2(zp2, 1), svget2(zp3, 1));
                
                svwrite_hor_za32_f32_vg4(0, trow, zq0);
                svwrite_hor_za32_f32_vg4(1, trow, zq1);
            }
            
            // Store transposed data
            const uint64_t dest_0 = row * K + col * SVL;
            const uint64_t dest_1 = dest_0 + SVL * SVL;
            
            for (uint64_t tcol = 0; tcol < SVL; tcol += 4) {
                svcount_t p0 = svwhilelt_c32(dest_0 + tcol * SVL, K * M_mod, 4);
                svcount_t p1 = svwhilelt_c32(dest_1 + tcol * SVL, K * M_mod, 4);
                
                svfloat32x4_t zq0 = svread_ver_za32_f32_vg4(0, tcol);
                svfloat32x4_t zq1 = svread_ver_za32_f32_vg4(1, tcol);
                
                svst1(p0, &A_mod[dest_0 + tcol * SVL], zq0);
                svst1(p1, &A_mod[dest_1 + tcol * SVL], zq1);
            }
        }
    }
}

/**
 * @brief SME kernel using single tile
 * Basic SME matrix multiplication using one ZA tile
 */
void matmul_sme_kernel(const float *A_mod, const float *B, float *C,
                      uint64_t M, uint64_t K, uint64_t N, uint64_t SVL) 
                      __arm_streaming __arm_inout("za") {
    
    for (uint64_t row = 0; row < M; row += SVL) {
        svbool_t pMDim = svwhilelt_b32(row, M);
        
        for (uint64_t col = 0; col < N; col += SVL) {
            svbool_t pNDim = svwhilelt_b32(col, N);
            
            svzero_za();
            
            const uint64_t matLeft_pos = row * K;
            const uint64_t matRight_UL_corner = col;
            
            // Accumulate outer products
            for (uint64_t k = 0; k < K; k++) {
                svfloat32_t zL = svld1(pMDim, &A_mod[matLeft_pos + k * SVL]);
                svfloat32_t zR = svld1(pNDim, &B[matRight_UL_corner + k * N]);
                svmopa_za32_m(0, pMDim, pNDim, zL, zR);
            }
            
            // Store results
            const uint64_t result_tile_UL_corner = row * N + col;
            for (uint64_t trow = 0; trow < SVL && row + trow < M; trow += 4) {
                svbool_t p0 = svpsel_lane_b32(pNDim, pMDim, row + trow + 0);
                svbool_t p1 = svpsel_lane_b32(pNDim, pMDim, row + trow + 1);
                svbool_t p2 = svpsel_lane_b32(pNDim, pMDim, row + trow + 2);
                svbool_t p3 = svpsel_lane_b32(pNDim, pMDim, row + trow + 3);
                
                svst1_hor_za32(0, trow + 0, p0, 
                    &C[result_tile_UL_corner + (trow + 0) * N]);
                svst1_hor_za32(0, trow + 1, p1, 
                    &C[result_tile_UL_corner + (trow + 1) * N]);
                svst1_hor_za32(0, trow + 2, p2, 
                    &C[result_tile_UL_corner + (trow + 2) * N]);
                svst1_hor_za32(0, trow + 3, p3, 
                    &C[result_tile_UL_corner + (trow + 3) * N]);
            }
        }
    }
}

/**
 * @brief SME kernel using 4 tiles - Column Split
 * Processes 4 column blocks simultaneously for better tile utilization
 */
void matmul_sme_kernel_4tiles(const float *A_mod, const float *B, float *C,
                              uint64_t M, uint64_t K, uint64_t N, uint64_t SVL) 
                              __arm_streaming __arm_inout("za") {
    
    for (uint64_t row = 0; row < M; row += SVL) {
        svbool_t pMDim = svwhilelt_b32(row, M);
        
        // Process 4 column blocks at once
        for (uint64_t col = 0; col < N; col += 4 * SVL) {
            // Prepare predicates for 4 column blocks
            svbool_t pNDim0 = svwhilelt_b32(col, N);
            svbool_t pNDim1 = svwhilelt_b32(col + SVL, N);
            svbool_t pNDim2 = svwhilelt_b32(col + 2*SVL, N);
            svbool_t pNDim3 = svwhilelt_b32(col + 3*SVL, N);
            
            // Zero all 4 accumulators
            svzero_za();
            
            // Execute outer product accumulation using all 4 tiles
            const uint64_t matLeft_pos = row * K;
            
            for (uint64_t k = 0; k < K; k++) {
                // Load left matrix column vector (shared by all 4 tiles)
                svfloat32_t zL = svld1(pMDim, &A_mod[matLeft_pos + k * SVL]);
                
                // Process each column block
                if (col < N) {
                    svfloat32_t zR0 = svld1(pNDim0, &B[col + k * N]);
                    svmopa_za32_m(0, pMDim, pNDim0, zL, zR0);
                }
                
                if (col + SVL < N) {
                    svfloat32_t zR1 = svld1(pNDim1, &B[col + SVL + k * N]);
                    svmopa_za32_m(1, pMDim, pNDim1, zL, zR1);
                }
                
                if (col + 2*SVL < N) {
                    svfloat32_t zR2 = svld1(pNDim2, &B[col + 2*SVL + k * N]);
                    svmopa_za32_m(2, pMDim, pNDim2, zL, zR2);
                }
                
                if (col + 3*SVL < N) {
                    svfloat32_t zR3 = svld1(pNDim3, &B[col + 3*SVL + k * N]);
                    svmopa_za32_m(3, pMDim, pNDim3, zL, zR3);
                }
            }
            
            // Store results from all 4 ZA tiles
            for (uint64_t trow = 0; trow < SVL && row + trow < M; trow += 4) {
                // Tile 0
                if (col < N) {
                    svbool_t p0 = svpsel_lane_b32(pNDim0, pMDim, row + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim0, pMDim, row + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim0, pMDim, row + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim0, pMDim, row + trow + 3);
                    
                    svst1_hor_za32(0, trow + 0, p0, &C[(row + trow + 0) * N + col]);
                    svst1_hor_za32(0, trow + 1, p1, &C[(row + trow + 1) * N + col]);
                    svst1_hor_za32(0, trow + 2, p2, &C[(row + trow + 2) * N + col]);
                    svst1_hor_za32(0, trow + 3, p3, &C[(row + trow + 3) * N + col]);
                }
                
                // Tile 1
                if (col + SVL < N) {
                    svbool_t p0 = svpsel_lane_b32(pNDim1, pMDim, row + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim1, pMDim, row + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim1, pMDim, row + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim1, pMDim, row + trow + 3);
                    
                    svst1_hor_za32(1, trow + 0, p0, &C[(row + trow + 0) * N + col + SVL]);
                    svst1_hor_za32(1, trow + 1, p1, &C[(row + trow + 1) * N + col + SVL]);
                    svst1_hor_za32(1, trow + 2, p2, &C[(row + trow + 2) * N + col + SVL]);
                    svst1_hor_za32(1, trow + 3, p3, &C[(row + trow + 3) * N + col + SVL]);
                }
                
                // Tile 2
                if (col + 2*SVL < N) {
                    svbool_t p0 = svpsel_lane_b32(pNDim2, pMDim, row + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim2, pMDim, row + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim2, pMDim, row + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim2, pMDim, row + trow + 3);
                    
                    svst1_hor_za32(2, trow + 0, p0, &C[(row + trow + 0) * N + col + 2*SVL]);
                    svst1_hor_za32(2, trow + 1, p1, &C[(row + trow + 1) * N + col + 2*SVL]);
                    svst1_hor_za32(2, trow + 2, p2, &C[(row + trow + 2) * N + col + 2*SVL]);
                    svst1_hor_za32(2, trow + 3, p3, &C[(row + trow + 3) * N + col + 2*SVL]);
                }
                
                // Tile 3
                if (col + 3*SVL < N) {
                    svbool_t p0 = svpsel_lane_b32(pNDim3, pMDim, row + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim3, pMDim, row + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim3, pMDim, row + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim3, pMDim, row + trow + 3);
                    
                    svst1_hor_za32(3, trow + 0, p0, &C[(row + trow + 0) * N + col + 3*SVL]);
                    svst1_hor_za32(3, trow + 1, p1, &C[(row + trow + 1) * N + col + 3*SVL]);
                    svst1_hor_za32(3, trow + 2, p2, &C[(row + trow + 2) * N + col + 3*SVL]);
                    svst1_hor_za32(3, trow + 3, p3, &C[(row + trow + 3) * N + col + 3*SVL]);
                }
            }
        }
    }
}

/**
 * @brief SME kernel using 4 tiles - Row Split
 * Processes 4 row blocks simultaneously for different parallelization strategy
 */
void matmul_sme_kernel_4tiles_row_split(const float *A_mod, const float *B, float *C,
                                        uint64_t M, uint64_t K, uint64_t N, uint64_t SVL) 
                                        __arm_streaming __arm_inout("za") {
    
    // Process 4 row blocks at once
    for (uint64_t row = 0; row < M; row += 4 * SVL) {
        // Prepare predicates for 4 row blocks
        svbool_t pMDim0 = svwhilelt_b32(row, M);
        svbool_t pMDim1 = svwhilelt_b32(row + SVL, M);
        svbool_t pMDim2 = svwhilelt_b32(row + 2*SVL, M);
        svbool_t pMDim3 = svwhilelt_b32(row + 3*SVL, M);
        
        // For each column block in B matrix
        for (uint64_t col = 0; col < N; col += SVL) {
            svbool_t pNDim = svwhilelt_b32(col, N);
            
            // Zero all 4 accumulators
            svzero_za();
            
            // Execute outer product accumulation - 4 row blocks simultaneously
            for (uint64_t k = 0; k < K; k++) {
                // Load B matrix column vector (shared by all 4 tiles)
                svfloat32_t zR = svld1(pNDim, &B[col + k * N]);
                
                // Process each row block
                if (row < M) {
                    const uint64_t matLeft_pos0 = row * K;
                    svfloat32_t zL0 = svld1(pMDim0, &A_mod[matLeft_pos0 + k * SVL]);
                    svmopa_za32_m(0, pMDim0, pNDim, zL0, zR);
                }
                
                if (row + SVL < M) {
                    const uint64_t matLeft_pos1 = (row + SVL) * K;
                    svfloat32_t zL1 = svld1(pMDim1, &A_mod[matLeft_pos1 + k * SVL]);
                    svmopa_za32_m(1, pMDim1, pNDim, zL1, zR);
                }
                
                if (row + 2*SVL < M) {
                    const uint64_t matLeft_pos2 = (row + 2*SVL) * K;
                    svfloat32_t zL2 = svld1(pMDim2, &A_mod[matLeft_pos2 + k * SVL]);
                    svmopa_za32_m(2, pMDim2, pNDim, zL2, zR);
                }
                
                if (row + 3*SVL < M) {
                    const uint64_t matLeft_pos3 = (row + 3*SVL) * K;
                    svfloat32_t zL3 = svld1(pMDim3, &A_mod[matLeft_pos3 + k * SVL]);
                    svmopa_za32_m(3, pMDim3, pNDim, zL3, zR);
                }
            }
            
            // Store results from 4 ZA tiles
            // Tile 0: Store 1st row block results
            if (row < M) {
                for (uint64_t trow = 0; trow < SVL && row + trow < M; trow += 4) {
                    svbool_t p0 = svpsel_lane_b32(pNDim, pMDim0, row + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim, pMDim0, row + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim, pMDim0, row + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim, pMDim0, row + trow + 3);
                    
                    svst1_hor_za32(0, trow + 0, p0, &C[(row + trow + 0) * N + col]);
                    svst1_hor_za32(0, trow + 1, p1, &C[(row + trow + 1) * N + col]);
                    svst1_hor_za32(0, trow + 2, p2, &C[(row + trow + 2) * N + col]);
                    svst1_hor_za32(0, trow + 3, p3, &C[(row + trow + 3) * N + col]);
                }
            }
            
            // Tile 1: Store 2nd row block results
            if (row + SVL < M) {
                for (uint64_t trow = 0; trow < SVL && row + SVL + trow < M; trow += 4) {
                    svbool_t p0 = svpsel_lane_b32(pNDim, pMDim1, row + SVL + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim, pMDim1, row + SVL + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim, pMDim1, row + SVL + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim, pMDim1, row + SVL + trow + 3);
                    
                    svst1_hor_za32(1, trow + 0, p0, &C[(row + SVL + trow + 0) * N + col]);
                    svst1_hor_za32(1, trow + 1, p1, &C[(row + SVL + trow + 1) * N + col]);
                    svst1_hor_za32(1, trow + 2, p2, &C[(row + SVL + trow + 2) * N + col]);
                    svst1_hor_za32(1, trow + 3, p3, &C[(row + SVL + trow + 3) * N + col]);
                }
            }
            
            // Tile 2: Store 3rd row block results
            if (row + 2*SVL < M) {
                for (uint64_t trow = 0; trow < SVL && row + 2*SVL + trow < M; trow += 4) {
                    svbool_t p0 = svpsel_lane_b32(pNDim, pMDim2, row + 2*SVL + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim, pMDim2, row + 2*SVL + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim, pMDim2, row + 2*SVL + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim, pMDim2, row + 2*SVL + trow + 3);
                    
                    svst1_hor_za32(2, trow + 0, p0, &C[(row + 2*SVL + trow + 0) * N + col]);
                    svst1_hor_za32(2, trow + 1, p1, &C[(row + 2*SVL + trow + 1) * N + col]);
                    svst1_hor_za32(2, trow + 2, p2, &C[(row + 2*SVL + trow + 2) * N + col]);
                    svst1_hor_za32(2, trow + 3, p3, &C[(row + 2*SVL + trow + 3) * N + col]);
                }
            }
            
            // Tile 3: Store 4th row block results
            if (row + 3*SVL < M) {
                for (uint64_t trow = 0; trow < SVL && row + 3*SVL + trow < M; trow += 4) {
                    svbool_t p0 = svpsel_lane_b32(pNDim, pMDim3, row + 3*SVL + trow + 0);
                    svbool_t p1 = svpsel_lane_b32(pNDim, pMDim3, row + 3*SVL + trow + 1);
                    svbool_t p2 = svpsel_lane_b32(pNDim, pMDim3, row + 3*SVL + trow + 2);
                    svbool_t p3 = svpsel_lane_b32(pNDim, pMDim3, row + 3*SVL + trow + 3);
                    
                    svst1_hor_za32(3, trow + 0, p0, &C[(row + 3*SVL + trow + 0) * N + col]);
                    svst1_hor_za32(3, trow + 1, p1, &C[(row + 3*SVL + trow + 1) * N + col]);
                    svst1_hor_za32(3, trow + 2, p2, &C[(row + 3*SVL + trow + 2) * N + col]);
                    svst1_hor_za32(3, trow + 3, p3, &C[(row + 3*SVL + trow + 3) * N + col]);
                }
            }
        }
    }
}

// ============================================================================
// SME Wrapper Functions
// ============================================================================

/**
 * @brief Wrapper for SME single tile matrix multiplication
 */
__arm_new("za") __arm_locally_streaming
void matmul_sme_single_tile(const float *A, const float *B, float *C,
                           uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    if (!A_mod) {
        fprintf(stderr, "Error: SME memory allocation failed\n");
        return;
    }
    
    preprocess_left_matrix_sme_kernel(A, A_mod, M, K, SVL);
    matmul_sme_kernel(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

/**
 * @brief Wrapper for SME 4-tiles column split matrix multiplication
 */
__arm_new("za") __arm_locally_streaming
void matmul_sme_4tiles(const float *A, const float *B, float *C,
                       uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    if (!A_mod) {
        fprintf(stderr, "Error: SME 4-tiles memory allocation failed\n");
        return;
    }
    
    preprocess_left_matrix_sme_kernel(A, A_mod, M, K, SVL);
    matmul_sme_kernel_4tiles(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

/**
 * @brief Wrapper for SME 4-tiles row split matrix multiplication
 */
__arm_new("za") __arm_locally_streaming
void matmul_sme_4tiles_row_split(const float *A, const float *B, float *C,
                                 uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    if (!A_mod) {
        fprintf(stderr, "Error: SME 4-tiles row-split memory allocation failed\n");
        return;
    }
    
    preprocess_left_matrix_sme_kernel(A, A_mod, M, K, SVL);
    matmul_sme_kernel_4tiles_row_split(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

// ============================================================================
// SME Support Functions for Stencil2Row
// ============================================================================

/**
 * @brief Get padded stencil for SME alignment
 */
void getStencilPadded(const float* input, int row, int col, float* stencil) {
    memset(stencil, 0, PADDED_STENCIL_COLS * sizeof(float));
    
    if (row >= KERNEL_RADIUS && row < INPUT_SIZE - KERNEL_RADIUS && 
        col >= KERNEL_RADIUS && col < INPUT_SIZE - KERNEL_RADIUS) {
        
        int base_row = row - KERNEL_RADIUS;
        int base_col = col - KERNEL_RADIUS;
        
        for (int i = 0; i < KERNEL_SIZE; i++) {
            for (int j = 0; j < KERNEL_SIZE; j++) {
                int kernel_row = base_row + i;
                int kernel_col = base_col + j;
                stencil[i * KERNEL_SIZE + j] = input[kernel_row * INPUT_SIZE + kernel_col];
            }
        }
    }
}

/**
 * @brief Create padded stencil2row matrices for SME
 */
void stencil2row_sme_padded(const float* input, float** matrix_A_out, float** matrix_B_out, 
                            int* out_rows, int* out_cols, int* total_groups_out) {
    int groupsize = GROUPSIZE;  // 4 for 3×3 kernel
    
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    
    int total_groups = 0;
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            total_groups++;
        }
    }
    
    // Pad rows to multiple of 64 for optimal SME performance
    int padded_rows = ((total_groups + 63) / 64) * 64;
    
    *out_rows = padded_rows;
    *out_cols = PADDED_STENCIL_COLS;
    *total_groups_out = total_groups;
    
    float* matrix_A = (float*)aligned_alloc(64, (*out_rows) * (*out_cols) * sizeof(float));
    float* matrix_B = (float*)aligned_alloc(64, (*out_rows) * (*out_cols) * sizeof(float));
    
    if (!matrix_A || !matrix_B) {
        fprintf(stderr, "Error: SME padded memory allocation failed\n");
        if (matrix_A) free(matrix_A);
        if (matrix_B) free(matrix_B);
        *matrix_A_out = NULL;
        *matrix_B_out = NULL;
        return;
    }
    
    memset(matrix_A, 0, (*out_rows) * (*out_cols) * sizeof(float));
    memset(matrix_B, 0, (*out_rows) * (*out_cols) * sizeof(float));
    
    float* temp_stencil = (float*)malloc(PADDED_STENCIL_COLS * sizeof(float));
    if (!temp_stencil) {
        fprintf(stderr, "Error: Temp stencil allocation failed\n");
        free(matrix_A);
        free(matrix_B);
        *matrix_A_out = NULL;
        *matrix_B_out = NULL;
        return;
    }
    
    int matrix_row = 0;
    
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            int group_start = j;
            int group_end = MIN(j + groupsize - 1, valid_end - 1);
            
            getStencilPadded(input, i, group_start, temp_stencil);
            for (int k = 0; k < PADDED_STENCIL_COLS; k++) {
                matrix_A[matrix_row * (*out_cols) + k] = temp_stencil[k];
            }
            
            getStencilPadded(input, i, group_end, temp_stencil);
            for (int k = 0; k < PADDED_STENCIL_COLS; k++) {
                matrix_B[matrix_row * (*out_cols) + k] = temp_stencil[k];
            }
            
            matrix_row++;
        }
    }
    
    free(temp_stencil);
    
    *matrix_A_out = matrix_A;
    *matrix_B_out = matrix_B;
}

/**
 * @brief Create padded kernel2col matrices for SME
 */
void kernel2col_padded(const float* kernel, float** weight_A_out, float** weight_B_out) {
    int padded_rows = PADDED_STENCIL_COLS;  // 16
    int padded_cols = PADDED_WEIGHT_COLS;   // 16
    
    float* weight_A = (float*)aligned_alloc(64, padded_rows * padded_cols * sizeof(float));
    float* weight_B = (float*)aligned_alloc(64, padded_rows * padded_cols * sizeof(float));
    
    if (!weight_A || !weight_B) {
        fprintf(stderr, "Error: kernel2col_padded allocation failed\n");
        if (weight_A) free(weight_A);
        if (weight_B) free(weight_B);
        *weight_A_out = NULL;
        *weight_B_out = NULL;
        return;
    }
    
    memset(weight_A, 0, padded_rows * padded_cols * sizeof(float));
    memset(weight_B, 0, padded_rows * padded_cols * sizeof(float));
    
    // Fill the non-padded portion (9×4 area) with actual kernel values
    for (int row = 0; row < KERNEL_ELEMENTS; row++) {
        int kernel_i = row / KERNEL_SIZE;
        int kernel_j = row % KERNEL_SIZE;
        
        for (int col = 0; col < WEIGHT_COLS; col++) {  // WEIGHT_COLS is 4
            if (kernel_j >= col) {
                weight_A[row * padded_cols + col] = 
                    kernel[kernel_i * KERNEL_SIZE + (kernel_j - col)];
            }
            
            if (kernel_j < col) {
                weight_B[row * padded_cols + col] = 
                    kernel[kernel_i * KERNEL_SIZE + (kernel_j + KERNEL_SIZE - col)];
            }
        }
    }
    
    *weight_A_out = weight_A;
    *weight_B_out = weight_B;
}

/**
 * @brief SME stencil2row computation with single tile
 */
double cpu_stencil2row_sme_single(const float* matrix_A, const float* matrix_B,
                                  const float* weight_A, const float* weight_B,
                                  float** result_combined_out,
                                  int stencil_rows, int stencil_cols) {
    float* result_A = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_B = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_combined = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    if (!result_A || !result_B || !result_combined) {
        fprintf(stderr, "Error: SME single tile result allocation failed\n");
        if (result_A) free(result_A);
        if (result_B) free(result_B);
        if (result_combined) free(result_combined);
        *result_combined_out = NULL;
        return 0;
    }
    
    memset(result_A, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_B, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_combined, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    double t1 = get_time_us();
    
    matmul_sme_single_tile(matrix_A, weight_A, result_A, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    matmul_sme_single_tile(matrix_B, weight_B, result_B, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    
    for (int i = 0; i < stencil_rows * PADDED_WEIGHT_COLS; i++) {
        result_combined[i] = result_A[i] + result_B[i];
    }
    
    double t2 = get_time_us();
    
    *result_combined_out = result_combined;
    
    free(result_A);
    free(result_B);
    
    return t2 - t1;
}

/**
 * @brief SME stencil2row computation with 4-tiles (column split)
 */
double cpu_stencil2row_sme_4tiles(const float* matrix_A, const float* matrix_B,
                                  const float* weight_A, const float* weight_B,
                                  float** result_combined_out,
                                  int stencil_rows, int stencil_cols) {
    float* result_A = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_B = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_combined = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    if (!result_A || !result_B || !result_combined) {
        fprintf(stderr, "Error: SME 4-tiles result allocation failed\n");
        if (result_A) free(result_A);
        if (result_B) free(result_B);
        if (result_combined) free(result_combined);
        *result_combined_out = NULL;
        return 0;
    }
    
    memset(result_A, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_B, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_combined, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    double t1 = get_time_us();
    
    matmul_sme_4tiles(matrix_A, weight_A, result_A, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    matmul_sme_4tiles(matrix_B, weight_B, result_B, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    
    for (int i = 0; i < stencil_rows * PADDED_WEIGHT_COLS; i++) {
        result_combined[i] = result_A[i] + result_B[i];
    }
    
    double t2 = get_time_us();
    
    *result_combined_out = result_combined;
    
    free(result_A);
    free(result_B);
    
    return t2 - t1;
}

/**
 * @brief SME stencil2row computation with 4-tiles (row split)
 */
double cpu_stencil2row_sme_4tiles_row_split(const float* matrix_A, const float* matrix_B,
                                            const float* weight_A, const float* weight_B,
                                            float** result_combined_out,
                                            int stencil_rows, int stencil_cols) {
    float* result_A = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_B = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    float* result_combined = (float*)aligned_alloc(64, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    if (!result_A || !result_B || !result_combined) {
        fprintf(stderr, "Error: SME 4-tiles row-split result allocation failed\n");
        if (result_A) free(result_A);
        if (result_B) free(result_B);
        if (result_combined) free(result_combined);
        *result_combined_out = NULL;
        return 0;
    }
    
    memset(result_A, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_B, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    memset(result_combined, 0, stencil_rows * PADDED_WEIGHT_COLS * sizeof(float));
    
    double t1 = get_time_us();
    
    matmul_sme_4tiles_row_split(matrix_A, weight_A, result_A, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    matmul_sme_4tiles_row_split(matrix_B, weight_B, result_B, stencil_rows, stencil_cols, PADDED_WEIGHT_COLS);
    
    for (int i = 0; i < stencil_rows * PADDED_WEIGHT_COLS; i++) {
        result_combined[i] = result_A[i] + result_B[i];
    }
    
    double t2 = get_time_us();
    
    *result_combined_out = result_combined;
    
    free(result_A);
    free(result_B);
    
    return t2 - t1;
}

/**
 * @brief Reorganize padded output to final format
 */
void reorganize_padded_output(const float* result_padded, float* output, 
                              int total_groups, int padded_rows) {
    int groupsize = GROUPSIZE;  // 4 for 3×3 kernel
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    
    memset(output, 0, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    
    int result_idx = 0;
    for (int i = 0; i < OUTPUT_SIZE; i++) {
        int out_col = 0;
        for (int j = valid_start; j < valid_end && out_col < OUTPUT_SIZE; j += groupsize) {
            int group_size_actual = MIN(groupsize, valid_end - j);
            
            for (int k = 0; k < group_size_actual && out_col < OUTPUT_SIZE; k++) {
                output[i * OUTPUT_SIZE + out_col] = result_padded[result_idx * PADDED_WEIGHT_COLS + k];
                out_col++;
            }
            result_idx++;
        }
    }
}

// ============================================================================
// Main Function
// ============================================================================
int main() {
    printf("==========================================\n");
    printf("3×3 Stencil Computation - ARM SME Optimized\n");
    printf("==========================================\n");
    
    // Check SME support
    int sme_available = 0;
    uint64_t SVL = 0;
    if (!__arm_has_sme()) {
        printf("⚠ Warning: System does not support SME\n");
        printf("  SME optimized versions will be skipped\n\n");
    } else {
        sme_available = 1;
        SVL = svcntsw();
        printf("✓ SME support detected\n");
        printf("  Vector length (SVL): %lu 32-bit words\n", SVL);
        printf("  ZA register: 4 tiles of %lu×%lu\n\n", SVL, SVL);
    }
    
    printf("Configuration:\n");
    printf("  Original data: %d×%d\n", ORIGINAL_SIZE, ORIGINAL_SIZE);
    printf("  Padding: %d\n", PADDING);
    printf("  Padded input: %d×%d\n", INPUT_SIZE, INPUT_SIZE);
    printf("  Kernel size: %d×%d (%d elements)\n", KERNEL_SIZE, KERNEL_SIZE, KERNEL_ELEMENTS);
    printf("  Group size: %d\n", GROUPSIZE);
    printf("  Original weight matrix: %d×%d\n", KERNEL_ELEMENTS, WEIGHT_COLS);
    printf("  Padded weight matrix for SME: %d×%d\n", PADDED_STENCIL_COLS, PADDED_WEIGHT_COLS);
    printf("  Output size: %d×%d\n", OUTPUT_SIZE, OUTPUT_SIZE);
    printf("  Warmup iterations: %d\n", WARMUP_ITERATIONS);
    printf("  Test iterations: %d\n", TEST_ITERATIONS);
    
    if (sme_available) {
        uint64_t tile_utilization = MIN(4, (WEIGHT_COLS + SVL - 1) / SVL);
        printf("  SME tile utilization: %lu / 4 (%.1f%%)\n", 
               tile_utilization, (tile_utilization * 100.0) / 4);
    }
    printf("==========================================\n\n");
    
    // Allocate memory
    float* original_data = (float*)malloc(ORIGINAL_SIZE * ORIGINAL_SIZE * sizeof(float));
    float* input = (float*)malloc(INPUT_SIZE * INPUT_SIZE * sizeof(float));
    float* kernel = (float*)malloc(KERNEL_ELEMENTS * sizeof(float));
    float* output_baseline = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_im2row = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_direct = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_sme_single = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_sme_4tiles = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_sme_4tiles_row_split = (float*)malloc(OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    
    double* baseline_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    double* im2row_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    double* stencil2row_direct_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    double* sme_single_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    double* sme_4tiles_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    double* sme_4tiles_row_split_times = (double*)malloc(TEST_ITERATIONS * sizeof(double));
    
    if (!original_data || !input || !kernel || !output_baseline || !output_im2row || 
        !output_stencil2row_direct || !output_stencil2row_sme_single || 
        !output_stencil2row_sme_4tiles || !output_stencil2row_sme_4tiles_row_split ||
        !baseline_times || !im2row_times || !stencil2row_direct_times || 
        !sme_single_times || !sme_4tiles_times || !sme_4tiles_row_split_times) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        return 1;
    }
    
    // Initialize data
    initialize_data(input, kernel, original_data);
    
    printf("\n========== Performance Testing ===========\n\n");
    
    // 1. Baseline version
    printf("1. Baseline version (direct convolution)...\n");
    printf("   Warming up...\n");
    for (int i = 0; i < WARMUP_ITERATIONS; i++) {
        cpu_stencil_baseline(input, output_baseline, kernel);
    }
    
    printf("   Testing...\n");
    for (int i = 0; i < TEST_ITERATIONS; i++) {
        double t1 = get_time_us();
        cpu_stencil_baseline(input, output_baseline, kernel);
        double t2 = get_time_us();
        baseline_times[i] = t2 - t1;
    }
    PerfStats baseline_stats = calculate_stats(baseline_times, TEST_ITERATIONS);
    printf("   Average time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n\n", 
           baseline_stats.mean, baseline_stats.std_dev, baseline_stats.min, baseline_stats.max);
    
    // 2. Im2Row version
    printf("2. Im2Row + GEMV version...\n");
    printf("   Preparing im2row matrix...\n");
    int row_rows = OUTPUT_SIZE * OUTPUT_SIZE;
    int row_cols = KERNEL_ELEMENTS;
    float* row_matrix = (float*)malloc(row_rows * row_cols * sizeof(float));
    im2row(input, row_matrix);
    
    printf("   Warming up...\n");
    for (int i = 0; i < WARMUP_ITERATIONS; i++) {
        cpu_im2row_gemv(row_matrix, kernel, output_im2row);
    }
    
    printf("   Testing (matrix multiplication only)...\n");
    for (int i = 0; i < TEST_ITERATIONS; i++) {
        im2row_times[i] = cpu_im2row_gemv(row_matrix, kernel, output_im2row);
    }
    PerfStats im2row_stats = calculate_stats(im2row_times, TEST_ITERATIONS);
    printf("   GEMV time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n\n", 
           im2row_stats.mean, im2row_stats.std_dev, im2row_stats.min, im2row_stats.max);
    
    // 3. Stencil2Row direct version
    printf("3. Stencil2Row direct version...\n");
    printf("   Preparing stencil2row matrices...\n");
    PerfStats stencil2row_direct_stats = {0};
    float* matrix_A = NULL;
    float* matrix_B = NULL;
    int stencil_rows, stencil_cols;
    stencil2row(input, &matrix_A, &matrix_B, &stencil_rows, &stencil_cols);
    
    if (matrix_A && matrix_B) {
        printf("   Preparing kernel weight matrices...\n");
        float* weight_A = (float*)malloc(KERNEL_ELEMENTS * WEIGHT_COLS * sizeof(float));
        float* weight_B = (float*)malloc(KERNEL_ELEMENTS * WEIGHT_COLS * sizeof(float));
        kernel2col(kernel, weight_A, weight_B);
        
        float* result_combined = (float*)malloc(stencil_rows * WEIGHT_COLS * sizeof(float));
        
        printf("   Warming up...\n");
        for (int i = 0; i < WARMUP_ITERATIONS; i++) {
            cpu_stencil2row_direct(matrix_A, matrix_B, weight_A, weight_B, 
                                   result_combined, stencil_rows, stencil_cols);
        }
        
        printf("   Testing (computation only)...\n");
        for (int i = 0; i < TEST_ITERATIONS; i++) {
            stencil2row_direct_times[i] = cpu_stencil2row_direct(matrix_A, matrix_B, 
                                                                  weight_A, weight_B,
                                                                  result_combined, 
                                                                  stencil_rows, stencil_cols);
            if (i == TEST_ITERATIONS - 1) {
                reorganize_stencil2row_output(result_combined, output_stencil2row_direct, WEIGHT_COLS);
            }
        }
        stencil2row_direct_stats = calculate_stats(stencil2row_direct_times, TEST_ITERATIONS);
        printf("   Time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n\n", 
               stencil2row_direct_stats.mean, stencil2row_direct_stats.std_dev, 
               stencil2row_direct_stats.min, stencil2row_direct_stats.max);
        
        free(weight_A);
        free(weight_B);
        free(result_combined);
        free(matrix_A);
        free(matrix_B);
    }
    
    free(row_matrix);
    
    // SME versions
    PerfStats sme_single_stats = {0};
    PerfStats sme_4tiles_stats = {0};
    PerfStats sme_4tiles_row_split_stats = {0};
    
    if (sme_available) {
        printf("4. SME versions...\n");
        printf("   Preparing padded matrices...\n");
        float* matrix_A_sme = NULL;
        float* matrix_B_sme = NULL;
        int stencil_rows_sme, stencil_cols_sme, total_groups_sme;
        stencil2row_sme_padded(input, &matrix_A_sme, &matrix_B_sme, 
                              &stencil_rows_sme, &stencil_cols_sme, &total_groups_sme);
        
        if (matrix_A_sme && matrix_B_sme) {
            printf("   Preparing padded weight matrices...\n");
            float* weight_A_sme = NULL;
            float* weight_B_sme = NULL;
            kernel2col_padded(kernel, &weight_A_sme, &weight_B_sme);
            
            if (weight_A_sme && weight_B_sme) {
                
                // 4a. SME Single Tile version
                printf("\n   4a. SME Single Tile version...\n");
                printf("       Warming up...\n");
                for (int i = 0; i < WARMUP_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    cpu_stencil2row_sme_single(matrix_A_sme, matrix_B_sme, 
                                              weight_A_sme, weight_B_sme,
                                              &result_combined_sme,
                                              stencil_rows_sme, stencil_cols_sme);
                    free(result_combined_sme);
                }
                
                printf("       Testing SME single tile (computation only)...\n");
                for (int i = 0; i < TEST_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    sme_single_times[i] = cpu_stencil2row_sme_single(matrix_A_sme, matrix_B_sme, 
                                                                    weight_A_sme, weight_B_sme,
                                                                    &result_combined_sme,
                                                                    stencil_rows_sme, stencil_cols_sme);
                    
                    if (i == TEST_ITERATIONS - 1) {
                        reorganize_padded_output(result_combined_sme, output_stencil2row_sme_single, 
                                                total_groups_sme, stencil_rows_sme);
                    }
                    free(result_combined_sme);
                }
                
                sme_single_stats = calculate_stats(sme_single_times, TEST_ITERATIONS);
                printf("       Single tile time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n", 
                       sme_single_stats.mean, sme_single_stats.std_dev, 
                       sme_single_stats.min, sme_single_stats.max);
                
                // 4b. SME 4-Tiles version (Column Split)
                printf("\n   4b. SME 4-Tiles version (Column Split)...\n");
                printf("       Warming up...\n");
                for (int i = 0; i < WARMUP_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    cpu_stencil2row_sme_4tiles(matrix_A_sme, matrix_B_sme, 
                                              weight_A_sme, weight_B_sme,
                                              &result_combined_sme,
                                              stencil_rows_sme, stencil_cols_sme);
                    free(result_combined_sme);
                }
                
                printf("       Testing SME 4-tiles column split (computation only)...\n");
                for (int i = 0; i < TEST_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    sme_4tiles_times[i] = cpu_stencil2row_sme_4tiles(matrix_A_sme, matrix_B_sme, 
                                                                    weight_A_sme, weight_B_sme,
                                                                    &result_combined_sme,
                                                                    stencil_rows_sme, stencil_cols_sme);
                    
                    if (i == TEST_ITERATIONS - 1) {
                        reorganize_padded_output(result_combined_sme, output_stencil2row_sme_4tiles, 
                                                total_groups_sme, stencil_rows_sme);
                    }
                    free(result_combined_sme);
                }
                
                sme_4tiles_stats = calculate_stats(sme_4tiles_times, TEST_ITERATIONS);
                printf("       4-tiles column split time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n", 
                       sme_4tiles_stats.mean, sme_4tiles_stats.std_dev,
                       sme_4tiles_stats.min, sme_4tiles_stats.max);
                
                // 4c. SME 4-Tiles Row Split version
                printf("\n   4c. SME 4-Tiles version (Row Split)...\n");
                printf("       Warming up...\n");
                for (int i = 0; i < WARMUP_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    cpu_stencil2row_sme_4tiles_row_split(matrix_A_sme, matrix_B_sme, 
                                                        weight_A_sme, weight_B_sme,
                                                        &result_combined_sme,
                                                        stencil_rows_sme, stencil_cols_sme);
                    free(result_combined_sme);
                }
                
                printf("       Testing SME 4-tiles row split (computation only)...\n");
                for (int i = 0; i < TEST_ITERATIONS; i++) {
                    float* result_combined_sme = NULL;
                    sme_4tiles_row_split_times[i] = cpu_stencil2row_sme_4tiles_row_split(
                                                        matrix_A_sme, matrix_B_sme, 
                                                        weight_A_sme, weight_B_sme,
                                                        &result_combined_sme,
                                                        stencil_rows_sme, stencil_cols_sme);
                    
                    if (i == TEST_ITERATIONS - 1) {
                        reorganize_padded_output(result_combined_sme, output_stencil2row_sme_4tiles_row_split, 
                                                total_groups_sme, stencil_rows_sme);
                    }
                    free(result_combined_sme);
                }
                
                sme_4tiles_row_split_stats = calculate_stats(sme_4tiles_row_split_times, TEST_ITERATIONS);
                printf("       4-tiles row split time: %.2f ± %.2f μs (min: %.2f, max: %.2f)\n\n", 
                       sme_4tiles_row_split_stats.mean, sme_4tiles_row_split_stats.std_dev,
                       sme_4tiles_row_split_stats.min, sme_4tiles_row_split_stats.max);
                
                free(weight_A_sme);
                free(weight_B_sme);
            }
            
            free(matrix_A_sme);
            free(matrix_B_sme);
        }
    }
    
    // Verify results
    printf("=========== Result Verification ===========\n");
    int correct1 = verify_results(output_baseline, output_im2row, 
                                  OUTPUT_SIZE * OUTPUT_SIZE, 
                                  "Baseline", "Im2Row");
    int correct2 = verify_results(output_baseline, output_stencil2row_direct, 
                                  OUTPUT_SIZE * OUTPUT_SIZE, 
                                  "Baseline", "Stencil2Row-Direct");
    
    int correct3 = 1, correct4 = 1, correct5 = 1;
    if (sme_available) {
        correct3 = verify_results(output_baseline, output_stencil2row_sme_single, 
                                  OUTPUT_SIZE * OUTPUT_SIZE, 
                                  "Baseline", "Stencil2Row-SME-Single");
        correct4 = verify_results(output_baseline, output_stencil2row_sme_4tiles, 
                                  OUTPUT_SIZE * OUTPUT_SIZE, 
                                  "Baseline", "Stencil2Row-SME-4tiles-ColSplit");
        correct5 = verify_results(output_baseline, output_stencil2row_sme_4tiles_row_split, 
                                  OUTPUT_SIZE * OUTPUT_SIZE, 
                                  "Baseline", "Stencil2Row-SME-4tiles-RowSplit");
    }
    
    if (correct1 && correct2 && correct3 && correct4 && correct5) {
        printf("\n✓ All methods produce consistent results!\n");
    } else {
        printf("\n✗ Results differ, please check implementation!\n");
    }
    
    // Performance summary
    printf("\n=========== Performance Summary ===========\n");
    printf("Note: Times shown are for core computations only\n");
    printf("All tests: %d warmup, %d test iterations\n\n", WARMUP_ITERATIONS, TEST_ITERATIONS);
    
    printf("%-35s %15s %15s %15s\n", "Method", "Time (μs)", "Speedup", "vs Baseline");
    printf("-----------------------------------------------------------------------\n");
    
    printf("%-35s %15.2f %15s %15s\n", 
           "Baseline (full)", baseline_stats.mean, "1.00x", "reference");
    
    printf("\nMatrix multiplication times only:\n");
    printf("%-35s %15.2f %15.2fx %15.2fx\n", 
           "Im2Row GEMV", im2row_stats.mean,
           baseline_stats.mean / im2row_stats.mean,
           baseline_stats.mean / im2row_stats.mean);
    
    printf("%-35s %15.2f %15.2fx %15.2fx\n", 
           "Stencil2Row Direct", stencil2row_direct_stats.mean,
           baseline_stats.mean / stencil2row_direct_stats.mean,
           baseline_stats.mean / stencil2row_direct_stats.mean);
    
    if (sme_available) {
        printf("\nSME Implementations:\n");
        printf("%-35s %15.2f %15.2fx %15.2fx\n", 
               "  SME Single Tile", sme_single_stats.mean,
               baseline_stats.mean / sme_single_stats.mean,
               baseline_stats.mean / sme_single_stats.mean);
        
        printf("%-35s %15.2f %15.2fx %15.2fx\n", 
               "  SME 4-Tiles (Column Split)", sme_4tiles_stats.mean,
               baseline_stats.mean / sme_4tiles_stats.mean,
               baseline_stats.mean / sme_4tiles_stats.mean);
        
        printf("%-35s %15.2f %15.2fx %15.2fx\n", 
               "  SME 4-Tiles (Row Split)", sme_4tiles_row_split_stats.mean,
               baseline_stats.mean / sme_4tiles_row_split_stats.mean,
               baseline_stats.mean / sme_4tiles_row_split_stats.mean);
    }
    
    // Cleanup
    free(baseline_times);
    free(im2row_times);
    free(stencil2row_direct_times);
    free(sme_single_times);
    free(sme_4tiles_times);
    free(sme_4tiles_row_split_times);
    
    free(original_data);
    free(input);
    free(kernel);
    free(output_baseline);
    free(output_im2row);
    free(output_stencil2row_direct);
    free(output_stencil2row_sme_single);
    free(output_stencil2row_sme_4tiles);
    free(output_stencil2row_sme_4tiles_row_split);
    
    printf("\n==========================================\n");
    printf("Testing complete!\n");
    printf("==========================================\n");
    
    return 0;
}