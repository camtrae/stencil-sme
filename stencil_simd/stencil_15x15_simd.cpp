#include <iostream>
#include <vector>
#include <cstring>
#include <chrono>
#include <iomanip>
#include <cmath>
#include <algorithm>
#include <immintrin.h>  // For AVX-512 intrinsics
#include <omp.h>        // For OpenMP

using namespace std;

// Configuration parameters - 修改为15×15 kernel
const int KERNEL_SIZE = 15;              // 15×15 kernel
const int KERNEL_RADIUS = KERNEL_SIZE / 2;  // radius 7

const int ORIGINAL_SIZE = 64;            // Original input size
const int PADDING = 7;                   // Padding size (for 15×15 kernel)
const int INPUT_SIZE = ORIGINAL_SIZE + 2 * PADDING;  // With padding
const int OUTPUT_SIZE = ORIGINAL_SIZE;  // Output size

const int ITERATIONS = 20;             // Number of iterations for timing
const int WARMUP_ITERATIONS = 5;       // Warmup iterations

#define IDX(x, y, ldm) ((x) * (ldm) + (y))  // 2D array row-major indexing

// ========== CPU Baseline Stencil Computation ==========
void cpu_stencil_baseline(const float* input, float* output, const float* kernel) {
    for (int row = 0; row < OUTPUT_SIZE; row++) {
        for (int col = 0; col < OUTPUT_SIZE; col++) {
            float sum = 0.0f;
            
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

// ========== Baseline with OpenMP ==========
void cpu_stencil_baseline_openmp(const float* input, float* output, const float* kernel) {
    #pragma omp parallel for schedule(static) num_threads(32)
    for (int row = 0; row < OUTPUT_SIZE; row++) {
        for (int col = 0; col < OUTPUT_SIZE; col++) {
            float sum = 0.0f;
            
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

// ========== im2row Transformation ==========
void im2row(const float* input, float* row_matrix) {
    int row_idx = 0;
    
    for (int out_row = 0; out_row < OUTPUT_SIZE; out_row++) {
        for (int out_col = 0; out_col < OUTPUT_SIZE; out_col++) {
            int col_idx = 0;
            for (int ki = 0; ki < KERNEL_SIZE; ki++) {
                for (int kj = 0; kj < KERNEL_SIZE; kj++) {
                    int in_row = out_row + ki;
                    int in_col = out_col + kj;
                    
                    row_matrix[row_idx * KERNEL_SIZE * KERNEL_SIZE + col_idx] = 
                        input[in_row * INPUT_SIZE + in_col];
                    col_idx++;
                }
            }
            row_idx++;
        }
    }
}

// ========== Matrix-Vector Multiplication ==========
void matrix_vector_multiply(const float* A, const float* x, float* y, int m, int n) {
    for (int i = 0; i < m; i++) {
        float sum = 0.0f;
        for (int j = 0; j < n; j++) {
            sum += A[i * n + j] * x[j];
        }
        y[i] = sum;
    }
}

// ========== SIMD Optimized Matrix-Vector Multiplication (AVX-512) ==========
void matrix_vector_multiply_avx512(const float* A, const float* x, float* y, int m, int n) {
    const int simd_width = 16;
    
    // Special optimization for n=225 (15x15 kernels)
    if (n == 225) {
        // Process in chunks of 16 elements
        // 225 = 14*16 + 1
        __m512 kernel_vecs[15];
        
        // Load kernel vectors
        for (int k = 0; k < 14; k++) {
            kernel_vecs[k] = _mm512_loadu_ps(x + k * 16);
        }
        
        // Use masked load for the last chunk (225 - 224 = 1 element)
        __mmask16 mask = _cvtu32_mask16(1);  // Only load 1 element
        kernel_vecs[14] = _mm512_maskz_loadu_ps(mask, x + 224);
        
        for (int i = 0; i < m; i++) {
            const float* A_row = A + i * n;
            
            __m512 sum_all = _mm512_setzero_ps();
            
            for (int k = 0; k < 14; k++) {
                __m512 a_vec = _mm512_loadu_ps(A_row + k * 16);
                __m512 prod = _mm512_mul_ps(a_vec, kernel_vecs[k]);
                sum_all = _mm512_add_ps(sum_all, prod);
            }
            
            // Last chunk with mask
            __m512 a_vec_last = _mm512_maskz_loadu_ps(mask, A_row + 224);
            __m512 prod_last = _mm512_mul_ps(a_vec_last, kernel_vecs[14]);
            sum_all = _mm512_add_ps(sum_all, prod_last);
            
            y[i] = _mm512_reduce_add_ps(sum_all);
        }
    } else {
        // Fallback for other sizes
        for (int i = 0; i < m; i++) {
            float sum = 0.0f;
            for (int j = 0; j < n; j++) {
                sum += A[i * n + j] * x[j];
            }
            y[i] = sum;
        }
    }
}

// ========== OpenMP Parallel Matrix-Vector Multiplication ==========
void matrix_vector_multiply_openmp(const float* A, const float* x, float* y, int m, int n) {
    #pragma omp parallel for schedule(static) num_threads(32)
    for (int i = 0; i < m; i++) {
        float sum = 0.0f;
        for (int j = 0; j < n; j++) {
            sum += A[i * n + j] * x[j];
        }
        y[i] = sum;
    }
}

// ========== Stencil2Row Helper: Extract Stencil Window ==========
void getStencil(const float* input, int row, int col, float* stencil) {
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

// ========== Stencil2Row Transformation (Dual Tessellation) ==========
void stencil2row(const float* input, float** matrix_A_out, float** matrix_B_out, 
                 int& out_rows, int& out_cols) {
    int groupsize = KERNEL_SIZE + 1;  // 16 for 15x15 kernel
    
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    int valid_size = valid_end - valid_start;
    
    // Calculate total number of groups
    int total_groups = 0;
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            total_groups++;
        }
    }
    
    out_rows = total_groups;
    out_cols = KERNEL_SIZE * KERNEL_SIZE;  // 225 for 15×15 kernel
    
    float* matrix_A = (float*)aligned_alloc(64, out_rows * out_cols * sizeof(float));
    float* matrix_B = (float*)aligned_alloc(64, out_rows * out_cols * sizeof(float));
    
    memset(matrix_A, 0, out_rows * out_cols * sizeof(float));
    memset(matrix_B, 0, out_rows * out_cols * sizeof(float));
    
    int matrix_row = 0;
    
    for (int i = valid_start; i < valid_end; i++) {
        for (int j = valid_start; j < valid_end; j += groupsize) {
            int group_start = j;
            int group_end = min(j + groupsize - 1, valid_end - 1);
            
            getStencil(input, i, group_start, &matrix_A[matrix_row * out_cols]);
            getStencil(input, i, group_end, &matrix_B[matrix_row * out_cols]);
            
            matrix_row++;
        }
    }
    
    *matrix_A_out = matrix_A;
    *matrix_B_out = matrix_B;
}

// ========== Kernel2Col Transformation (Transposed - Column Major) ==========
void kernel2col_transposed(const float* kernel, float** weight_A_T_out, float** weight_B_T_out) {
    int groupsize = KERNEL_SIZE + 1;  // 16 for 15×15 kernel
    int rows = KERNEL_SIZE * KERNEL_SIZE;  // 225
    int cols = groupsize;  // 16
    
    // Allocate transposed matrices (cols x rows instead of rows x cols)
    float* weight_A_T = (float*)aligned_alloc(64, cols * rows * sizeof(float));
    float* weight_B_T = (float*)aligned_alloc(64, cols * rows * sizeof(float));
    
    memset(weight_A_T, 0, cols * rows * sizeof(float));
    memset(weight_B_T, 0, cols * rows * sizeof(float));
    
    // Fill transposed matrices directly
    // For 15×15 kernel, each column corresponds to a position in the group (0-15)
    for (int col = 0; col < groupsize; col++) {
        for (int i = 0; i < KERNEL_SIZE; i++) {
            for (int j = 0; j < KERNEL_SIZE; j++) {
                int row_idx = i * KERNEL_SIZE + j;
                
                // Store in transposed format: weight_T[col][row] = weight_T[col * rows + row]
                // Weight_A: for positions starting from group_start
                if (j >= col) {
                    weight_A_T[col * rows + row_idx] = kernel[i * KERNEL_SIZE + (j - col)];
                }
                
                // Weight_B: for positions ending at group_end
                if (j < col) {
                    weight_B_T[col * rows + row_idx] = kernel[i * KERNEL_SIZE + (j + KERNEL_SIZE - col)];
                }
            }
        }
    }
    
    *weight_A_T_out = weight_A_T;
    *weight_B_T_out = weight_B_T;
}

// ========== Optimized Matrix Multiplication with Transposed B ==========
void matrix_multiply_transposed(const float* A, const float* B_T, float* C, int m, int k, int n) {
    // B_T is the transpose of B, so B_T[j][p] = B[p][j]
    // Now both A and B_T can be accessed row-wise for better cache performance
    for (int i = 0; i < m; i++) {
        const float* A_row = A + i * k;
        float* C_row = C + i * n;
        
        for (int j = 0; j < n; j++) {
            const float* B_T_row = B_T + j * k;  // j-th column of original B
            
            float sum = 0.0f;
            // This is now a dot product of two rows - cache friendly!
            for (int p = 0; p < k; p++) {
                sum += A_row[p] * B_T_row[p];
            }
            
            C_row[j] = sum;
        }
    }
}

// ========== Optimized SIMD Matrix Multiplication with Transposed B ==========
void matrix_multiply_transposed_simd(const float* A, const float* B_T, float* C, int m, int k, int n) {
    const int simd_width = 16;
    
    // Special optimization for k=225 (15x15 kernels)
    if (k == 225) {
        for (int i = 0; i < m; i++) {
            const float* A_row = A + i * k;
            float* C_row = C + i * n;
            
            // Load A row (225 elements) in chunks
            __m512 a_vecs[15];
            for (int v = 0; v < 14; v++) {
                a_vecs[v] = _mm512_loadu_ps(A_row + v * 16);
            }
            
            // Use masked load for the last element (225 - 224 = 1)
            __mmask16 mask = _cvtu32_mask16(1);
            a_vecs[14] = _mm512_maskz_loadu_ps(mask, A_row + 224);
            
            // Process 4 outputs at a time
            int j = 0;
            for (; j + 4 <= n; j += 4) {
                // Process 4 columns
                for (int jj = 0; jj < 4; jj++) {
                    const float* B_T_row = B_T + (j + jj) * k;
                    
                    __m512 sum_all = _mm512_setzero_ps();
                    
                    for (int v = 0; v < 14; v++) {
                        __m512 b_vec = _mm512_loadu_ps(B_T_row + v * 16);
                        __m512 prod = _mm512_mul_ps(a_vecs[v], b_vec);
                        sum_all = _mm512_add_ps(sum_all, prod);
                    }
                    
                    // Last chunk with mask
                    __m512 b_vec_last = _mm512_maskz_loadu_ps(mask, B_T_row + 224);
                    __m512 prod_last = _mm512_mul_ps(a_vecs[14], b_vec_last);
                    sum_all = _mm512_add_ps(sum_all, prod_last);
                    
                    C_row[j + jj] = _mm512_reduce_add_ps(sum_all);
                }
            }
            
            // Process remaining columns
            for (; j < n; j++) {
                const float* B_T_row = B_T + j * k;
                
                __m512 sum_all = _mm512_setzero_ps();
                
                for (int v = 0; v < 14; v++) {
                    __m512 b_vec = _mm512_loadu_ps(B_T_row + v * 16);
                    __m512 prod = _mm512_mul_ps(a_vecs[v], b_vec);
                    sum_all = _mm512_add_ps(sum_all, prod);
                }
                
                // Last chunk with mask
                __m512 b_vec_last = _mm512_maskz_loadu_ps(mask, B_T_row + 224);
                __m512 prod_last = _mm512_mul_ps(a_vecs[14], b_vec_last);
                sum_all = _mm512_add_ps(sum_all, prod_last);
                
                C_row[j] = _mm512_reduce_add_ps(sum_all);
            }
        }
    } else {
        // Fallback for other kernel sizes
        for (int i = 0; i < m; i++) {
            const float* A_row = A + i * k;
            float* C_row = C + i * n;
            
            for (int j = 0; j < n; j++) {
                const float* B_T_row = B_T + j * k;
                
                float sum = 0.0f;
                for (int p = 0; p < k; p++) {
                    sum += A_row[p] * B_T_row[p];
                }
                
                C_row[j] = sum;
            }
        }
    }
}

// ========== OpenMP Optimized Matrix Multiplication with Transposed B ==========
void matrix_multiply_transposed_openmp(const float* A, const float* B_T, float* C, int m, int k, int n) {
    #pragma omp parallel for schedule(static) num_threads(32)
    for (int i = 0; i < m; i++) {
        const float* A_row = A + i * k;
        float* C_row = C + i * n;
        
        for (int j = 0; j < n; j++) {
            const float* B_T_row = B_T + j * k;
            
            float sum = 0.0f;
            #pragma omp simd reduction(+:sum)
            for (int p = 0; p < k; p++) {
                sum += A_row[p] * B_T_row[p];
            }
            
            C_row[j] = sum;
        }
    }
}

// ========== Stencil2Row结果重组 ==========
void reorganize_stencil2row_output(const float* result_combined, float* output, int weight_cols) {
    int groupsize = KERNEL_SIZE + 1;  // 16 for 15×15 kernel
    int valid_start = KERNEL_RADIUS;
    int valid_end = INPUT_SIZE - KERNEL_RADIUS;
    
    memset(output, 0, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    
    int result_idx = 0;
    for (int i = 0; i < OUTPUT_SIZE; i++) {
        int out_col = 0;
        for (int j = valid_start; j < valid_end && out_col < OUTPUT_SIZE; j += groupsize) {
            int group_size_actual = min(groupsize, valid_end - j);
            
            for (int k = 0; k < group_size_actual && out_col < OUTPUT_SIZE; k++) {
                output[i * OUTPUT_SIZE + out_col] = result_combined[result_idx * weight_cols + k];
                out_col++;
            }
            result_idx++;
        }
    }
}

// ========== Data Initialization ==========
void initialize_data(float* input, float* kernel, float* original_data) {
    // Initialize original data
    for (int i = 0; i < ORIGINAL_SIZE; i++) {
        for (int j = 0; j < ORIGINAL_SIZE; j++) {
            original_data[i * ORIGINAL_SIZE + j] = (i * ORIGINAL_SIZE + j + 1) % 100;
        }
    }
    
    // Initialize padded input
    memset(input, 0, INPUT_SIZE * INPUT_SIZE * sizeof(float));
    
    // Copy original data to center of padded input
    for (int i = 0; i < ORIGINAL_SIZE; i++) {
        for (int j = 0; j < ORIGINAL_SIZE; j++) {
            input[(i + PADDING) * INPUT_SIZE + (j + PADDING)] = 
                original_data[i * ORIGINAL_SIZE + j];
        }
    }
    
    // Initialize 15×15 kernel (averaging filter)
    for (int i = 0; i < KERNEL_SIZE * KERNEL_SIZE; i++) {
        kernel[i] = 1.0f / (KERNEL_SIZE * KERNEL_SIZE);  // 1/225 for averaging
    }
}

// ========== Result Verification ==========
bool verify_results(const float* result1, const float* result2, int size, 
                   const string& name1, const string& name2) {
    float max_diff = 0.0f;
    int diff_count = 0;
    
    for (int i = 0; i < size; i++) {
        float diff = std::abs(result1[i] - result2[i]);
        if (diff > max_diff) max_diff = diff;
        if (diff > 1e-4) diff_count++;
    }
    
    cout << "Verifying " << name1 << " vs " << name2 << ":" << endl;
    cout << "  Max difference: " << scientific << setprecision(9) << max_diff << endl;
    cout << "  Different points: " << diff_count << " / " << size << endl;
    
    return max_diff < 1e-4;
}

// ========== Statistics Calculation ==========
struct TimeStats {
    double mean;
    double stddev;
    double min;
    double max;
    double total;
    
    void calculate(const vector<double>& times) {
        if (times.empty()) return;
        
        // Calculate mean
        total = 0;
        min = times[0];
        max = times[0];
        
        for (double t : times) {
            total += t;
            if (t < min) min = t;
            if (t > max) max = t;
        }
        mean = total / times.size();
        
        // Calculate standard deviation
        double sum_sq_diff = 0;
        for (double t : times) {
            double diff = t - mean;
            sum_sq_diff += diff * diff;
        }
        stddev = sqrt(sum_sq_diff / times.size());
    }
    
    void print(const string& name, double baseline_mean = 0) {
        cout << name << ":" << endl;
        cout << "  Average time: " << fixed << setprecision(2) << mean << " μs";
        if (baseline_mean > 0 && mean > 0) {
            cout << " (Speedup: " << setprecision(2) << baseline_mean / mean << "×)";
        }
        cout << endl;
        cout << "  Std dev: " << setprecision(2) << stddev << " μs (" 
             << setprecision(1) << (stddev / mean * 100) << "%)" << endl;
        cout << "  Min/Max: " << setprecision(2) << min << " / " << max << " μs" << endl;
        cout << "  Total time for " << ITERATIONS << " iterations: " 
             << setprecision(2) << total << " μs" << endl;
    }
};

// ========== Main Function ==========
int main() {
    cout << "==========================================" << endl;
    cout << "15×15 Kernel Stencil2Row Optimization Test" << endl;
    cout << "Using Transposed Weight Matrices (Column-Major)" << endl;
    cout << "==========================================" << endl;
    cout << "Configuration:" << endl;
    cout << "  Original size: " << ORIGINAL_SIZE << "×" << ORIGINAL_SIZE << endl;
    cout << "  Padding: " << PADDING << " (for 15×15 kernel)" << endl;
    cout << "  Padded input: " << INPUT_SIZE << "×" << INPUT_SIZE << endl;
    cout << "  Kernel size: " << KERNEL_SIZE << "×" << KERNEL_SIZE << endl;
    cout << "  Output size: " << OUTPUT_SIZE << "×" << OUTPUT_SIZE << endl;
    cout << "  Group size: " << KERNEL_SIZE + 1 << " (for stencil2row)" << endl;
    cout << "  OpenMP threads: " << omp_get_max_threads() << endl;
    cout << "  Test iterations: " << ITERATIONS << endl;
    cout << "  Warmup iterations: " << WARMUP_ITERATIONS << endl;
    cout << "==========================================" << endl << endl;
    
    // Allocate memory (aligned to 64-byte boundary for AVX-512)
    float* original_data = (float*)aligned_alloc(64, ORIGINAL_SIZE * ORIGINAL_SIZE * sizeof(float));
    float* input = (float*)aligned_alloc(64, INPUT_SIZE * INPUT_SIZE * sizeof(float));
    float* kernel = (float*)aligned_alloc(64, KERNEL_SIZE * KERNEL_SIZE * sizeof(float));
    
    // Output arrays for different methods
    float* output_baseline = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_baseline_omp = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_im2row = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_im2row_simd = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_im2row_omp = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_simd = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    float* output_stencil2row_omp = (float*)aligned_alloc(64, OUTPUT_SIZE * OUTPUT_SIZE * sizeof(float));
    
    // Initialize data
    initialize_data(input, kernel, original_data);
    
    // Warm-up
    cout << "Warming up..." << endl;
    for (int i = 0; i < WARMUP_ITERATIONS; i++) {
        cpu_stencil_baseline(input, output_baseline, kernel);
    }
    
    cout << "\n========== Data Preparation Phase ==========" << endl;
    
    // ===== im2row数据准备 =====
    cout << "\nPreparing im2row data..." << endl;
    int row_rows = OUTPUT_SIZE * OUTPUT_SIZE;
    int row_cols = KERNEL_SIZE * KERNEL_SIZE;  // 225 for 15×15
    float* row_matrix = (float*)aligned_alloc(64, row_rows * row_cols * sizeof(float));
    
    vector<double> im2row_prep_times;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto prep_start = chrono::high_resolution_clock::now();
        im2row(input, row_matrix);
        auto prep_end = chrono::high_resolution_clock::now();
        im2row_prep_times.push_back(chrono::duration_cast<chrono::microseconds>(prep_end - prep_start).count());
    }
    TimeStats im2row_prep_stats;
    im2row_prep_stats.calculate(im2row_prep_times);
    cout << "  im2row transformation average time: " << fixed << setprecision(2) 
         << im2row_prep_stats.mean << " μs (σ=" << im2row_prep_stats.stddev << ")" << endl;
    cout << "  Matrix size: " << row_rows << " × " << row_cols 
         << " (" << (row_rows * row_cols * sizeof(float)) / 1024.0 / 1024.0 << " MB)" << endl;
    
    // ===== Stencil2Row数据准备 =====
    cout << "\nPreparing Stencil2Row data..." << endl;
    float* matrix_A = nullptr;
    float* matrix_B = nullptr;
    int stencil_rows, stencil_cols;
    
    stencil2row(input, &matrix_A, &matrix_B, stencil_rows, stencil_cols);
    
    // Prepare transposed kernel weights (column-major)
    float* weight_A_T = nullptr;
    float* weight_B_T = nullptr;
    kernel2col_transposed(kernel, &weight_A_T, &weight_B_T);
    
    int weight_cols = KERNEL_SIZE + 1;  // 16 for 15×15 kernel
    cout << "  Matrix A/B size: " << stencil_rows << " × " << stencil_cols 
         << " (" << (stencil_rows * stencil_cols * sizeof(float) * 2) / 1024.0 / 1024.0 << " MB total)" << endl;
    cout << "  Weight matrices (transposed): " << weight_cols << " × " << stencil_cols 
         << " (column-major for cache efficiency)" << endl;
    
    // Calculate memory savings
    float im2row_memory = row_rows * row_cols * sizeof(float) / 1024.0 / 1024.0;
    float stencil2row_memory = stencil_rows * stencil_cols * sizeof(float) * 2 / 1024.0 / 1024.0;
    float memory_reduction = (1.0 - stencil2row_memory / im2row_memory) * 100;
    cout << "  Memory reduction vs im2row: " << fixed << setprecision(1) << memory_reduction << "%" << endl;
    
    // Allocate result buffers
    float* result_A = (float*)aligned_alloc(64, stencil_rows * weight_cols * sizeof(float));
    float* result_B = (float*)aligned_alloc(64, stencil_rows * weight_cols * sizeof(float));
    float* result_combined = (float*)aligned_alloc(64, stencil_rows * weight_cols * sizeof(float));
    
    cout << "\n========== Pure Computation Time Tests ==========" << endl;
    cout << "(Excluding data preparation/transformation time)" << endl;
    cout << "Running " << ITERATIONS << " iterations for each method..." << endl;
    
    // Timing storage
    vector<double> baseline_times, baseline_omp_times;
    vector<double> im2row_compute_times, im2row_simd_compute_times, im2row_omp_compute_times;
    vector<double> stencil2row_times, stencil2row_simd_times, stencil2row_omp_times;
    
    // 1. CPU Baseline
    cout << "\n1. Testing CPU Baseline..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto t1 = chrono::high_resolution_clock::now();
        cpu_stencil_baseline(input, output_baseline, kernel);
        auto t2 = chrono::high_resolution_clock::now();
        baseline_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    TimeStats baseline_stats;
    baseline_stats.calculate(baseline_times);
    baseline_stats.print("CPU Baseline");
    
    // 2. Baseline with OpenMP
    cout << "\n2. Testing Baseline with OpenMP..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto t1 = chrono::high_resolution_clock::now();
        cpu_stencil_baseline_openmp(input, output_baseline_omp, kernel);
        auto t2 = chrono::high_resolution_clock::now();
        baseline_omp_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    TimeStats baseline_omp_stats;
    baseline_omp_stats.calculate(baseline_omp_times);
    baseline_omp_stats.print("Baseline with OpenMP", baseline_stats.mean);
    
    // 3. im2row
    cout << "\n3. Testing im2row (Matrix-Vector Multiply)..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto t1 = chrono::high_resolution_clock::now();
        matrix_vector_multiply(row_matrix, kernel, output_im2row, row_rows, row_cols);
        auto t2 = chrono::high_resolution_clock::now();
        im2row_compute_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    TimeStats im2row_compute_stats;
    im2row_compute_stats.calculate(im2row_compute_times);
    im2row_compute_stats.print("im2row (Matrix-Vector Multiply)", baseline_stats.mean);
    
    // 4. im2row with SIMD
    cout << "\n4. Testing im2row with SIMD..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto t1 = chrono::high_resolution_clock::now();
        matrix_vector_multiply_avx512(row_matrix, kernel, output_im2row_simd, row_rows, row_cols);
        auto t2 = chrono::high_resolution_clock::now();
        im2row_simd_compute_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    TimeStats im2row_simd_compute_stats;
    im2row_simd_compute_stats.calculate(im2row_simd_compute_times);
    im2row_simd_compute_stats.print("im2row with SIMD", baseline_stats.mean);
    
    // 5. im2row with OpenMP
    cout << "\n5. Testing im2row with OpenMP..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        auto t1 = chrono::high_resolution_clock::now();
        matrix_vector_multiply_openmp(row_matrix, kernel, output_im2row_omp, row_rows, row_cols);
        auto t2 = chrono::high_resolution_clock::now();
        im2row_omp_compute_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    TimeStats im2row_omp_compute_stats;
    im2row_omp_compute_stats.calculate(im2row_omp_compute_times);
    im2row_omp_compute_stats.print("im2row with OpenMP", baseline_stats.mean);
    
    // 6. Stencil2Row (Transposed)
    cout << "\n6. Testing Stencil2Row (Transposed - Cache Optimized)..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        memset(result_A, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_B, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_combined, 0, stencil_rows * weight_cols * sizeof(float));
        
        auto t1 = chrono::high_resolution_clock::now();
        matrix_multiply_transposed(matrix_A, weight_A_T, result_A, stencil_rows, stencil_cols, weight_cols);
        matrix_multiply_transposed(matrix_B, weight_B_T, result_B, stencil_rows, stencil_cols, weight_cols);
        for (int i = 0; i < stencil_rows * weight_cols; i++) {
            result_combined[i] = result_A[i] + result_B[i];
        }
        auto t2 = chrono::high_resolution_clock::now();
        stencil2row_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    reorganize_stencil2row_output(result_combined, output_stencil2row, weight_cols);
    TimeStats stencil2row_stats;
    stencil2row_stats.calculate(stencil2row_times);
    stencil2row_stats.print("Stencil2Row (Transposed)", baseline_stats.mean);
    
    // 7. Stencil2Row with SIMD (Transposed)
    cout << "\n7. Testing Stencil2Row with SIMD (Transposed)..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        memset(result_A, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_B, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_combined, 0, stencil_rows * weight_cols * sizeof(float));
        
        auto t1 = chrono::high_resolution_clock::now();
        matrix_multiply_transposed_simd(matrix_A, weight_A_T, result_A, stencil_rows, stencil_cols, weight_cols);
        matrix_multiply_transposed_simd(matrix_B, weight_B_T, result_B, stencil_rows, stencil_cols, weight_cols);
        
        const int simd_width = 16;
        int total_elements = stencil_rows * weight_cols;
        int i = 0;
        for (; i + simd_width <= total_elements; i += simd_width) {
            __m512 a = _mm512_loadu_ps(result_A + i);
            __m512 b = _mm512_loadu_ps(result_B + i);
            __m512 sum = _mm512_add_ps(a, b);
            _mm512_storeu_ps(result_combined + i, sum);
        }
        for (; i < total_elements; i++) {
            result_combined[i] = result_A[i] + result_B[i];
        }
        auto t2 = chrono::high_resolution_clock::now();
        stencil2row_simd_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    reorganize_stencil2row_output(result_combined, output_stencil2row_simd, weight_cols);
    TimeStats stencil2row_simd_stats;
    stencil2row_simd_stats.calculate(stencil2row_simd_times);
    stencil2row_simd_stats.print("Stencil2Row with SIMD (Transposed)", baseline_stats.mean);
    
    // 8. Stencil2Row with OpenMP (Transposed)
    cout << "\n8. Testing Stencil2Row with OpenMP (Transposed)..." << endl;
    for (int iter = 0; iter < ITERATIONS; iter++) {
        memset(result_A, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_B, 0, stencil_rows * weight_cols * sizeof(float));
        memset(result_combined, 0, stencil_rows * weight_cols * sizeof(float));
        
        auto t1 = chrono::high_resolution_clock::now();
        matrix_multiply_transposed_openmp(matrix_A, weight_A_T, result_A, stencil_rows, stencil_cols, weight_cols);
        matrix_multiply_transposed_openmp(matrix_B, weight_B_T, result_B, stencil_rows, stencil_cols, weight_cols);
        
        #pragma omp parallel for schedule(static) num_threads(32)
        for (int i = 0; i < stencil_rows * weight_cols; i++) {
            result_combined[i] = result_A[i] + result_B[i];
        }
        auto t2 = chrono::high_resolution_clock::now();
        stencil2row_omp_times.push_back(chrono::duration_cast<chrono::microseconds>(t2 - t1).count());
    }
    reorganize_stencil2row_output(result_combined, output_stencil2row_omp, weight_cols);
    TimeStats stencil2row_omp_stats;
    stencil2row_omp_stats.calculate(stencil2row_omp_times);
    stencil2row_omp_stats.print("Stencil2Row with OpenMP (Transposed)", baseline_stats.mean);
    
    // ========== Result Verification ==========
    cout << "\n========== Result Verification ==========" << endl;
    cout << "Verifying all methods against CPU baseline..." << endl << endl;
    
    bool all_correct = true;
    
    // Verify Baseline with OpenMP
    bool correct1 = verify_results(output_baseline, output_baseline_omp, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "Baseline OpenMP");
    all_correct = all_correct && correct1;
    
    // Verify im2row methods
    bool correct2 = verify_results(output_baseline, output_im2row, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "im2row");
    all_correct = all_correct && correct2;
    
    bool correct3 = verify_results(output_baseline, output_im2row_simd, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "im2row SIMD");
    all_correct = all_correct && correct3;
    
    bool correct4 = verify_results(output_baseline, output_im2row_omp, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "im2row OpenMP");
    all_correct = all_correct && correct4;
    
    // Verify Stencil2Row methods
    bool correct5 = verify_results(output_baseline, output_stencil2row, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "Stencil2Row");
    all_correct = all_correct && correct5;
    
    bool correct6 = verify_results(output_baseline, output_stencil2row_simd, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "Stencil2Row SIMD");
    all_correct = all_correct && correct6;
    
    bool correct7 = verify_results(output_baseline, output_stencil2row_omp, 
                                   OUTPUT_SIZE * OUTPUT_SIZE, 
                                   "CPU Baseline", "Stencil2Row OpenMP");
    all_correct = all_correct && correct7;
    
    if (all_correct) {
        cout << "\n✓ All methods produce correct results!" << endl;
    } else {
        cout << "\n✗ Result discrepancy detected in some methods!" << endl;
    }
    
    // ========== Performance Summary ==========
    cout << "\n========== Performance Summary ==========" << endl;
    cout << "Method                           Avg Time(μs)   Speedup vs Baseline" << endl;
    cout << "---------------------------------------------------------------" << endl;
    
    cout << "CPU Baseline:                    " << setw(10) << fixed << setprecision(2) 
         << baseline_stats.mean << "      1.00×" << endl;
    
    cout << "Baseline OpenMP:                 " << setw(10)
         << baseline_omp_stats.mean << "      " 
         << baseline_stats.mean / baseline_omp_stats.mean << "×" << endl;
    
    cout << "---------------------------------------------------------------" << endl;
    
    cout << "im2row:                          " << setw(10)
         << im2row_compute_stats.mean << "      " 
         << baseline_stats.mean / im2row_compute_stats.mean << "×" << endl;
    
    cout << "im2row SIMD:                     " << setw(10)
         << im2row_simd_compute_stats.mean << "      " 
         << baseline_stats.mean / im2row_simd_compute_stats.mean << "×" << endl;
    
    cout << "im2row OpenMP:                   " << setw(10)
         << im2row_omp_compute_stats.mean << "      " 
         << baseline_stats.mean / im2row_omp_compute_stats.mean << "×" << endl;
    
    cout << "---------------------------------------------------------------" << endl;
    
    cout << "Stencil2Row (Transposed):        " << setw(10)
         << stencil2row_stats.mean << "      " 
         << baseline_stats.mean / stencil2row_stats.mean << "×" << endl;
    
    cout << "Stencil2Row SIMD (Transposed):   " << setw(10)
         << stencil2row_simd_stats.mean << "      " 
         << baseline_stats.mean / stencil2row_simd_stats.mean << "×" << endl;
    
    cout << "Stencil2Row OpenMP (Transposed): " << setw(10)
         << stencil2row_omp_stats.mean << "      " 
         << baseline_stats.mean / stencil2row_omp_stats.mean << "×" << endl;
    
    // Memory access pattern analysis
    cout << "\n========== Memory Access Pattern Analysis ==========" << endl;
    cout << "15×15 Kernel Stencil2Row Characteristics:" << endl;
    cout << "  - Group size: " << KERNEL_SIZE + 1 << " (kernel size + 1)" << endl;
    cout << "  - Memory reduction: " << fixed << setprecision(1) << memory_reduction << "% vs im2row" << endl;
    cout << "  - Matrix A: Stores first point of each group (225 elements)" << endl;
    cout << "  - Matrix B: Stores last point of each group (225 elements)" << endl;
    cout << "  - Weight construction: Shifted kernels for intermediate points" << endl;
    cout << "  - Trade-off: 2× compute for " << memory_reduction << "% memory savings" << endl;
    cout << "\nTransposed Weight Matrix Implementation:" << endl;
    cout << "  - Matrix A: Row-major access (cache friendly) ✓" << endl;
    cout << "  - Weight matrix (transposed): Row-major access (cache friendly) ✓" << endl;
    cout << "  - Cache line utilization: ~100% (sequential access)" << endl;
    
    // Find best performing method
    double best_time = min({baseline_omp_stats.mean, im2row_compute_stats.mean, 
                            im2row_simd_compute_stats.mean, im2row_omp_compute_stats.mean,
                            stencil2row_stats.mean, stencil2row_simd_stats.mean, 
                            stencil2row_omp_stats.mean});
    
    string best_method;
    if (best_time == baseline_omp_stats.mean) best_method = "Baseline OpenMP";
    else if (best_time == im2row_compute_stats.mean) best_method = "im2row";
    else if (best_time == im2row_simd_compute_stats.mean) best_method = "im2row SIMD";
    else if (best_time == im2row_omp_compute_stats.mean) best_method = "im2row OpenMP";
    else if (best_time == stencil2row_stats.mean) best_method = "Stencil2Row (Transposed)";
    else if (best_time == stencil2row_simd_stats.mean) best_method = "Stencil2Row SIMD (Transposed)";
    else if (best_time == stencil2row_omp_stats.mean) best_method = "Stencil2Row OpenMP (Transposed)";
    
    cout << "\n========== Best Performance ==========" << endl;
    cout << "Best method: " << best_method << endl;
    cout << "Time: " << fixed << setprecision(2) << best_time << " μs" << endl;
    cout << "Speedup over baseline: " << baseline_stats.mean / best_time << "×" << endl;
    
    // Free memory
    free(original_data);
    free(input);
    free(kernel);
    free(output_baseline);
    free(output_baseline_omp);
    free(output_im2row);
    free(output_im2row_simd);
    free(output_im2row_omp);
    free(output_stencil2row);
    free(output_stencil2row_simd);
    free(output_stencil2row_omp);
    free(row_matrix);
    free(matrix_A);
    free(matrix_B);
    free(weight_A_T);
    free(weight_B_T);
    free(result_A);
    free(result_B);
    free(result_combined);
    
    cout << "\n==========================================" << endl;
    cout << "Test completed successfully!" << endl;
    cout << "==========================================" << endl;
    
    return 0;
}