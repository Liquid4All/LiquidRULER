#!/bin/bash

set -euo pipefail

cd scripts/
./run.sh "$MODEL_NAME" synthetic
./summarize.sh "$MODEL_NAME"
