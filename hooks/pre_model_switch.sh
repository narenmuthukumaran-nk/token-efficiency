#!/usr/bin/env bash
# PreModelSwitch hook: a model switch mid-session throws away the whole prompt cache.
# Blocks the switch unless ~/.config/token-efficiency/allow-switch exists (touch it to allow once).
flag="$HOME/.config/token-efficiency/allow-switch"
if [ -f "$flag" ]; then rm -f "$flag"; exit 0; fi
to=$(jq -r '.to_model // "?"' 2>/dev/null)
echo "token-efficiency: switching to $to restarts the cache (every model has its own). Use /effort for cheaper turns, or /clear and start a new session on $to. To force this once: touch $flag" >&2
exit 2
