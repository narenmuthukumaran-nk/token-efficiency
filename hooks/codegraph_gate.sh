#!/usr/bin/env bash
# Gate for `codegraph prompt-hook`: only inject on real code-structure prompts.
# Needs 6+ words, a how/where/trace/who-calls cue, and a code-looking token. Otherwise silent.
in="$(cat)"
ok=$(printf '%s' "$in" | python3 -c '
import sys,json,re
try: p=json.load(sys.stdin).get("prompt","")
except Exception: p=""
w=p.split()
cue=re.search(r"\b(how does|how do|where is|where are|trace|who calls|what calls|call path|callers?|callees?|find the|which file|defined)\b",p,re.I)
code=re.search(r"[A-Z][a-z]+[A-Z]\w*|\w+_\w+|\w+\.(swift|ts|tsx|py|js|sql)\b|/\w+/|\b(function|class|struct|module|engine|service|file|symbol|method)\b",p)
print("1" if len(w)>=6 and cue and code else "0")')
[ "$ok" = 1 ] && printf '%s' "$in" | codegraph prompt-hook
exit 0
