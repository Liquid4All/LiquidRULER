# This script works when starting in a fresh conda environment with python=3.11
# conda create -n ruler python=3.11
# conda activate ruler
cd RULER/
bash install_script.sh

export OPENAI_API_KEY="<YOUR LIQUID API KEY HERE>"
bash run_ruler.sh
