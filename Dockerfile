FROM python:3.11-slim AS base

FROM base AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# copy requirements first to leverage docker cache
COPY RULER/custom_requirements.txt RULER/custom_requirements.txt
WORKDIR /app/RULER
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install cython
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install -r custom_requirements.txt

RUN pip cache purge

# copy data scripts and download dataset
COPY RULER/scripts/data /app/RULER/scripts/data
WORKDIR /app/RULER/scripts/data/synthetic/json
RUN python download_paulgraham_essay.py
RUN bash download_qa_dataset.sh

# copy the rest of the app
WORKDIR /app
COPY . .

FROM base AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app .
COPY --from=builder /usr/local /usr/local

RUN python -c "import nltk; nltk.download('punkt'); nltk.download('punkt_tab')"

VOLUME /app/RULER/scripts/benchmark_root

WORKDIR /app/RULER

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
