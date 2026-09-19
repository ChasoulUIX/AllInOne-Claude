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

# --- Tier 1: mode/process plugins -------------------------------------------
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
