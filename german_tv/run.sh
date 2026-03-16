#!/usr/bin/with-contenv bashio
# ==============================================================================
# German TV Panel – Startup
# 1. Liest /data/channels.json (User-Saves) oder /data/options.json (HA-Konfig)
# 2. Bettet Sender inline in index.html ein (kein Cache-Problem)
# 3. Startet API-Server (Persistenz) + nginx
# ==============================================================================

bashio::log.info "Starting German TV Panel v1.0.3..."

python3 << 'PYEOF'
import json, sys, os, hashlib

OPTIONS_FILE  = "/data/options.json"
CHANNELS_FILE = "/data/channels.json"
TEMPLATE_FILE = "/usr/share/nginx/html/index.template.html"
OUTPUT_FILE   = "/usr/share/nginx/html/index.html"

def load_channels():
    # Bevorzuge channels.json (User-Änderungen im Frontend)
    for path, key in [(CHANNELS_FILE, None), (OPTIONS_FILE, "channels")]:
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            ch = data if key is None else data.get(key, [])
            if isinstance(ch, list) and ch:
                print(f"[german_tv] {len(ch)} Sender geladen aus {path}")
                return ch
        except Exception:
            continue
    print("[german_tv] WARNUNG: Keine Sender gefunden!", file=sys.stderr)
    return []

channels = load_channels()

try:
    with open(TEMPLATE_FILE, "r", encoding="utf-8") as f:
        template = f.read()
except Exception as e:
    print(f"[german_tv] ERROR: Template nicht lesbar: {e}", file=sys.stderr)
    sys.exit(1)

html = template.replace("__TV_CHANNELS_JSON__", json.dumps(channels, ensure_ascii=False))

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html)

print(f"[german_tv] index.html generiert ({len(channels)} Sender eingebettet).")
PYEOF

# API-Server im Hintergrund starten
bashio::log.info "Starting API server..."
python3 /api_server.py &

bashio::log.info "Starting nginx..."
exec nginx -g "daemon off;"
