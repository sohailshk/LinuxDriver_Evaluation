# Linux Device Driver Evaluation Framework

An automated system for benchmarking AI models on Linux device driver code generation.

## Overview

This framework provides an end-to-end evaluation pipeline that:
- Takes LLM prompts for device driver generation
- Automatically compiles, analyzes, and tests generated code
- Produces comprehensive scoring and reports
- Enables systematic comparison of AI models for kernel development

## Project Structure

```
├── src/           # Generated device driver source code
├── scripts/       # Evaluation and automation scripts
├── tests/         # Functional test suite
├── docs/          # Documentation and specifications
├── reports/       # Generated evaluation reports
├── slides/        # Presentation materials
├── Makefile       # Build system for kernel modules
└── requirements.txt # Python dependencies
```

## Quick Start

1. **Setup Environment:**
   ```bash
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Build Test Module:**
   ```bash
   make
   ```

3. **Run Evaluation:**
   ```bash
   ./scripts/evaluate_compile.sh
   python3 scripts/generate_report.py
   ```

## Requirements

- Linux environment (WSL2/Ubuntu recommended)
- GCC compiler and build tools
- Python 3.8+
- clang-tidy, checkpatch.pl
- Docker (for isolated kernel builds)

## Documentation

- [Architecture](docs/architecture.md) - System design and components
- [Rubrics](docs/rubrics.md) - Evaluation metrics and scoring
- [User Guide](docs/user_guide.md) - Detailed usage instructions

## License

MIT License - See LICENSE file for details.
