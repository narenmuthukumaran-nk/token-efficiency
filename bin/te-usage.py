#!/usr/bin/env python3
"""Today / 7-day token totals from local Claude Code transcripts. Local only, nothing leaves the machine.
Set TE_WEEKLY_TOKEN_BUDGET in ~/.config/token-efficiency/.env to get a percentage."""
import json, os, glob, datetime as dt
home=os.path.expanduser("~")
env={}
try:
    for line in open(f"{home}/.config/token-efficiency/.env"):
        if "=" in line and not line.startswith("#"):
            k,v=line.strip().split("=",1); env[k]=v
except FileNotFoundError: pass
budget=int(env.get("TE_WEEKLY_TOKEN_BUDGET","0") or 0)
now=dt.datetime.now().astimezone(); today=now.date()
week_start=today-dt.timedelta(days=today.weekday())
tot={"today":0,"week":0}; seen=set()
for f in glob.glob(f"{home}/.claude/projects/*/*.jsonl"):
    if dt.date.fromtimestamp(os.path.getmtime(f))<week_start: continue
    try:
        for line in open(f, errors="ignore"):
            if '"usage"' not in line: continue
            try: o=json.loads(line)
            except Exception: continue
            m=o.get("message") or {}; u=m.get("usage")
            if not u: continue
            key=(m.get("id"),o.get("requestId"))
            if key in seen: continue
            seen.add(key)
            n=u.get("input_tokens",0)+u.get("output_tokens",0)+u.get("cache_creation_input_tokens",0)
            ts=o.get("timestamp")
            try: d=dt.datetime.fromisoformat(ts.replace("Z","+00:00")).astimezone().date()
            except Exception: continue
            if d>=week_start: tot["week"]+=n
            if d==today: tot["today"]+=n
    except Exception: continue
def k(n): return f"{n/1000:.0f}k" if n<1e6 else f"{n/1e6:.2f}M"
s=f"tokens today {k(tot['today'])}, week-to-date {k(tot['week'])} (uncached input+output+cache writes)"
if budget:
    s+=f" | {tot['week']*100//budget}% of weekly budget, daily target 15% = {k(budget*15//100)}"
print(s)
