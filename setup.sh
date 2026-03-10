#!/bin/bash

# OpenClaw Docker Setup Script
# Interactive stepped installer for the OpenClaw AI environment.

# Function to print colorful headers
print_header() {
    echo ""
    echo -e "\e[1;36m======================================================================\e[0m"
    echo -e "\e[1;36m $1\e[0m"
    echo -e "\e[1;36m======================================================================\e[0m"
}

# Function to prompt the user
prompt_user() {
    local prompt_msg=$1
    local default_yes=$2

    if [ "$default_yes" = true ]; then
        read -p "$prompt_msg [Y/n] " response
        response=${response:-Y}
    else
        read -p "$prompt_msg [y/N] " response
        response=${response:-N}
    fi

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        return 0 # True
    else
        return 1 # False
    fi
}

echo -e "\e[1;32mWelcome to the OpenClaw Docker Assistant!\e[0m"
echo "This script will guide you through setting up the multi-container application."
echo "Ensure you have Docker and Docker Compose installed."

# -------------------------------------------------------------------------
# Step 1: OpenClaw
# -------------------------------------------------------------------------
print_header "Step 1: OpenClaw AI Agent"
echo "Install OpenClaw Docker image with pre-configured workspace for Telegram"
echo "AI agent with local LLM support?"
if prompt_user "→ Install OpenClaw?" true; then
    docker compose pull openclaw
    # Do not start it yet, wait for other components
else
    echo "Skipping OpenClaw..."
fi

# -------------------------------------------------------------------------
# Step 2: Ollama + Local LLM
# -------------------------------------------------------------------------
print_header "Step 2: Local LLM (Ollama + Qwen 2.5 Coder 7B)"
echo "Install Ollama and pull the Qwen 2.5 Coder 7B model?"
echo "This model runs locally for chat and AI agent tasks."
if prompt_user "→ Install Ollama + Qwen?" true; then
    docker compose up -d ollama
    echo "Waiting for Ollama to boot up..."
    sleep 5
    echo "Pulling Qwen 2.5 Coder 7B model. This may take a few minutes..."
    docker exec -it ollama ollama pull qwen2.5-coder:7b
else
    echo "Skipping Ollama..."
fi

# -------------------------------------------------------------------------
# Step 3: Text-to-Image Container
# -------------------------------------------------------------------------
print_header "Step 3: Text-to-Image Capabilities"
echo "Install Text-to-Image container with SDXS-512 model?"
echo "This enables the /imagine command for image generation."
echo "Note: This is cool, but absolutely not necessary for this project."
echo "Warning: Building this image takes 5-15 mins to bake in the AI model."
if prompt_user "→ Install Text-to-Image?" false; then
    echo -e "\e[1;34mBE PATIENT: IT IS WORKING!\e[0m"
    docker compose build text-to-image
    docker compose up -d text-to-image
else
    echo "Skipping Text-to-Image..."
fi

# -------------------------------------------------------------------------
# Step 4: Web UIs
# -------------------------------------------------------------------------
print_header "Step 4: Web Interfaces"
echo "Build and start Chat WebUI and Config WebUI?"
if prompt_user "→ Build and Start Web UIs?" true; then
    docker compose build chat-webui config-webui
    docker compose up -d chat-webui config-webui
else
    echo "Skipping Web UIs..."
fi

# -------------------------------------------------------------------------
# Final Step: Start OpenClaw
# -------------------------------------------------------------------------
echo ""
echo "Starting OpenClaw service if necessary..."
docker compose up -d openclaw

# -------------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------------
echo ""
echo -e "\e[1;32m┌────────────────────────────────────────────────────────┐\e[0m"
echo -e "\e[1;32m│  ✓ Services deployment sequence completed!             │\e[0m"
echo -e "\e[1;32m│                                                        │\e[0m"
echo -e "\e[1;32m│  Config/Telegram:    http://localhost:9999             │\e[0m"
echo -e "\e[1;32m│  LLM Web Chat:       http://localhost:8888             │\e[0m"
echo -e "\e[1;32m│  Text-to-Image:      http://localhost:9998             │\e[0m"
echo -e "\e[1;32m└────────────────────────────────────────────────────────┘\e[0m"
echo ""
echo "Note: If you run into memory issues, ensure your VM has at least 16GB of RAM."
echo "To set up Telegram, go to http://localhost:9999 and follow the instructions."
