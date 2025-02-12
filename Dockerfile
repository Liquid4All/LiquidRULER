FROM python:3.11-slim AS base

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
WORKDIR /app/RULER

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install cython torch torchvision torchaudio

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install -r custom_requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install torchaudio --upgrade

# Clean up pip cache to reduce image size
RUN pip cache purge

# Final stage with minimal runtime dependencies
FROM base AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app .
COPY --from=builder /usr/local /usr/local

RUN python -c "import nltk; nltk.download('punkt')"

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
