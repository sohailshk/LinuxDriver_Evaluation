# User Guide - Linux Device Driver Evaluation Framework

## Overview

This comprehensive guide explains how to use the Linux Device Driver Evaluation Framework to benchmark AI models on device driver code generation tasks.

## Quick Start

### Prerequisites

- **Linux Environment**: WSL2/Ubuntu recommended
- **Build Tools**: GCC, make, kernel headers (optional)
- **Python**: 3.8+ with virtual environment
- **Static Analysis**: clang-tidy, checkpatch.pl

### Installation

1. **Clone or download the framework:**
   ```bash
   cd /path/to/Kernel_Assignment
   ```

2. **Set up Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Verify tools:**
   ```bash
   make help
   ./scripts/evaluate_compile_clean.sh --help
   ```

## Complete Evaluation Workflow

### Step 1: Prepare Driver Code

Place your device driver source files in the `src/` directory:

```bash
# Example: Copy AI-generated driver
cp ai_generated_driver.c src/
```

### Step 2: Run Compilation & Static Analysis

```bash
# Analyze all drivers in src/
./scripts/evaluate_compile_clean.sh

# Process results with scoring
python3 scripts/compile_analyzer.py
```

**Expected Output:**
- Compilation success/failure status
- Warning and error counts
- Checkpatch style violations
- Clang-tidy static analysis results
- Scored results in `reports/compilation_results_analyzed.json`

### Step 3: Run Functional Tests

```bash
# Test specific module (requires root)
sudo python3 tests/test_driver.py src/your_driver.ko

# Or test default hello_world module
sudo python3 tests/test_driver.py
```

**Tests Performed:**
- Module loading (`insmod`)
- Device node creation
- File operations (open, read, write, close)
- Data consistency verification
- Module unloading (`rmmod`)

### Step 4: Generate Comprehensive Reports

```bash
# Generate HTML report with charts
python3 scripts/generate_report.py --format html

# Generate Markdown documentation
python3 scripts/generate_report.py --format markdown

# Generate JSON for machine processing
python3 scripts/generate_report.py --format json
```

## Detailed Usage

### Compilation Analysis

The `evaluate_compile_clean.sh` script provides comprehensive build analysis:

```bash
# Basic usage
./scripts/evaluate_compile_clean.sh

# Custom output file
./scripts/evaluate_compile_clean.sh reports/my_results.json
```

**Analyzed Metrics:**
- **Compilation Status**: Success, warnings, or failure
- **Warning Count**: GCC warning messages
- **Error Count**: GCC error messages  
- **Checkpatch Violations**: Linux kernel style compliance
- **Clang-tidy Warnings**: Static code analysis issues

### Functional Testing

The functional test harness evaluates real-world driver behavior:

```bash
# Test specific module
python3 tests/test_driver.py path/to/module.ko

# Test with custom device name
python3 tests/test_driver.py src/mydriver.ko mydevice
```

**Test Categories:**
1. **Module Management** (7 points)
   - Module loading (5 pts)
   - Module unloading (2 pts)

2. **Device Interface** (5 points)
   - Device node creation (3 pts)
   - Open/close operations (2 pts)

3. **I/O Operations** (5 points)
   - Read operations (2 pts)
   - Write operations (2 pts)
   - Read/write consistency (1 pt)

### Report Generation

Generate professional evaluation reports:

```bash
# HTML report with interactive elements
python3 scripts/generate_report.py --format html --output my_report.html

# Markdown for documentation
python3 scripts/generate_report.py --format markdown --output report.md

# JSON for API integration
python3 scripts/generate_report.py --format json --output results.json
```

## Scoring System

### Overall Rubric (100 points)

| Category | Weight | Points | Description |
|----------|--------|--------|-------------|
| **Correctness** | 40% | 40 | Compilation + Functional Testing |
| **Security** | 25% | 25 | Memory safety, input validation |
| **Code Quality** | 20% | 20 | Style, documentation, structure |
| **Performance** | 10% | 10 | Resource usage, efficiency |
| **Advanced** | 5% | 5 | Error handling, innovation |

### Detailed Breakdown

**Correctness (40 points):**
- Compilation Success: 15 points
- Functional Testing: 15 points
- Static Analysis: 10 points

**Grading Scale:**
- **A (90-100)**: Production-ready code
- **B (80-89)**: High-quality implementation
- **C (70-79)**: Functional with improvements needed
- **D (60-69)**: Basic implementation
- **F (<60)**: Major issues requiring significant work

## AI Model Evaluation

### Prompt Templates

Use consistent prompts for fair comparison:

