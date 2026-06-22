# Conductor (Autonomous Ecosystem)

Trigger **ecosystem-conductor** — the **only auto-router** for skills, commands, and subagents.

Domain skills (`/bot`, `/db`, `/motion`, …) run when conductor routes or user typed slash directly.

## Pipeline presets

| Preset | Use when |
|--------|----------|
| `full` | Large feature, cross-cutting, unfamiliar (default for big tasks) |
| `fix` | Known bug, familiar area |
| `discover` | Research only — no implement |
| `gate` | Pre-PR / pre-merge verification |
| `parallel_discover` | Parallel scouts → merge ContextMap |
| `ideate` | Project ideas → then `full` |
| `ctf` | CTF web + bot + OOB |

User may write: `Preset: full` plus **Goal**, **Constraints**, **Done criteria**.

## Steps

1. Read `~/.cursor/skills/ecosystem-conductor/SKILL.md` (skill name: `ecosystem-conductor`).
2. Triage: intent, complexity, context, risk → pick preset.
3. Emit **PipelinePlan** one-liner, then execute phases with **artifacts** (ContextMap → TouchPointPlan → … → SessionHandoff).
4. Parallel scouts: invoke `subagent-orchestrator` as a **phase** — conductor stays router.
5. Local review → `/review`, `/security`. PR/GitHub → `/review-bugbot`, `/review-security`.
6. End large tasks with **SessionHandoff** for next chat.

## Example prompt

```
/conductor
Preset: full
Цель: [what to build]
Ограничения: [do not touch]
Готово когда: [verification]
```

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, assess the current conversation and project state, pick the best preset, and start immediately.
