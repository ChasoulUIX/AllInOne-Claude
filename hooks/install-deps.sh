#!/usr/bin/env bash
# AllInOne dependency installer — installs whatever is missing via each tool's CLI.
# Usage: install-deps.sh [--vault <obsidian-vault-path>] [--os <linux|windows|mac>] [--yes]
# Interactive on first run: banner + OS selection menu.

set -uo pipefail

VAULT_PATH=""
OS_CHOICE=""
ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --vault) VAULT_PATH="$2"; shift 2 ;;
    --os)    OS_CHOICE="$2"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
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

# --- Banner ------------------------------------------------------------------
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

# --- First-run check ---------------------------------------------------------
FIRST_RUN_MARKER="${CLAUDE_DIR}/.allinone-installed"

# --- OS selection ------------------------------------------------------------
select_os() {
  echo "  Select your OS:"
  echo
  printf '\033[1;32m  1)\033[0m Linux\n'
  printf '\033[1;32m  2)\033[0m Windows\n'
  printf '\033[1;31m  3)\033[0m Mac — \033[1;33mCOMING SOON\033[0m\n'
  echo
  while true; do
    read -r -p "  Choice [1-3]: " choice
    case "$choice" in
      1) OS_CHOICE="linux"; break ;;
      2) OS_CHOICE="windows"; break ;;
      3)
        printf '\033[1;33m%s\033[0m\n' "  Mac support is COMING SOON. Follow Instagram : chasoul.uix for updates."
        exit 0 ;;
      *) printf '  Invalid. Pick 1, 2, or 3.\n' ;;
    esac
  done
  echo
}

# --- OS-specific config ------------------------------------------------------
apply_os() {
  case "$OS_CHOICE" in
    linux)
      # follows ChasoulUIX's own setup
      VAULT_PATH="${VAULT_PATH:-${HOME}/MyProject/ChasoulUIX-BRAINSTROMING}"
      log "OS: Linux — vault at ${VAULT_PATH}"
      ;;
    windows)
      # Git Bash / WSL on Windows: vault on C:/ drive, not home
      VAULT_PATH="${VAULT_PATH:-C:/MyProject/ChasoulUIX-BRAINSTROMING}"
      log "OS: Windows — vault at ${VAULT_PATH}"
      ;;
    *)
      printf '\033[1;33m%s\033[0m\n' "  Mac support is COMING SOON. Follow Instagram : chasoul.uix for updates."
      exit 0 ;;
  esac
}

# --- Run ---------------------------------------------------------------------
banner

if [ -f "${FIRST_RUN_MARKER}" ] && [ "${ASSUME_YES}" -eq 0 ]; then
  log "Not first run — skipping OS selection. (Delete ${FIRST_RUN_MARKER} to redo.)"
  OS_CHOICE="${OS_CHOICE:-linux}"
else
  if [ -z "${OS_CHOICE}" ] && [ "${ASSUME_YES}" -eq 0 ]; then
    select_os
  elif [ -z "${OS_CHOICE}" ]; then
    OS_CHOICE="linux" # non-interactive default
  fi
fi

apply_os

if [ "${ASSUME_YES}" -eq 0 ]; then
  read -r -p "  Proceed with install? [y/N]: " confirm
  case "$confirm" in
    [yY]|[yY][eE][sS]) ;;
    *) log "Aborted."; exit 1 ;;
  esac
  echo
fi

# --- Dependency checks -------------------------------------------------------
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
  mkdir -p "${CLAUDE_DIR}/skills/graphify/references"
  if [ -f "${SCRIPT_DIR}/../skills/graphify/SKILL.md" ]; then
    cp "${SCRIPT_DIR}/../skills/graphify/SKILL.md" "${CLAUDE_DIR}/skills/graphify/SKILL.md"
    cp -r "${SCRIPT_DIR}/../skills/graphify/references/." "${CLAUDE_DIR}/skills/graphify/references/" 2>/dev/null
  else
    npx -y skills add Leonxlnx/graphify -g -y 2>/dev/null # fallback attempt
  fi
  pip install --user graphifyy >/dev/null 2>&1 || pipx install graphifyy >/dev/null 2>&1
  have_skill graphify && ok "graphify installed" || fail "graphify"
fi

if have_obsidian; then ok "obsidian-vault MCP already configured"; else
  log "Configuring obsidian-vault MCP (filesystem → ${VAULT_PATH})…"
  mkdir -p "${VAULT_PATH}"
  claude mcp add obsidian-vault -s user -- npx -y @modelcontextprotocol/server-filesystem "${VAULT_PATH}" >/dev/null 2>&1 \
    && ok "obsidian-vault MCP added (vault: ${VAULT_PATH})" || fail "obsidian"
fi

# --- CLAUDE.md rules injection ------------------------------------------------
# Tambahkan aturan AllInOne ke ~/.claude/CLAUDE.md user (append, tidak menimpa).
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
RULES_TEMPLATE="${SCRIPT_DIR}/../templates/CLAUDE.md.template"

inject_claude_md() {
  # windows path: C:/... → tampil apa adanya; linux/mac biarkan
  local vault_display="${VAULT_PATH/#$HOME/~}"
  if [ ! -f "${RULES_TEMPLATE}" ]; then
    return 1
  fi
  # skip jika sudah pernah diinject
  if [ -f "${CLAUDE_MD}" ] && grep -q "ATURAN PRIORITAS UTAMA" "${CLAUDE_MD}" 2>/dev/null; then
    ok "CLAUDE.md rules sudah ada (skip)"
    return 0
  fi
  sed "s|{{VAULT_PATH}}|${vault_display}|g" "${RULES_TEMPLATE}" >> "${CLAUDE_MD}"
  ok "CLAUDE.md rules ditambahkan (vault: ${vault_display})"
}

if [ -f "${CLAUDE_MD}" ] || mkdir -p "${CLAUDE_DIR}" 2>/dev/null; then
  inject_claude_md || fail "claude-md"
else
  fail "claude-md"
fi

# --- Summary -----------------------------------------------------------------
echo
if [ "${#FAILED[@]}" -eq 0 ]; then
  log "All dependencies installed."
  log "Restart Claude Code session to activate plugins & MCP."
  printf '\033[1;33m%s\033[0m\n' "  Thanks for using AllInOne — Follow Instagram : chasoul.uix"
  date +%s > "${FIRST_RUN_MARKER}"
  exit 0
else
  log "Failed: ${FAILED[*]}"
  log "Fix manually — see README.md troubleshooting section."
  exit 1
fi
