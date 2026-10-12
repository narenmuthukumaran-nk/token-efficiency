# Handoff: token-efficiency, next session

Open in: ~/Developer/token-efficiency. Model: Sonnet. Effort: medium for prompt 1, then low.
Read first: README.md, TOKEN_EFFICIENCY.md section 9 and 10, bin/te. Nothing else.

## Job
Finish the remaining build items of the token-efficiency plan. Keep NK's quality bar: every change small, tested, pushed to github narenmuthukumaran-nk/token-efficiency.

## Why
NK burned 50M tokens in 2 days from a Stop hook that spawned headless Claude runs. The hook is gone. The remaining items cut the fixed per-session cost and make the setup replicable in every repo.

## Tasks, in order, with done-means
1. CLAUDE.md diet for ~/Developer/timebank-production (31 KB, 398 lines).
   Done = CLAUDE.md under 8 KB holding only laws and pointers; the moved sections live as skills under .claude/skills/<name>/SKILL.md with a one-line description each; nothing deleted, only moved; NK sees a before/after list of section names. Do not change any law text.
2. `te init` in ~/Developer/ledger, ~/Developer/timebank-atlas, ~/Developer/timebank-website, ~/Developer/timebank-map.
   Done = hooks fire (check .claude/settings.json has SessionStart, UserPromptSubmit, PreModelSwitch), CLAUDE.md has the token law block, `te check` green.
3. `te init` must refresh existing copies. Today it skipped stale hook files.
   Done = running `te init` twice overwrites .te/hooks and .te/bin from the repo every time.
4. Two pre-planning skills in the repo, installed to ~/.claude/skills: `interview-me` (asks NK the unknowns of a task until job / why / guardrails / done-means are filled, then writes the brief to a file) and `prompt-master` (turns a voice dump into that same four-part brief).
   Done = both skills exist, each under 60 lines, tested once on a sample dump.
5. Token dashboard upgrade in bin/te-usage.py: per-model split, percent of TE_WEEKLY_TOKEN_BUDGET when set, and cache warm or cold from the latest session.
   Done = `te usage` prints one line per model plus the totals line.
6. Codegraph's "front-load on how/where/trace prompts" hook fires on non-code prompts (it matched the word "continue"). Find the hook in ~/.claude/settings.json and narrow it or turn it off.
   Done = a plain question in a Timebank session no longer injects codegraph context.
7. Swift code-intelligence trial: the swift-lsp plugin is installed. In one Timebank session compare one "who calls X" question via codegraph vs the LSP. Write the result as 5 lines in TOKEN_EFFICIENCY.md.

## Guardrails
- Never add a hook, cron, launchd job or scheduled task that calls `claude -p` or any model.
- No keys in the repo. Keys live in ~/.config/token-efficiency/.env only. The pre-commit hook must stay.
- Do not push any Timebank repo. Only the token-efficiency repo is pushed.
- Do not edit files another running session owns. If blocked, stop and say so.
- No algorithm or threshold changes anywhere, so the atlas skill is not triggered.
- Terse replies, lists, one plain-English line for technical terms.

## Waiting on NK, do not do these
- Memory trim list for ~/.claude/projects/-Users-nk-Developer/memory/MEMORY.md.
- Headroom: keep the proxy and MCP or remove fully.
- Desktop app plugin cleanup (deferred MCP count 481, target under 150).
- Connect Notion and Todoist in Composio before their connectors are turned off.
