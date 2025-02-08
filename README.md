# Evaluating Liquid Models on RULER

## Setup

1. Start with a new conda environment with `python=3.11`:

```bash
conda create -n ruler python=3.11
conda activate ruler
```

2. Get Liquid API key from [labs](https://labs.liquid.ai/settings).

3. Run `./ruler.sh --liquid-api-key <LIQUID_API_KEY>` to install necessary packages and run RULER.

All `ruler.sh` parameters:

| Parameter | Required | Description | Default |
| --- | --- | --- | --- |
| `--liquid-api-key <API-KEY>` | Yes | Inference server API key. | |
| `--liquid-server <SERVER-URL>` | No | Inference server URL base. | `https://inference-1.liquid.ai` |
| `--skip-install` | No | Skip dependency installation. Useful for re-running the script. | |
| `--num-samples <N>` | No | Number of samples to run. | 100 |

## Docker Usage

Run benchmarks using Docker:

```bash
# Create results directory if it doesn't exist
mkdir -p ./benchmark_root

# Run benchmarks
docker run -e LIQUID_API_KEY=<your-api-key> \
           -e LIQUID_SERVER=<server-url> \
           -e NUM_SAMPLES=<num-samples> \
           -v $(pwd)/benchmark_root:/app/RULER/benchmark_root \
           liquid4all/ruler:latest
```

Environment variables:
- `LIQUID_API_KEY` (required): Your Liquid API key
- `LIQUID_SERVER` (optional): Inference server URL (default: https://inference-1.liquid.ai)
- `NUM_SAMPLES` (optional): Number of samples to run (default: 100)

The benchmark results will be stored in the `./benchmark_root` directory relative to where you run the Docker command.

## Troubleshooting

### Installation error with `GLIBCXX_3.4.20' not found`

Run the following command to create a symbolic link to the system's `libstdc++.so.6` in the conda environment:

```bash
ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 ${CONDA_PREFIX}/lib/libstdc++.so.6
```

## Acknowledgement

This repository is modified from [NVIDIA/RULER](https://github.com/NVIDIA/RULER).
