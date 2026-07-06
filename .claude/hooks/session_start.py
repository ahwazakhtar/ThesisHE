"""
SessionStart hook: injects conductor state into context at the start of
every session (startup/resume/clear) so the Session Start protocol is
deterministic instead of instruction-dependent.

Prints: active tracks with each track's first open task, not-started
tracks, and git state. Keep output compact — it lands in every context.
"""
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = os.getcwd()
TRACKS = os.path.join(ROOT, "conductor", "tracks.md")
MAX_TASK_CHARS = 160


def first_open_task(plan_path):
    """Return (marker, text) of the first [ ] or [~] task line, else None."""
    try:
        with open(plan_path, encoding="utf-8", errors="replace") as f:
            for line in f:
                m = re.match(r"\s*-\s\[([ ~])\]\s*(.+)", line)
                if m:
                    text = re.sub(r"\*\*", "", m.group(2)).strip()
                    if len(text) > MAX_TASK_CHARS:
                        text = text[: MAX_TASK_CHARS - 1] + "…"
                    return m.group(1), text
    except OSError:
        pass
    return None


def git(*args):
    try:
        out = subprocess.run(["git", *args], capture_output=True, text=True,
                             cwd=ROOT, timeout=10)
        return out.stdout.strip()
    except Exception:
        return ""


if not os.path.exists(TRACKS):
    sys.exit(0)

with open(TRACKS, encoding="utf-8", errors="replace") as f:
    registry = f.read()

# Entries look like:  - [~] **Track: Name**\n  *Link: [./tracks/folder/](...)*
entries = re.findall(
    r"-\s\[([ ~x])\]\s\*\*Track:\s*(.+?)\*\*.*?\./tracks/([^/\)]+)/",
    registry, flags=re.S,
)

active, not_started = [], []
for marker, name, folder in entries:
    if marker == "~":
        active.append((name.strip(), folder))
    elif marker == " ":
        not_started.append(folder)

lines = ["[HOOK session-start] Conductor state (read plan.md before acting):", ""]

if active:
    lines.append("Active tracks — next open task in each:")
    for name, folder in active:
        plan = os.path.join(ROOT, "conductor", "tracks", folder, "plan.md")
        task = first_open_task(plan)
        if task:
            lines.append(f"- {folder}: [{task[0]}] {task[1]}")
        else:
            lines.append(f"- {folder}: no open tasks (verification gate or closed)")
if not_started:
    lines.append("")
    lines.append("Registered but not started: " + ", ".join(not_started))

branch = git("branch", "--show-current")
dirty = git("status", "--porcelain")
n_dirty = len([l for l in dirty.splitlines() if l.strip()])
lines.append("")
lines.append(f"Git: branch '{branch}', {n_dirty} uncommitted change(s).")
lines.append("")
lines.append("Per CLAUDE.md: state the next task and confirm with the user "
             "before starting work.")

print("\n".join(lines))
