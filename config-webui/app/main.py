import os
import json
import logging
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("config-webui")

app = FastAPI(title="OpenClaw Config UI")

CONFIG_FILE = "/config/openclaw.json"

class TokenRequest(BaseModel):
    token: str

@app.post("/api/save-token")
async def save_token(req: TokenRequest):
    if not os.path.exists(CONFIG_FILE):
        raise HTTPException(status_code=404, detail="openclaw.json not found. Is the volume mounted?")
    
    try:
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
            
        if "channels" not in config:
            config["channels"] = {}
        if "telegram" not in config["channels"]:
            config["channels"]["telegram"] = {}
            
        config["channels"]["telegram"]["token"] = req.token.strip()
        
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
            
        logger.info("Successfully updated Telegram token in openclaw.json")
        return {"status": "success", "message": "Token saved. Please restart the OpenClaw container if it is already running."}
    except Exception as e:
        logger.error(f"Error saving token: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/pairings")
async def scan_pairings():
    # Since we cannot easily read OpenClaw logs from here without docker.sock,
    # we return a mock response guiding the user to the OpenClaw UI.
    return {
        "status": "manual",
        "message": "Please navigate to the OpenClaw dashboard at http://localhost:8080 to approve pairing requests."
    }

# Mount static files at /
app.mount("/", StaticFiles(directory=os.path.join(os.path.dirname(__file__), "static"), html=True), name="static")
