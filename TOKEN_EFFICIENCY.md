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

## 9. What Anthropic's own caching docs say (Claude Code, Oct 2026)

Source: code.claude.com/docs/en/prompt-caching and /costs. Every point below is from those pages.

| Fact | What it means for you |
|---|---|
| Each model has its own cache. `/model` mid-session re-reads the whole history uncached. | Pick the model before prompt 1. The `pre_model_switch.sh` hook blocks accidental switches. Avoid `opusplan`: every plan-mode toggle is a model switch. |
| Changing effort keeps the cache on Opus 5.5, Sonnet 5.5, Haiku 5.5, Fable 5.1 (Claude Code 2.1.260+). | Use `/effort` freely. Prompt 1 high, iterations low. |
| Turning fast mode on changes the model. | Decide fast mode at session start. |
| Cache lifetime: 1 hour on a subscription within plan usage, 5 minutes on usage credits or API key. Every hit resets the timer. | Do not pause more than an hour. If you did, `/clear` or resume from summary instead of continuing the big session. |
| Sub-agent and compaction requests get the 5-minute TTL by default. | Keep sub-agent tasks short and self-contained. `subagentPromptCacheTtl` can raise it, at 2x write cost. |
| Compaction invalidates the conversation layer and costs the most after a break. | `/compact` at a natural break while the cache is warm, never right after returning. |
| MCP tools are deferred, so connecting or removing a server mid-session does not disturb the cache. | Toggle MCP between sessions anyway, but a mid-session toggle is not a disaster. |
| Cache is scoped to machine + directory. Parallel sessions in the same directory share the cached prefix. Sequential sessions share it only if the git status snapshot matches. | Parallel sessions in one repo are cheaper than they look. Still, each carries its own conversation. |
| Editing CLAUDE.md mid-session neither invalidates the cache nor applies. | CLAUDE.md edits take effect next session. |
| Removing old images reprocesses the conversation from that point. | Screenshots are expensive twice: once to send, once when they get evicted. |
| Idle sessions still spend: scheduled tasks, cross-session messages, goal check-ins each send the full context. | Close idle sessions. Do not broadcast messages to every running session. |
| Prompt suggestions send one extra request after every reply. | Turn them off in `/config`. |
| Extended thinking is output tokens, tens of thousands per turn at default. | Lower effort for simple tasks. |
| Hooks can pre-filter output before Claude sees it. CLI tools (`gh`, `xcodebuild | grep`) cost less than MCP servers. | rtk and the PreToolUse pattern are the official recommendation. |
| Code intelligence plugins (Swift, TypeScript, Python, Rust) give go-to-definition instead of grep. | Official alternative or complement to codegraph for Swift. |
| Move workflow instructions from CLAUDE.md into skills. | CLAUDE.md is paid for on every session; skills load on demand. |

## 10. Improvements we adopted from that

1. `pre_model_switch.sh` hook: blocks a mid-session model switch, tells you to use `/effort` or `/clear`.
2. Compact instructions block in CLAUDE.md so `/compact` keeps the brief, paths, decisions and next step only.
3. Rule: `/compact` at task boundaries while warm, never after a break.
4. Rule: close idle sessions, no broadcast messages between sessions.
5. Prompt suggestions off.
6. Sub-agents get short, self-contained briefs because their cache is 5 minutes.
7. Next: Swift code-intelligence plugin trial next to codegraph, and move the long CLAUDE.md sections into skills.

## Swift code-intelligence trial (2026-10-12, an Xcode-project Swift repo)
- Question: "who calls <a class used in 14+ files>". Codegraph: 0.8 s, 54 callers across 14+ files, plus test files and blast radius, about 25 KB (~6k tokens) of output.
- sourcekit-lsp (the swift-lsp plugin engine) via `textDocument/references`: 10 s, 0 references. The repo is an .xcodeproj with no Package.swift or buildServer.json, so it cannot see across files.
- LSP needs `xcode-build-server` to generate buildServer.json plus a fresh index in build/sim before it can compete. Not worth it for "who calls" today.
- Codegraph wins on speed, cross-file answers and tests. LSP would only add exact type-aware go-to-definition, which Xcode already gives you.
- Decision: keep codegraph as the structure tool. Cap its output with the codegraph_gate.sh hook so it fires only on real code-structure prompts.

## 11. Bulk tasks and big builds

- Route by ambiguity and risk, never by size. A large feature with a clear brief and a design system is Sonnet work. A 10-line change in a locked algorithm is Fable work.
- UI quality comes from the design system, a reference screenshot and a review pass, not from the model. Opus decides layout and flow once; Sonnet builds the screens.
- Flow for a dump of tasks: one Opus session writes the task list (interview-me or prompt-master), then `te route --batch tasks.md` labels every task with model and effort in one Jev call, grouped into batches.
- One batch = one fresh session with model and effort set once. High effort only for the first prompt of an ambiguous batch, then low. Nothing switches effort per task mid-session; there is no API for it and the gain is nil.
- Run batches sequentially: Haiku, Sonnet, then the one or two Fable items alone. Sub-agents only for verbose or parallel work inside a batch (tests, logs, independent screens).
- No Fable or Opus orchestrator spawning many sub-agents: the orchestrator idles at the most expensive rate, every sub-agent starts cold on a 5-minute cache, and failures are invisible to it.
- Keep a 3-column log (task, model, rework needed). After two weeks the data decides the ladder, not opinion.
