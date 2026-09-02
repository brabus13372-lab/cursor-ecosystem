# Conductor (Autonomous Ecosystem)

Trigger **ecosystem-conductor** — the **only auto-router** for skills, commands, and subagents.

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature, cross-cutting, unfamiliar (default) |
| `fix` | Known bug, familiar area |
| `discover` | Research only — no implement |
| `improve` | Repo health → Scout → ImprovementPlan → optional `full` |
| `gate` | Pre-PR / pre-merge verification |
| `coordinator` | Multi-domain; main routes, subagents build |

**Not named presets** (still available): `/dream` (`memory-dream`; Signals: memory stale / weekly upkeep); `/ideas` (then user may continue with `full`); `/ctf-audit` (domain routing like `/bot`/`/db`); `parallel_discover` (Scout/orchestrate **phase** inside `coordinator`).

**Aliases:** `Scout` → `discover` (Scout is a role, not a named preset). Typos `Impove` / `improv` / `imporve` → `improve`.

**Memory:** Orient + auto-bootstrap `.cursor/memory/` on `full`/`fix`/`coordinator`/`improve`. Hook injects MEMORY on session start.

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
