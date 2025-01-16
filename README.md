# Evaluating Liquid Models on RULER
`ruler.sh` contains the basic logic for evaluating Liquid 3B on RULER.

**Setup:**
1. Start with a new conda environment with `python=3.11`, e.g. via
```
conda create -n ruler python=3.11
conda activate ruler
```
2. Get Liquid API key from [labs](https://labs.liquid.ai/settings).
2. Run `bash ruler.sh --liquid-api-key <LIQUID_API_KEY>` to install necessary packages and run RULER.
