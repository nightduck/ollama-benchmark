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


# Build and install the ollama-benchmark repo
RUN git clone https://github.com/nightduck/ollama-benchmark.git /app
WORKDIR /app
RUN python3 -m venv /app/venv
RUN . /app/venv/bin/activate && pip install -r requirements.txt
RUN . /app/venv/bin/activate && python3 setup.py install

# Add venv to PATH so commands can be found
ENV PATH="/app/venv/bin:$PATH"

# Use shell form for ENTRYPOINT to allow variable expansion and sourcing
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ollama serve > /dev/null 2>&1 & && llm_benchmark run"]