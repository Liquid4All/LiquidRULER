#!/bin/bash

set -euo pipefail

cd scripts/
./run.sh "$MODEL_NAME" synthetic
./generate_summary.sh "$MODEL_NAME"
