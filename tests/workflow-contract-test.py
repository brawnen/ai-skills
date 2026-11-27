#!/usr/bin/env python3
"""任务图、真实临时 Git worktree 集成与发布资源回归；不调用模型。"""
import argparse
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("task_graph", ROOT / "scripts/check-task-graph.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
ARTIFACTS = None


def evidence(name, value):
    if ARTIFACTS:
        (ARTIFACTS / name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def graph():
    return {"schema_version": 1, "spec": "checkout-spec", "tasks": [
        {"id": "A", "source": "price-ticket", "blocked_by": [], "status": "pending"},
        {"id": "B", "source": "shipping-ticket", "blocked_by": [], "status": "pending"},
        {"id": "C", "source": "checkout-ticket", "blocked_by": ["A", "B"], "status": "pending"}]}


class TaskGraphTests(unittest.TestCase):
    def test_frontier_updates_only_after_actual_blockers_done(self):
        data = graph()
        self.assertEqual(module.frontier(data)["ready"], ["A", "B"])
        data["tasks"][0]["status"] = "done"
        self.assertEqual(module.frontier(data)["ready"], ["B"])
        data["tasks"][1]["status"] = "done"
        self.assertEqual(module.frontier(data)["ready"], ["C"])
        data["tasks"][2]["status"] = "running"
        self.assertEqual(module.frontier(data)["ready"], [])

    def test_rejects_invalid_edges_cycles_and_premature_completion(self):
        examples = []
        data = graph(); data["tasks"][1]["id"] = "A"; examples.append(data)
        data = graph(); data["tasks"][0]["blocked_by"] = ["missing"]; examples.append(data)
        data = graph(); data["tasks"][0]["blocked_by"] = ["A"]; examples.append(data)
        data = graph(); data["tasks"][0]["blocked_by"] = ["C"]; examples.append(data)
        data = graph(); data["tasks"][2]["status"] = "done"; examples.append(data)
        data = graph(); data["tasks"][0]["status"] = "typo"; examples.append(data)
        data = graph(); data["tasks"][0]["source"] = ""; examples.append(data)
        for document in examples:
            with self.subTest(document=document), self.assertRaises(ValueError):
                module.frontier(document)

    def test_cli_reports_frontier_and_fails_invalid_graph(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "graph.json"
            path.write_text(json.dumps(graph()))
            cmd = [sys.executable, str(ROOT / "scripts/check-task-graph.py"), str(path)]
            valid = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            self.assertEqual(valid.returncode, 0, valid.stderr)
            self.assertEqual(json.loads(valid.stdout)["ready"], ["A", "B"])
            path.write_text('{"schema_version":1,"spec":"x","tasks":[]}')
            invalid = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            self.assertNotEqual(invalid.returncode, 0)
            self.assertIn("tasks must be", invalid.stderr)


class DistributionTests(unittest.TestCase):
    def test_reference_snapshot_preserves_all_original_files(self):
        record = json.loads((ROOT / "vendor/mattpocock.snapshot.json").read_text())
        snapshot = ROOT / "vendor/mattpocock"
        actual = {str(p.relative_to(snapshot)) for p in snapshot.rglob("*") if p.is_file() and not p.is_symlink()}
        self.assertEqual(actual, set(record["files"]))
        for relative, expected in record["files"].items():
            self.assertEqual(hashlib.sha256((snapshot / relative).read_bytes()).hexdigest(), expected, relative)
        for relative, target in record["symlinks"].items():
            self.assertEqual(str((snapshot / relative).readlink()), target)
        self.assertEqual((ROOT / "docs/workflow-protocols/LICENSE.mattpocock").read_bytes(),
                         (snapshot / "LICENSE").read_bytes())

    def test_installed_resources_resolve_to_authoritative_files(self):
        with tempfile.TemporaryDirectory(prefix="workflow-install-") as temp:
            target = Path(temp) / "skills"
            run = subprocess.run([str(ROOT / "scripts/publish-skills.sh"), "global", "--target", str(target),
                                  "--bundles", "all"], capture_output=True, text=True, timeout=10)
            self.assertEqual(run.returncode, 0, run.stderr)
            results = []
            for line in (ROOT / "config/skills.tsv").read_text().splitlines():
                columns = line.split("|")
                if len(columns) != 6 or columns[1] != "global" or columns[4] != "active":
                    continue
                name, _, source = columns[:3]
                self.assertEqual((target / name).resolve(), ROOT / source)
                for resource_dir in ["references", "scripts"]:
                    directory = ROOT / source / resource_dir
                    if not directory.exists():
                        continue
                    for link in directory.rglob("*"):
                        if not link.is_symlink():
                            continue
                        installed = target / name / link.relative_to(ROOT / source)
                        self.assertTrue(installed.is_file(), installed)
                        self.assertEqual(installed.read_bytes(), link.resolve().read_bytes())
                        results.append(str(installed.relative_to(target)))
            for retired_or_protocol in [
                "to-decision", "review-cross-stack-change", "implement", "pr", "release",
                "show-me", "prototype", "implement-spec", "verify-change",
                "dev", "to-requirement", "to-spec", "to-tickets", "code-review", "to-html",
                "x-tdd", "x-domain", "x-tasks", "x-retro",
            ]:
                self.assertFalse((target / retired_or_protocol).exists(), retired_or_protocol)
                self.assertFalse((target / retired_or_protocol).is_symlink(), retired_or_protocol)
            evidence("publication-resources.json", {"checked": results, "count": len(results)})


class WorktreeIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="workflow-git-")
        self.root = Path(self.temp.name)
        self.repo = self.root / "repository"
        self.repo.mkdir()
        self.env = {**os.environ, "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1",
                    "GIT_TERMINAL_PROMPT": "0", "PYTHONDONTWRITEBYTECODE": "1"}
        self.git(self.repo, "init", "-b", "main")
        self.git(self.repo, "config", "user.name", "Workflow Test")
        self.git(self.repo, "config", "user.email", "workflow@example.invalid")
        self.git(self.repo, "config", "commit.gpgsign", "false")
        self.git(self.repo, "config", "core.hooksPath", str(self.root / "empty-hooks"))
        (self.repo / "SPEC.md").write_text("Price=quantity*unit; shipping=7; total=price+shipping. 3*14+7=49.\n")
        (self.repo / "shared.txt").write_text("base\n")
        self.commit(self.repo, "fixture baseline")
        self.base = self.git(self.repo, "rev-parse", "HEAD").stdout.strip()
        self.git(self.repo, "checkout", "-b", "integration")

    def tearDown(self):
        self.temp.cleanup()

    def git(self, directory, *args, check=True):
        result = subprocess.run(["git", *args], cwd=directory, env=self.env,
                                capture_output=True, text=True, timeout=10)
        if check and result.returncode:
            self.fail(f"git {args}: {result.stderr}")
        return result

    def commit(self, directory, message):
        self.git(directory, "add", ".")
        self.git(directory, "commit", "-m", message)

    def worktree(self, name):
        path = self.root / name
        self.git(self.repo, "worktree", "add", "-b", name, str(path), "integration")
        return path

    def run_tests(self, directory):
        result = subprocess.run([sys.executable, "-m", "unittest", "discover", "-v"], cwd=directory,
                                env=self.env, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stderr

    def test_two_ready_tasks_then_dependent_task_integrate_and_verify(self):
        state = graph(); frontiers = [module.frontier(state)["ready"]]
        a = self.worktree("price")
        b = self.worktree("shipping")
        self.assertEqual(self.git(a, "rev-parse", "HEAD").stdout.strip(), self.base)
        self.assertEqual(self.git(b, "rev-parse", "HEAD").stdout.strip(), self.base)
        (a / "price.py").write_text("def price(quantity, unit):\n    return quantity * unit\n")
        (a / "test_price.py").write_text("import unittest\nfrom price import price\nclass Price(unittest.TestCase):\n    def test_price(self): self.assertEqual(price(3,14),42)\n")
        (b / "shipping.py").write_text("def shipping():\n    return 7\n")
        (b / "test_shipping.py").write_text("import unittest\nfrom shipping import shipping\nclass Shipping(unittest.TestCase):\n    def test_shipping(self): self.assertEqual(shipping(),7)\n")
        self.run_tests(a); self.run_tests(b)
        self.commit(a, "A price behavior"); self.commit(b, "B shipping behavior")
        self.git(self.repo, "merge", "--ff-only", "price")
        state["tasks"][0]["status"] = "done"; frontiers.append(module.frontier(state)["ready"])
        self.git(b, "merge", "--no-edit", "integration")
        self.run_tests(b)
        self.git(self.repo, "merge", "--ff-only", "shipping")
        state["tasks"][1]["status"] = "done"; frontiers.append(module.frontier(state)["ready"])
        c = self.worktree("checkout")
        (c / "checkout.py").write_text("from price import price\nfrom shipping import shipping\ndef total(quantity, unit):\n    return price(quantity,unit)+shipping()\n")
        (c / "test_checkout.py").write_text("import unittest\nfrom checkout import total\nclass Checkout(unittest.TestCase):\n    def test_total(self): self.assertEqual(total(3,14),49)\n")
        self.run_tests(c); self.commit(c, "C integrated checkout behavior")
        self.git(self.repo, "merge", "--ff-only", "checkout")
        final_tests = self.run_tests(self.repo)
        self.assertIn("Ran 3 tests", final_tests)
        state["tasks"][2]["status"] = "done"; frontiers.append(module.frontier(state)["ready"])
        for directory in [a, b, c]:
            self.assertEqual(self.git(directory, "status", "--porcelain").stdout, "")
            self.git(self.repo, "worktree", "remove", str(directory))
        self.assertEqual(len(self.git(self.repo, "worktree", "list", "--porcelain").stdout.split("worktree ")) - 1, 1)
        evidence("integration.json", {"scope": "deterministic Git worktree exercise; no model workers",
                 "frontiers": frontiers, "base": self.base,
                 "head": self.git(self.repo, "rev-parse", "HEAD").stdout.strip(),
                 "log": self.git(self.repo, "log", "--oneline", "--graph").stdout,
                 "patch": self.git(self.repo, "diff", self.base, "HEAD").stdout,
                 "final_tests": final_tests, "owned_worktrees_removed": True})

    def test_conflict_preserves_unmerged_work_and_blocks_downstream(self):
        a = self.worktree("left"); b = self.worktree("right")
        (a / "shared.txt").write_text("left change\n"); self.commit(a, "left change")
        (b / "shared.txt").write_text("right change\n"); self.commit(b, "right change")
        right_sha = self.git(b, "rev-parse", "HEAD").stdout.strip()
        self.git(self.repo, "merge", "--ff-only", "left")
        result = self.git(self.repo, "merge", "--no-edit", "right", check=False)
        self.assertNotEqual(result.returncode, 0)
        status = self.git(self.repo, "status", "--porcelain").stdout
        self.assertIn("UU shared.txt", status)
        self.assertEqual((b / "shared.txt").read_text(), "right change\n")
        state = graph(); state["tasks"][0]["status"] = "done"; state["tasks"][1]["status"] = "blocked"
        self.assertEqual(module.frontier(state)["ready"], [])
        evidence("conflict.json", {"merge_returncode": result.returncode, "status": status,
                 "conflict": self.git(self.repo, "diff", "--cc").stdout,
                 "unmerged_commit": right_sha, "downstream_ready": [],
                 "task_work_preserved_before_cleanup": True})
        self.git(self.repo, "merge", "--abort")
        self.assertEqual(self.git(b, "rev-parse", "HEAD").stdout.strip(), right_sha)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--artifacts", type=Path)
    options, remaining = parser.parse_known_args()
    if options.artifacts:
        ARTIFACTS = options.artifacts.resolve()
        ARTIFACTS.mkdir(parents=True, exist_ok=False)
    program = unittest.main(argv=[sys.argv[0], *remaining], verbosity=2, exit=False)
    result = program.result
    evidence("summary.json", {"tests": result.testsRun, "failures": len(result.failures),
             "errors": len(result.errors), "skipped": len(result.skipped),
             "scope": "deterministic contracts, snapshot, publication and Git exercises; not model behavior"})
    sys.exit(0 if result.wasSuccessful() else 1)
