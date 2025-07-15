#!/bin/bash
#
# evaluate_compile.sh - Automated compilation and static analysis for device drivers
# 
# This script compiles all .c files in src/ directory, captures build results,
# runs static analysis tools, and outputs structured JSON for scoring.
#
# Usage: ./scripts/evaluate_compile.sh [output_file.json]
#

set -e  # Exit on any error

# Configuration
SRC_DIR="src"
SCRIPTS_DIR="scripts"
REPORTS_DIR="reports"
OUTPUT_FILE="${1:-${REPORTS_DIR}/compilation_results.json}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"
mkdir -p "$REPORTS_DIR"

echo -e "${BLUE}=== Linux Device Driver Compilation & Analysis ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Source Directory: $SRC_DIR"
echo "Output File: $OUTPUT_FILE"
echo

# Initialize JSON structure
cat > "$OUTPUT_FILE" << EOF
{
  "evaluation_timestamp": "$TIMESTAMP",
  "framework_version": "1.0",
  "total_files": 0,
  "compilation_summary": {
    "successful": 0,
    "failed": 0,
    "warnings": 0
  },
  "static_analysis_summary": {
    "checkpatch_violations": 0,
    "clang_tidy_warnings": 0
  },
  "files": []
}
EOF

# Function to update JSON with file results
update_json_file() {
    local file="$1"
    local compile_status="$2"
    local warnings="$3"
    local errors="$4"
    local checkpatch_violations="$5"
    local clang_warnings="$6"
    
    # Create temporary file entry
    cat > "/tmp/file_entry.json" << EOF
{
  "filename": "$file",
  "compilation": {
    "status": "$compile_status",
    "warnings": $warnings,
    "errors": $errors,
    "warning_details": [],
    "error_details": []
  },
  "static_analysis": {
    "checkpatch": {
      "violations": $checkpatch_violations,
      "details": []
    },
    "clang_tidy": {
      "warnings": $clang_warnings,
      "details": []
    }
  },
  "scores": {
    "compilation_score": 0,
    "static_analysis_score": 0
  }
}
EOF
}

# Function to compile a single file
compile_file() {
    local src_file="$1"
    local basename=$(basename "$src_file" .c)
    local compile_log="/tmp/compile_${basename}.log"
    local warnings=0
    local errors=0
    local status="failed"
    
    echo -n "  Compiling $src_file... "
    
    # Try compilation with make
    if make -f Makefile hello > "$compile_log" 2>&1; then
        status="success"
        echo -e "${GREEN}SUCCESS${NC}"
    else
        # Check if it's warnings or errors
        if grep -q "error:" "$compile_log"; then
            status="failed"
            errors=$(grep -c "error:" "$compile_log" || echo "0")
            echo -e "${RED}FAILED${NC} ($errors errors)"
        else
            status="warnings"
            warnings=$(grep -c "warning:" "$compile_log" || echo "0")
            echo -e "${YELLOW}WARNINGS${NC} ($warnings warnings)"
        fi
    fi
    
    # Count warnings even in successful builds
    if [ "$status" = "success" ]; then
        warnings=$(grep -c "warning:" "$compile_log" || echo "0")
        if [ "$warnings" -gt 0 ]; then
            echo -e "    ${YELLOW}Note: $warnings warnings found${NC}"
        fi
    fi
    
    echo "$status:$warnings:$errors"
}

# Function to run checkpatch analysis
run_checkpatch() {
    local src_file="$1"
    local checkpatch_log="/tmp/checkpatch_$(basename "$src_file" .c).log"
    local violations=0
    
    echo -n "  Running checkpatch on $src_file... "
    
    if [ -f "./checkpatch.pl" ]; then
        ./checkpatch.pl --no-tree --file "$src_file" > "$checkpatch_log" 2>&1 || true
        violations=$(grep -c "WARNING\|ERROR" "$checkpatch_log" || echo "0")
        
        if [ "$violations" -eq 0 ]; then
            echo -e "${GREEN}CLEAN${NC}"
        else
            echo -e "${YELLOW}${violations} violations${NC}"
        fi
    else
        echo -e "${RED}checkpatch.pl not found${NC}"
    fi
    
    echo "$violations"
}

# Function to run clang-tidy analysis
run_clang_tidy() {
    local src_file="$1"
    local tidy_log="/tmp/clang_tidy_$(basename "$src_file" .c).log"
    local warnings=0
    
    echo -n "  Running clang-tidy on $src_file... "
    
    if command -v clang-tidy >/dev/null 2>&1; then
        # Run clang-tidy with kernel-specific checks
        clang-tidy "$src_file" \
            --checks='-*,readability-*,bugprone-*,clang-analyzer-*' \
            -- -I/usr/src/linux-headers-$(uname -r)/include 2>/dev/null > "$tidy_log" 2>&1 || true
        
        warnings=$(grep -c "warning:" "$tidy_log" || echo "0")
        
        if [ "$warnings" -eq 0 ]; then
            echo -e "${GREEN}CLEAN${NC}"
        else
            echo -e "${YELLOW}$warnings warnings${NC}"
        fi
    else
        echo -e "${RED}clang-tidy not found${NC}"
    fi
    
    echo "$warnings"
}

