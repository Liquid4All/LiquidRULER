FROM continuumio/miniconda3:latest AS base

# Create conda environment
RUN conda create -n ruler python=3.11 -y && \
    conda run -n ruler pip install pyyaml

SHELL ["conda", "run", "-n", "ruler", "/bin/bash", "-c"]

# Build stage for installing dependencies and downloading datasets
FROM base AS builder
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# Install Python dependencies in steps for better caching
RUN --mount=type=cache,target=/root/.cache/pip \
    cd RULER && \
    pip install --no-cache-dir cython && \
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r custom_requirements.txt && \
    pip install --no-cache-dir "fasttext @ git+https://github.com/facebookresearch/fastText.git"

# Clean up pip cache to reduce image size
RUN pip cache purge

# Final stage with minimal runtime dependencies
FROM base
WORKDIR /app
COPY --from=builder /app .
COPY --from=builder /opt/conda/envs/ruler /opt/conda/envs/ruler

# Set default environment variables
ENV LIQUID_SERVER="https://inference-1.liquid.ai"
ENV NUM_SAMPLES=100

# Create volume for benchmark results
VOLUME /app/RULER/scripts/benchmark_root

# Set working directory
WORKDIR /app/RULER

# Copy and set entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
