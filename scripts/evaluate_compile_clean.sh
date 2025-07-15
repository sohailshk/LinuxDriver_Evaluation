#!/bin/bash
#
# evaluate_compile.sh - Clean compilation and static analysis script
#

# Configuration
SRC_DIR="src"
REPORTS_DIR="reports"
OUTPUT_FILE="${1:-${REPORTS_DIR}/compilation_results.json}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create output directory
mkdir -p "$REPORTS_DIR"

echo -e "${BLUE}=== Device Driver Evaluation ===${NC}"
echo "Timestamp: $TIMESTAMP"
echo "Output: $OUTPUT_FILE"
echo

# Function to safely count grep results
safe_count() {
    local pattern="$1"
    local file="$2"
    local result
    
    if [ -f "$file" ]; then
        result=$(grep -c "$pattern" "$file" 2>/dev/null || echo "0")
        # Ensure result is a number
        if [[ "$result" =~ ^[0-9]+$ ]]; then
            echo "$result"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Compile and analyze
total_files=0
successful=0
failed=0
total_warnings=0
total_checkpatch=0
total_clang=0

# Start JSON
echo '{' > "$OUTPUT_FILE"
echo "  \"evaluation_timestamp\": \"$TIMESTAMP\"," >> "$OUTPUT_FILE"
echo "  \"framework_version\": \"1.0\"," >> "$OUTPUT_FILE"
echo "  \"files\": [" >> "$OUTPUT_FILE"

first_file=true

for src_file in "$SRC_DIR"/*.c; do
    if [ -f "$src_file" ]; then
        echo "Processing: $src_file"
        total_files=$((total_files + 1))
        
        # Compilation
        compile_log="/tmp/compile.log"
        if make hello > "$compile_log" 2>&1; then
            compile_status="success"
            successful=$((successful + 1))
            echo "  ✓ Compilation: SUCCESS"
        else
            compile_status="failed"
            failed=$((failed + 1))
            echo "  ✗ Compilation: FAILED"
        fi
        
        warnings=$(safe_count "warning:" "$compile_log")
        errors=$(safe_count "error:" "$compile_log")
        total_warnings=$((total_warnings + warnings))
        
        # Static analysis
        checkpatch_log="/tmp/checkpatch.log"
        if [ -f "./checkpatch.pl" ]; then
            ./checkpatch.pl --no-tree --file "$src_file" > "$checkpatch_log" 2>&1 || true
            violations=$(safe_count "WARNING\|ERROR" "$checkpatch_log")
            total_checkpatch=$((total_checkpatch + violations))
            echo "  📋 Checkpatch: $violations violations"
        else
            violations=0
            echo "  📋 Checkpatch: SKIPPED (not found)"
        fi
        
        clang_log="/tmp/clang.log"
        if command -v clang-tidy >/dev/null 2>&1; then
            clang-tidy "$src_file" --checks='-*,readability-*' > "$clang_log" 2>&1 || true
            clang_warnings=$(safe_count "warning:" "$clang_log")
            total_clang=$((total_clang + clang_warnings))
            echo "  🔍 Clang-tidy: $clang_warnings warnings"
        else
            clang_warnings=0
            echo "  🔍 Clang-tidy: SKIPPED (not found)"
        fi
        
        # Add to JSON
        if [ "$first_file" = false ]; then
            echo "    ," >> "$OUTPUT_FILE"
        fi
        first_file=false
        
        cat >> "$OUTPUT_FILE" << EOF
    {
      "filename": "$src_file",
      "compilation": {
        "status": "$compile_status",
        "warnings": $warnings,
        "errors": $errors
      },
      "static_analysis": {
        "checkpatch": {"violations": $violations},
        "clang_tidy": {"warnings": $clang_warnings}
      }
    }
EOF
        
        echo
    fi
done

# Close JSON
echo "" >> "$OUTPUT_FILE"
echo "  ]," >> "$OUTPUT_FILE"
echo "  \"summary\": {" >> "$OUTPUT_FILE"
echo "    \"total_files\": $total_files," >> "$OUTPUT_FILE"
echo "    \"successful\": $successful," >> "$OUTPUT_FILE"
echo "    \"failed\": $failed," >> "$OUTPUT_FILE"
echo "    \"total_warnings\": $total_warnings," >> "$OUTPUT_FILE"
echo "    \"total_checkpatch_violations\": $total_checkpatch," >> "$OUTPUT_FILE"
echo "    \"total_clang_warnings\": $total_clang" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Summary
echo -e "${BLUE}=== SUMMARY ===${NC}"
echo "Files processed: $total_files"
echo "Successful: $successful"
echo "Failed: $failed"
echo "Total warnings: $total_warnings"
echo "Checkpatch violations: $total_checkpatch"
echo "Clang-tidy warnings: $total_clang"
echo
echo "Results saved to: $OUTPUT_FILE"
echo -e "${GREEN}Run: python3 scripts/compile_analyzer.py${NC}"
