#!/bin/bash
set -euo pipefail

# Validate required environment variables
if [ -z "${LIQUID_API_KEY}" ]; then
    echo "Error: LIQUID_API_KEY environment variable is required"
    exit 1
fi

# Export variables for the benchmark
export MODEL_API_KEY="${LIQUID_API_KEY}"
export MODEL_URL="${MODEL_URL:-https://inference-1.liquid.ai}"
export NUM_SAMPLES="${NUM_SAMPLES:-100}"
export CI="${CI:-false}"

# Create benchmark_root directory
cd /app/RULER
mkdir -p scripts/benchmark_root
./run_ruler.sh
