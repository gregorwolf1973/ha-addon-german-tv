#!/usr/bin/with-contenv bashio
# ==============================================================================
# German TV Panel – Startup
# Priorität: /data/channels.json (User-Saves) > /data/options.json (HA-Konfig)
# ==============================================================================

bashio::log.info "Starting German TV Panel v1.0.5..."

python3 << 'PYEOF'
import json, sys, os

OPTIONS_FILE  = "/data/options.json"
CHANNELS_FILE = "/data/channels.json"
TEMPLATE_FILE = "/usr/share/nginx/html/index.template.html"
OUTPUT_FILE   = "/usr/share/nginx/html/index.html"

def load_channels():
    # 1. User-Saves aus dem Frontend
    try:
        with open(CHANNELS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
        ch = data if isinstance(data, list) else []
        if ch:
            print(f"[german_tv] {len(ch)} Sender aus channels.json (User-Saves)")
            return ch
    except Exception:
        pass

    # 2. Fallback: HA Add-on Konfiguration
    try:
        with open(OPTIONS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
        ch = data.get("channels", []) if isinstance(data, dict) else []
        if ch:
            print(f"[german_tv] {len(ch)} Sender aus options.json (HA-Konfig)")
            return ch
    except Exception as e:
        print(f"[german_tv] FEHLER beim Lesen der Konfiguration: {e}", file=sys.stderr)

    print("[german_tv] WARNUNG: Keine Sender gefunden!", file=sys.stderr)
    return []

channels = load_channels()

try:
    with open(TEMPLATE_FILE, "r", encoding="utf-8") as f:
        template = f.read()
except Exception as e:
    print(f"[german_tv] FEHLER: Template nicht lesbar: {e}", file=sys.stderr)
    sys.exit(1)

html = template.replace("__TV_CHANNELS_JSON__", json.dumps(channels, ensure_ascii=False))

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html)

print(f"[german_tv] index.html generiert ({len(channels)} Sender).")
PYEOF

bashio::log.info "Starting API server..."
python3 /api_server.py &

bashio::log.info "Starting nginx..."
exec nginx -g "daemon off;"
