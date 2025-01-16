#!/bin/bash

usage() {
  echo "Usage: $0 --liquid-api-key <LIQUID_API_KEY>"
  exit 1
}

if [ "$1" != "--liquid-api-key" ] || [ -z "$2" ]; then
  echo "Error: missing Liquid API key."
  usage
fi

LIQUID_API_KEY=$2

if [ -z "$LIQUID_API_KEY" ]; then
  echo "Error: Liquid API key cannot be empty."
  show_usage
fi

# This script works when starting in a fresh conda environment with python=3.11
# conda create -n ruler python=3.11
# conda activate ruler
cd RULER
bash install_script.sh

export OPENAI_API_KEY="$LIQUID_API_KEY"
bash run_ruler.sh
