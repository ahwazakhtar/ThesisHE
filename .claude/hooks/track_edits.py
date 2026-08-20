"""
PostToolUse hook: fires after every Edit or Write tool call.
Appends the changed file path + timestamp to .claude/session_edits.log.
"""
import json
import sys
import os
from datetime import datetime

# Project root: prefer Claude Code's CLAUDE_PROJECT_DIR, else derive from this
# file's location (.claude/hooks/<script>.py). Never trust os.getcwd() -- the
# hook inherits whatever cwd the shell happens to be in.
PROJECT_DIR = os.environ.get("CLAUDE_PROJECT_DIR") or os.path.abspath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
)

payload = json.load(sys.stdin)
file_path = payload.get("tool_input", {}).get("file_path", "")

if file_path:
    log_path = os.path.join(PROJECT_DIR, ".claude", "session_edits.log")
    timestamp = datetime.now().strftime("%H:%M:%S")
    with open(log_path, "a") as f:
        f.write(f"{timestamp}  {file_path}\n")
