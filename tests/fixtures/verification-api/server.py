#!/usr/bin/env python3
"""仅用于流程验证的隔离 HTTP/SQLite 样例，不是生产认证实现。"""
import argparse
import hashlib
import json
import sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ACTORS = {"admin-a": ("a", True), "member-a": ("a", False), "admin-b": ("b", True)}


def serve(state, ready):
    state.mkdir(parents=True, exist_ok=True)
    database = state / "data.sqlite"
    with sqlite3.connect(database) as conn:
        conn.executescript("CREATE TABLE items (id INTEGER PRIMARY KEY, tenant TEXT, name TEXT);"
                           "CREATE TABLE audit (action TEXT, actor TEXT, item_id INTEGER);")
    digest = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()

    class Handler(BaseHTTPRequestHandler):
        def reply(self, code, body):
            data = json.dumps(body).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def actor(self):
            identity = self.headers.get("X-Actor", "")
            return identity, ACTORS.get(identity)

        def do_GET(self):
            if self.path == "/health":
                return self.reply(200, {"ready": True, "artifact_digest": digest})
            identity, actor = self.actor()
            if actor is None:
                return self.reply(401, {"error": "unknown-actor"})
            try:
                item_id = int(self.path.removeprefix("/items/"))
            except ValueError:
                return self.reply(404, {"error": "not-found"})
            with sqlite3.connect(database) as conn:
                row = conn.execute("SELECT id, tenant, name FROM items WHERE id=?", (item_id,)).fetchone()
            if row is None:
                return self.reply(404, {"error": "not-found"})
            if row[1] != actor[0]:
                return self.reply(403, {"error": "forbidden"})
            self.reply(200, dict(zip(("id", "tenant", "name"), row)))

        def do_POST(self):
            identity, actor = self.actor()
            if self.path != "/items":
                return self.reply(404, {"error": "not-found"})
            if actor is None:
                return self.reply(401, {"error": "unknown-actor"})
            if not actor[1]:
                return self.reply(403, {"error": "forbidden"})
            try:
                data = json.loads(self.rfile.read(int(self.headers.get("Content-Length", "0"))))
                name = data["name"]
                if not isinstance(name, str) or not name:
                    raise ValueError("invalid-name")
            except (ValueError, KeyError, TypeError):
                return self.reply(400, {"error": "invalid-name"})
            with sqlite3.connect(database) as conn:
                cursor = conn.execute("INSERT INTO items(tenant,name) VALUES (?,?)", (actor[0], name))
                item_id = cursor.lastrowid
                conn.execute("INSERT INTO audit VALUES ('created',?,?)", (identity, item_id))
            self.reply(201, {"id": item_id})

        def do_DELETE(self):
            identity, actor = self.actor()
            if actor is None:
                return self.reply(401, {"error": "unknown-actor"})
            try:
                item_id = int(self.path.removeprefix("/items/"))
            except ValueError:
                return self.reply(404, {"error": "not-found"})
            with sqlite3.connect(database) as conn:
                row = conn.execute("SELECT tenant FROM items WHERE id=?", (item_id,)).fetchone()
                if row is None:
                    return self.reply(404, {"error": "not-found"})
                if not actor[1] or row[0] != actor[0]:
                    conn.execute("INSERT INTO audit VALUES ('denied',?,?)", (identity, item_id))
                    code, result = 403, {"error": "forbidden"}
                else:
                    conn.execute("DELETE FROM items WHERE id=?", (item_id,))
                    conn.execute("INSERT INTO audit VALUES ('deleted',?,?)", (identity, item_id))
                    code, result = 200, {"deleted": True}
            self.reply(code, result)

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    ready.write_text(json.dumps({"url": f"http://127.0.0.1:{server.server_port}"}))
    try:
        server.serve_forever()
    finally:
        server.server_close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--state", type=Path, required=True)
    parser.add_argument("--ready", type=Path, required=True)
    options = parser.parse_args()
    serve(options.state, options.ready)
