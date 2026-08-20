"""
UserPromptSubmit hook: fires before Claude processes each prompt.
If the prompt signals session end, injects the session edit log and
git diff summary into Claude's context via stdout.
"""
import json
import sys
import os
import subprocess

# Project root: prefer Claude Code's CLAUDE_PROJECT_DIR, else derive from this
# file's location (.claude/hooks/<script>.py). Never trust os.getcwd() -- the
# hook inherits whatever cwd the shell happens to be in.
PROJECT_DIR = os.environ.get("CLAUDE_PROJECT_DIR") or os.path.abspath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
)

WRAPUP_KEYWORDS = [
    "wrap up", "wrapup", "wrap-up",
    "end session", "we're done", "we are done",
    "session end", "finish up", "that's all for today",
    "done for today", "closing up",
]

payload = json.load(sys.stdin)
prompt = payload.get("prompt", "").lower()

if not any(kw in prompt for kw in WRAPUP_KEYWORDS):
    sys.exit(0)

# --- Session end detected: build context injection ---
lines = ["[HOOK: A wrap-up phrase was detected. If the user is signaling the end of the "
         "session, invoke the `session-end` skill (Skill tool) and follow it. If they are "
         "only asking about or mentioning the protocol (false positive), ignore this and "
         "answer normally.]\n"]

# Append list of files edited this session
log_path = os.path.join(PROJECT_DIR, ".claude", "session_edits.log")
if os.path.exists(log_path):
    with open(log_path) as f:
        edits = f.read().strip()
    if edits:
        lines.append("Files edited this session:")
        lines.append(edits)
        lines.append("")

# Append git diff --stat for context
try:
    result = subprocess.run(
        ["git", "diff", "HEAD", "--stat"],
        capture_output=True, text=True, cwd=PROJECT_DIR
    )
    if result.stdout.strip():
        lines.append("Git diff --stat (uncommitted changes):")
        lines.append(result.stdout.strip())
except Exception:
    pass

print("\n".join(lines))
sys.exit(0)
