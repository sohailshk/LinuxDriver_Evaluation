#!/bin/bash

# Linux Device Driver Evaluation Framework - Complete Demonstration
# This script showcases the entire evaluation pipeline end-to-end

echo "=================================================================="
echo "  LINUX DEVICE DRIVER EVALUATION FRAMEWORK - COMPLETE DEMO"
echo "=================================================================="
echo

# Set up colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📁 STEP 1: Project Structure Overview${NC}"
echo "=================================================================="
echo "Displaying framework directory structure:"
echo
tree -L 2 . 2>/dev/null || find . -type d -not -path '*/\.*' | head -20
echo

echo -e "${BLUE}📋 STEP 2: Documentation Available${NC}"
echo "=================================================================="
echo "Framework includes comprehensive documentation:"
echo
echo "📄 docs/rubrics.md       - Evaluation criteria and scoring"
echo "📄 docs/user_guide.md    - Installation and usage guide"  
echo "📄 docs/architecture.md  - Technical architecture details"
echo "📄 slides/overview.md    - Presentation slides (10-12 slides)"
echo

echo -e "${BLUE}🔧 STEP 3: Sample Driver Analysis${NC}"
echo "=================================================================="
echo "Analyzing hello_world.c character device driver:"
echo
if [ -f "src/hello_world.c" ]; then
    echo "✅ Driver source found: $(wc -l < src/hello_world.c) lines, $(wc -c < src/hello_world.c) bytes"
    echo "📝 Driver type: Character device driver with 1KB buffer"
else
    echo "❌ Driver source not found"
fi
echo

echo -e "${BLUE}⚙️ STEP 4: Compilation & Static Analysis${NC}"
echo "=================================================================="
echo "Running automated compilation and static analysis..."
echo
cd scripts
if [ -f "evaluate_compile_clean.sh" ]; then
    echo "🔨 Executing compilation pipeline..."
    bash evaluate_compile_clean.sh ../src/hello_world.c
    echo
    if [ -f "compilation_results.json" ]; then
        echo "✅ Compilation analysis complete - Results saved to compilation_results.json"
        echo "📊 Quick preview:"
        python3 -c "
import json
try:
    with open('compilation_results.json', 'r') as f:
        data = json.load(f)
    print(f'    Compilation Score: {data.get(\"compilation_score\", \"N/A\")}/15')
    print(f'    Checkpatch Score: {data.get(\"checkpatch_score\", \"N/A\")}/5')
    print(f'    Clang-tidy Score: {data.get(\"clang_tidy_score\", \"N/A\")}/5')
except Exception as e:
    print(f'    Preview unavailable: {e}')
"
    else
        echo "⚠️ Compilation results not generated"
    fi
else
    echo "❌ Compilation script not found"
fi
cd ..
echo

echo -e "${BLUE}🧪 STEP 5: Functional Testing${NC}"
echo "=================================================================="
echo "Running functional testing suite..."
echo
cd tests
if [ -f "test_driver.py" ]; then
    echo "🔬 Executing functional tests..."
    python3 test_driver.py --target ../src/hello_world.c 2>/dev/null || echo "⚠️ Functional testing requires root privileges"
    echo
    if [ -f "functional_results.json" ]; then
        echo "✅ Functional testing complete - Results saved to functional_results.json"
        echo "📊 Quick preview:"
        python3 -c "
import json
try:
    with open('functional_results.json', 'r') as f:
        data = json.load(f)
    print(f'    Total Tests: {len(data.get(\"test_results\", []))}')
    print(f'    Tests Passed: {sum(1 for test in data.get(\"test_results\", []) if test.get(\"status\") == \"PASS\")}')
    print(f'    Total Score: {data.get(\"total_score\", \"N/A\")}/17')
except Exception as e:
    print(f'    Preview unavailable: {e}')
"
    else
        echo "⚠️ Functional test results not generated"
    fi
else
    echo "❌ Functional testing script not found"
fi
cd ..
echo

echo -e "${BLUE}📊 STEP 6: Comprehensive Reporting${NC}"
echo "=================================================================="
echo "Generating multi-format evaluation reports..."
echo
cd scripts
if [ -f "generate_report.py" ]; then
    echo "📄 Generating HTML report..."
    python3 generate_report.py --format html --output ../reports/ 2>/dev/null
    
    echo "📄 Generating Markdown report..."
    python3 generate_report.py --format markdown --output ../reports/ 2>/dev/null
    
    echo "📄 Generating JSON report..."  
    python3 generate_report.py --format json --output ../reports/ 2>/dev/null
    
    echo "✅ Report generation complete"
    echo
    echo "📋 Generated reports:"
    ls -la ../reports/ 2>/dev/null | grep -E "\.(html|md|json)$" | while read -r line; do
        echo "    $line"
    done
else
    echo "❌ Report generator not found"
fi
cd ..
echo

echo -e "${BLUE}🎯 STEP 7: Final Evaluation Summary${NC}"
echo "=================================================================="
echo "Framework evaluation summary:"
echo
if [ -f "reports/evaluation_report_$(date +%Y%m%d)_"*.json ]; then
    latest_report=$(ls -t reports/evaluation_report_*_*.json 2>/dev/null | head -1)
    if [ -n "$latest_report" ]; then
        echo "📊 Latest evaluation results:"
        python3 -c "
import json
try:
    with open('$latest_report', 'r') as f:
        data = json.load(f)
    overall = data.get('summary', {}).get('overall_score', 'N/A')
    grade = data.get('summary', {}).get('grade', 'N/A')
    print(f'    Overall Score: {overall}/100')
    print(f'    Grade: {grade}')
    print(f'    Evaluation Status: Complete')
except Exception as e:
    print(f'    Summary unavailable: {e}')
"
    fi
fi
echo

echo -e "${GREEN}✅ DEMONSTRATION COMPLETE${NC}"
echo "=================================================================="
echo
echo -e "${CYAN}📚 Next Steps:${NC}"
echo "1. Review generated reports in reports/ directory"
echo "2. Examine detailed documentation in docs/ directory"
echo "3. View presentation slides in slides/overview.md"
echo "4. Try evaluating your own device driver code"
echo
echo -e "${CYAN}🔗 Quick Access:${NC}"
echo "• User Guide: docs/user_guide.md"
echo "• Architecture: docs/architecture.md"
echo "• Evaluation Rubric: docs/rubrics.md"
echo "• Presentation: slides/overview.md"
echo
echo -e "${PURPLE}Framework developed by: [Your Name]${NC}"
echo -e "${PURPLE}GitHub: [Your GitHub Repository]${NC}"
echo "=================================================================="
