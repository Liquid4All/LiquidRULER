#!/bin/bash

set -euo pipefail

# install requirements
python -m pip install packaging
python -m pip install -r custom_requirements.txt

# download data
cd scripts/data/synthetic/json/
python download_paulgraham_essay.py
bash download_qa_dataset.sh
