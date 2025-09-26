cmake_minimum_required(VERSION 3.20)
project(StencilSME 
    VERSION 1.0.0
    DESCRIPTION "ARM SME optimized 15x15 stencil computation for Apple Silicon"
    LANGUAGES C)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Options
option(ENABLE_SME "Enable ARM SME optimizations" ON)
option(BUILD_TESTS "Build test suite" ON)
option(USE_LTO "Enable Link Time Optimization" OFF)
option(USE_FAST_MATH "Enable fast math optimizations" OFF)
option(ENABLE_SANITIZERS "Enable address and UB sanitizers (Debug only)" OFF)

# Detect Apple Silicon and SME support
if(APPLE)
    execute_process(
        COMMAND sysctl -n machdep.cpu.brand_string
        OUTPUT_VARIABLE CPU_BRAND
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "CPU: ${CPU_BRAND}")
    
    # Check if it's Apple Silicon
    if(CPU_BRAND MATCHES "Apple M[0-9]")
        message(STATUS "Apple Silicon detected")
        set(IS_APPLE_SILICON ON)
    else()
        message(WARNING "Not running on Apple Silicon")
        set(IS_APPLE_SILICON OFF)
    endif()
endif()

# Prefer Homebrew LLVM if available
if(APPLE AND EXISTS "/opt/homebrew/opt/llvm/bin/clang")
    set(CMAKE_C_COMPILER "/opt/homebrew/opt/llvm/bin/clang")
    set(CMAKE_CXX_COMPILER "/opt/homebrew/opt/llvm/bin/clang++")
    message(STATUS "Using Homebrew LLVM: ${CMAKE_C_COMPILER}")
else()
    message(STATUS "Using system compiler: ${CMAKE_C_COMPILER}")
endif()

# Check compiler version and SME support
if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS 15.0)
        message(WARNING "Clang version ${CMAKE_C_COMPILER_VERSION} may not support SME properly")
    endif()
endif()

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Compiler flags based on build type
set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG")
set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG")

# Architecture-specific flags
if(IS_APPLE_SILICON AND ENABLE_SME)
    set(ARCH_FLAGS "-march=native+sme2")
    message(STATUS "Enabling SME2 extensions: ${ARCH_FLAGS}")
else()
    set(ARCH_FLAGS "-march=native")
    message(STATUS "Using native architecture without SME")
endif()

# Common compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ARCH_FLAGS} -Wall -Wextra -pedantic")

# Optional optimizations
if(USE_LTO)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto")
    message(STATUS "Link Time Optimization enabled")
endif()

if(USE_FAST_MATH)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffast-math")
    message(STATUS "Fast math optimizations enabled (may reduce accuracy)")
endif()

# Sanitizers for debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug" AND ENABLE_SANITIZERS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize=undefined")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address -fsanitize=undefined")
    message(STATUS "Address and UB sanitizers enabled")
endif()

# Find required libraries
find_library(MATH_LIBRARY m)

# Main executable
add_executable(stencil_kernel15 stencil_15x15_sme_optimized.c)

# Link libraries
if(MATH_LIBRARY)
    target_link_libraries(stencil_kernel15 ${MATH_LIBRARY})
endif()

# Set output directory
set_target_properties(stencil_kernel15 PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Installation
install(TARGETS stencil_kernel15
    RUNTIME DESTINATION bin
)

# Tests
if(BUILD_TESTS)
    enable_testing()
    
    # Basic execution test
    add_test(NAME BasicRun
        COMMAND stencil_kernel15
    )
    set_tests_properties(BasicRun PROPERTIES
        TIMEOUT 30
        PASS_REGULAR_EXPRESSION "All methods produce consistent results"
    )
    
    # Performance test (only checks if it runs without errors)
    add_test(NAME PerformanceCheck
        COMMAND stencil_kernel15
    )
    set_tests_properties(PerformanceCheck PROPERTIES
        TIMEOUT 60
        PASS_REGULAR_EXPRESSION "Testing complete"
    )
endif()

# Custom targets
# Benchmark target
add_custom_target(benchmark
    COMMAND ${CMAKE_BINARY_DIR}/bin/stencil_kernel15
    DEPENDS stencil_kernel15
    COMMENT "Running performance benchmark..."
)

# Assembly generation target
add_custom_target(asm
    COMMAND ${CMAKE_C_COMPILER} ${CMAKE_C_FLAGS} -S 
            ${CMAKE_SOURCE_DIR}/stencil_15x15_sme_optimized.c
            -o ${CMAKE_BINARY_DIR}/stencil_15x15_sme_optimized.s
    COMMENT "Generating assembly output..."
)

# Check SME support
add_custom_target(check-sme
    COMMAND ${CMAKE_COMMAND} -E echo "Checking SME support..."
    COMMAND sysctl -n machdep.cpu.brand_string
    COMMAND sysctl -a | grep -E "hw.optional.(arm|neon|armv)" | sort || true
    COMMENT "Checking system SME capabilities..."
)

# Format code (if clang-format is available)
find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    add_custom_target(format
        COMMAND ${CLANG_FORMAT} -i ${CMAKE_SOURCE_DIR}/stencil_15x15_sme_optimized.c
        COMMENT "Formatting source code..."
    )
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "========== Build Configuration ==========")
message(STATUS "Build type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "C Compiler:        ${CMAKE_C_COMPILER}")
message(STATUS "C Compiler ID:     ${CMAKE_C_COMPILER_ID}")
message(STATUS "C Compiler Ver:    ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "C Flags:           ${CMAKE_C_FLAGS}")
message(STATUS "Architecture:      ${ARCH_FLAGS}")
message(STATUS "SME Enabled:       ${ENABLE_SME}")
message(STATUS "LTO Enabled:       ${USE_LTO}")
message(STATUS "Fast Math:         ${USE_FAST_MATH}")
message(STATUS "Build Tests:       ${BUILD_TESTS}")
message(STATUS "Install Prefix:    ${CMAKE_INSTALL_PREFIX}")
message(STATUS "=========================================")
message(STATUS "")

# Generate compile_commands.json for better IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# CPack configuration for creating packages
set(CPACK_PACKAGE_NAME "StencilSME")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VENDOR "ZHANGFAN")
set(CPACK_PACKAGE_CONTACT "your.email@example.com")
set(CPACK_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_IGNORE_FILES
    "/build/;/.git/;/.cache/;/.vscode/;/\\\\.DS_Store;/.*\\\\.swp"
)
include(CPack)