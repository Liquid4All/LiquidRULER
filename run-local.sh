#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 --model-url <model-url> --model-name <model-name> --model-api-key <api-key> [--skip-install] [--num-samples <num-samples>] [--ci]"
  exit 1
}

MODEL_URL=""
MODEL_NAME=""
MODEL_API_KEY=""
SKIP_INSTALL=false
NUM_SAMPLES=100
CI=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --model-url)
      MODEL_URL="$2"
      shift 2
      ;;
    --model-name)
      MODEL_NAME="$2"
      shift 2
      ;;
    --model-api-key)
      MODEL_API_KEY="$2"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --num-samples)
      NUM_SAMPLES="$2"
      shift 2
      ;;
    --ci)
      CI="true"
      shift
      ;;
    *)
      echo "Error: Unknown parameter $1"
      usage
      ;;
  esac
done

if [ -z "$MODEL_NAME" ]; then
  echo "Error: missing model name (e.g. lfm-3b)."
  usage
fi

if [ -z "$MODEL_URL" ]; then
  echo "Error: missing model URL (e.g. https://inference-1.liquid.ai)."
  usage
fi

if [ -z "$MODEL_API_KEY" ]; then
  echo "Error: missing model API key."
  usage
fi

# This script works when starting in a fresh conda environment with python=3.11
# conda create -n ruler python=3.11
# conda activate ruler
cd RULER

if [ "$SKIP_INSTALL" = false ]; then
  ./install_script.sh
fi

export MODEL_URL="$MODEL_URL"
export MODEL_NAME="$MODEL_NAME"
export MODEL_API_KEY="$MODEL_API_KEY"
export NUM_SAMPLES="$NUM_SAMPLES"
export CI="$CI"

./run_ruler.sh
