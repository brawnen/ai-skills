#!/usr/bin/env python3
"""从真实 HTTP 入口及只读 SQLite 状态验证独立验收，始终清理并保留证据。"""
import argparse
import hashlib
import json
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import uuid
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def request(url, method="GET", actor=None, data=None):
    headers = {"Content-Type": "application/json"}
    if actor:
        headers["X-Actor"] = actor
    body = json.dumps(data).encode() if data is not None else None
    req = Request(url, data=body, method=method, headers=headers)
    try:
        response = urlopen(req, timeout=2)
    except HTTPError as error:
        response = error
    with response:
        return response.status, json.loads(response.read())


def snapshot(database):
    with sqlite3.connect(database.as_uri() + "?mode=ro", uri=True) as conn:
        return {"items": conn.execute("SELECT id,tenant,name FROM items ORDER BY id").fetchall(),
                "audit": conn.execute("SELECT action,actor,item_id FROM audit ORDER BY rowid").fetchall()}


def doctor(url, app):
    code, body = request(url + "/health")
    expected = hashlib.sha256(app.read_bytes()).hexdigest()
    if code != 200 or body.get("ready") is not True or body.get("artifact_digest") != expected:
        raise AssertionError("doctor: wrong artifact or unready instance")
    return body


def run(app, artifacts):
    app = app.resolve()
    artifacts = artifacts.resolve()
    artifacts.mkdir(parents=True, exist_ok=True)
    if (artifacts / "report.json").exists() or (artifacts / "server.log").exists():
        raise FileExistsError("evidence directory already contains a run; choose a fresh directory")
    report = {"run_id": uuid.uuid4().hex, "subject": {"artifact_digest": hashlib.sha256(app.read_bytes()).hexdigest()},
              "environment": {"target": "local", "config_scope": "isolated-sqlite; fixture actors"},
              "checks": [], "coverage_gaps": ["browser/staging/production not exercised"], "cleanup": {}}
    process = None
    passed = False
    runtime_path = None
    with tempfile.TemporaryDirectory(prefix="verify-api-") as runtime:
        runtime_path = Path(runtime)
        ready = runtime_path / "ready.json"
        database = runtime_path / "data.sqlite"
        log_path = runtime_path / "server.log"
        try:
            with log_path.open("w") as log:
                process = subprocess.Popen([sys.executable, str(app), "--state", runtime, "--ready", str(ready)],
                                           stdout=log, stderr=log)
                deadline = time.monotonic() + 5
                while not ready.exists():
                    if process.poll() is not None:
                        raise RuntimeError("environment: server exited before ready")
                    if time.monotonic() > deadline:
                        raise RuntimeError("environment: readiness timeout")
                    time.sleep(0.02)
                url = json.loads(ready.read_text())["url"]
                doctor(url, app)
                report["instance"] = url

                def check(ac, entry, expected, actual, okay):
                    state = snapshot(database)
                    report["checks"].append({"ac": ac, "entry": entry, "expected": expected,
                                              "actual": actual, "status": "PASS" if okay else "FAIL",
                                              "database": state})
                    if not okay:
                        raise AssertionError(f"{ac}: expected {expected}; got {actual}")

                code, body = request(url + "/items", "POST", "admin-a", {"name": "sample"})
                item_id = body.get("id")
                state = snapshot(database)
                okay = (code == 201 and isinstance(item_id, int)
                        and state["items"] == [(item_id, "a", "sample")]
                        and state["audit"] == [("created", "admin-a", item_id)])
                check("AC-01", "POST /items as admin-a", "201; exactly one A/sample item and created audit", body, okay)
                code, body = request(url + f"/items/{item_id}", actor="admin-a")
                check("AC-01-read", "GET created item as admin-a", "200; same id, tenant and name", body,
                      code == 200 and body == {"id": item_id, "tenant": "a", "name": "sample"})

                code, body = request(url + f"/items/{item_id}", "DELETE", "admin-b")
                state = snapshot(database)
                okay = (code == 403 and body == {"error": "forbidden"}
                        and state["items"] == [(item_id, "a", "sample")]
                        and state["audit"][-1] == ("denied", "admin-b", item_id))
                check("AC-02", "DELETE A item as admin-b", "403; original row unchanged; denied audit",
                      {"status": code, "body": body}, okay)

                code, body = request(url + "/items", "POST", "member-a", {"name": "blocked"})
                check("AC-03", "POST /items as member-a", "403; no extra business row", body,
                      code == 403 and snapshot(database)["items"] == [(item_id, "a", "sample")])

                code, body = request(url + f"/items/{item_id}", "DELETE", "admin-a")
                check("AC-04", "DELETE A item as admin-a", "200; item removed; deleted audit", body,
                      code == 200 and body == {"deleted": True} and snapshot(database)["items"] == []
                      and snapshot(database)["audit"][-1] == ("deleted", "admin-a", item_id))
                passed = True
        except (AssertionError, RuntimeError, OSError, URLError, ValueError) as error:
            report["failure"] = str(error)
            report["failure_class"] = "assertion" if isinstance(error, AssertionError) else "environment"
        finally:
            if process is not None:
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait(timeout=2)
                report["cleanup"]["process_stopped"] = process.poll() is not None
            else:
                report["cleanup"]["process_stopped"] = True
            if log_path.exists():
                shutil.copyfile(log_path, artifacts / "server.log")
    executed = {check["ac"] for check in report["checks"]}
    for ac in ("AC-01", "AC-01-read", "AC-02", "AC-03", "AC-04"):
        if ac not in executed:
            report["checks"].append({"ac": ac, "status": "NOT_RUN", "reason": "stopped after prior failure"})
    report["status"] = "PASS" if passed else "FAIL"
    report["cleanup"]["owned_resources_removed"] = not runtime_path.exists()
    report["cleanup"]["evidence_preserved"] = True
    (artifacts / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("run", "doctor"))
    parser.add_argument("--app", type=Path, default=Path(__file__).with_name("server.py"))
    parser.add_argument("--artifacts", type=Path)
    parser.add_argument("--url")
    args = parser.parse_args()
    if args.mode == "doctor":
        if not args.url:
            parser.error("doctor requires --url")
        print(json.dumps(doctor(args.url, args.app.resolve())))
    else:
        if not args.artifacts:
            parser.error("run requires --artifacts")
        result = run(args.app, args.artifacts)
        print(json.dumps({"status": result["status"], "run_id": result["run_id"], "artifacts": str(args.artifacts.resolve())}))
        sys.exit(0 if result["status"] == "PASS" else 1)
