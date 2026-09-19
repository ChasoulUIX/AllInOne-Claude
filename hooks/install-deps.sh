#!/usr/bin/env bash
# AllInOne installer — vendored stack. caveman/ponytail/superpowers/taste-skill/graphify
# ship inside this repo as plugins; only obsidian MCP + graphify CLI need external setup.
# Usage: install-deps.sh [--vault <obsidian-vault-path>] [--os <linux|windows|mac>] [--yes]

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

CLAUDE_DIR="${HOME}/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
      VAULT_PATH="${VAULT_PATH:-${HOME}/MyProject/ChasoulUIX-BRAINSTROMING}"
      log "OS: Linux — vault at ${VAULT_PATH}"
      ;;
    windows)
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

# --- Tier 1: vendored plugins — install all six from this repo's marketplace ----
log "Tier 1 — vendored plugins (caveman, ponytail, superpowers, taste-skill, graphify)"

PLUGIN_ROOT_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

# register self-marketplace if missing
if ! grep -q '"allinone"' "${HOME}/.claude/plugins/known_marketplaces.json" 2>/dev/null \
   && ! claude plugin marketplace list 2>/dev/null | grep -q "allinone"; then
  log "Registering marketplace allinone…"
  claude plugin marketplace add "${PLUGIN_ROOT_DIR}" >/dev/null 2>&1 || true
fi

for p in caveman ponytail superpowers taste-skill graphify; do
  if grep -q "\"${p}@allinone\"" "${CLAUDE_DIR}/plugins/installed_plugins.json" 2>/dev/null; then
    ok "${p} already installed"
  else
    log "Installing ${p}@allinone…"
    if claude plugin install "${p}@allinone" -y >/dev/null 2>&1; then
      ok "${p} installed"
    else
      fail "${p}"
    fi
  fi
done

# --- Tier 2: external deps — graphify CLI + obsidian MCP ----------------------
log "Tier 2 — external deps (graphify CLI, obsidian-vault MCP)"

# graphify CLI (pip package graphifyy)
if command -v graphify >/dev/null 2>&1; then
  ok "graphify CLI already installed ($(graphify --version 2>/dev/null || echo 'version unknown'))"
else
  log "Installing graphify CLI (pip package graphifyy)…"
  if pip install --user graphifyy >/dev/null 2>&1 || pipx install graphifyy >/dev/null 2>&1 || pip install graphifyy >/dev/null 2>&1; then
    ok "graphify CLI installed"
  else
    fail "graphify CLI — try: pip install --user graphifyy"
  fi
fi

# obsidian-vault MCP
if grep -q "obsidian" "${HOME}/.claude.json" 2>/dev/null || grep -q "obsidian" "${CLAUDE_DIR}/.mcp.json" 2>/dev/null; then
  ok "obsidian-vault MCP already configured"
else
  log "Configuring obsidian-vault MCP (filesystem → ${VAULT_PATH})…"
  mkdir -p "${VAULT_PATH}"
  if claude mcp add obsidian-vault -s user -- npx -y @modelcontextprotocol/server-filesystem "${VAULT_PATH}" >/dev/null 2>&1; then
    ok "obsidian-vault MCP added (vault: ${VAULT_PATH})"
  else
    fail "obsidian MCP"
  fi
fi

# --- CLAUDE.md rules injection ------------------------------------------------
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
RULES_TEMPLATE="${SCRIPT_DIR}/../templates/CLAUDE.md.template"

inject_claude_md() {
  local vault_display="${VAULT_PATH/#$HOME/~}"
  if [ ! -f "${RULES_TEMPLATE}" ]; then
    return 1
  fi
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
