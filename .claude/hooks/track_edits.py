"""
PostToolUse hook: fires after every Edit or Write tool call.
Appends the changed file path + timestamp to .claude/session_edits.log.
"""
import json
import sys
import os
from datetime import datetime

payload = json.load(sys.stdin)
file_path = payload.get("tool_input", {}).get("file_path", "")

if file_path:
    log_path = os.path.join(os.getcwd(), ".claude", "session_edits.log")
    timestamp = datetime.now().strftime("%H:%M:%S")
    with open(log_path, "a") as f:
        f.write(f"{timestamp}  {file_path}\n")
