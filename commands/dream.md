# Dream (Memory Consolidation)

Trigger **memory-dream** — consolidate durable project memory under `.cursor/memory/`.

Inspired by Claude Code `autoDream`: orient → gather → merge → prune index.

## When

- After large `/conductor` sessions
- Weekly maintenance on active projects
- Before starting a new epic when memory feels stale

## Steps

1. Read `~/.cursor/skills/memory-dream/SKILL.md`
2. Bootstrap `.cursor/memory/` from template if missing
3. Run 4-phase workflow → **DreamReport**
4. Optional gate: `node ~/.cursor/skills/memory-dream/scripts/dream-gate.mjs`

## Example

```
/dream
Проект: [path or context]
Фокус: architecture + decisions from last handoff
```

## User context

Apply to whatever the user writes after this command.
