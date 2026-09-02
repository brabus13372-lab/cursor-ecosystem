# Ecosystem inventory

## Skills (`~/.cursor/skills/`) — **9**

| Skill | Slash |
|-------|-------|
| ecosystem-conductor | /conductor |
| memory-dream | /dream |
| subagent-orchestrator | /orchestrate |
| fsd-project-explorer | /fsd-map |
| motion-system-builder | /motion |
| test-writer | /tests |
| database-engineer | /db |
| telegram-bot-builder | /bot |
| project-idea-generator | /ideas |

## Conductor docs

- `coordinator-preset.md` — Preset: coordinator
- `improve-preset.md` — Preset: improve (repo health → ImprovementPlan)
- `memory-layer.md` — Orient, bootstrap, handoffs
- `skill-chains.md` — `after:` registry + **6** named preset chains (`full`/`fix`/`discover`/`improve`/`gate`/`coordinator`)
- `agent-roles.md` — readonly / writes_code matrix

## Agents (`~/.cursor/agents/`)

Hub: **AGENTS.md** — 8 agents, Scout/Builder/Critic

## Commands

Mirror skills + `/agents` hub + `/improve`. See `commands/skills.md`. **23** command files.

## Hooks

`~/.cursor/hooks.json` — sessionStart memory, stop handoff hint

## Pitfalls

- `install.ps1` / `install.sh` force-overwrite `~/.cursor` (no dry-run/backup yet)
- Repo `README` skill badge must stay at **9**

## GitHub

- https://github.com/brabus13372-lab/cursor-ecosystem
- Local work 2026-08-01 may be ahead of last noted tip `a70e1dd`
