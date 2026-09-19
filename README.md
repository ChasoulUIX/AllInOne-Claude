# AllInOne-Claude

<p>
  <b>C H A S O U L U I X&nbsp;&nbsp;B R A I N S T R O M I N G</b><br>
  <b>A L L&nbsp;&nbsp;I N&nbsp;&nbsp;O N E&nbsp;&nbsp;S K I L L&nbsp;&nbsp;C L A U D E</b>
</p>

> One install. Full Claude Code skill stack. 5 plugins vendored in this repo — **no third-party downloads**, no version drift, no broken upstream. Only 2 things bootstrap from outside: graphify CLI (pip) and obsidian-vault MCP.

**Follow Instagram : chasoul.uix**

---

## Why AllInOne-Claude?

Install sekali, dapat seluruh stack. Bukan sekadar bundler — repo ini **menyimpan copy resmi (vendored) dari tiap plugin**, jadi:

| Kelebihan | Penjelasan |
|---|---|
| 🚀 **Satu perintah, semua terpasang** | `claude plugin install allinone@allinone` + `/allinone install`. Caveman, ponytail, superpowers, taste-skill, graphify terpasang bersamaan dari marketplace repo ini sendiri. |
| 🔒 **Zero third-party download** | Semua kode plugin ada di repo ini (MIT surfaces). Tidak ada runtime dependency ke repo orang lain — upstream down/renamed/deleted tidak memengaruhi kamu. |
| 📌 **Version beku, teruji** | Versi plugin yang kamu pakai = versi yang sudah dites di repo ini. Upgrade hanya saat kamu mau (re-vendor + bump version), bukan kapan upstream berubah. |
| ⚡ **Banding token turun** | Caveman memotong ~65% token output; ponytail memaksa solusi paling minimal. Gabungan keduanya = sesi jauh lebih murah. |
| 🧠 **Context berlapis** | Prioritas konteks: knowledge graph (`graphify-out/`) → Obsidian vault → codebase. Claude baca ringkasan dulu, bukan scan semua file. |
| 📝 **Auto-dokumentasi** | Rules injected ke `~/.claude/CLAUDE.md` (idempotent): tiap perubahan penting otomatis dicatat ke vault Obsidian dengan frontmatter YAML + wikilinks. |
| 🎨 **Design taste lengkap** | 13 skill desain frontend: anti-slop landing page, GSAP motion, brand-kit, brutalist, minimalist, imagegen web/mobile, image-to-code, redesign. |
| 🛠️ **Proses engineering matang** | Superpowers bawa brainstorming, TDD, systematic debugging, subagent-driven development, code review, writing plans — workflow, bukan tebak-tebakan. |
| 🔁 **Idempotent semua** | Installer aman dijalankan berulang: yang sudah terpasang di-skip, tidak ada dobel config, tidak menimpa CLAUDE.md user. |
| 🖥️ **Cross-OS** | Installer interaktif pilih OS (Linux/Windows; Mac coming soon), vault path menyesuaikan otomatis. |
| ⏱️ **First-run experience** | Banner ASCII, menu OS, konfirmasi, marker first-run — run kedua langsung cepat tanpa prompt. |
| 🪶 **Ringan** | Total vendored ~1.7MB, 200 file. No node_modules, no build step, no compiled binary. |

---

## The stack

| # | Plugin | Origin | Type | Purpose |
|---|---|---|---|---|
| 1 | **caveman** | juliusbrussee/caveman (MIT) | vendored plugin | Terse output mode — potong ~65% token, substansi teknis tetap utuh. 20 skill + hook SessionStart/UserPromptSubmit + cavecrew subagents |
| 2 | **ponytail** | dietrichgebert/ponytail (MIT) | vendored plugin | Lazy senior dev mode — ladder 7 rung (YAGNI, stdlib first, one line over fifty), root-cause fix, no over-engineering. 6 skill + 3 hook |
| 3 | **superpowers** | obra/superpowers (MIT) | vendored plugin | Process skills — brainstorming, systematic-debugging, TDD, subagent-driven dev, git worktree, writing plans & skills. 15 skill + SessionStart hook |
| 4 | **taste-skill** | Leonxlnx/taste-skill (MIT) | vendored plugin | Design taste family — 13 skill: design-taste-frontend, gpt-taste, high-end-visual-design, brandkit, minimalist-ui, industrial-brutalist-ui, imagegen web/mobile, image-to-code, redesign |
| 5 | **graphify** | vendored di repo ini | vendored plugin + pip CLI | Codebase → knowledge graph (god nodes, community detection), query-first context, GraphRAG-ready JSON |
| 6 | **obsidian-vault** | @modelcontextprotocol/server-filesystem | MCP server | Read/write vault Obsidian — catatan, backlog, dokumentasi per project |

