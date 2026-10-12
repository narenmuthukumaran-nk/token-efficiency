# Token Efficiency for Claude Code

A field guide for people on a fixed Claude plan (Pro / Max) who hit the weekly limit too early.
Goal: ship more work per week without changing how good the work is.

## 1. Why you run out

| Cause | What it costs |
|---|---|
| Expensive model (Opus / Fable) on the main thread for grep, reads, doc edits | 5 to 10x the price of the same work on Sonnet or Haiku |
| Mega sessions (audit + 100 fixes + docs in one chat) | Context fills, compacts, re-reads the same files 3 to 4 times |
| Session start tax (big memory index, mandatory skills, status docs) | 30 to 60k tokens before any work |
| Hundreds of MCP tools attached | Deferred tool list sits in every prompt and every cache miss |
| Raw build / test logs and screenshots in context | Thousands of tokens of noise per command |
| 3 to 5 parallel sessions | Each one carries the full context above |
| Weekend burst, no budget | Limit gone by Monday |

## 2. Tools (all open source)

| Tool | Repo | What it does | Install |
|---|---|---|---|
| CodeGraph | github.com/colbymchenry/codegraph | Pre-indexed code knowledge graph, auto-syncs on change, 100% local. Claude queries a node instead of grepping the repo. | see repo README |
| RTK | github.com/rtk-ai/rtk | CLI proxy, single Rust binary. Compresses `git`, `npm`, `cargo`, `xcodebuild`, test and log output 60 to 90%. | see repo README |
| Caveman | github.com/JuliusBrussee/caveman | Skill + proxy that makes the agent reply tersely. Cuts ~65% of output tokens. Tune it to keep your preferred reply shape (lists, steps). | see repo README |
| Token Dashboard | github.com/nateherkai/token-dashboard | Turns local Claude Code JSONL transcripts into cost analytics and hotspot views. Shows where tokens go. | see repo README |
| Composio | composio.dev | One tool bridge instead of many MCP servers. Free Hobby plan, hard-capped, no credit card. | app.composio.dev |

Trade-offs
- CodeGraph: index and code must stay in sync. If sync breaks, the agent is confidently wrong.
- RTK: can drop a line you needed. Decide up front when it is off (for example self-healing or crash debugging runs).
- Caveman: terse by default. Say what shape you still want (lists, file paths, commands).

## 3. Model ladder

| Job | Model | Effort |
|---|---|---|
| Plan a task, write the brief | Opus | high, once |
| Implement from a written plan | Sonnet | medium |
| Grep, find files, read logs, update docs or changelog | Haiku (sub-agent) | low |
| Code review, test writing | Sonnet (sub-agent) | medium |
| Locked or security-critical algorithms, deadlocks, crypto | Fable / Opus | high, short session |
| Orchestrator for multi-agent runs | Fable or Opus, sub-agents never Fable | medium |

Rules
- Pick the model BEFORE prompt 1. Switching model mid-task breaks the prompt cache.
- Switch EFFORT mid-task instead. Prompt 1 high, iterations low. Opus and Fable keep the cache.
- Fable is an orchestrator, never a sub-agent.

## 4. Session habits

1. One task, one session. Start fresh for a new task.
2. Start with a clean context window. No carried-over chat.
3. Do not pause more than an hour. The cache expires.
4. Do not paste long documents. Point to a path or a section.
5. Pre-plan every task in four lines: the job, the why, the guardrails, what "done" means. Use an "interview me" skill to surface unknowns and a prompt-master skill to turn a voice dump into that structure.
6. 450k tokens is the dumb zone. Compact or restart before it.
7. Compact manually at phase boundaries with one line on what to keep.
8. Max 2 parallel sessions. Never two on the same repo.
9. Pipe builds and logs through RTK or `grep | tail` to a file. Never paste full output.
10. Screenshots only as final proof, never for exploring.

## 5. Prompt habits

| Do not write | Why |
|---|---|
| "double check", "verify twice" | Already trained in. Only adds passes. |
| "think step by step" | Burns reasoning tokens for no gain on modern models. |
| "be very thorough", "this is critical", "make sure" | Emphasis boosters cause over-checking. |
| Whole documents pasted inline | Cache miss plus context bloat. Reference the file. |

## 6. Setup hygiene

- Trim the memory index to ~25 lines. Archive the rest.
- Load skills on demand, not at session start.
- Disable MCP servers you do not use in this project. Keep 2 or 3.
- Keep ONE doc of record per project. Every extra doc system is paid for by the expensive model.
- Generate a repo map file (modules, key types, paths) by script. Cheaper than any tool call.

## 7. Weekly token budget

| Day | Share of weekly limit |
|---|---|
| Mon to Fri | 15% each |
| Sat + Sun | 25% total, reserve |
| Any single session | max 25% |

Check usage at every session start. When a session hits its share: stop, write a 20-line handoff, close.

## 8. Guard rails the agent enforces for you

Put these in CLAUDE.md or a SessionStart hook so the agent warns you before it starts:
- model chosen before prompt 1
- task brief has job / why / guardrails / done
- context under 450k
- no booster words in the prompt
- no pasted document over ~200 lines
- usage share for today not exceeded
