#!/usr/bin/env bash
# UserPromptSubmit hook: warns (never blocks) on habits that waste tokens.
input=$(cat)
prompt=$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)
warn=()
lines=$(printf '%s\n' "$prompt" | wc -l | tr -d ' ')
[ "$lines" -gt 200 ] && warn+=("pasted ${lines} lines: point to a file path instead")
if printf '%s' "$prompt" | /usr/bin/grep -Eiq 'double[- ]check|verify (it )?twice|think step by step|be (very |extremely )?thorough|this is critical|make sure you'; then
  warn+=("booster words found (double check / step by step / thorough / critical): remove them, they only add passes")
fi
if printf '%s' "$prompt" | /usr/bin/grep -Eiq 'switch to (opus|sonnet|haiku|fable)|use (opus|sonnet|haiku|fable) (now|from here)'; then
  warn+=("model switch mid-session breaks the cache: change effort instead, or start a new session")
fi
[ ${#warn[@]} -eq 0 ] && exit 0
msg=$(printf 'token-efficiency: %s\n' "${warn[@]}")
python3 - "$msg" <<'PY'
import json,sys
m=sys.argv[1]
print(json.dumps({"systemMessage": m, "hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": m + "\nFlag this to the user in one line before doing the work."}}))
PY
