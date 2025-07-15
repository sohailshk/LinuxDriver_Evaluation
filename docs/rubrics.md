# Linux Device Driver Evaluation Rubric

## Overview

This document defines the comprehensive evaluation metrics and scoring system for benchmarking AI models on Linux device driver code generation.

## Scoring System

**Total Score: 100 points**

### 1. Correctness (40 points) - Critical Success Metrics

#### 1.1 Compilation Success (15 points)
- **Clean Compilation (15 pts)**: No errors, compiles successfully
- **Minor Warnings (10 pts)**: Compiles with 1-3 warnings
- **Major Warnings (5 pts)**: Compiles with 4+ warnings or style violations
- **Compilation Failure (0 pts)**: Does not compile

#### 1.2 Static Analysis (10 points)
- **checkpatch.pl compliance (5 pts)**:
  - 0 violations: 5 pts
  - 1-3 violations: 3 pts
  - 4-10 violations: 1 pt
  - 10+ violations: 0 pts
- **clang-tidy analysis (5 pts)**:
  - 0 warnings: 5 pts
  - 1-2 warnings: 3 pts
  - 3-5 warnings: 1 pt
  - 5+ warnings: 0 pts

#### 1.3 Functional Testing (15 points)
- **Module Load/Unload (5 pts)**: insmod/rmmod succeeds
- **Device Node Creation (3 pts)**: /dev/device_name appears
- **Basic Read/Write Operations (4 pts)**: open, read, write syscalls work
- **Proper Return Values (3 pts)**: Correct error codes and data handling

### 2. Security (25 points) - Critical Safety Metrics

#### 2.1 Memory Safety (10 points)
- **Buffer Overflow Protection (5 pts)**: Proper bounds checking
- **Memory Leak Prevention (3 pts)**: Proper allocation/deallocation
- **Null Pointer Checks (2 pts)**: Validates pointers before use

#### 2.2 Input Validation (8 points)
- **User Input Sanitization (4 pts)**: copy_from_user validation
- **Parameter Bounds Checking (2 pts)**: Length and range validation
- **Privilege Checking (2 pts)**: Proper capability checks

#### 2.3 Race Condition Prevention (7 points)
- **Locking Mechanisms (4 pts)**: Proper mutex/spinlock usage
- **Atomic Operations (2 pts)**: Race-free variable updates
- **Resource Management (1 pt)**: Cleanup in error paths

### 3. Code Quality (20 points) - Maintainability & Style

#### 3.1 Linux Kernel Coding Style (8 points)
- **Indentation & Formatting (3 pts)**: Tabs, 80-char lines, braces
- **Naming Conventions (2 pts)**: Function, variable naming
- **Comment Quality (3 pts)**: Function headers, inline comments

#### 3.2 Documentation (6 points)
- **Module Documentation (3 pts)**: MODULE_* macros, file headers
- **Function Documentation (2 pts)**: Clear function descriptions
- **Usage Examples (1 pt)**: How to use the driver

#### 3.3 Code Structure (6 points)
- **Modularity (3 pts)**: Well-organized functions
- **Error Handling (2 pts)**: Proper cleanup and error paths
- **Readability (1 pt)**: Clear, maintainable code

### 4. Performance (10 points) - Efficiency Metrics

#### 4.1 Resource Usage (5 points)
- **Memory Efficiency (3 pts)**: Minimal memory footprint
- **CPU Efficiency (2 pts)**: Efficient algorithms

#### 4.2 Scalability (3 points)
- **Multiple Device Support (2 pts)**: Handles multiple instances
- **Concurrent Access (1 pt)**: Thread-safe operations

#### 4.3 Optimization (2 points)
- **Minimal System Calls (1 pt)**: Efficient kernel interaction
- **Fast Path Optimization (1 pt)**: Common operations optimized

### 5. Advanced Features (5 points) - Bonus Capabilities

#### 5.1 Error Recovery (2 points)
- **Graceful Degradation (1 pt)**: Handles errors without crashing
- **State Recovery (1 pt)**: Maintains consistency after errors

#### 5.2 Feature Completeness (2 points)
- **IOCTL Support (1 pt)**: Additional device controls
- **Proc/Sysfs Integration (1 pt)**: Kernel interface exposure

#### 5.3 Innovation (1 point)
- **Creative Solutions (1 pt)**: Novel approaches to requirements

## Detailed Scoring Methodology

### Automated Scoring Components (70%)
1. **Compilation Results**: Binary pass/fail with warning count
2. **Static Analysis**: Tool output parsing (checkpatch.pl, clang-tidy)
3. **Functional Tests**: Automated test suite execution
4. **Security Scans**: Pattern matching for common vulnerabilities

### Manual Review Components (30%)
1. **Code Quality Assessment**: Human review of structure and style
2. **Documentation Evaluation**: Completeness and clarity review
3. **Innovation Scoring**: Subjective assessment of creative solutions

## Test Cases by Category

### Basic Character Device (Entry Level)
- **Prompt**: "Create a simple character device with 1KB buffer"
- **Expected Features**: open, close, read, write operations
- **Minimum Score**: 60/100 for basic functionality

### Advanced Block Device (Intermediate)
- **Prompt**: "Create a RAM-based block device with 1MB capacity"
- **Expected Features**: Block I/O operations, partition support
- **Minimum Score**: 70/100 for full functionality

### Network Device Driver (Advanced)
- **Prompt**: "Create a virtual network interface"
- **Expected Features**: Packet transmission, statistics, ethtool support
- **Minimum Score**: 80/100 for production readiness

## Score Interpretation

- **90-100**: Production-ready code, suitable for mainline kernel
- **80-89**: High-quality code with minor improvements needed
- **70-79**: Functional code requiring moderate refactoring
- **60-69**: Basic functionality present, significant improvements needed
- **Below 60**: Major issues, not suitable for deployment

## Reporting Format

Each evaluation generates:
1. **Overall Score**: Weighted total (0-100)
2. **Category Breakdown**: Points per major category
3. **Detailed Analysis**: Specific findings and recommendations
4. **Comparison Matrix**: Against baseline and other models
5. **Improvement Suggestions**: Actionable feedback for enhancement

## Version History

- **v1.0**: Initial rubric with 5 major categories
- **v1.1**: Added security emphasis and automated scoring
- **v1.2**: Enhanced performance metrics and test cases
