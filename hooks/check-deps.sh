#!/usr/bin/env bash
# AllInOne dependency checker — vendored stack.
# caveman/ponytail/superpowers/taste-skill/graphify-skill ship as plugins in this repo;
# only graphify CLI and obsidian MCP live outside. Light check, no install.
# Usage: check-deps.sh [--quiet]
# Exit 0 = all present, exit 1 = something missing.

QUIET="${1:-}"

CLAUDE_DIR="${HOME}/.claude"

missing=()

banner() {
  printf '\033[1;35m%s\033[0m\n' "  ____ _   _    _    ____ ___ ____ _____ ____      ____  _   _   _  ____  _  ___ ___  _   _ _   _ "
  printf '\033[1;35m%s\033[0m\n' " / ___| | | |  / \  / ___|_ _/ ___|_   _|  _ \    | __ )| |/ / | || |/ /, )| |/ _ \_ _| \ | | \ | |"
  printf '\033[1;35m%s\033[0m\n' "| |   | |_| | / _ \| |  _ | |\___ \ | | | |_) |   |  _ \| ' / | || | ' / | | | | | || |  \| |  \| |"
  printf '\033[1;35m%s\033[0m\n' "| |___|  _  |/ ___ \ |_| || | ___) || | |  _ <    | |_) | . \| || | . \ | | |_| | || | |\  | |\  |"
  printf '\033[1;35m%s\033[0m\n' " \____|_| |_/_/   \_\____|___|____/ |_| |_| \_\___|____/|_|\_\|_||_|_|\_\|___\___/ |_||_|_| \_|"
  printf '\033[1;35m%s\033[0m\n' "                                              |_____|                                             "
  echo
  printf '\033[1;33m%s\033[0m\n' "  C H A S O U L U I X   B R A I N S T R O M I N G"
  printf '\033[1;36m%s\033[0m\n' "  A L L   I N   O N E   S K I L L   C L A U D E"
  echo
  printf '\033[0;37m%s\033[0m\n' "  Follow Instagram : chasoul.uix"
  echo
}

# --- Vendored plugins: installed = the 5 plugins from this repo's marketplace ---
check_allinone_plugin() {
  local json="${CLAUDE_DIR}/plugins/installed_plugins.json"
  for p in caveman ponytail superpowers taste-skill graphify; do
    grep -q "\"${p}@allinone\"" "$json" 2>/dev/null || return 1
  done
}

# --- External deps -------------------------------------------------------------
check_graphify_cli() { command -v graphify >/dev/null 2>&1; }
check_obsidian()     { grep -q "obsidian" "${HOME}/.claude.json" 2>/dev/null || grep -q "obsidian" "${CLAUDE_DIR}/.mcp.json" 2>/dev/null; }

[ -n "$QUIET" ] || banner

if check_allinone_plugin; then
  [ -z "$QUIET" ] && echo "vendored plugins (caveman, ponytail, superpowers, taste-skill, graphify): OK" || true
else
  missing+=("vendored plugins (caveman, ponytail, superpowers, taste-skill, graphify — /allinone install)")
fi

check_graphify_cli || missing+=("graphify CLI")
check_obsidian     || missing+=("obsidian MCP")

# --- Output ------------------------------------------------------------------
if [ "${#missing[@]}" -eq 0 ]; then
  [ -n "$QUIET" ] || echo "AllInOne: all dependencies installed."
  exit 0
else
  if [ -z "$QUIET" ]; then
    echo "AllInOne: missing: ${missing[*]}"
    echo "Run /allinone install (or hooks/install-deps.sh) to fix."
  fi
  printf '{"systemMessage":"[AllInOne] Missing: %s. Run /allinone install to fix."}\n' "${missing[*]}"
  exit 1
fi
