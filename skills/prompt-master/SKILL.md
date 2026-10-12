---
name: prompt-master
description: Turn a voice dump or rambling message into the four-part brief (job, why, guardrails, done-means), ready to paste into a fresh session. Use when NK pastes a long unstructured dump, says "clean this up", or "make this a prompt".
---

# prompt-master

Input: a messy dump (voice transcript, stream of thought). Output: one tight brief. No questions unless a part is truly missing.

## Steps
1. Read the dump once. Extract every concrete ask, constraint and success signal.
2. Sort into four parts:
   - **Job**: the actions wanted, merged and ordered. Drop repetition and filler.
   - **Why**: the stated reason or pain. If none, write "not stated".
   - **Guardrails**: every "don't", "never", "only", "keep" in the dump, plus known project laws.
   - **Done-means**: any "it works when" signal, turned into a checkable item. If none stated, propose one and mark it "(proposed)".
3. Keep NK's own words for names, paths and numbers. Never invent facts.
4. Anything unclear goes under "Open questions" at the end, max 3 lines.
5. If a part is "not stated" and matters, say so and suggest running `interview-me`.

## Output format
```
# Brief: <short name>
## Job
- ...
## Why
- ...
## Guardrails
- ...
## Done-means
- ...
## Open questions
- ...
```
Under 40 lines. Offer to save it as `BRIEF.md`. Do not start the work.
