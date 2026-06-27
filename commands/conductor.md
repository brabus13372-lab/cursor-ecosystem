# Conductor (Autonomous Ecosystem)

Trigger **ecosystem-conductor** — the **only auto-router** for skills, commands, and subagents.

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature, cross-cutting, unfamiliar (default) |
| `coordinator` | Multi-domain; main routes, subagents build |
| `fix` | Known bug, familiar area |
| `discover` | Research only — no implement |
| `gate` | Pre-PR / pre-merge verification |
| `parallel_discover` | Parallel scouts → merge ContextMap |
| `ideate` | Project ideas → then `full` |
| `ctf` | CTF web + bot + OOB |
| `dream` | Memory consolidation (`/dream`) |

**Memory:** Orient + auto-bootstrap `.cursor/memory/` on `full`/`fix`/`coordinator`. Hook injects MEMORY on session start.

## Steps

1. Read `~/.cursor/skills/ecosystem-conductor/SKILL.md`
2. Triage → pick preset (`coordinator-preset.md` for coordinator)
3. PipelinePlan → artifacts → execute
4. `/orchestrate` for parallel scouts when needed
5. `/review`, `/security` — local; PR → bugbot stack
6. SessionHandoff → `handoffs/latest.md` → offer `/dream`

## Example

```
/conductor
Preset: coordinator
Цель: [multi-domain task]
Ограничения: coordinator не пишет feature code
```

## User context

Apply to whatever the user writes after this command.
