# Cursor Ecosystem

![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-10-green)
![Commands](https://img.shields.io/badge/commands-23-blue)
![Agents](https://img.shields.io/badge/agents-8-purple)

Personal Cursor ecosystem: **skills**, **slash commands**, **sub-agents**, **hooks**, and **cross-session memory**. Central router: `ecosystem-conductor` (`/conductor`).

Ideas adapted from Claude Code architecture (autoDream, coordinator mode, skill chains) — for Cursor skills + hooks, not a copy of proprietary runtime.

**Русский:** [README.md](README.md)

---

## Layers

| Layer | Purpose | Repo | Install to |
|-------|---------|------|------------|
| Skills | Domain workflows + conductor | `skills/` | `~/.cursor/skills/` |
| Commands | Slash entry points | `commands/` | `~/.cursor/commands/` |
| Agents | Sub-agent prompts | `agents/` | `~/.cursor/agents/` |
| Hooks | Memory inject, handoff hint | `hooks/`, `hooks.json` | `~/.cursor/` |
| Memory | Global ecosystem index | `memory/` | `~/.cursor/memory/` |

Per-project memory: `.cursor/memory/` in each repo (bootstrap via conductor or `/dream`).

---

## Install

**Windows:**

```powershell
git clone https://github.com/brabus13372-lab/cursor-ecosystem.git
cd cursor-ecosystem
.\install.ps1
```

**macOS/Linux:** `chmod +x install.sh && ./install.sh`

Requires Cursor with Skills + Hooks, Node.js 18+. Restart Cursor after install.

---

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature — Orient → pipeline → handoff → `/dream`? |
| `coordinator` | Multi-domain — **main routes only**, subagents build |
| `fix` | Known bug |
| `discover` | Research only — no recommendations |
| `gate` | Pre-merge verification |
| `parallel_discover` | Parallel scouts |
| `ideate` | `/ideas` → pick → continue (**greenfield** project ideas) |
| `improve` | `/improve` — Scout → **ImprovementPlan** → pick → `full` (**this repo**) |
| `ctf` | CTF web pipeline |
| `dream` | Memory consolidation |

### Preset `coordinator`

Main agent does not write feature code — delegates to scoped builders. See `skills/ecosystem-conductor/coordinator-preset.md`.

### Preset `improve`

```
Orient → Scout (ContextMap + Health signals) → Advisor → ImprovementPlan → stop
```

- **Advisor (main):** evidence-based recommendations — no code changes
- **Scout:** `/research`, `/explore`, `/fsd-map`, or parallel via `/orchestrate`
- Slash: `/improve` or `Preset: improve`
- Not the same as `ideate` (new projects) or `discover` (locate only)
- Doc: `skills/ecosystem-conductor/improve-preset.md`

---

## Memory layer

- **`/dream`** (`memory-dream` skill) — consolidate durable facts into `.cursor/memory/`
- **`sessionStart` hook** — injects MEMORY + latest handoff
- **`stop` hook** — one-time handoff reminder per session
- **SessionHandoff** — written to `.cursor/memory/handoffs/latest.md`

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

10 skills · 23 commands · 8 agents · 2 hooks · 5 conductor supplement docs

## License

MIT
