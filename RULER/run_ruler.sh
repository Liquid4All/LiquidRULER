#!/bin/bash

set -euo pipefail

cd scripts/
./run.sh "$MODEL_NAME" synthetic

calculate_average() {
    local csv_file="$1"
    local context_length="$2"
    
    if [ ! -f "$csv_file" ]; then
        echo "Warning: CSV file $csv_file not found"
        return 1
    fi
    
    python3 -c "
import sys
import csv
import os

csv_file = '$csv_file'
context_length = '$context_length'

try:
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)
        rows = list(reader)
    
    if len(rows) < 2:
        print(f'Warning: Invalid CSV format in {csv_file}')
        sys.exit(1)
    
    tasks = rows[0][1:]  # Skip 'Tasks' header
    scores = [float(x) for x in rows[1][1:]]  # Skip 'Score' header
    
    avg_score = sum(scores) / len(scores)
    
    print(f'Context length: {context_length}')
    for task, score in zip(tasks, scores):
        print(f'  {task}: {score}')
    print(f'  Average: {avg_score:.2f}')
    print()
    
    temp_file = '/tmp/ruler_results.csv'
    file_exists = os.path.exists(temp_file)
    
    with open(temp_file, 'a') as f:
        if not file_exists:
            f.write('Context_Length,' + ','.join(tasks) + ',Average\\n')
        score_str = ','.join([str(s) for s in scores])
        f.write(f'{context_length},{score_str},{avg_score:.2f}\\n')
        
except Exception as e:
    print(f'Error processing {csv_file}: {e}')
    sys.exit(1)
"
}

rm -f /tmp/ruler_results.csv

# See results in benchmark_root
calculate_average "benchmark_root/$MODEL_NAME/synthetic/32768/pred/summary.csv" "32K"
calculate_average "benchmark_root/$MODEL_NAME/synthetic/16384/pred/summary.csv" "16K"
calculate_average "benchmark_root/$MODEL_NAME/synthetic/8192/pred/summary.csv" "8K"
calculate_average "benchmark_root/$MODEL_NAME/synthetic/4096/pred/summary.csv" "4K"

echo "=========================================="
echo "RULER Evaluation Summary (CSV format):"
echo "=========================================="
if [ -f /tmp/ruler_results.csv ]; then
    cat /tmp/ruler_results.csv
    echo
    echo "CSV results saved to: benchmark_root/$MODEL_NAME/synthetic/ruler_summary.csv"
    cp /tmp/ruler_results.csv "benchmark_root/$MODEL_NAME/synthetic/ruler_summary.csv" 2>/dev/null || true
else
    echo "No results generated"
fi
