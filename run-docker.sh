#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 --liquid-api-key <LIQUID_API_KEY> [--liquid-server <LIQUID_SERVER>] [--num-samples <NUM_SAMPLES>] [--ci]"
  exit 1
}

# Default values
LIQUID_SERVER="https://inference-1.liquid.ai"
NUM_SAMPLES=100
CI=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --liquid-api-key)
      LIQUID_API_KEY="$2"
      shift 2
      ;;
    --liquid-server)
      LIQUID_SERVER="$2"
      shift 2
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

if [ -z "${LIQUID_API_KEY:-}" ]; then
  echo "Error: missing Liquid API key."
  usage
fi

docker run \
  -e LIQUID_API_KEY="$LIQUID_API_KEY" \
  -e LIQUID_SERVER="$LIQUID_SERVER" \
  -e NUM_SAMPLES="$NUM_SAMPLES" \
  -e CI="$CI" \
  -v "$(pwd)/benchmark_root:/app/RULER/scripts/benchmark_root" \
  liquidai/ruler:latest
