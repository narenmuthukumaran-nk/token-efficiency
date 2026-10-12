#!/usr/bin/env bash
# SessionStart hook: prints the habit checklist and today's token usage.
root="$(cd "$(dirname "$0")/.." && pwd)"
usage=$(python3 "$root/bin/te-usage.py" 2>/dev/null || echo "usage: token-dashboard not scanned yet")
read -r -d '' habits <<'TXT'
token-efficiency checklist (warn the user on any miss before starting):
1 model picked for this whole session, no mid-task switch (effort may change)
2 brief has: job / why / guardrails / done-means
3 one task, clean context, under 450k
4 no pasted documents, no booster words
5 logs via rtk or tail to file, codegraph before grep
6 sub-agents Haiku/Sonnet only
7 session ends with a 20-line handoff, not a mega run
TXT
python3 - "$habits" "$usage" <<'PY'
import json,sys
h,u=sys.argv[1],sys.argv[2]
print(json.dumps({"systemMessage": u, "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": h+"\n"+u}}))
PY
