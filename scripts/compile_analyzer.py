#!/usr/bin/env python3
"""
compile_analyzer.py - Advanced compilation analysis and scoring

This script provides detailed analysis of compilation results and calculates
scores according to the evaluation rubric.
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

class CompilationAnalyzer:
    def __init__(self, rubric_weights=None):
        """Initialize analyzer with scoring weights from rubric."""
        self.rubric_weights = rubric_weights or {
            'compilation_success': 15,
            'static_analysis': 10,
            'checkpatch': 5,
            'clang_tidy': 5
        }
        
    def calculate_compilation_score(self, status, warnings, errors):
        """Calculate compilation score based on rubric (15 points max)."""
        if status == 'failed':
            return 0
        elif status == 'success' and warnings == 0:
            return 15  # Clean compilation
        elif status == 'success' and 1 <= warnings <= 3:
            return 10  # Minor warnings
        elif warnings >= 4 or status == 'warnings':
            return 5   # Major warnings
        else:
            return 0
            
    def calculate_checkpatch_score(self, violations):
        """Calculate checkpatch score based on rubric (5 points max)."""
        if violations == 0:
            return 5
        elif 1 <= violations <= 3:
            return 3
        elif 4 <= violations <= 10:
            return 1
        else:
            return 0
            
    def calculate_clang_tidy_score(self, warnings):
        """Calculate clang-tidy score based on rubric (5 points max)."""
        if warnings == 0:
            return 5
        elif 1 <= warnings <= 2:
            return 3
        elif 3 <= warnings <= 5:
            return 1
        else:
            return 0
            
    def analyze_file(self, file_data):
        """Analyze a single file and calculate scores."""
        compilation = file_data.get('compilation', {})
        static_analysis = file_data.get('static_analysis', {})
        
        # Calculate individual scores
        comp_score = self.calculate_compilation_score(
            compilation.get('status', 'failed'),
            compilation.get('warnings', 0),
            compilation.get('errors', 0)
        )
        
        checkpatch_score = self.calculate_checkpatch_score(
            static_analysis.get('checkpatch', {}).get('violations', 0)
        )
        
        clang_score = self.calculate_clang_tidy_score(
            static_analysis.get('clang_tidy', {}).get('warnings', 0)
        )
        
        # Update file data with scores
        file_data['scores'] = {
            'compilation_score': comp_score,
            'checkpatch_score': checkpatch_score,
            'clang_tidy_score': clang_score,
            'static_analysis_score': checkpatch_score + clang_score,
            'total_score': comp_score + checkpatch_score + clang_score
        }
        
        return file_data
        
    def generate_summary(self, results_data):
        """Generate comprehensive summary with scores."""
        files = results_data.get('files', [])
        
        if not files:
            print("Warning: No file data found for analysis")
            return results_data
            
        total_files = len(files)
        total_compilation_score = sum(f.get('scores', {}).get('compilation_score', 0) for f in files)
        total_static_score = sum(f.get('scores', {}).get('static_analysis_score', 0) for f in files)
        total_overall_score = sum(f.get('scores', {}).get('total_score', 0) for f in files)
        
        # Calculate averages
        avg_compilation = total_compilation_score / total_files if total_files > 0 else 0
        avg_static = total_static_score / total_files if total_files > 0 else 0
        avg_overall = total_overall_score / total_files if total_files > 0 else 0
        
        # Add scoring summary
        results_data['scoring_summary'] = {
            'total_files_analyzed': total_files,
            'average_scores': {
                'compilation': round(avg_compilation, 2),
                'static_analysis': round(avg_static, 2),
                'overall': round(avg_overall, 2)
            },
            'max_possible_scores': {
                'compilation': 15,
                'static_analysis': 10,
                'overall': 25
            },
            'score_percentages': {
                'compilation': round((avg_compilation / 15) * 100, 1) if avg_compilation > 0 else 0,
                'static_analysis': round((avg_static / 10) * 100, 1) if avg_static > 0 else 0,
                'overall': round((avg_overall / 25) * 100, 1) if avg_overall > 0 else 0
            }
        }
        
        return results_data

def main():
    """Main execution function."""
    if len(sys.argv) < 2:
        results_file = "reports/compilation_results.json"
    else:
        results_file = sys.argv[1]
        
    if not os.path.exists(results_file):
        print(f"Error: Results file '{results_file}' not found")
        print("Please run ./scripts/evaluate_compile.sh first")
        sys.exit(1)
        
    print("🔍 Analyzing compilation results...")
    print(f"📁 Input file: {results_file}")
    
    # Load results
    try:
        with open(results_file, 'r') as f:
            results_data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {results_file}: {e}")
        sys.exit(1)
        
    # Initialize analyzer
    analyzer = CompilationAnalyzer()
    
    # Analyze each file (if file data exists)
    files = results_data.get('files', [])
    analyzed_files = []
    
    for file_data in files:
        analyzed_file = analyzer.analyze_file(file_data)
        analyzed_files.append(analyzed_file)
        
    results_data['files'] = analyzed_files
    
    # Generate summary
    results_data = analyzer.generate_summary(results_data)
    
    # Save updated results
    output_file = results_file.replace('.json', '_analyzed.json')
    with open(output_file, 'w') as f:
        json.dump(results_data, f, indent=2)
        
    # Print summary
    summary = results_data.get('scoring_summary', {})
    print("\n📊 COMPILATION ANALYSIS SUMMARY")
    print("=" * 40)
    print(f"Files analyzed: {summary.get('total_files_analyzed', 0)}")
    
    if 'average_scores' in summary:
        avg_scores = summary['average_scores']
        percentages = summary['score_percentages']
        
        print(f"\nAverage Scores:")
        print(f"  Compilation: {avg_scores['compilation']}/15 ({percentages['compilation']}%)")
        print(f"  Static Analysis: {avg_scores['static_analysis']}/10 ({percentages['static_analysis']}%)")
        print(f"  Overall: {avg_scores['overall']}/25 ({percentages['overall']}%)")
        
    print(f"\n📁 Detailed results saved to: {output_file}")
    print("🚀 Ready for functional testing phase!")

if __name__ == "__main__":
    main()
