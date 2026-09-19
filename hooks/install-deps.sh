#!/usr/bin/env bash
# AllInOne dependency installer — installs whatever is missing via each tool's CLI.
# Usage: install-deps.sh [--vault <obsidian-vault-path>]
# Default vault: ~/MyProject/ChasoulUIX-BRAINSTROMING

set -uo pipefail

VAULT_PATH="${HOME}/MyProject/ChasoulUIX-BRAINSTROMING"
while [ $# -gt 0 ]; do
  case "$1" in
    --vault) VAULT_PATH="$2"; shift 2 ;;
    *) shift ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
PLUGINS_JSON="${CLAUDE_DIR}/plugins/installed_plugins.json"
SKILL_LOCK="${HOME}/.agents/.skill-lock.json"
INSTALLED=()
FAILED=()

log()  { printf '\033[1;34m[AllInOne]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m  ✗\033[0m %s\n' "$*"; FAILED+=("$1"); }

have_plugin() { grep -q "\"${1}@" "${PLUGINS_JSON}" 2>/dev/null; }
have_skill()  { [ -f "${CLAUDE_DIR}/skills/${1}/SKILL.md" ] || [ -L "${CLAUDE_DIR}/skills/${1}" ]; }
have_taste()  { [ -f "${SKILL_LOCK}" ] && grep -q "Leonxlnx/taste-skill" "${SKILL_LOCK}" 2>/dev/null; }
have_obsidian() { grep -q "obsidian" "${HOME}/.claude.json" 2>/dev/null || grep -q "obsidian" "${CLAUDE_DIR}/.mcp.json" 2>/dev/null; }

# --- Tier 1: plugins ---------------------------------------------------------
log "Tier 1 — mode & process plugins"

if have_plugin caveman; then ok "caveman already installed"; else
  log "Installing caveman (juliusbrussee/caveman)…"
  claude plugin marketplace add juliusbrussee/caveman >/dev/null 2>&1
  claude plugin install caveman@caveman >/dev/null 2>&1 && ok "caveman installed" || fail "caveman"
fi

if have_plugin ponytail; then ok "ponytail already installed"; else
  log "Installing ponytail (dietrichgebert/ponytail)…"
  claude plugin marketplace add dietrichgebert/ponytail >/dev/null 2>&1
  claude plugin install ponytail@ponytail >/dev/null 2>&1 && ok "ponytail installed" || fail "ponytail"
fi

if have_plugin superpowers; then ok "superpowers already installed"; else
  log "Installing superpowers (anthropics/claude-plugins-official)…"
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1
  claude plugin install superpowers@claude-plugins-official >/dev/null 2>&1 && ok "superpowers installed" || fail "superpowers"
fi

# --- Tier 2: skills & MCP ----------------------------------------------------
log "Tier 2 — knowledge, design, graph, vault"

if have_taste; then ok "taste-skill already installed"; else
  log "Installing taste-skill (Leonxlnx/taste-skill) via npx skills…"
  npx -y skills add Leonxlnx/taste-skill -g -y >/dev/null 2>&1 && ok "taste-skill installed" || fail "taste-skill"
fi

if have_skill graphify; then ok "graphify skill already installed"; else
  log "Installing graphify…"
  # skill file
  mkdir -p "${CLAUDE_DIR}/skills/graphify/references"
  if [ -f "${SCRIPT_DIR}/../skills/graphify/SKILL.md" ]; then
    cp "${SCRIPT_DIR}/../skills/graphify/SKILL.md" "${CLAUDE_DIR}/skills/graphify/SKILL.md"
    cp -r "${SCRIPT_DIR}/../skills/graphify/references/." "${CLAUDE_DIR}/skills/graphify/references/" 2>/dev/null
  else
    npx -y skills add Leonxlnx/graphify -g -y 2>/dev/null # fallback attempt
  fi
  # CLI engine (pip package name: graphifyy)
  pip install --user graphifyy >/dev/null 2>&1 || pipx install graphifyy >/dev/null 2>&1
  have_skill graphify && ok "graphify installed" || fail "graphify"
fi

if have_obsidian; then ok "obsidian-vault MCP already configured"; else
  log "Configuring obsidian-vault MCP (filesystem → ${VAULT_PATH})…"
  mkdir -p "${VAULT_PATH}"
  claude mcp add obsidian-vault -s user -- npx -y @modelcontextprotocol/server-filesystem "${VAULT_PATH}" >/dev/null 2>&1 \
    && ok "obsidian-vault MCP added (vault: ${VAULT_PATH})" || fail "obsidian"
fi

# --- Summary -----------------------------------------------------------------
echo
if [ "${#FAILED[@]}" -eq 0 ]; then
  log "All dependencies installed."
  log "Restart Claude Code session to activate plugins & MCP."
  exit 0
else
  log "Failed: ${FAILED[*]}"
  log "Fix manually — see README.md troubleshooting section."
  exit 1
fi