**Vendored** = kode tinggal di repo ini. `/allinone install` tidak pernah unduh dari repo pihak ketiga. Bagian BSL-1.1 milik caveman (`engine/`, `proxy/`, `rewriter/`, dll) **dibuang** — hanya MIT surfaces (`skills/`, `hooks/`, `commands/`, agents) yang divendor. Tiap plugin bawa `LICENSE` upstream + `.VENDORED.md` provenance.

---

## Install

### Option A — Claude Code plugin marketplace (recommended)

```bash
claude plugin marketplace add ChasoulUIX/AllInOne-Claude
claude plugin install allinone@allinone
```

Restart sesi, lalu jalankan sekali:

```
/allinone install
```

Installer otomatis:

1. install 5 plugin vendored dari marketplace repo ini (`caveman@allinone` … `graphify@allinone`) — dengan banner ASCII + menu OS,
2. `pip install --user graphifyy` untuk graphify CLI (skip jika sudah ada),
3. `claude mcp add obsidian-vault` menunjuk vault kamu (skip jika sudah terdaftar),
4. inject rules ke `~/.claude/CLAUDE.md` — append, tidak menimpa, skip jika sudah ada.

### Option B — skills CLI (tanpa hook)

```bash
npx skills add ChasoulUIX/AllInOne-Claude -g -y
```

⚠️ Option B hanya copy file skill — tidak ada SessionStart hook, tidak ada vendored plugin, tidak ada installer. Untuk pengalaman penuh pakai Option A.

### Upgrade

