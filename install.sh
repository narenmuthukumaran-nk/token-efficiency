#!/usr/bin/env bash
# One-shot install of the token-efficiency toolchain on macOS / Linux. Re-runnable.
set -e
cfg="$HOME/.config/token-efficiency"; mkdir -p "$cfg"; chmod 700 "$cfg"
[ -f "$cfg/.env" ] || { printf 'JEV_API_KEY=\nCOMPOSIO_API_KEY=\nTE_WEEKLY_TOKEN_BUDGET=\n' > "$cfg/.env"; chmod 600 "$cfg/.env"; }
echo "[1/5] rtk (compressed command output)"
command -v rtk >/dev/null || { command -v brew >/dev/null && brew install rtk || curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; }
rtk init -g >/dev/null 2>&1 && echo "  rtk wired into Claude Code (global)" || echo "  run 'rtk init -g' manually"
echo "[2/5] codegraph (local code knowledge graph)"
command -v codegraph >/dev/null || curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
echo "  per project: run 'codegraph' once inside the repo"
echo "[3/5] caveman (terse replies skill)"
command -v npx >/dev/null && npx -y skills add JuliusBrussee/caveman -g || echo "  needs node: npm i -g @caveman-ai/cli && caveman setup --install"
mkdir -p ~/.claude/skills; for s in caveman caveman-compress caveman-commit; do [ -e ~/.claude/skills/$s ] || ln -s ~/.agents/skills/$s ~/.claude/skills/$s 2>/dev/null; done; echo "  caveman linked into ~/.claude/skills"
echo "[4/5] token-dashboard (local usage analytics)"
[ -d "$cfg/token-dashboard" ] && git -C "$cfg/token-dashboard" pull -q || git clone -q https://github.com/nateherkai/token-dashboard.git "$cfg/token-dashboard"
python3 "$cfg/token-dashboard/cli.py" scan >/dev/null 2>&1 && echo "  scanned local transcripts" || echo "  run: python3 $cfg/token-dashboard/cli.py scan"
mkdir -p ~/.claude/skills; for s in interview-me prompt-master; do ln -sfn "$(cd "$(dirname "$0")" && pwd)/skills/$s" ~/.claude/skills/$s; done; echo "  interview-me + prompt-master skills linked"
cp "$(cd "$(dirname "$0")" && pwd)/hooks/codegraph_gate.sh" "$cfg/codegraph_gate.sh"; echo "  codegraph gate copied (wire it in settings.json UserPromptSubmit)"
echo "[5/5] te command"
here="$(cd "$(dirname "$0")" && pwd)"; mkdir -p "$HOME/.local/bin"; ln -sf "$here/bin/te" "$HOME/.local/bin/te"
echo "  add to PATH if missing: export PATH=\"\$HOME/.local/bin:\$PATH\""
echo
echo "done. Next: 1) put keys in $cfg/.env  2) cd <project> && te init  3) te usage"
echo "Composio (optional, one bridge for Gmail/Notion/Calendar/...): app.composio.dev > MCP > copy the Claude Code command"
