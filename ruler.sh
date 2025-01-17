#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 --liquid-api-key <LIQUID_API_KEY> [--liquid-server <LIQUID_SERVER>]"
  exit 1
}

# TODO: change to inference-1
LIQUID_SERVER="inference-dev.liquid.ai"

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
    *)
      echo "Error: Unknown parameter $1"
      usage
      ;;
  esac
done

if [ -z "$LIQUID_API_KEY" ]; then
  echo "Error: missing Liquid API key."
  usage
fi

# This script works when starting in a fresh conda environment with python=3.11
# conda create -n ruler python=3.11
# conda activate ruler
cd RULER
bash install_script.sh

export OPENAI_API_KEY="$LIQUID_API_KEY"
export LIQUID_SERVER="$LIQUID_SERVER"
bash run_ruler.sh
