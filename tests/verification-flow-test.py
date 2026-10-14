#!/usr/bin/env python3
"""通过真实样例观察验证协议，覆盖目标缺陷、版本错配与失败清理。"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/verification-api"


class VerificationFlowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="flow-behavior-")
        self.root = Path(self.temp.name)
        self.project = self.root / "project"
        shutil.copytree(FIXTURE, self.project, ignore=shutil.ignore_patterns("__pycache__"))
        target = self.project / ".agents/skills/verify-sample-api"
        target.parent.mkdir(parents=True)
        shutil.move(str(self.project / "verify-sample-api"), target)

    def tearDown(self):
        self.temp.cleanup()

    def run_cli(self, artifacts, app=None):
        cmd = [sys.executable, str(self.project / "verify.py"), "run", "--artifacts", str(artifacts)]
        if app is not None:
            cmd += ["--app", str(app)]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15,
                                env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}, cwd=self.project)
        report = json.loads((artifacts / "report.json").read_text())
        self.assertTrue(report["cleanup"]["owned_resources_removed"])
        self.assertTrue(report["cleanup"]["process_stopped"])
        self.assertTrue((artifacts / "server.log").is_file())
        return result, report

    def test_real_normal_and_rejection_paths(self):
        result, report = self.run_cli(self.root / "evidence")
        self.assertEqual(result.returncode, 0, report)
        self.assertEqual(report["status"], "PASS")
        self.assertEqual([c["ac"] for c in report["checks"]], ["AC-01", "AC-01-read", "AC-02", "AC-03", "AC-04"])
        self.assertTrue(all(c["status"] == "PASS" for c in report["checks"]))
        self.assertEqual(report["checks"][2]["actual"]["status"], 403)
        self.assertEqual(report["checks"][2]["database"]["items"][0][1:], ["a", "sample"])
        self.assertEqual(report["checks"][-1]["database"]["items"], [])
        self.assertIn('"DELETE /items/', (self.root / "evidence/server.log").read_text())

    def test_isolated_mutation_detects_target_defect_and_preserves_source(self):
        original = self.project / "server.py"
        before = original.read_bytes()
        source = before.decode()
        guard = "if not actor[1] or row[0] != actor[0]:"
        self.assertEqual(source.count(guard), 1)
        mutated = self.root / "isolated-server.py"
        mutated.write_text(source.replace(guard, "if not actor[1]:"))
        result, report = self.run_cli(self.root / "mutation-evidence", mutated)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(report["failure_class"], "assertion")
        self.assertIn("AC-02", report["failure"])
        failed = next(c for c in report["checks"] if c["ac"] == "AC-02")
        self.assertEqual(failed["status"], "FAIL")
        self.assertEqual(failed["actual"]["status"], 200)
        self.assertEqual(failed["database"]["items"], [])
        self.assertEqual([c["ac"] for c in report["checks"] if c["status"] == "NOT_RUN"], ["AC-03", "AC-04"])
        self.assertEqual(original.read_bytes(), before)
        correct, good = self.run_cli(self.root / "correct-evidence")
        self.assertEqual(correct.returncode, 0, good)

    def test_environment_failure_is_not_successful_negative_proof(self):
        broken = self.root / "cannot-start.py"
        broken.write_text("raise RuntimeError('fixture startup failure')\n")
        result, report = self.run_cli(self.root / "environment-evidence", broken)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(report["failure_class"], "environment")
        self.assertTrue(all(c["status"] == "NOT_RUN" for c in report["checks"]))
        self.assertIn("fixture startup failure", (self.root / "environment-evidence/server.log").read_text())

    def test_existing_evidence_is_not_overwritten(self):
        directory = self.root / "protected-evidence"
        result, report = self.run_cli(directory)
        self.assertEqual(result.returncode, 0, report)
        before = (directory / "report.json").read_bytes()
        log_before = (directory / "server.log").read_bytes()
        repeated = subprocess.run([sys.executable, str(self.project / "verify.py"), "run", "--artifacts", str(directory)],
                                  capture_output=True, text=True, timeout=5)
        self.assertNotEqual(repeated.returncode, 0)
        self.assertIn("choose a fresh directory", repeated.stderr)
        self.assertEqual((directory / "report.json").read_bytes(), before)
        self.assertEqual((directory / "server.log").read_bytes(), log_before)

    def test_parallel_runs_are_isolated(self):
        with ThreadPoolExecutor(max_workers=2) as pool:
            outcomes = list(pool.map(self.run_cli, [self.root / "parallel-a", self.root / "parallel-b"]))
        for result, report in outcomes:
            self.assertEqual(result.returncode, 0, report)
        self.assertNotEqual(outcomes[0][1]["run_id"], outcomes[1][1]["run_id"])
        self.assertNotEqual(outcomes[0][1]["instance"], outcomes[1][1]["instance"])

    def test_doctor_rejects_wrong_artifact(self):
        state = self.root / "manual-state"
        state.mkdir()
        ready = state / "ready.json"
        with (self.root / "manual.log").open("w") as log:
            process = subprocess.Popen([sys.executable, str(self.project / "server.py"),
                                        "--state", str(state), "--ready", str(ready)], stdout=log, stderr=log)
            try:
                deadline = time.monotonic() + 5
                while not ready.exists():
                    self.assertIsNone(process.poll(), "server failed to start")
                    self.assertLess(time.monotonic(), deadline, "readiness timeout")
                    time.sleep(0.02)
                url = json.loads(ready.read_text())["url"]
                cmd = [sys.executable, str(self.project / "verify.py"), "doctor", "--url", url]
                good = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                self.assertEqual(good.returncode, 0, good.stderr)
                other = self.root / "other-artifact.py"
                other.write_text("# a different artifact\n")
                bad = subprocess.run(cmd + ["--app", str(other)], capture_output=True, text=True, timeout=5)
                self.assertNotEqual(bad.returncode, 0)
                self.assertIn("wrong artifact", bad.stderr)
            finally:
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait(timeout=2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
