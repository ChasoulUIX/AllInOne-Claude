---
name: allinone
description: "Meta-skill that checks, installs, and orchestrates the full Claude Code skill stack: caveman (terse mode), ponytail (lazy ladder), superpowers (process), taste-skill (design), graphify (knowledge graph), obsidian-vault (notes). Use when the user says 'allinone', asks to check or install the skill stack, or at the start of any session where the embedded rules below apply."
---

# AllInOne

One skill stack. Two jobs:

1. **Bootstrap** — check and install the dependency skills via CLI (`/allinone check|install`).
2. **Run** — act as the always-on rules layer + dispatcher to the other skills.

## Bootstrap commands

Setiap kali menjalankan `/allinone`, `/allinone check`, `/allinone install`, atau `/allinone status`, WAJIB tampilkan ASCII banner berikut di awal respon:

```text
  ____ _   _    _    ____ ___ ____ _____ ____      ____  _   _   _  ____  _  ___ ___  _   _ _   _ 
 / ___| | | |  / \  / ___|_ _/ ___|_   _|  _ \    | __ )| |/ / | || |/ /, )| |/ _ \_ _| \ | | \ | |
| |   | |_| | / _ \| |  _ | |\___ \ | | | |_) |   |  _ \| ' /| || | ' / | | | | | || |  \| |  \| |
| |___|  _  |/ ___ \ |_| || | ___) || | |  _ <    | |_) | . \| || | . \ | | |_| | || | |\  | |\  |
 \____|_| |_/_/   \_\____|___|____/ |_| |_| \_\___|____/|_|\_\|_||_|_|\_\|___\___/ |_||_|_| \_|
                                              |_____|                                             

  C H A S O U L U I X   B R A I N S T R O M I N G
  A L L   I N   O N E   S K I L L   C L A U D E

  Follow Instagram : chasoul.uix
```

| Command | What it does |
|---|---|
| `/allinone check` | Run `hooks/check-deps.sh`, report status table |
| `/allinone install` | Run `hooks/install-deps.sh [--vault <path>]`, install missing via CLI |
| `/allinone status` | Same as check, plus versions where cheap to get |

Installation order (user's spec): caveman → ponytail → superpowers → taste-skill → graphify → obsidian.

---

## Part A — Embedded always-on rules

These rules run whenever AllInOne is active. They are the *core* of each dependency skill, embedded so behavior holds even before the originals load. When the original plugin is installed, its full rules win on conflict.

### A1. Context retrieval priority (graphify + obsidian)

For every new task, follow this order strictly:

1. **Prioritas 1 — Knowledge Graph (`graphify-out/`)**: check `graphify-out/` in the project for file relations, architecture, summaries. If it exists, treat questions about the codebase as graphify queries first.
2. **Prioritas 2 — Obsidian Vault** (`<vault>/<project-name>/`): read notes, backlog, issues, context stored for this project.
3. **Prioritas 3 — Codebase**: scan/read files only if info not found in 1 & 2.

### A2. Obsidian vault logging

- Save documentation, notes, brainstorming, analysis to the project's vault folder (absolute path), never inside the codebase root.
- Format: Markdown with YAML frontmatter (`title`, `date`, `tags`, `status`, `project`).
- Use wikilinks `[[note-name]]`.
- Create subfolders automatically when missing.
- Log after completing significant implementation or changes.

### A3. Caveman core — terse output

- Drop articles, filler, pleasantries, hedging. Fragments OK.
- Keep ALL technical substance: exact numbers, units, errors, terms.
- Never drop not/never/no/only — meaning beats brevity.
- Preserve the user's language exactly; compress style, not language.
- Full rules: caveman plugin. Off: "stop caveman".

### A4. Ponytail core — lazy ladder

Stop at the first rung that holds:

1. Does this need to exist? (YAGNI)
2. Already in this codebase? Reuse.
3. Stdlib does it?
4. Native platform feature?
5. Installed dependency solves it?
6. One line?
7. Only then: minimum code that works.

Read the problem fully first, THEN climb. Bug fix = root cause, grep every caller. Full rules: ponytail plugin. Off: "stop ponytail".

### A5. Superpowers core — invoke skills first

If a skill might apply (even 1% chance), invoke it before responding. Process skills before implementation skills. Full rules: superpowers plugin.

---

## Part B — Dispatcher

When a task is contextual, dispatch to the ORIGINAL installed skill via the Skill tool:

| Trigger | Invoke |
|---|---|
| New feature / creative work / "let's build X" | `superpowers:brainstorming` |
| Bug, test failure, unexpected behavior | `superpowers:systematic-debugging` |
| Writing implementation plan | `superpowers:writing-plans` |
| TDD work | `superpowers:test-driven-development` |
| Landing page, portfolio, frontend redesign | `design-taste-frontend` |
| GSAP motion / animation-heavy UI | `gpt-taste` |
| Premium visual direction / brand boards | `high-end-visual-design` |
| "How is this codebase structured", file relations, graphify-out exists | `graphify` |
| Code review request | `code-review` or `superpowers:requesting-code-review` |
| Session about to end / wrap-up | obsidian vault logging (A2), `session-report` if installed |

Priority: skills from plugins take precedence over user-level skills with the same name when both apply — plugins are versioned and maintained.

If a dispatched skill is missing (dependency check failed), say so, suggest `/allinone install`, and fall back to Part A embedded rules.

---

## Part C — Integration notes

- Vault path resolution: check `obsidian-vault` MCP server's allowed directory; if no MCP, ask the user for the vault root once per session.
- AllInOne does not auto-install anything without the user running `/allinone install`. Hooks only check.
- Attribution for commits made under AllInOne sessions follows the host session's rules.
