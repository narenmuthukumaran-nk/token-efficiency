# token-efficiency

Stop hitting the Claude weekly limit by Monday. A guide plus a two-command setup for any project.

- [TOKEN_EFFICIENCY.md](TOKEN_EFFICIENCY.md): why you run out, the model ladder, habits, the weekly budget.
- [JEV_USE_CASES.md](JEV_USE_CASES.md): where a small cheap model (Jev) takes the repeating jobs.

## Install (macOS / Linux)

```bash
git clone https://github.com/narenmuthukumaran-nk/token-efficiency.git ~/token-efficiency
~/token-efficiency/install.sh
```

Then in any project:

```bash
te init
```

## What you get

| Piece | What it does |
|---|---|
| [rtk](https://github.com/rtk-ai/rtk) | Compresses git / build / test output 60 to 90% before it reaches the model |
| [codegraph](https://github.com/colbymchenry/codegraph) | Local code graph, auto-syncs; the model queries a node instead of grepping |
| [caveman](https://github.com/JuliusBrussee/caveman) | Terse replies, ~65% fewer output tokens |
| [token-dashboard](https://github.com/nateherkai/token-dashboard) | Local analytics on where your tokens go |
| `te init` | SessionStart hook (habit checklist + today's usage) and UserPromptSubmit hook (warns on booster words, pasted docs, mid-task model switch), plus a token law block in CLAUDE.md |
| `te mcp slim / full` | Park every local MCP server except a keep-list, restore any time |
| `te usage` | Today and week-to-date tokens, percentage if `TE_WEEKLY_TOKEN_BUDGET` is set |

## Keys

All keys live in `~/.config/token-efficiency/.env` (mode 600). Nothing in this repo reads or commits them. A pre-commit hook blocks commits that look like they contain a secret: `git config core.hooksPath .githooks`.

## Toggle, never delete

`te mcp slim` writes a backup of your MCP config first; `te mcp full` restores it. claude.ai connectors (Gmail, Notion, Figma) are toggled in the desktop app under Connectors. Composio is optional: free Hobby plan, 100K tool calls a month, no card.

## License
MIT
