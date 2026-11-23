#!/usr/bin/env python3
"""校验 tracker 派生的任务图快照，只输出 ready frontier，不执行任务。"""
import argparse
import json
import sys
from pathlib import Path


def frontier(document):
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        raise ValueError("schema_version must be 1")
    if not isinstance(document.get("spec"), str) or not document["spec"].strip():
        raise ValueError("spec must be a non-empty source pointer")
    tasks = document.get("tasks")
    if not isinstance(tasks, list) or not tasks:
        raise ValueError("tasks must be a non-empty list")
    by_id = {}
    for task in tasks:
        if not isinstance(task, dict):
            raise ValueError("each task must be an object")
        identity = task.get("id")
        if not isinstance(identity, str) or not identity.strip() or identity in by_id:
            raise ValueError("task IDs must be unique non-empty strings")
        if not isinstance(task.get("source"), str) or not task["source"].strip():
            raise ValueError(f"{identity}: source pointer required")
        blockers = task.get("blocked_by")
        if (not isinstance(blockers, list)
                or any(not isinstance(item, str) for item in blockers)
                or len(set(blockers)) != len(blockers)):
            raise ValueError(f"{identity}: blocked_by must list unique IDs")
        if task.get("status") not in {"pending", "running", "done", "blocked"}:
            raise ValueError(f"{identity}: invalid status")
        by_id[identity] = task
    for identity, task in by_id.items():
        for blocker in task["blocked_by"]:
            if blocker == identity or blocker not in by_id:
                raise ValueError(f"{identity}: unknown or self blocker {blocker}")

    # 用拓扑消解而不是递归，避免大图触及解释器递归上限。
    remaining = {key: set(value["blocked_by"]) for key, value in by_id.items()}
    while remaining:
        roots = {key for key, blockers in remaining.items() if not blockers}
        if not roots:
            raise ValueError("dependency cycle detected")
        remaining = {key: blockers - roots for key, blockers in remaining.items() if key not in roots}
    for identity, task in by_id.items():
        if task["status"] in {"running", "done"} and any(
                by_id[item]["status"] != "done" for item in task["blocked_by"]):
            raise ValueError(f"{identity}: started/completed before blockers were done")
    ready = [identity for identity, task in by_id.items()
             if task["status"] == "pending"
             and all(by_id[item]["status"] == "done" for item in task["blocked_by"])]
    return {"spec": document["spec"], "ready": ready,
            "done": [identity for identity, task in by_id.items() if task["status"] == "done"],
            "total": len(tasks)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("graph", type=Path)
    args = parser.parse_args()
    try:
        result = frontier(json.loads(args.graph.read_text()))
    except (OSError, UnicodeError, ValueError) as error:
        print(f"invalid task graph: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
