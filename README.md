# Cursor Ecosystem

![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-9-green)
![Commands](https://img.shields.io/badge/commands-23-blue)
![Agents](https://img.shields.io/badge/agents-8-purple)

Personal Cursor ecosystem: **skills**, **slash commands**, **sub-agents**, **hooks**, and **cross-session memory**. Central router: `ecosystem-conductor` (`/conductor`).

Ideas adapted from Claude Code architecture (autoDream, coordinator mode, skill chains) — for Cursor skills + hooks, not a copy of proprietary runtime.

**Русский:** [README.ru.md](README.ru.md)

---

## Layers

| Layer | Purpose | Repo | Install to |
|-------|---------|------|------------|
| Skills | Domain workflows + conductor | `skills/` | `~/.cursor/skills/` |
| Commands | Slash entry points | `commands/` | `~/.cursor/commands/` |
| Agents | Sub-agent prompts | `agents/` | `~/.cursor/agents/` |
| Hooks | Memory inject, handoff hint | `hooks/`, `hooks.json` | `~/.cursor/` |
| Memory | Global ecosystem index | `memory/` | `~/.cursor/memory/` |

Per-project memory: `.cursor/memory/` in each repo (bootstrap via conductor or `/dream`). Optional local backlog: `.cursor/conductor-prompts.md` (often gitignored with `.cursor/`).

---

## Repo layout

```
cursor-ecosystem/
├── package.json                 # npm test
├── install.ps1 / install.sh     # -DryRun / -Backup
├── hooks/
│   ├── session-start-memory.mjs
│   ├── stop-handoff-hint.mjs
│   └── __tests__/               # node:test smokes
├── memory/                      # global template → ~/.cursor/memory/
├── skills/                      # 9 skills
├── commands/                    # 23 commands
└── agents/                      # 8 agents + AGENTS.md
```

---

## Install

**Windows:**

```powershell
git clone https://github.com/brabus13372-lab/cursor-ecosystem.git
cd cursor-ecosystem
.\install.ps1 -DryRun     # plan only
.\install.ps1 -Backup     # backup then install
.\install.ps1             # overwrite install
```

**macOS/Linux:**

```bash
chmod +x install.sh
./install.sh --dry-run
./install.sh --backup
./install.sh
```

Scripts print a repo vs `~/.cursor` summary and warn on drift. `--backup` / `-Backup` snapshots to `~/.cursor-backup-YYYYMMDD-HHmmss` before overwrite.

Requires Cursor with Skills + Hooks, Node.js 18+. Restart Cursor after install.

---

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature — Orient → pipeline → handoff → `/dream`? |
| `fix` | Known bug |
| `discover` | Research only — no recommendations |
| `improve` | `/improve` — Scout → **ImprovementPlan** → pick → `full` (**this repo**) |
| `gate` | Pre-merge verification |
| `coordinator` | Multi-domain — **main routes only**, subagents build |

**Not named presets** (still available): `/dream` (`memory-dream`; conductor still routes from Signals — memory stale / weekly upkeep); `/ideas` (`project-idea-generator`, then user may continue with `full`); `/ctf-audit` (domain routing like `/bot`/`/db`); `parallel_discover` (Scout/orchestrate **phase** inside `coordinator`, or optional parallel scouts — `/orchestrate` → merge ContextMap → `full` or stop).

**Aliases:** `Scout` → `discover` (role, not a named preset). Typos `Impove` / `improv` / `imporve` → `improve`.

### Preset `coordinator`

Main agent does not write feature code — delegates to scoped builders. See `skills/ecosystem-conductor/coordinator-preset.md`.

### Preset `improve`

```
Orient → Scout (ContextMap + Health signals) → Advisor → ImprovementPlan → stop
```

- **Advisor (main):** evidence-based recommendations — no code changes
- **Scout:** `/research`, `/explore`, `/fsd-map`, or parallel via `/orchestrate`
- Slash: `/improve` or `Preset: improve`
- Not the same as `/ideas` (new projects) or `discover` (locate only)
- Doc: `skills/ecosystem-conductor/improve-preset.md`

---

## Memory layer

- **`/dream`** (`memory-dream` skill) — consolidate durable facts into `.cursor/memory/`
- **`sessionStart` hook** — injects MEMORY + latest handoff
- **`stop` hook** — one-time handoff reminder per session
- **SessionHandoff** — written to `.cursor/memory/handoffs/latest.md`
- Hook smoke tests: `npm test`

---

## Agent roles

| Role | Who | Writes code? |
|------|-----|--------------|
| Scout | `codebase-research`, `explore` | No |
| Advisor | main (`improve` preset) | No — `ImprovementPlan` |
| Critic | reviewers | No |
| Builder | domain agents | Yes, bounded scope |
| Coordinator | main (`coordinator` preset) | No feature code |

Hub: `agents/AGENTS.md`

---

## Skill chains (`after:`)

| Skill | Then |
|-------|------|
| `/db` | `/tests` → `/db-review` |
| `/bot`, `/motion` | `/tests` |

See `skills/ecosystem-conductor/skill-chains.md`.

---

## Phase artifacts

| Artifact | Who | Purpose |
|----------|-----|---------|
| `PipelinePlan` | Conductor | Goal, phases, constraints |
| `ContextMap` | Scout | Files, patterns, Health signals (`improve`) |
| `ImprovementPlan` | Advisor | Prioritized repo improvements (`improve`) |
| `TouchPointPlan` | Architect | Create / modify scope |
| `SessionHandoff` | Closer | → `handoffs/latest.md` |
| `DreamReport` | memory-dream | Memory consolidation |

---

## Quick examples

```
/conductor Preset: full
Goal: add auth middleware
Constraints: do not touch legacy API
Done when: tests green, review ok
```

```
/conductor Preset: coordinator
Goal: bot + DB + motion
Constraints: main does not write feature code
```

```
/improve
Scope: backend + tests
```

```
/conductor Preset: improve
what to improve in architecture and CI
```

```
/dream
```

---

## Stats

9 skills · 23 commands · 8 agents · 2 hooks (+ smokes) · 5 conductor supplement docs

## Verify

```bash
npm test
# or: node --test hooks/__tests__/*.test.mjs
```

## License

MIT
