ARG TARGETARCH=arm64
FROM --platform=linux/$TARGETARCH ollama/ollama:latest AS base

# Install language
RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

# Configure timezone and locale
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      python3 \
      python3-pip \
      python3-dev \
      python3-venv \
      gcc \
      git \
    && rm -rf /var/lib/apt/lists/*

# TODO: Build and install the ollama-benchmark repo
RUN git clone https://github.com/nightduck/ollama-benchmark.git
RUN cd ollama-benchmark
RUN python3 -m venv /opt/venv
RUN . /opt/venv/bin/activate && pip install -r requirements.txt
RUN python3 setup.py install

# TODO: Have entry point run the benchmark script with appropriate arguments
CMD . /opt/venv/bin/activate && llm_benchmark run