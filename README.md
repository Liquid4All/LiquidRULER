# Evaluating Liquid Models on RULER

## Run with Docker

```bash
./run-docker.sh \
  --model-url <MODEL_URL> \
  --model-name <MODEL_NAME> \
  --model-api-key <MODEL_API_KEY>
```

The benchmark results will be stored in the `./benchmark_root` directory relative to where you run the Docker command.

**Examples**

```bash
# run against liquid labs
./run-docker.sh \
  --model-url https://inference-1.liquid.ai \
  --model-name lfm-40b \
  --model-api-key <MODEL_API_KEY>

# run on-prem
./run-docker.sh \
  --model-url http://localhost:8000 \
  --model-name lfm-40b \
  --model-api-key <MODEL_API_KEY>
```

> [!IMPORTANT]
> The script uses Python `requests` to call the `/tokenize` endpoint. It is important to include `http://` or `https://` in the model URL argument, especially when the URL is `localhost`. Otherwise, `requests` will throw the `no connection adapters were found` error.

## Run locally without Docker

1. Start with a new conda environment with `python=3.11`:

```bash
conda create -n ruler python=3.11
conda activate ruler
```

2. Get the model provider URL and API key.

To run against Liquid `labs`, get API key [here](https://labs.liquid.ai/settings).

3. Run `./run-local.sh --model-url <MODEL_URL> --model-name <MODEL_NAME> --model-api-key <LIQUID_API_KEY>` to install necessary packages and run RULER.

**Examples**

```bash
# run against liquid labs
./run-local.sh \
  --model-url https://inference-1.liquid.ai \
  --model-name lfm-40b \
  --model-api-key <MODEL_API_KEY>

# run on-prem
./run-local.sh \
  --model-url http://localhost:8000 \
  --model-name lfm-40b \
  --model-api-key <MODEL_API_KEY>
```

The benchmark results will be stored in the `./benchmark_root` directory under the project root.

## Script parameters

These parameters are available for both the `run-docker.sh` and `run-local.sh` scripts.

| Parameter | Required | Description | Default |
| --- | --- | --- | --- |
| `--model-url <SERVER_URL>` | Yes | Inference server URL base. | |
| `--model-name <MODEL_NAME>` | Yes | Model ID. | |
| `--model-api-key <API_KEY>` | Yes | Inference server API key. | |
| `--skip-install` | No | Skip dependency installation. Useful for re-running the script. | |
| `--num-samples <N>` | No | Number of samples to run. | 100 |
| `--ci` | No | Run in CI mode with as few tests as possible. | |

## Troubleshooting

### Installation error with `GLIBCXX_3.4.20' not found`

Run the following command to create a symbolic link to the system's `libstdc++.so.6` in the conda environment:

```bash
ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 ${CONDA_PREFIX}/lib/libstdc++.so.6
```

## Acknowledgement

This repository is modified from [NVIDIA/RULER](https://github.com/NVIDIA/RULER).
