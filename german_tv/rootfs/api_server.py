#!/usr/bin/env python3
"""
Minimal API-Server für German TV Panel.
Lauscht auf 127.0.0.1:8100 – wird von nginx nach /api/ proxied.

GET  /api/channels  → gibt aktuelle Senderliste zurück (JSON)
POST /api/channels  → speichert neue Senderliste in /data/channels.json
"""
import json, os, sys
from http.server import BaseHTTPRequestHandler, HTTPServer

DATA_FILE    = "/data/channels.json"
OPTIONS_FILE = "/data/options.json"


def load_channels():
    """Lädt aus channels.json (User-Saves), Fallback: options.json."""
    for path in [DATA_FILE, OPTIONS_FILE]:
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            # channels.json speichert direkt eine Liste
            if isinstance(data, list):
                return data
            # options.json ist ein Dict mit "channels"-Key
            if isinstance(data, dict) and "channels" in data:
                return data["channels"]
        except Exception:
            continue
    return []


def save_channels(channels):
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(channels, f, ensure_ascii=False, indent=2)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f"[api] {fmt % args}", file=sys.stdout)

    def _send_json(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", len(body))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        if self.path.startswith("/api/channels"):
            self._send_json(200, load_channels())
        else:
            self._send_json(404, {"error": "not found"})

    def do_POST(self):
        if self.path.startswith("/api/channels"):
            try:
                length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(length)
                channels = json.loads(body)
                if not isinstance(channels, list):
                    raise ValueError("Expected JSON array")
                save_channels(channels)
                print(f"[api] Saved {len(channels)} channel(s) to {DATA_FILE}")
                self._send_json(200, {"ok": True, "count": len(channels)})
            except Exception as e:
                print(f"[api] Save error: {e}", file=sys.stderr)
                self._send_json(400, {"error": str(e)})
        else:
            self._send_json(404, {"error": "not found"})


if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 8100), Handler)
    print(f"[api] Listening on 127.0.0.1:8100")
    server.serve_forever()
