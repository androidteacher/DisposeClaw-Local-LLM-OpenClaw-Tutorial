#!/bin/bash
clear
echo "============================================="
echo "   OpenClaw Telegram API Key Injection Tool  "
echo "============================================="
echo ""
echo "Please paste your Telegram Bot API Key below:"
echo -n "> "
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo "Error: Token cannot be empty. Setup aborted."
    exit 1
fi

echo ""

# Ensure the openclaw container is running
if ! sudo docker ps --format '{{.Names}}' | grep -q '^openclaw$'; then
    echo "OpenClaw container is not running. Starting it..."
    sudo docker compose up -d openclaw
fi

# Wait for OpenClaw to fully initialize its config
echo "Waiting for OpenClaw to initialize..."
for i in $(seq 1 30); do
    if sudo docker exec openclaw test -f /home/node/.openclaw/openclaw.json 2>/dev/null; then
        break
    fi
    sleep 1
done

# Restart the container to ensure config is fully generated from the skeleton
echo "Ensuring OpenClaw config is fully initialized..."
sudo docker restart openclaw
sleep 5

echo "Injecting token into the OpenClaw container..."

# Use the native OpenClaw CLI to register the Telegram channel (no -t flag for script compatibility)
sudo docker exec openclaw openclaw channels add --channel telegram --token "$TOKEN"

if [ $? -eq 0 ]; then
    echo ""
    echo "Token successfully injected into OpenClaw!"
    echo ""
    echo "Restarting OpenClaw to apply changes..."
    sudo docker restart openclaw
    sleep 3
    echo ""
    echo "Next steps:"
    echo "1. Open Telegram, find your bot, and send it a message (like 'hello')."
    echo ""
    echo "2. List the pending pairing request:"
    echo "   sudo docker exec openclaw openclaw pairing list telegram"
    echo ""
    echo "3. Approve the pairing request with your unique code:"
    echo "   sudo docker exec openclaw openclaw pairing approve telegram <CODE>"
    echo "============================================="
else
    echo ""
    echo "Failed to inject token."
    echo "Ensure the openclaw container is running: sudo docker compose up -d openclaw"
fi
