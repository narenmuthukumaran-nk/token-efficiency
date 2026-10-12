#!/usr/bin/env bash
# PreModelSwitch hook: a model switch mid-session throws away the prompt cache.
# Allowed when nothing is cached yet (no assistant turn in the transcript) or when ~/.config/token-efficiency/allow-switch exists.
input=$(cat)
flag="$HOME/.config/token-efficiency/allow-switch"
if [ -f "$flag" ]; then rm -f "$flag"; exit 0; fi
transcript=$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null)
{ [ -z "$transcript" ] || [ ! -s "$transcript" ] || ! /usr/bin/grep -q '"type":"assistant"' "$transcript"; } && exit 0
to=$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("to_model","?"))' 2>/dev/null)
echo "token-efficiency: switching to $to mid-session restarts the cache. Use /effort, or /clear and reopen on $to. Force once: touch $flag" >&2
exit 2
