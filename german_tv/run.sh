#!/usr/bin/with-contenv bashio
# ==============================================================================
# German TV Panel – Add-on startup script
# Liest /data/options.json, bettet Senderliste direkt in index.html ein
# (kein separates channels.js → keine Cache-Probleme)
# ==============================================================================

bashio::log.info "Starting German TV Panel..."

python3 - << 'PYEOF'
import json, sys, os

OPTIONS_FILE  = "/data/options.json"
TEMPLATE_FILE = "/usr/share/nginx/html/index.template.html"
OUTPUT_FILE   = "/usr/share/nginx/html/index.html"

# ── Optionen lesen ─────────────────────────────────────────────────────────────
try:
    with open(OPTIONS_FILE, "r", encoding="utf-8") as f:
        options = json.load(f)
except Exception as e:
    print(f"[german_tv] ERROR: Kann {OPTIONS_FILE} nicht lesen: {e}", file=sys.stderr)
    options = {}

channels = options.get("channels", [])

if not channels:
    print("[german_tv] WARNUNG: Keine Sender in options.json gefunden!", file=sys.stderr)
else:
    print(f"[german_tv] {len(channels)} Sender geladen.")

# ── Template lesen ─────────────────────────────────────────────────────────────
try:
    with open(TEMPLATE_FILE, "r", encoding="utf-8") as f:
        template = f.read()
except Exception as e:
    print(f"[german_tv] ERROR: Kann {TEMPLATE_FILE} nicht lesen: {e}", file=sys.stderr)
    sys.exit(1)

# ── Senderdaten inline einbetten ───────────────────────────────────────────────
channels_json = json.dumps(channels, ensure_ascii=False)
html = template.replace("__TV_CHANNELS_JSON__", channels_json)

# ── index.html schreiben ───────────────────────────────────────────────────────
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html)

print(f"[german_tv] index.html erfolgreich generiert ({len(channels)} Sender eingebettet).")
PYEOF

bashio::log.info "Starting nginx..."
exec nginx -g "daemon off;"
