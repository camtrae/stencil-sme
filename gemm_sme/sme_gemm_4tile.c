// sme_matmul_complete.c - 完整的SME矩阵乘法性能对比测试
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <arm_sme.h>

// 矩阵大小定义
#define M_SIZE 256  // 行数
#define K_SIZE 240  // 共同维度
#define N_SIZE 16   // 列数
#define MIN(a, b) ((a) < (b) ? (a) : (b))

// ============================================================================
// 传统CPU矩阵乘法实现
// ============================================================================
void matmul_cpu(const float *A, const float *B, float *C, 
                 uint64_t M, uint64_t K, uint64_t N) {
    for (uint64_t m = 0; m < M; m++) {
        for (uint64_t n = 0; n < N; n++) {
            float sum = 0.0f;
            for (uint64_t k = 0; k < K; k++) {
                sum += A[m * K + k] * B[k * N + n];
            }
            C[m * N + n] = sum;
        }
    }
}

// ============================================================================
// CPU版本的预处理函数（原始版本）
// ============================================================================
void preprocess_left_matrix_cpu(const float *A, float *A_mod, 
                                uint64_t M, uint64_t K, uint64_t SVL) {
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    
    for (uint64_t row = 0; row < M; row += SVL) {
        for (uint64_t col = 0; col < K; col += SVL) {
            const uint64_t dest = row * K + col * SVL;
            
            for (uint64_t j = 0; j < SVL; j++) {
                for (uint64_t i = 0; i < SVL && (col + i) < K; i++) {
                    if (row + j < M) {
                        A_mod[dest + i * SVL + j] = A[(row + j) * K + col + i];
                    } else {
                        A_mod[dest + i * SVL + j] = 0.0f;
                    }
                }
            }
        }
    }
}

