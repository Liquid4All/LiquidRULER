#!/bin/bash
set -euo pipefail

# Validate required environment variables
if [ -z "${LIQUID_API_KEY}" ]; then
    echo "Error: LIQUID_API_KEY environment variable is required"
    exit 1
fi

# Export variables for the benchmark
export OPENAI_API_KEY="${LIQUID_API_KEY}"
export LIQUID_SERVER="${LIQUID_SERVER:-https://inference-1.liquid.ai}"
export NUM_SAMPLES="${NUM_SAMPLES:-100}"

# Create benchmark_root directory
cd /app/RULER/scripts
mkdir -p benchmark_root

# Run the benchmark and evaluation
cd ..
./run_ruler.sh
cd scripts/eval
python evaluate.py --data-dir ../benchmark_root/lfm-3b/synthetic
