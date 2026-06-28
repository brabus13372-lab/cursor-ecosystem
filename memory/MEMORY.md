# Cursor Ecosystem Memory

> Global index — skills, hooks, conductor. App code → per-repo `.cursor/memory/`.

## Topics

- [ecosystem](ecosystem.md) — skills, commands, agents, hooks
- [conductor](conductor.md) — presets, artifacts, memory layer

## Hooks

| Event | Script |
|-------|--------|
| `sessionStart` | `hooks/session-start-memory.mjs` |
| `stop` (loop_limit 1) | `hooks/stop-handoff-hint.mjs` |

## Last consolidated

- **2026-06-29** — preset `improve`, `/improve`, ImprovementPlan artifact
- **2026-06-27** — coordinator preset, full skill chains, AGENTS.md, bootstrap memory, stop hook
