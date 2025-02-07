FROM continuumio/miniconda3:latest AS base

# Create conda environment
RUN conda create -n ruler python=3.11 -y
SHELL ["conda", "run", "-n", "ruler", "/bin/bash", "-c"]

# Build stage for installing dependencies and downloading datasets
FROM base AS builder
WORKDIR /app
COPY . .
RUN cd RULER && \
    pip install cython torch torchvision torchaudio && \
    pip install -r custom_requirements.txt && \
    pip install torchaudio --upgrade && \
    cd scripts/data/synthetic/json/ && \
    python download_paulgraham_essay.py && \
    bash download_qa_dataset.sh

# Final stage with minimal runtime dependencies
FROM base
WORKDIR /app
COPY --from=builder /app .
COPY --from=builder /opt/conda/envs/ruler /opt/conda/envs/ruler

# Set default environment variables
ENV LIQUID_SERVER="https://inference-1.liquid.ai"
ENV NUM_SAMPLES=100

# Create volume for benchmark results
VOLUME /app/RULER/benchmark_root

# Set working directory
WORKDIR /app/RULER

# Copy and set entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
