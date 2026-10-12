# token-efficiency

Stop hitting the Claude weekly limit by Monday. A guide plus a two-command setup for any project.

- [TOKEN_EFFICIENCY.md](TOKEN_EFFICIENCY.md): why you run out, the model ladder, habits, the weekly budget.
- [JEV_USE_CASES.md](JEV_USE_CASES.md): where a small cheap model (Jev) takes the repeating jobs.

## Install (macOS / Linux), one command

```bash
curl -fsSL https://raw.githubusercontent.com/narenmuthukumaran-nk/token-efficiency/main/install.sh | bash
```

Already have several projects? This lists every git repo under the folder and asks before touching any (an empty `.te-skip` file in a repo excludes it; `te init-all --yes <dir>` skips the question):

```bash
curl -fsSL https://raw.githubusercontent.com/narenmuthukumaran-nk/token-efficiency/main/install.sh | bash -s -- --all ~/Developer
```

Or one project at a time: `cd <project> && te init`. Re-running is safe; it refreshes the hook files.
See your numbers: `te usage` (terminal) or `te dashboard` (local web page).

## What you get

| Piece | What it does |
|---|---|
| [rtk](https://github.com/rtk-ai/rtk) | Compresses git / build / test output 60 to 90% before it reaches the model |
| [codegraph](https://github.com/colbymchenry/codegraph) | Local code graph, auto-syncs; the model queries a node instead of grepping |
| [caveman](https://github.com/JuliusBrussee/caveman) | Terse replies, ~65% fewer output tokens |
| [token-dashboard](https://github.com/nateherkai/token-dashboard) | Local analytics on where your tokens go |
| `te init` | SessionStart hook (habit checklist + today's usage), UserPromptSubmit hook (warns on booster words, pasted docs), PreModelSwitch hook (blocks mid-session model switch, the cache killer), plus a token law and compact-instructions block in CLAUDE.md |
| `te mcp slim / full` | Park every local MCP server except a keep-list, restore any time |
| `te route "brief"` or `te route --batch tasks.md` | Jev (TypeSafe System One) picks model + effort for the task before you open the session, about 600 tokens, no Claude usage |
| `te usage` | Today and week-to-date tokens (week reset via `TE_WEEK_RESET`), percentage if `TE_WEEKLY_TOKEN_BUDGET` is set |

## Keys

All keys live in `~/.config/token-efficiency/.env` (mode 600). Nothing in this repo reads or commits them. A pre-commit hook blocks commits that look like they contain a secret: `git config core.hooksPath .githooks`.

## Toggle, never delete

`te mcp slim` writes a backup of your MCP config first; `te mcp full` restores it. claude.ai connectors (Gmail, Notion, Figma) are toggled in the desktop app under Connectors. Composio is optional: free Hobby plan, 100K tool calls a month, no card.

## License
MIT
