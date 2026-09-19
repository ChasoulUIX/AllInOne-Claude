# AllInOne-Claude

One install, full Claude Code skill stack. Five plugins vendored in this repo install together from its own marketplace; only graphify CLI and the obsidian MCP bootstrap from outside.

## The stack

| # | Dependency | Type | Lives | Purpose |
|---|---|---|---|---|
| 1 | caveman | vendored plugin | `plugins/caveman` (from juliusbrussee/caveman, MIT) | Terse output, ~65% token cut |
| 2 | ponytail | vendored plugin | `plugins/ponytail` (from dietrichgebert/ponytail, MIT) | Lazy minimal-solution ladder |
| 3 | superpowers | vendored plugin | `plugins/superpowers` (from obra/superpowers, MIT) | Process skills (brainstorming, TDD, debugging) |
| 4 | taste-skill | vendored plugin | `plugins/taste-skill` (from Leonxlnx/taste-skill, MIT) | Design taste family |
| 5 | graphify | vendored plugin + pip CLI | `plugins/graphify` + `pip install graphifyy` | Codebase → knowledge graph |
| 6 | obsidian-vault | MCP server | `claude mcp add` (filesystem server) | Vault notes read/write |

Vendored = the code ships in this repo, so `/allinone install` never downloads from third-party repos. caveman's BSL-licensed engine dirs are excluded — only its MIT surfaces (skills, hooks, commands, agents) are vendored.

## Install

### Option A — Claude Code plugin marketplace (recommended)

```bash
claude plugin marketplace add ChasoulUIX/AllInOne-Claude
claude plugin install allinone@allinone
```

Then run `/allinone install` once inside Claude Code to:

1. install the five vendored plugins from this repo's marketplace,
2. `pip install graphifyy` for the graphify CLI,
3. `claude mcp add obsidian-vault` pointing at your vault,
4. inject the rules into `~/.claude/CLAUDE.md` (idempotent).

### Option B — skills CLI

```bash
npx skills add ChasoulUIX/AllInOne-Claude -g -y
```

Note: option B installs skill files only — no SessionStart hook, no vendored plugins. Not recommended; use Option A.

## Usage

```
/allinone check     # status table: vendored plugins + graphify CLI + obsidian MCP
/allinone install   # install what's missing (asks first)
/allinone status    # same as check
```

After install, the allinone skill becomes the always-on layer:

- **Part A (embedded rules)** — context priority (graphify-out → vault → codebase), obsidian logging, caveman terse core, ponytail ladder core, superpowers skill-check core.
- **Part B (dispatcher)** — routes tasks to the installed skills: new feature → `superpowers:brainstorming`, bug → `superpowers:systematic-debugging`, frontend design → `design-taste-frontend`/`gpt-taste`, codebase questions → `graphify`, wrap-up → vault logging.

## Obsidian vault

The obsidian-vault MCP points at a filesystem root. Default assumed by the installer:

```
~/MyProject/ChasoulUIX-BRAINSTROMING
```

Override at install time:

```bash
bash hooks/install-deps.sh --vault /your/vault/path
```

Each project keeps notes under `<vault>/<project-name>/`, Markdown with YAML frontmatter (`title`, `date`, `tags`, `status`, `project`) and wikilinks.

## Troubleshooting

- **Vendored plugin install fails** — run `claude plugin marketplace list` and confirm `allinone` shows; if not, `claude plugin marketplace add ChasoulUIX/AllInOne-Claude` manually, then retry `/allinone install`.
- **graphify CLI fails** — needs Python 3.10+; try `pipx install graphifyy`. The skill layer works without the CLI; only repo ingestion needs it.
- **obsidian MCP fails** — verify with `claude mcp list`; the vault path must exist (`mkdir -p` it first).
- **Hook doesn't fire** — hooks only run in plugin installs (Option A).

## Development

```
.claude-plugin/plugin.json      # allinone plugin metadata
.claude-plugin/marketplace.json # multi-plugin marketplace: allinone + 5 vendored plugins
hooks/hooks.json                # SessionStart → check-deps.sh
hooks/check-deps.sh             # light check, no install, exit 1 if missing
hooks/install-deps.sh           # installs vendored plugins + graphify CLI + obsidian MCP
skills/allinone/SKILL.md        # the skill: embedded rules + dispatcher
skills/allinone/references/deps.json  # machine-readable dependency table
skills/graphify/                # graphify skill source (also vendored at plugins/graphify)
plugins/caveman/                # vendored caveman (MIT surfaces only)
plugins/ponytail/               # vendored ponytail
plugins/superpowers/            # vendored superpowers
plugins/taste-skill/            # vendored taste-skill
plugins/graphify/               # vendored graphify skill as plugin
commands/allinone.md            # /allinone slash command
templates/CLAUDE.md.template    # rules injected into ~/.claude/CLAUDE.md
```

Vendoring updates: re-copy from upstream repos (MIT dirs only), keep each plugin's own `LICENSE`, and bump `plugins/<name>/.claude-plugin/plugin.json` versions.

## License

MIT. Vendored plugins keep their upstream licenses: caveman (MIT + BSL split — MIT surfaces vendored), ponytail (MIT), superpowers (MIT), taste-skill (MIT).
