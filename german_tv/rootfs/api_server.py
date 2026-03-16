#!/usr/bin/env python3
"""
Mini API-Server für German TV Panel.
Lauscht auf 127.0.0.1:8100
nginx proxied: location ~ ^/?api/  →  dieser Server

GET  /api/channels  → aktuelle Senderliste (JSON)
POST /api/channels  → Senderliste in /data/channels.json speichern
"""
import json, os, sys
from http.server import BaseHTTPRequestHandler, HTTPServer

DATA_FILE    = "/data/channels.json"
OPTIONS_FILE = "/data/options.json"


def load_channels():
    for path in [DATA_FILE, OPTIONS_FILE]:
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            ch = data if isinstance(data, list) else data.get("channels", [])
            if ch:
                return ch
        except Exception:
            continue
    return []


def save_channels(channels):
    os.makedirs("/data", exist_ok=True)
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(channels, f, ensure_ascii=False, indent=2)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f"[api] {fmt % args}", flush=True)

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _send_json(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", len(body))
        self._cors()
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors()
        self.end_headers()

    def _is_channels(self):
        # Akzeptiert: /api/channels  UND  api/channels
        return "channels" in self.path

    def do_GET(self):
        if self._is_channels():
            self._send_json(200, load_channels())
        else:
            self._send_json(404, {"error": "not found"})

    def do_POST(self):
        if self._is_channels():
            try:
                length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(length)
                channels = json.loads(body)
                if not isinstance(channels, list):
                    raise ValueError("JSON-Array erwartet")
                save_channels(channels)
                print(f"[api] ✓ {len(channels)} Sender gespeichert → {DATA_FILE}", flush=True)
                self._send_json(200, {"ok": True, "count": len(channels)})
            except Exception as e:
                print(f"[api] FEHLER: {e}", file=sys.stderr, flush=True)
                self._send_json(400, {"error": str(e)})
        else:
            self._send_json(404, {"error": "not found"})


if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 8100), Handler)
    print("[api] Listening on 127.0.0.1:8100", flush=True)
    server.serve_forever()
