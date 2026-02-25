"""
UserPromptSubmit hook: fires before Claude processes each prompt.
If the prompt signals session end, injects the session edit log and
git diff summary into Claude's context via stdout.
"""
import json
import sys
import os
import subprocess

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
lines = ["[HOOK: Session end detected. Execute the Session End Protocol from CLAUDE.md.]\n"]

# Append list of files edited this session
log_path = os.path.join(os.getcwd(), ".claude", "session_edits.log")
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
        capture_output=True, text=True, cwd=os.getcwd()
    )
    if result.stdout.strip():
        lines.append("Git diff --stat (uncommitted changes):")
        lines.append(result.stdout.strip())
except Exception:
    pass

print("\n".join(lines))
sys.exit(0)
