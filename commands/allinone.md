---
description: Check, install, or report status of the AllInOne skill stack
argument-hint: "[check|install|status] [--vault <path>]"
---

# /allinone

Handle the AllInOne skill stack bootstrap.

Use `$ARGUMENTS` to decide (default: `check`):

## `check` / `status`

Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/check-deps.sh"
```

Present the result as a table:

| Dependency | Type | Status |
|---|---|---|
| caveman | vendored plugin | ✓ / ✗ |
| ponytail | vendored plugin | ✓ / ✗ |
| superpowers | vendored plugin | ✓ / ✗ |
| taste-skill | vendored plugin | ✓ / ✗ |
| graphify skill | vendored plugin | ✓ / ✗ |
| graphify CLI | pip (graphifyy) | ✓ / ✗ |
| obsidian | MCP | ✓ / ✗ |

If anything is missing, tell the user to run `/allinone install` (ask first — never install without consent).

## `install`

Confirm with the user, then run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/install-deps.sh" [--vault <path>]
```

- caveman/ponytail/superpowers/taste-skill/graphify install from this repo's own marketplace (vendored, no third-party download).
- graphify CLI installs via `pip install --user graphifyy`.
- Obsidian MCP registers via `claude mcp add obsidian-vault`.
- Default vault is `~/MyProject/ChasoulUIX-BRAINSTROMING`; ask the user for their vault path if they haven't given one.
- After install: tell the user to restart the Claude Code session so plugins and MCP activate.
- If any install step failed, show the failed list and point to README troubleshooting.

## Both

After any run, remind: once all dependencies are green, Part A rules of the allinone skill are in effect and Part B dispatches to the installed skills.