Vendored plugin tidak auto-update. Untuk ambil versi baru: `claude plugin update allinone` (mengikuti repo ini), atau re-vendor manual dari upstream (lihat [Development](#development)).

---

## Usage

```
/allinone check     # tabel status: 5 vendored plugin + graphify CLI + obsidian MCP
/allinone install   # pasang yang kurang (konfirmasi dulu)
/allinone status    # sama dengan check
```

Setelah semua hijau, skill allinone jadi layer always-on:

**Part A — embedded rules (selalu aktif):**
- Prioritas konteks: `graphify-out/` → Obsidian vault → codebase
- Log tiap perubahan penting ke vault (path absolut, frontmatter YAML, wikilinks)
- Caveman core: output terse, substansi teknis tetap
- Ponytail core: ladder minimal, root-cause fix
- Superpowers core: invoke skill sebelum respons

**Part B — dispatcher (routing otomatis):**

| Task | Skill yang dipanggil |
|---|---|
| Fitur baru / "let's build X" | `superpowers:brainstorming` |
| Bug / test failure | `superpowers:systematic-debugging` |
| Tulis implementation plan | `superpowers:writing-plans` |
| TDD | `superpowers:test-driven-development` |
| Landing page / portfolio / redesign | `design-taste-frontend` |
| GSAP motion / animasi kompleks | `gpt-taste` |
| Brand board / visual direction | `high-end-visual-design` |
| "Codebase ini strukturnya gimana" | `graphify` |
| Code review | `code-review` / `superpowers:requesting-code-review` |
| Sesi mau selesai | vault logging (Part A2) |

---

## Obsidian vault

MCP obsidian-vault menunjuk filesystem root. Default installer:

```
~/MyProject/ChasoulUIX-BRAINSTROMING      # Linux
C:/MyProject/ChasoulUIX-BRAINSTROMING    # Windows
```

Override saat install:

```bash
bash hooks/install-deps.sh --vault /your/vault/path
```

Tiap project simpan catatan di `<vault>/<nama-project>/` — Markdown dengan frontmatter YAML (`title`, `date`, `tags`, `status`, `project`) + wikilinks `[[nama-catatan]]`. Subfolder dibuat otomatis.

---

## Skill inventory (40+ skill)

<details>
<summary><b>caveman</b> (20) — mode + utilities</summary>

caveman · caveman-commit · caveman-compress · caveman-discover · caveman-evidence-review · caveman-explore · caveman-help · caveman-learn · caveman-manage · caveman-optimize · caveman-review · caveman-setup · caveman-stats · cavecrew · investigate-first · lean-build · migration · safe-refactor · surgical-patch · verify-and-stop
</details>

<details>
<summary><b>ponytail</b> (6) — lazy ladder</summary>

ponytail · ponytail-audit · ponytail-debt · ponytail-gain · ponytail-help · ponytail-review
</details>

<details>
<summary><b>superpowers</b> (15) — process</summary>

brainstorming · diagnosing-superpowers · dispatching-parallel-agents · executing-plans · finishing-a-development-branch · receiving-code-review · requesting-code-review · subagent-driven-development · systematic-debugging · test-driven-development · using-git-worktrees · using-superpowers · verification-before-completion · writing-plans · writing-skills
</details>

<details>
<summary><b>taste-skill</b> (13) — design</summary>

design-taste-frontend · design-taste-frontend-v1 · gpt-taste · high-end-visual-design · brandkit · minimalist-ui · industrial-brutalist-ui · stitch-design-taste · imagegen-frontend-web · imagegen-frontend-mobile · image-to-code · redesign-existing-projects · full-output-enforcement
</details>

<details>
<summary><b>graphify</b> (1 + 8 references) — knowledge graph</summary>

graphify — plus references: add-watch, exports, extraction-spec, github-and-merge, hooks, query, transcribe, update
</details>

---

## Troubleshooting

- **Vendored plugin install gagal** — `claude plugin marketplace list` harus menampilkan `allinone`. Kalau tidak: `claude plugin marketplace add ChasoulUIX/AllInOne-Claude` manual, lalu retry `/allinone install`.
- **graphify CLI gagal** — butuh Python 3.10+; coba `pipx install graphifyy`. Skill layer tetap jalan tanpa CLI; hanya ingestion repo yang butuh.
- **obsidian MCP gagal** — cek `claude mcp list`; path vault harus ada (`mkdir -p` dulu).
- **Hook tidak jalan** — hook hanya aktif di plugin install (Option A), bukan skills CLI (Option B).
- **Mode caveman/ponytail tidak aktif** — restart sesi setelah install; hook SessionStart inject ruleset saat startup.

---

## Development

```
.claude-plugin/plugin.json       # metadata plugin allinone
.claude-plugin/marketplace.json  # marketplace multi-plugin: allinone + 5 vendored
hooks/hooks.json                 # SessionStart → check-deps.sh
hooks/check-deps.sh              # cek ringan, no install, exit 1 jika kurang
hooks/install-deps.sh            # install vendored plugins + graphify CLI + obsidian MCP
skills/allinone/SKILL.md         # skill meta: embedded rules + dispatcher
skills/allinone/references/deps.json  # tabel dependency machine-readable
plugins/caveman/                 # vendored caveman (MIT surfaces, + LICENSE + .VENDORED.md)
plugins/ponytail/                # vendored ponytail (+ LICENSE + .VENDORED.md)
plugins/superpowers/             # vendored superpowers (+ LICENSE + .VENDORED.md)
plugins/taste-skill/             # vendored taste-skill (+ LICENSE + .VENDORED.md)
plugins/graphify/                # vendored graphify skill sebagai plugin
commands/allinone.md             # slash command /allinone
templates/CLAUDE.md.template     # rules yang di-inject ke ~/.claude/CLAUDE.md
```

**Update vendored plugin:** copy ulang dari upstream (MIT dirs only, buang BSL/multi-harness/build dirs), simpan `LICENSE` upstream, bump version di `plugins/<name>/.claude-plugin/plugin.json`. Detail scope ambil/buang per plugin ada di `plugins/<name>/.VENDORED.md`.

---

## License

MIT. Plugin vendored pertahankan license upstream: caveman (MIT + BSL split — hanya MIT surfaces yang divendor), ponytail (MIT), superpowers (MIT), taste-skill (MIT).

---

<div align="center">

**AllInOne-Claude** — by ChasoulUIX

Thanks for using AllInOne — Follow Instagram : chasoul.uix

</div>
