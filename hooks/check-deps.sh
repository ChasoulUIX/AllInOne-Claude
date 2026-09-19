#!/usr/bin/env bash
# AllInOne dependency checker — light check, no install.
# Usage: check-deps.sh [--quiet]
# Exit 0 = all present, exit 1 = something missing.

QUIET="${1:-}"

CLAUDE_DIR="${HOME}/.claude"
PLUGINS_JSON="${CLAUDE_DIR}/plugins/installed_plugins.json"
SKILL_LOCK="${HOME}/.agents/.skill-lock.json"

missing=()

# check_plugin <name> — installed AND enabled in settings
check_plugin() {
  local name="$1"
  grep -q "\"${name}@" "${PLUGINS_JSON}" 2>/dev/null && \
    grep -Eq "\"${name}@[^\"]+\": *true" "${CLAUDE_DIR}/settings.json" 2>/dev/null
}

# check_skill <skill-dir-name> — user-level skill present
check_skill() {
  [ -f "${CLAUDE_DIR}/skills/${1}/SKILL.md" ] || [ -L "${CLAUDE_DIR}/skills/${1}" ]
}

banner() {
  printf '\033[1;35m%s\033[0m\n' "  ____ _   _    _    ____ ___ ____ _____ ____      ____  _   _   _  ____  _  ___ ___  _   _ _   _ "
  printf '\033[1;35m%s\033[0m\n' " / ___| | | |  / \  / ___|_ _/ ___|_   _|  _ \    | __ )| |/ / | || |/ /, )| |/ _ \_ _| \ | | \ | |"
  printf '\033[1;35m%s\033[0m\n' "| |   | |_| | / _ \| |  _ | |\___ \ | | | |_) |   |  _ \| ' /| || | ' / | | | | | || |  \| |  \| |"
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

[ -n "$QUIET" ] || banner
check_plugin caveman      || missing+=("caveman")
check_plugin ponytail     || missing+=("ponytail")
check_plugin superpowers  || missing+=("superpowers")

# --- Tier 2: knowledge & design ---------------------------------------------
# taste-skill family: any skill sourced from Leonxlnx/taste-skill in the skills lock
if [ -f "${SKILL_LOCK}" ] && grep -q "Leonxlnx/taste-skill" "${SKILL_LOCK}" 2>/dev/null; then
  : # installed via npx skills
elif check_skill design-taste-frontend || check_skill gpt-taste || check_skill high-end-visual-design; then
  : # at least one taste skill present
else
  missing+=("taste-skill")
fi

# graphify: skill present (CLI optional at check time, install fixes it)
if ! check_skill graphify; then
  missing+=("graphify")
fi

# obsidian: MCP server registered (local config or managed)
if ! grep -q "obsidian" "${HOME}/.claude.json" 2>/dev/null && ! grep -rq "obsidian" "${CLAUDE_DIR}/.mcp.json" 2>/dev/null; then
  missing+=("obsidian")
fi

# --- Output ------------------------------------------------------------------
if [ "${#missing[@]}" -eq 0 ]; then
  [ -n "$QUIET" ] || echo "AllInOne: all dependencies installed."
  exit 0
else
  if [ -z "$QUIET" ]; then
    echo "AllInOne: missing dependencies: ${missing[*]}"
    echo "Run /allinone install (or hooks/install-deps.sh) to fix."
  fi
  # hook-friendly JSON systemMessage
  printf '{"systemMessage":"[AllInOne] Missing: %s. Run /allinone install to fix."}\n' "${missing[*]}"
  exit 1
fi
