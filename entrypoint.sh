#!/bin/bash

YAML_FILE="benchmark_models_16b.yml"

# Start ollama serve in the background
ollama serve > /dev/null 2>&1 &
OLLAMA_PID=$!

# Wait for Ollama to be ready (max 60 seconds)
echo "Waiting for Ollama to start..."
MAX_WAIT=60
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if curl -s http://127.0.0.1:11434/ > /dev/null 2>&1; then
        echo "Ollama is ready!"
        break
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

# Check if Ollama started successfully
if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo "ERROR: Ollama failed to start within ${MAX_WAIT} seconds"
    kill $OLLAMA_PID 2>/dev/null
    exit 1
fi

# Run the benchmark with explicit output and unbuffered Python
echo "Starting benchmark..."
export PYTHONUNBUFFERED=1
exec llm_benchmark run --custombenchmark=/app/llm_benchmark/data/${YAML_FILE}