# Main processing loop
echo -e "${BLUE}Phase 1: Compilation Analysis${NC}"
echo "----------------------------------------"

total_files=0
successful_compiles=0
failed_compiles=0
total_warnings=0
total_checkpatch_violations=0
total_clang_warnings=0

# Temporary array to store file results
declare -a file_results

# Process all .c files in src directory
if [ -d "$SRC_DIR" ]; then
    for src_file in "$SRC_DIR"/*.c; do
        if [ -f "$src_file" ]; then
            total_files=$((total_files + 1))
            echo "Processing file $total_files: $src_file"
            
            # Compile the file
            compile_result=$(compile_file "$src_file")
            IFS=':' read -r compile_status warnings errors <<< "$compile_result"
            
            # Update counters
            if [ "$compile_status" = "success" ] || [ "$compile_status" = "warnings" ]; then
                successful_compiles=$((successful_compiles + 1))
            else
                failed_compiles=$((failed_compiles + 1))
            fi
            total_warnings=$((total_warnings + warnings))
            
            # Store file result for later
            file_results+=("$src_file:$compile_status:$warnings:$errors")
            
            echo
        fi
    done
else
    echo -e "${RED}Error: Source directory '$SRC_DIR' not found${NC}"
    exit 1
fi

echo -e "${BLUE}Phase 2: Static Analysis${NC}"
echo "----------------------------------------"

# Run static analysis and update file results
for i in "${!file_results[@]}"; do
    IFS=':' read -r src_file compile_status warnings errors <<< "${file_results[$i]}"
    
    if [ -f "$src_file" ]; then
        echo "Analyzing: $src_file"
        
        # Run checkpatch
        checkpatch_violations=$(run_checkpatch "$src_file")
        total_checkpatch_violations=$((total_checkpatch_violations + checkpatch_violations))
        
        # Run clang-tidy
        clang_warnings=$(run_clang_tidy "$src_file")
        total_clang_warnings=$((total_clang_warnings + clang_warnings))
        
        # Update file_results with static analysis data
        file_results[$i]="$src_file:$compile_status:$warnings:$errors:$checkpatch_violations:$clang_warnings"
        
        echo
    fi
done

# Update final JSON with summary and file details
python3 << EOF
import json

# Read the current JSON
with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)

# Update summary
data['total_files'] = $total_files
data['compilation_summary']['successful'] = $successful_compiles
data['compilation_summary']['failed'] = $failed_compiles
data['compilation_summary']['warnings'] = $total_warnings
data['static_analysis_summary']['checkpatch_violations'] = $total_checkpatch_violations
data['static_analysis_summary']['clang_tidy_warnings'] = $total_clang_warnings

# Add individual file results
file_results = []
EOF

# Add each file result to the Python script
for file_result in "${file_results[@]}"; do
    IFS=':' read -r src_file compile_status warnings errors checkpatch_violations clang_warnings <<< "$file_result"
    
    cat << EOF >> /tmp/update_json.py
file_results.append({
    "filename": "$src_file",
    "compilation": {
        "status": "$compile_status",
        "warnings": $warnings,
        "errors": $errors,
        "warning_details": [],
        "error_details": []
    },
    "static_analysis": {
        "checkpatch": {
            "violations": $checkpatch_violations,
            "details": []
        },
        "clang_tidy": {
            "warnings": $clang_warnings,
            "details": []
        }
    },
    "scores": {
        "compilation_score": 0,
        "static_analysis_score": 0
    }
})
EOF
done

# Complete the Python script
cat << EOF >> /tmp/update_json.py

data['files'] = file_results

# Write back
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF

# Execute the Python script
python3 /tmp/update_json.py
rm -f /tmp/update_json.py

# Final summary
echo -e "${BLUE}=== ANALYSIS COMPLETE ===${NC}"
echo "Total files processed: $total_files"
echo "Successful compilations: $successful_compiles"
echo "Failed compilations: $failed_compiles"
echo "Total warnings: $total_warnings"
echo "Checkpatch violations: $total_checkpatch_violations"
echo "Clang-tidy warnings: $total_clang_warnings"
echo
echo "Results saved to: $OUTPUT_FILE"
echo
echo -e "${GREEN}Next step: Run 'python3 scripts/generate_report.py' to generate full evaluation report${NC}"
