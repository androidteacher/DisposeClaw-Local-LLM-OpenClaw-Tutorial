---
name: imagine
description: "Generate images from text prompts. Use when: user asks to generate, create, or draw an image, or uses /imagine. Sends the result as a photo."
metadata: { "openclaw": { "emoji": "🎨", "requires": { "bins": ["curl"] } } }
---

# Image Generation

Generate an image and send it as a Telegram photo.

## Steps

1. **Generate the image** — run this with `exec`, replacing `[PROMPT]` with the user's description:

```bash
curl -s -X POST http://text-to-image:9998/generate-file \
  -H "Content-Type: application/json" \
  -d '{"prompt": "[PROMPT]"}' \
  -o /tmp/generated.png && echo "OK"
```

If the output does NOT contain `OK`, tell the user generation failed and stop.

2. **Send the image** — extract the sender's ID from the conversation metadata and run with `exec`:

```bash
openclaw message send --channel telegram --target [SENDER_ID] --media /tmp/generated.png --message "Here's your image for: [PROMPT]"
```

Replace `[SENDER_ID]` with the numeric sender ID from the conversation info at the top of this chat (e.g. `8416351842`).

3. **Confirm** — reply with a short text message confirming the image was sent. Do NOT attempt to read, display, or include the image contents in your text response.
