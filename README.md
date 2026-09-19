# AllInOne-Claude

One install, full Claude Code skill stack. Checks and installs six dependencies, then runs them as one unified rules layer.

## The stack

| # | Dependency | Type | Source | Purpose |
|---|---|---|---|---|
| 1 | caveman | plugin | juliusbrussee/caveman | Terse output, ~65% token cut |
| 2 | ponytail | plugin | dietrichgebert/ponytail | Lazy minimal-solution ladder |
| 3 | superpowers | plugin | anthropics/claude-plugins-official | Process skills (brainstorming, TDD, debugging) |
| 4 | taste-skill | skills CLI | Leonxlnx/taste-skill | Design taste family (design-taste-frontend, gpt-taste, …) |
| 5 | graphify | skill + pip CLI | vendored + graphifyy | Codebase → knowledge graph, query-first context |
| 6 | obsidian-vault | MCP server | @modelcontextprotocol/server-filesystem | Vault notes read/write |

## Install

### Option A — Claude Code plugin (recommended)

```bash
claude plugin marketplace add <your-github>/AllInOne-Claude
claude plugin install allinone@allinone
```

Restart the session. The SessionStart hook checks dependencies automatically.

### Option B — skills CLI

```bash
npx skills add <your-github>/AllInOne-Claude -g -y
```

Note: option B installs the skill files only — no SessionStart hook. Run `/allinone check` manually.

## Usage

```
/allinone check     # status table of all six dependencies
/allinone install   # install missing ones via their CLIs (asks first)
/allinone status    # same as check
```

After install, the allinone skill becomes the always-on layer:

- **Part A (embedded rules)** — context priority (graphify-out → vault → codebase), obsidian logging, caveman terse core, ponytail ladder core, superpowers skill-check core.
- **Part B (dispatcher)** — routes tasks to the original skills: new feature → `superpowers:brainstorming`, bug → `superpowers:systematic-debugging`, frontend design → `design-taste-frontend`/`gpt-taste`, codebase questions → `graphify`, wrap-up → vault logging.

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

- **Plugin install fails** — check `claude plugin marketplace list` shows the marketplace; some marketplaces need manual `claude plugin marketplace add` first.
- **taste-skill fails** — needs Node/npm (`npx`). Verify with `npx -y skills find taste`.
- **graphify CLI fails** — needs Python 3.10+; try `pipx install graphifyy`. The skill file works without the CLI; only repo ingestion needs it.
- **obsidian MCP fails** — verify with `claude mcp list`; the vault path must exist (`mkdir -p` it first).
- **Hook doesn't fire** — hooks only run in plugin installs (Option A), not skills CLI installs (Option B).

## Development

```
.claude-plugin/plugin.json      # plugin metadata
.claude-plugin/marketplace.json # self-marketplace for `claude plugin marketplace add`
hooks/hooks.json                # SessionStart → check-deps.sh
hooks/check-deps.sh             # light check, no install, exit 1 if missing
hooks/install-deps.sh           # CLI installer for all six
skills/allinone/SKILL.md        # the skill: embedded rules + dispatcher
skills/allinone/references/deps.json  # machine-readable dependency table
skills/graphify/                # vendored graphify skill (copied to ~/.claude/skills on install)
commands/allinone.md            # /allinone slash command
```

## License

MIT
