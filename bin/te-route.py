#!/usr/bin/env python3
"""te route: ask Jev (TypeSafe System One) which Claude model and effort a task needs, BEFORE the session starts.
Usage: te route "task brief"   or   te route < brief.md
Reads JEV_API_KEY from ~/.config/token-efficiency/.env. One cheap call, no Claude tokens."""
import json, os, sys, urllib.request
env = {}
for line in open(os.path.expanduser("~/.config/token-efficiency/.env")):
    if "=" in line and not line.startswith("#"):
        k, v = line.strip().split("=", 1); env[k] = v
key = env.get("JEV_API_KEY") or sys.exit("JEV_API_KEY missing in ~/.config/token-efficiency/.env")
args=sys.argv[1:]
if args and args[0]=="--batch":
    # te route --batch tasks.md : one Jev call per task line, grouped output (model, effort) for session batching
    lines=[l.strip(" -*\t") for l in open(args[1]) if l.strip() and not l.startswith("#")]
    groups={}
    for t in lines:
        body={"state":t,"model":"jev-latest","questions":{
          "model":{"type":"choice","instructions":"Which Claude model should run this coding task? Cheapest that does it well. Risk and ambiguity matter, size does not.",
            "criteria":{"haiku":"search, logs, docs, renames, mechanical edits","sonnet":"implement from a clear brief, tests, review, UI screens with a design system","opus":"unclear scope, architecture, cross-module debugging, writing the brief","fable":"locked or security-critical algorithm, crash with no clear cause, go-live audit"}},
          "effort":{"type":"choice","instructions":"Reasoning effort for this task","criteria":{"low":"mechanical, well specified","medium":"normal","high":"ambiguous or risky"}}}}
        rq=urllib.request.Request("https://api.typesafe.ai/v1/systemone",data=json.dumps(body).encode(),headers={"Authorization":f"Bearer {key}","Content-Type":"application/json"})
        try: a=json.load(urllib.request.urlopen(rq,timeout=20))["answers"]
        except Exception as e: sys.exit(f"jev call failed: {e}")
        mo=max(a["model"]["probabilities"],key=a["model"]["probabilities"].get); ef=max(a["effort"]["probabilities"],key=a["effort"]["probabilities"].get)
        groups.setdefault((mo,ef),[]).append(t)
    order={"haiku":0,"sonnet":1,"opus":2,"fable":3}; eo={"low":0,"medium":1,"high":2}
    for (mo,ef),ts in sorted(groups.items(),key=lambda k:(order[k[0][0]],eo[k[0][1]])):
        print(f"\n## batch: {mo} / effort {ef}  ({len(ts)} tasks)  -> one fresh session: claude --model {mo}, /effort {ef}")
        for t in ts: print(f"- {t}")
    sys.exit(0)
brief = " ".join(args) or sys.stdin.read()
body = {
  "state": brief, "model": "jev-latest",
  "questions": {
    "model": {"type": "choice", "instructions": "Which Claude model should run this coding task? Pick the cheapest that can do it well.",
      "criteria": {
        "haiku": "search, grep, find files, read logs, update docs or changelog, rename, mechanical edits, formatting",
        "sonnet": "implement a feature or fix from a clear brief, write tests, code review, UI work, refactors with known scope",
        "opus": "plan an unclear task, design architecture, hard debugging across modules, review a large diff, write a brief for others",
        "fable": "locked or security-critical algorithms (auth, encryption, sleep, calls, commute detection), deadlocks or crashes with no clear cause, final go-live audit"}},
    "effort": {"type": "choice", "instructions": "How much reasoning effort does the first prompt need?",
      "criteria": {"low": "mechanical, well specified, small", "medium": "normal implementation", "high": "ambiguous, cross-module, risky, or needs a plan first"}},
    "needs_brief": {"type": "noul", "instructions": "Is this task too vague to start without first writing a brief (job, why, guardrails, done-means)?"}
  }}
req = urllib.request.Request("https://api.typesafe.ai/v1/systemone", data=json.dumps(body).encode(),
  headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
try:
    r = json.load(urllib.request.urlopen(req, timeout=20))
except Exception as e:
    sys.exit(f"jev call failed: {e}")
a = r["answers"]
m, e = a["model"], a["effort"]
mo = m.get("answer") or m.get("choice") or max(m["probabilities"], key=m["probabilities"].get)
ef = e.get("answer") or e.get("choice") or max(e["probabilities"], key=e["probabilities"].get)
nb = a["needs_brief"].get("probability", a["needs_brief"].get("answer", 0))
print(f"model: {mo}  (confidence {m['probabilities'][mo]:.2f})")
print(f"effort: {ef}  (then drop to low for iterations)")
if isinstance(nb, (int, float)) and nb > 0.6: print(f"write a brief first (job / why / guardrails / done): Jev is {nb:.0%} sure this is too vague")
print(f"start: claude --model {mo}   then /effort {ef}")
print(f"jev usage: {r.get('usage')}")