```
Basic Character Device:
"Create a simple Linux character device driver with a 1KB buffer that supports open, close, read, and write operations. Include proper error handling and follow Linux kernel coding standards."

Advanced Block Device:
"Implement a RAM-based block device driver with 1MB capacity, supporting block I/O operations and partition handling."

Network Interface:
"Create a virtual network interface driver with packet transmission, statistics tracking, and ethtool support."
```

### Comparison Workflow

1. **Generate Multiple Implementations**:
   ```bash
   # Test GPT-4 implementation
   cp gpt4_driver.c src/driver_gpt4.c
   
   # Test Claude implementation  
   cp claude_driver.c src/driver_claude.c
   
   # Test custom implementation
   cp human_driver.c src/driver_human.c
   ```

2. **Run Batch Evaluation**:
   ```bash
   for driver in src/driver_*.c; do
       echo "Evaluating $driver"
       ./scripts/evaluate_compile_clean.sh
       python3 scripts/compile_analyzer.py
       sudo python3 tests/test_driver.py "${driver%.c}.ko"
       python3 scripts/generate_report.py --format json --output "reports/$(basename $driver .c)_report.json"
   done
   ```

3. **Compare Results**:
   - Overall scores
   - Category breakdowns
   - Specific failure patterns
   - Code quality metrics

## Troubleshooting

### Common Issues

**1. Compilation Failures**
```bash
# Check kernel headers
ls /lib/modules/$(uname -r)/build

# Use mock compilation for testing
make hello  # Should generate mock .ko file
```

**2. Permission Errors**
```bash
# Functional tests need root access
sudo python3 tests/test_driver.py

# Or test compilation only
python3 tests/test_driver.py  # Shows permission warnings
```

**3. Missing Dependencies**
```bash
# Install missing tools
sudo apt install build-essential clang-tools-extra

# Download checkpatch.pl
wget https://raw.githubusercontent.com/torvalds/linux/master/scripts/checkpatch.pl
chmod +x checkpatch.pl
```

**4. WSL2 Kernel Module Issues**
- The framework includes mock compilation for WSL2
- Functional tests will show expected failures for module loading
- This demonstrates the evaluation system's ability to detect real issues

### Debugging Tips

**View Detailed Results:**
```bash
# Check compilation logs
cat /tmp/compile*.log

# Review functional test details
cat reports/functional_test_results.json | jq '.'

# Examine scoring breakdown
cat reports/compilation_results_analyzed.json | jq '.scoring_summary'
```

**Verbose Mode:**
```bash
# Enable debug output
export DEBUG=1
./scripts/evaluate_compile_clean.sh
```

## Advanced Features

### Custom Scoring Weights

Modify `scripts/generate_report.py` to adjust rubric weights:

```python
self.rubric_weights = {
    'correctness': 50,      # Increase emphasis on correctness
    'security': 20,         # Reduce security weight
    'code_quality': 20,     # Keep code quality
    'performance': 10,      # Keep performance
    'advanced': 0           # Disable advanced features
}
```

### Integration with CI/CD

```yaml
# Example GitHub Actions workflow
name: Driver Evaluation
on: [push, pull_request]
jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.8'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          sudo apt install build-essential clang-tools-extra
      - name: Evaluate drivers
        run: |
          ./scripts/evaluate_compile_clean.sh
          python3 scripts/compile_analyzer.py
          python3 scripts/generate_report.py --format json
      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: evaluation-reports
          path: reports/
```

### Batch Processing

```bash
#!/bin/bash
# evaluate_batch.sh - Process multiple AI models

MODELS=("gpt4" "claude" "codellama" "human")

for model in "${MODELS[@]}"; do
    echo "Evaluating $model implementation..."
    
    # Copy model-specific driver
    cp "drivers/${model}_driver.c" "src/current_driver.c"
    
    # Run evaluation
    ./scripts/evaluate_compile_clean.sh
    python3 scripts/compile_analyzer.py
    sudo python3 tests/test_driver.py
    python3 scripts/generate_report.py --format json \
        --output "reports/${model}_evaluation.json"
    
    echo "Completed $model evaluation"
done

# Generate comparison report
python3 scripts/compare_models.py reports/*_evaluation.json
```

## Support and Contributing

### Getting Help

- Review this user guide thoroughly
- Check the [Architecture Documentation](architecture.md)
- Examine the [Rubric Specifications](rubrics.md)
- Run tests with verbose output for debugging

### Contributing

1. Follow Linux kernel coding standards
2. Add comprehensive tests for new features
3. Update documentation for any changes
4. Ensure backward compatibility with existing reports

### Version History

- **v1.0**: Initial release with complete evaluation pipeline
- **v1.1**: Enhanced static analysis and reporting
- **v1.2**: Added batch processing and CI/CD integration

---

*For technical support or questions about the evaluation framework, please refer to the documentation or create an issue in the project repository.*
