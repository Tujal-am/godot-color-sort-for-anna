#!/usr/bin/env python3
"""Read-only preflight before Codex changes. Usage:
python3 scripts/codex_preflight.py --branch BR_V1.0.0-rc14 --remote origin --repo Tujal-am/godot-color-sort-for-anna
"""
import argparse
import subprocess
import sys


def git(*args):
    p = subprocess.run(["git", *args], text=True, capture_output=True)
    if p.returncode:
        raise RuntimeError(f"git {' '.join(args)}: {p.stderr.strip()}")
    return p.stdout.strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--branch", required=True, help="Explicit expected branch, never guessed")
    parser.add_argument("--remote", default="origin")
    parser.add_argument("--repo", required=True, help="Expected GitHub owner/repo")
    parser.add_argument("--allow-dirty", action="store_true", help="Read-only warning override")
    a = parser.parse_args()
    errors = []
    try:
        root = git("rev-parse", "--show-toplevel")
        branch = git("branch", "--show-current")
        head = git("rev-parse", "HEAD")
        status = git("status", "--porcelain")
        url = git("remote", "get-url", a.remote)
        norm = url.removesuffix(".git").lower().replace(":", "/")
        expected = a.repo.lower()
        if not (norm.endswith("github.com/" + expected)):
            errors.append(f"Remote mismatch: {url} != {a.repo}")
        if branch != a.branch:
            errors.append(f"Branch mismatch: {branch!r} != {a.branch!r}")
        if status and not a.allow_dirty:
            errors.append("Working tree is not clean; inspect existing work before edits")
        try:
            upstream = git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")
        except RuntimeError:
            upstream = "(none)"
        print(f"ROOT: {root}\nREMOTE: {url}\nBRANCH: {branch}\nHEAD: {head}\nUPSTREAM: {upstream}")
        print(f"WORKTREE: {'dirty' if status else 'clean'}")
    except RuntimeError as e:
        errors.append(str(e))
    if errors:
        for error in errors:
            print("BLOCKED:", error, file=sys.stderr)
        return 2
    print("PASS: Git identity/branch/worktree preflight only; gameplay and visual tests NOT RUN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
