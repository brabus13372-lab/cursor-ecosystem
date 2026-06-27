# Cursor Ecosystem

![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-10-green)
![Commands](https://img.shields.io/badge/commands-22-blue)
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

**Windows:** `git clone … && cd cursor-ecosystem && .\install.ps1`  
**macOS/Linux:** `chmod +x install.sh && ./install.sh`

Requires Cursor with Skills + Hooks, Node.js 18+.

Restart Cursor after install.

---

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature — Orient → pipeline → handoff → `/dream`? |
| `coordinator` | Multi-domain — **main routes only**, subagents build |
| `fix` | Known bug |
| `discover` | Research only |
| `gate` | Pre-merge verification |
| `parallel_discover` | Parallel scouts |
| `ideate` | `/ideas` → pick → continue |
| `ctf` | CTF web pipeline |
| `dream` | Memory consolidation |

**Coordinator** (Claude Code–inspired): main agent does not write feature code — delegates to scoped builders. See `skills/ecosystem-conductor/coordinator-preset.md`.

---

## Memory layer

- **`/dream`** (`memory-dream` skill) — consolidate durable facts into `.cursor/memory/`
- **`sessionStart` hook** — injects MEMORY + latest handoff
- **`stop` hook** — one-time handoff reminder per session
- **SessionHandoff** — written to `.cursor/memory/handoffs/latest.md`

---

## Skill chains (`after:`)

| Skill | Then |
|-------|------|
| `/db` | `/tests` → `/db-review` |
| `/bot`, `/motion` | `/tests` |

See `skills/ecosystem-conductor/skill-chains.md`.

---

## Quick examples

```
/conductor Preset: full
Goal: …
Constraints: …
Done when: …
```

```
/conductor Preset: coordinator
Goal: bot + DB + motion
Constraints: main does not write feature code
```

```
/dream
```

---

## Stats

10 skills · 22 commands · 8 agents · 2 hooks

## License

MIT
