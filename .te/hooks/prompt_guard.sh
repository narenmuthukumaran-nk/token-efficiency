#!/usr/bin/env bash
# UserPromptSubmit hook. Never blocks.
# 1) On the FIRST prompt of a session: asks Jev which model + effort the task needs (one cheap call, zero Claude tokens)
#    and tells Claude to compare with itself and fix it before working. Multi-line task dumps get batched.
# 2) Every prompt: warns on booster words and long pastes.
input=$(cat)
ptmp=$(mktemp)
transcript=$(printf '%s' "$input" | python3 -c 'import sys,json;o=json.load(sys.stdin);open(sys.argv[1],"w").write(o.get("prompt",""));print(o.get("transcript_path",""))' "$ptmp" 2>/dev/null)
prompt=$(cat "$ptmp"); rm -f "$ptmp"
root="$(cd "$(dirname "$0")/.." && pwd)"
warn=(); ctx=()
first=0; { [ -z "$transcript" ] || [ ! -s "$transcript" ] || ! /usr/bin/grep -q '"type":"assistant"' "$transcript"; } && first=1
if [ "$first" = 1 ] && [ ${#prompt} -gt 40 ]; then
  tasks=$(printf '%s\n' "$prompt" | /usr/bin/grep -cE '^\s*([-*]|[0-9]+[.)])\s+\S')
  if [ "$tasks" -ge 3 ]; then
    tmp=$(mktemp); printf '%s\n' "$prompt" | /usr/bin/grep -E '^\s*([-*]|[0-9]+[.)])\s+\S' | sed -E 's/^\s*([-*]|[0-9]+[.)])\s+//' > "$tmp"
    route=$(python3 "$root/bin/te-route.py" --batch "$tmp" 2>/dev/null); rm -f "$tmp"
    [ -n "$route" ] && ctx+=("JEV BATCH PLAN for this task list (one fresh session per batch, do only the batch that matches your model, write the rest to tasks-remaining.md and tell the user which sessions to open):$route")
  else
    route=$(python3 "$root/bin/te-route.py" "$prompt" 2>/dev/null | head -3 | tr '\n' ' ')
    [ -n "$route" ] && ctx+=("JEV ROUTING for this task: $route. If the model differs from you: this is prompt 1, nothing is cached yet, so switch now with set_session_model and set_session_effort if those tools exist, else tell the user in ONE line to reopen on that model. If it matches, set the effort and start.")
  fi
fi
lines=$(printf '%s\n' "$prompt" | wc -l | tr -d ' ')
[ "$lines" -gt 200 ] && warn+=("pasted ${lines} lines: point to a file path instead")
printf '%s' "$prompt" | /usr/bin/grep -Eiq 'double[- ]check|verify (it )?twice|think step by step|be (very |extremely )?thorough|this is critical|make sure you' && warn+=("booster words found: remove them, they only add passes")
[ ${#warn[@]} -eq 0 ] && [ ${#ctx[@]} -eq 0 ] && exit 0
python3 - "$(printf '%s\n' "${warn[@]}")" "$(printf '%s\n' "${ctx[@]}")" <<'PY'
import json,sys
w,c=sys.argv[1].strip(),sys.argv[2].strip()
out={"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":(("token-efficiency warnings: "+w+"\nFlag these to the user in one line.\n") if w else "")+c}}
if w: out["systemMessage"]="token-efficiency: "+w
print(json.dumps(out))
PY
