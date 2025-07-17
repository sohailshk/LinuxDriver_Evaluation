# Linux Device Driver Evaluation Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Linux](https://img.shields.io/badge/platform-Linux-green.svg)](https://www.linux.org/)

An automated, comprehensive evaluation system for benchmarking AI models on Linux device driver code generation tasks.

## 🎯 Overview

This framework provides a complete end-to-end evaluation pipeline that:
- **Evaluates AI-generated device drivers** across multiple quality dimensions
- **Automatically compiles, analyzes, and tests** generated code
- **Produces comprehensive scoring and reports** with actionable recommendations
- **Enables systematic comparison** of different AI models for kernel development
- **Follows Linux kernel development standards** for authentic evaluation

## ✨ Key Features

- **🔧 Automated Compilation Testing** - GCC compilation with kernel-specific flags
- **📊 Static Code Analysis** - checkpatch.pl and clang-tidy integration
- **🧪 Functional Testing** - Real device driver loading and I/O operations
- **📈 Comprehensive Scoring** - 100-point rubric based on Linux kernel standards
- **📋 Multi-format Reports** - HTML, Markdown, and JSON output formats
- **🔒 Security Analysis** - Memory safety and input validation checks
- **🌐 Environment Awareness** - Handles WSL2 and containerized environments

## 📁 Project Structure

```
Kernel_Assignment/
├── 📂 src/                    # Device driver source code
│   ├── hello_world.c         # Sample character device driver
│   └── *.c                   # AI-generated drivers for evaluation
├── 📂 scripts/               # Evaluation automation scripts
│   ├── evaluate_compile_clean.sh  # Compilation & static analysis
│   ├── compile_analyzer.py        # Scoring engine
│   ├── generate_report.py         # Report generation
│   └── create_mock_device.sh      # WSL2 compatibility
├── 📂 tests/                 # Functional test suite
│   └── test_driver.py        # Device driver testing harness
├── 📂 docs/                  # Comprehensive documentation
│   ├── architecture.md       # System design and components
│   ├── rubrics.md            # Evaluation criteria and scoring
│   ├── user_guide.md         # Detailed usage instructions
│   └── demo_script.md        # Presentation guide
├── 📂 reports/               # Generated evaluation reports
├── 📂 slides/                # Presentation materials
├── Makefile                  # Build system for kernel modules
├── requirements.txt          # Python dependencies
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites
- **Linux environment** (WSL2/Ubuntu recommended)
- **GCC compiler** and build tools
- **Python 3.8+** with pip
- **Git** for version control

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/LinuxDriver_Evaluation.git
   cd LinuxDriver_Evaluation
   ```

2. **Set up Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Install system dependencies:**
   ```bash
   sudo apt update
   sudo apt install build-essential clang-tools-extra
   
   # Download Linux kernel style checker
   wget https://raw.githubusercontent.com/torvalds/linux/master/scripts/checkpatch.pl
   chmod +x checkpatch.pl
   ```

### Running the Evaluation

1. **Compile and analyze the sample driver:**
   ```bash
   ./scripts/evaluate_compile_clean.sh
   python3 scripts/compile_analyzer.py
   ```

2. **Run functional tests:**
   ```bash
   make clean && make hello
   sudo python3 tests/test_driver.py
   ```

3. **Generate comprehensive reports:**
   ```bash
   python3 scripts/generate_report.py --format html
   python3 scripts/generate_report.py --format markdown
   ```

### Expected Output
- **Compilation Results:** `reports/compilation_results_analyzed.json`
- **Functional Test Results:** `reports/functional_test_results.json`
- **Final Evaluation Report:** `reports/evaluation_report_*.html`

## 📊 Evaluation Metrics

The framework uses a comprehensive **100-point scoring system** based on Linux kernel development standards:

| **Category** | **Weight** | **Max Points** | **Description** |
|--------------|------------|-----------------|------------------|
| **Correctness** | 40% | 40 pts | Compilation success + Functional testing |
| **Security** | 25% | 25 pts | Memory safety + Input validation |
| **Code Quality** | 20% | 20 pts | Style compliance + Documentation |
| **Performance** | 10% | 10 pts | Resource usage + Efficiency |
| **Advanced Features** | 5% | 5 pts | Error handling + Innovation |

### Grading Scale
- **A (90-100)**: Production-ready code
- **B (80-89)**: High-quality implementation
- **C (70-79)**: Functional with improvements needed
- **D (60-69)**: Basic implementation
- **F (<60)**: Major issues requiring significant work

## 🔍 Sample Results

Our framework successfully evaluated a sample device driver with the following improvements:

**Before Optimization:**
- Checkpatch violations: 138
- Clang-tidy warnings: 2
- Overall score: 46.4/100 (Grade: F)

**After Optimization:**
- Checkpatch violations: 3 (97.8% improvement!)
- Clang-tidy warnings: 3
- Overall score: 53.7/100 (Grade: F, but significant improvement)
- Functional tests: 5/7 passed (71.4% success rate)

## 📋 System Requirements

### Minimum Requirements
- **OS**: Linux (Ubuntu 18.04+, WSL2 supported)
- **Memory**: 4GB RAM
- **Storage**: 2GB free space
- **Python**: 3.8 or higher
- **GCC**: 7.0 or higher

### Recommended Tools
- **Static Analysis**: clang-tidy, checkpatch.pl
- **Kernel Headers**: linux-headers-$(uname -r)
- **Container Runtime**: Docker (for isolated builds)

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [📐 Architecture](docs/architecture.md) | System design, components, and data flow |
| [📏 Rubrics](docs/rubrics.md) | Detailed evaluation criteria and scoring matrix |
| [📖 User Guide](docs/user_guide.md) | Complete usage instructions and examples |
| [🎬 Demo Script](docs/demo_script.md) | Presentation guide and video script |
| [🐙 GitHub Strategy](docs/github_strategy.md) | Repository management and commit guidelines |

## 🎯 Use Cases

### AI Model Benchmarking
- Compare GPT-4, Claude, CodeLlama, and other models
- Evaluate model performance on complex system programming tasks
- Track improvements over time with consistent metrics

### Educational Applications
- Automated grading of student device driver assignments
- Learning progress tracking in kernel development courses
- Provide detailed feedback on code quality and security

### Industry Applications
- Quality assurance for AI-generated system code
- Code review automation for kernel development
- Compliance verification against Linux kernel standards

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🐛 Troubleshooting

### Common Issues

**WSL2 Kernel Module Issues:**
- The framework includes mock compilation for WSL2
- Functional tests will show expected failures for module loading
- This demonstrates the evaluation system's ability to detect real issues

**Permission Errors:**
```bash
# Functional tests need root access
sudo python3 tests/test_driver.py
```

**Missing Dependencies:**
```bash
# Install missing tools
sudo apt install build-essential clang-tools-extra
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Linux kernel development community for coding standards
- Static analysis tools: checkpatch.pl and clang-tidy
- Python testing frameworks and report generation libraries

## 📧 Contact

- **Author**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourusername](https://github.com/yourusername)
- **Project Link**: [https://github.com/yourusername/LinuxDriver_Evaluation](https://github.com/yourusername/LinuxDriver_Evaluation)

---

**⭐ If you find this project useful, please give it a star!**
