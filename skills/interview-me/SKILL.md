---
name: interview-me
description: Before planning or coding a vague task, interview the user until the four-part brief (job, why, guardrails, done-means) is complete, then write it to a file. Use when NK says "interview me", gives a half-formed idea, or starts a big task with unknowns.
---

# interview-me

Goal: fill a four-part brief before any work starts. Cheap questions now beat a wrong build later.

## The brief (all four must be filled)
1. **Job**: what exactly gets built or changed, in one or two lines.
2. **Why**: the problem or outcome it serves. Decides trade-offs.
3. **Guardrails**: what must not change or be touched (locked files, no push, no new deps, other sessions' work).
4. **Done-means**: checks that prove it is finished (a command that passes, a screen that shows X, a file that exists).

## How to run it
- Read nothing in the repo first, except what the user points to. Ask first.
- Ask at most 3 questions per turn, multiple choice where possible, with your recommended answer first.
- Only ask about unknowns. Skip anything the message already answers.
- One plain-English line for any technical term, lists not paragraphs.
- Stop asking when all four parts are specific enough for a fresh session to act on without guessing.
- Echo the brief back in four short lists and ask "correct?" once.

## Output
Write the brief to `BRIEF.md` in the current project root (or the path the user names):

```
# Brief: <task name>
## Job
## Why
## Guardrails
## Done-means
## Open questions (only if the user said "decide later")
```

Then tell the user: "Brief saved at <path>. Open a fresh session, model <Sonnet|other>, effort <level>, and say: do BRIEF.md." Do not start the work in this session.
