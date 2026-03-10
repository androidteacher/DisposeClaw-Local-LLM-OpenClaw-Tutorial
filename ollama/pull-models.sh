#!/bin/bash
echo "Waiting for Ollama to become ready within the container..."
sleep 5
echo "Pulling qwen2.5-coder:7b..."
ollama pull qwen2.5-coder:7b
echo "Pull complete!"