// ============================================================================
// SME加速版本的预处理函数
// ============================================================================
void preprocess_left_matrix_sme_kernel(const float *A, float *A_mod, 
                                       uint64_t M, uint64_t K, uint64_t SVL) 
                                       __arm_streaming __arm_inout("za") {
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    
    for (uint64_t row = 0; row < M; row += SVL) {
        svbool_t pMDim = svwhilelt_b32(row, M);
        
        for (uint64_t col = 0; col < K; col += 2 * SVL) {
            svcount_t pKDim = svwhilelt_c32(col, K, 2);
            
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

// ============================================================================
// SME矩阵乘法 - 原始版本（单tile）
// ============================================================================
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
            
            for (uint64_t k = 0; k < K; k++) {
                svfloat32_t zL = svld1(pMDim, &A_mod[matLeft_pos + k * SVL]);
                svfloat32_t zR = svld1(pNDim, &B[matRight_UL_corner + k * N]);
                svmopa_za32_m(0, pMDim, pNDim, zL, zR);
            }
            
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

// ============================================================================
// SME矩阵乘法 - 优化版本（4 tiles并行）
// ============================================================================
void matmul_sme_kernel_4tiles(const float *A_mod, const float *B, float *C,
                              uint64_t M, uint64_t K, uint64_t N, uint64_t SVL) 
                              __arm_streaming __arm_inout("za") {
    
    for (uint64_t row = 0; row < M; row += SVL) {
        svbool_t pMDim = svwhilelt_b32(row, M);
        
        // 一次处理4个列块
        for (uint64_t col = 0; col < N; col += 4 * SVL) {
            // 为4个列块准备谓词
            svbool_t pNDim0 = svwhilelt_b32(col, N);
            svbool_t pNDim1 = svwhilelt_b32(col + SVL, N);
            svbool_t pNDim2 = svwhilelt_b32(col + 2*SVL, N);
            svbool_t pNDim3 = svwhilelt_b32(col + 3*SVL, N);
            
            // 清零所有4个累加器
            svzero_za();
            
            // 执行外积累加 - 同时使用4个tiles
            const uint64_t matLeft_pos = row * K;
            
            for (uint64_t k = 0; k < K; k++) {
                // 加载左矩阵的列向量（所有4个tiles共享）
                svfloat32_t zL = svld1(pMDim, &A_mod[matLeft_pos + k * SVL]);
                
                // 根据实际列数决定加载和计算
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
            
            // 从4个ZA tiles存储结果到内存
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

// ============================================================================
// SME包装函数
// ============================================================================

// SME矩阵乘法包装函数（CPU转置 + 单tile）
__arm_new("za") __arm_locally_streaming
void matmul_sme_cpu_preprocess(const float *A, const float *B, float *C,
                              uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    preprocess_left_matrix_cpu(A, A_mod, M, K, SVL);
    matmul_sme_kernel(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

// SME矩阵乘法包装函数（SME转置 + 单tile）
__arm_new("za") __arm_locally_streaming
void matmul_sme_sme_preprocess(const float *A, const float *B, float *C,
                              uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    preprocess_left_matrix_sme_kernel(A, A_mod, M, K, SVL);
    matmul_sme_kernel(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

// SME矩阵乘法包装函数（SME转置 + 4-tiles）
__arm_new("za") __arm_locally_streaming
void matmul_sme_4tiles(const float *A, const float *B, float *C,
                       uint64_t M, uint64_t K, uint64_t N) {
    uint64_t SVL = svcntsw();
    const uint64_t M_mod = SVL * ((M + SVL - 1) / SVL);
    float *A_mod = (float *)aligned_alloc(64, M_mod * K * sizeof(float));
    
    preprocess_left_matrix_sme_kernel(A, A_mod, M, K, SVL);
    matmul_sme_kernel_4tiles(A_mod, B, C, M, K, N, SVL);
    
    free(A_mod);
}

// ============================================================================
// 工具函数
// ============================================================================

void init_matrix(float *mat, uint64_t size, int seed) {
    srand(seed);
    for (uint64_t i = 0; i < size; i++) {
        mat[i] = ((float)(rand() % 1000)) / 100.0f - 5.0f;
    }
}

int compare_matrices(const float *ref, const float *result, 
                    uint64_t M, uint64_t N, float tolerance) {
    int errors = 0;
    float max_error = 0.0f;
    float avg_error = 0.0f;
    
    for (uint64_t i = 0; i < M * N; i++) {
        float error = fabsf(ref[i] - result[i]);
        avg_error += error;
        
        if (error > max_error) {
            max_error = error;
        }
        
        if (error > tolerance) {
            errors++;
            if (errors < 5) {
                printf("  误差位置[%lu]: 参考值=%.6f, 结果=%.6f, 差值=%.6f\n", 
                       i, ref[i], result[i], error);
            }
        }
    }
    
    avg_error /= (M * N);
    
    printf("  错误数量: %d / %lu\n", errors, M * N);
    printf("  最大误差: %.9f\n", max_error);
    printf("  平均误差: %.9f\n", avg_error);
    
    return errors == 0;
}

uint64_t get_time_us() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)(ts.tv_sec) * 1000000 + (ts.tv_nsec / 1000);
}

void print_matrix_sample(const float *mat, uint64_t M, uint64_t N, 
                        const char *name) {
    printf("%s (前4x4):\n", name);
    for (uint64_t i = 0; i < 4 && i < M; i++) {
        printf("  ");
        for (uint64_t j = 0; j < 4 && j < N; j++) {
            printf("%8.2f ", mat[i * N + j]);
        }
        printf("...\n");
    }
    printf("  ...\n");
}

// ============================================================================
// 主程序
// ============================================================================
int main(int argc, char **argv) {
    printf("====================================================\n");
    printf("SME 矩阵乘法性能对比测试（含4-tiles优化）\n");
    printf("====================================================\n");
    
    // 检查SME支持
    if (!__arm_has_sme()) {
        printf("错误: 系统不支持SME\n");
        return 1;
    }
    
    uint64_t SVL = svcntsw();
    printf("✓ 检测到SME支持\n");
    printf("✓ 向量长度(SVL): %lu 个32位字\n", SVL);
    printf("✓ ZA寄存器: 4个 %lu×%lu tiles\n\n", SVL, SVL);
    
    // 解析参数或使用默认值
    uint64_t M = M_SIZE, K = K_SIZE, N = N_SIZE;
    int iterations = 10;
    
    if (argc >= 4) {
        M = strtoul(argv[1], NULL, 0);
        K = strtoul(argv[2], NULL, 0);
        N = strtoul(argv[3], NULL, 0);
    }
    if (argc >= 5) {
        iterations = atoi(argv[4]);
    }
    
    printf("矩阵维度: A[%lu×%lu] × B[%lu×%lu] = C[%lu×%lu]\n", 
           M, K, K, N, M, N);
    printf("测试迭代次数: %d\n", iterations);
    
    // 计算理论最佳tile利用率
    uint64_t cols_per_iteration = MIN(N, 4 * SVL);
    uint64_t tile_utilization = MIN(4, (N + SVL - 1) / SVL);
    printf("理论最大tile利用数: %lu / 4\n", tile_utilization);
    printf("==========================================\n\n");
    
    // 分配内存
    float *A = (float *)aligned_alloc(64, M * K * sizeof(float));
    float *B = (float *)aligned_alloc(64, K * N * sizeof(float));
    float *C_cpu = (float *)aligned_alloc(64, M * N * sizeof(float));
    float *C_sme_cpu = (float *)aligned_alloc(64, M * N * sizeof(float));
    float *C_sme_sme = (float *)aligned_alloc(64, M * N * sizeof(float));
    float *C_sme_4tiles = (float *)aligned_alloc(64, M * N * sizeof(float));
    
    if (!A || !B || !C_cpu || !C_sme_cpu || !C_sme_sme || !C_sme_4tiles) {
        printf("内存分配失败\n");
        return 1;
    }
    
    // 初始化矩阵
    printf("初始化测试矩阵...\n");
    init_matrix(A, M * K, 42);
    init_matrix(B, K * N, 123);
    
    // 显示矩阵样本
    print_matrix_sample(A, M, K, "矩阵 A");
    print_matrix_sample(B, K, N, "矩阵 B");
    
    // ========== 1. CPU版本测试 ==========
    printf("\n----------------------------------------------------\n");
    printf("1. 运行传统CPU版本...\n");
    
    // 预热
    matmul_cpu(A, B, C_cpu, M, K, N);
    
    // 计时
    uint64_t cpu_total_time = 0;
    for (int i = 0; i < iterations; i++) {
        uint64_t start = get_time_us();
        matmul_cpu(A, B, C_cpu, M, K, N);
        cpu_total_time += get_time_us() - start;
    }
    
    float cpu_avg_time = (float)cpu_total_time / iterations;
    printf("   平均时间: %.3f μs\n", cpu_avg_time);
    
    // ========== 2. SME版本测试（CPU转置 + 单tile） ==========
    printf("\n----------------------------------------------------\n");
    printf("2. 运行SME版本（CPU转置 + 单tile）...\n");
    
    // 预热
    matmul_sme_cpu_preprocess(A, B, C_sme_cpu, M, K, N);
    
    // 计时
    uint64_t sme_cpu_total_time = 0;
    for (int i = 0; i < iterations; i++) {
        uint64_t start = get_time_us();
        matmul_sme_cpu_preprocess(A, B, C_sme_cpu, M, K, N);
        sme_cpu_total_time += get_time_us() - start;
    }
    
    float sme_cpu_avg_time = (float)sme_cpu_total_time / iterations;
    printf("   平均时间: %.3f μs\n", sme_cpu_avg_time);
    
    // ========== 3. SME版本测试（SME转置 + 单tile） ==========
    printf("\n----------------------------------------------------\n");
    printf("3. 运行SME版本（SME转置 + 单tile）...\n");
    
    // 预热
    matmul_sme_sme_preprocess(A, B, C_sme_sme, M, K, N);
    
    // 计时
    uint64_t sme_sme_total_time = 0;
    for (int i = 0; i < iterations; i++) {
        uint64_t start = get_time_us();
        matmul_sme_sme_preprocess(A, B, C_sme_sme, M, K, N);
        sme_sme_total_time += get_time_us() - start;
    }
    
    float sme_sme_avg_time = (float)sme_sme_total_time / iterations;
    printf("   平均时间: %.3f μs\n", sme_sme_avg_time);
    
    // ========== 4. SME版本测试（SME转置 + 4-tiles） ==========
    printf("\n----------------------------------------------------\n");
    printf("4. 运行SME版本（SME转置 + 4-tiles并行）...\n");
    
    // 预热
    matmul_sme_4tiles(A, B, C_sme_4tiles, M, K, N);
    
    // 计时
    uint64_t sme_4tiles_total_time = 0;
    for (int i = 0; i < iterations; i++) {
        uint64_t start = get_time_us();
        matmul_sme_4tiles(A, B, C_sme_4tiles, M, K, N);
        sme_4tiles_total_time += get_time_us() - start;
    }
    
    float sme_4tiles_avg_time = (float)sme_4tiles_total_time / iterations;
    printf("   平均时间: %.3f μs\n", sme_4tiles_avg_time);
    
    // ========== 准确度验证 ==========
    printf("\n----------------------------------------------------\n");
    printf("验证计算准确度...\n");
    
    float tolerance = 1e-3f;
    
    printf("\n对比CPU结果与SME(CPU转置+单tile):\n");
    int accurate1 = compare_matrices(C_cpu, C_sme_cpu, M, N, tolerance);
    
    printf("\n对比CPU结果与SME(SME转置+单tile):\n");
    int accurate2 = compare_matrices(C_cpu, C_sme_sme, M, N, tolerance);
    
    printf("\n对比CPU结果与SME(SME转置+4-tiles):\n");
    int accurate3 = compare_matrices(C_cpu, C_sme_4tiles, M, N, tolerance);
    
    if (accurate1 && accurate2 && accurate3) {
        printf("\n✓ 所有版本准确度验证通过！\n");
    } else {
        printf("\n✗ 准确度验证失败！\n");
    }
    
    // ========== 性能总结 ==========
    printf("\n====================================================\n");
    printf("性能总结\n");
    printf("====================================================\n");
    printf("%-25s %12s %12s %12s %15s\n", 
           "版本", "时间(μs)", "加速比", "GFLOPS", "Tile利用率");
    printf("----------------------------------------------------\n");
    
    // 计算GFLOPS
    double ops = 2.0 * M * N * K;
    double cpu_gflops = (ops / cpu_avg_time) / 1000.0;
    double sme_cpu_gflops = (ops / sme_cpu_avg_time) / 1000.0;
    double sme_sme_gflops = (ops / sme_sme_avg_time) / 1000.0;
    double sme_4tiles_gflops = (ops / sme_4tiles_avg_time) / 1000.0;
    
    printf("%-25s %12.3f %12s %12.2f %15s\n", 
           "CPU", cpu_avg_time, "1.00x", cpu_gflops, "N/A");
    printf("%-25s %12.3f %12.2fx %12.2f %15s\n", 
           "SME(CPU转置+单tile)", sme_cpu_avg_time, 
           cpu_avg_time / sme_cpu_avg_time, sme_cpu_gflops, "1/4 (25%)");
    printf("%-25s %12.3f %12.2fx %12.2f %15s\n", 
           "SME(SME转置+单tile)", sme_sme_avg_time, 
           cpu_avg_time / sme_sme_avg_time, sme_sme_gflops, "1/4 (25%)");
    printf("%-25s %12.3f %12.2fx %12.2f %15s\n", 
           "SME(SME转置+4-tiles)", sme_4tiles_avg_time, 
           cpu_avg_time / sme_4tiles_avg_time, sme_4tiles_gflops, 
           tile_utilization == 4 ? "4/4 (100%)" : 
           tile_utilization == 3 ? "3/4 (75%)" :
           tile_utilization == 2 ? "2/4 (50%)" : "1/4 (25%)");
    
    printf("\n----------------------------------------------------\n");
    
    // 优化效果分析
    printf("\n优化效果分析:\n");
    printf("==========================================\n");
    
    // 转置优化效果
    if (sme_cpu_avg_time > 0 && sme_sme_avg_time > 0) {
        float transpose_speedup = sme_cpu_avg_time / sme_sme_avg_time;
        printf("1. 转置优化（单tile）:\n");
        if (transpose_speedup > 1.0) {
            printf("   ✓ SME转置比CPU转置快 %.1f%%\n", 
                   (transpose_speedup - 1.0) * 100);
        } else {
            printf("   ✗ SME转置比CPU转置慢 %.1f%%\n", 
                   (1.0 - transpose_speedup) * 100);
        }
    }
    
    // 4-tiles优化效果
    if (sme_sme_avg_time > 0 && sme_4tiles_avg_time > 0) {
        float tiles_speedup = sme_sme_avg_time / sme_4tiles_avg_time;
        printf("\n2. 4-tiles并行优化:\n");
        printf("   相比单tile版本加速: %.2fx\n", tiles_speedup);
        printf("   理论最大加速: %.1fx\n", (float)tile_utilization);
        printf("   效率: %.1f%%\n", (tiles_speedup / tile_utilization) * 100);
    }
    
    // 总体最佳性能
    float best_speedup = cpu_avg_time / sme_4tiles_avg_time;
    printf("\n3. 最佳SME版本相比CPU:\n");
    if (best_speedup > 1.0) {
        printf("   ✓ 总体加速 %.2fx (快%.1f%%)\n", 
               best_speedup, (best_speedup - 1.0) * 100);
        printf("   达到 %.2f GFLOPS 性能\n", sme_4tiles_gflops);
    } else {
        printf("   ✗ 没有加速效果 (慢%.1f%%)\n", 
               (1.0 - best_speedup) * 100);
    }
    
    // 性能瓶颈分析
    printf("\n4. 性能分析:\n");
    if (N <= SVL) {
        printf("   ⚠ N维度(%lu) <= SVL(%lu)，只能使用1个tile\n", N, SVL);
        printf("   建议：增大N维度以充分利用4个tiles\n");
    } else if (N < 4 * SVL) {
        printf("   ⚠ N维度(%lu) < 4*SVL(%lu)，只能部分利用tiles\n", N, 4*SVL);
        printf("   当前使用 %lu/%d tiles\n", tile_utilization, 4);
    } else {
        printf("   ✓ N维度充足，可完全利用4个tiles\n");
    }
    
    printf("\n====================================================\n");
    
    // 释放内存
    free(A);
    free(B);
    free(C_cpu);
    free(C_sme_cpu);
    free(C_sme_sme);
    free(C_sme_4tiles);
    
    return (accurate1 && accurate2 && accurate3) ? 0 : 1;
}