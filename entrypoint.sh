#!/bin/bash

YAML_FILE="benchmark_models_4b.yml"

ollama serve > /dev/null 2>&1 &
llm_benchmark run --custombenchmark=/app/data/${YAML_FILE}