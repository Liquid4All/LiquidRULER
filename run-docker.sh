#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 --model-url <model-url> --model-name <model-name> [--model-api-key <api-key>] [--num-samples <num-samples>] [--ci]"
  exit 1
}

mkdir -p ./benchmark_root

MODEL_URL=""
MODEL_NAME=""
MODEL_API_KEY="placeholder"
SKIP_INSTALL=false
CI=false
NUM_SAMPLES=100

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

USER_ID=$(id -u)
GROUP_ID=$(id -g)

docker run --rm -it \
  --user "$USER_ID:$GROUP_ID" \
  --network="host" \
  -e MODEL_API_KEY="$MODEL_API_KEY" \
  -e MODEL_URL="$MODEL_URL" \
  -e MODEL_NAME="$MODEL_NAME" \
  -e NUM_SAMPLES="$NUM_SAMPLES" \
  -e CI="$CI" \
  -v "$(pwd)/benchmark_root:/app/RULER/scripts/benchmark_root" \
  liquidai/ruler:latest
