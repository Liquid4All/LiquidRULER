#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Error: Model name is required" >&2
    echo "Usage: $0 <model_name>" >&2
    exit 1
fi

MODEL_NAME="$1"

# Function to convert context length to abbreviated form
get_abbreviated_context() {
    local context_length="$1"
    case "$context_length" in
        4096) echo "4K" ;;
        8192) echo "8K" ;;
        16384) echo "16K" ;;
        32768) echo "32K" ;;
        *) echo "$context_length" ;;
    esac
}

# Function to extract scores from summary.csv and calculate average
process_context_length() {
    local context_length="$1"
    local abbreviated_context=$(get_abbreviated_context "$context_length")
    local summary_file="benchmark_root/$MODEL_NAME/synthetic/$context_length/pred/summary.csv"

    if [[ ! -f "$summary_file" ]]; then
        echo "Warning: $summary_file not found" >&2
        return 1
    fi

    # Extract the score row - find the line that starts with "Score"
    local score_line=$(grep "^Score," "$summary_file")

    # Calculate average using Python to handle the CSV parsing properly
    local average=$(python3 -c "
import csv
import sys
score_line = '''$score_line'''
scores = score_line.split(',')[1:]  # Skip first column 'Score'
numeric_scores = [float(x) for x in scores]
print(f'{sum(numeric_scores) / len(numeric_scores):.2f}')
")

    # Output the row: context_length,average_score,task1_score,task2_score,...
    echo "$abbreviated_context,$average,$(echo "$score_line" | cut -d',' -f2-)"
}

# Output CSV header
echo "context_length,average_score,niah_single_1,niah_single_2,niah_single_3,niah_multikey_1,niah_multikey_2,niah_multikey_3,niah_multivalue,niah_multiquery,vt,cwe,fwe,qa_1,qa_2"

# Process each context length
for context_length in 32768 16384 8192 4096; do
    process_context_length "$context_length"
done
