# Conductor preferences

## Presets

`full` · `coordinator` · `fix` · `discover` · `gate` · `parallel_discover` · `ideate` · **`improve`** · `ctf` · `dream`

## Improve (2026-06-29)

Repo health — not greenfield (`ideate`), not locate-only (`discover`), not diff review (`gate`).

```
Orient → Scout → ContextMap (+ Health signals) → Advisor → ImprovementPlan → stop
```

- Slash: `/improve` or `Preset: improve`
- Doc: `skills/ecosystem-conductor/improve-preset.md`
- User picks item → `Preset: full`
- No Builder until user explicitly continues
- Canvas optional tail (not core graph)

## Coordinator

Main agent routes only — Builders are subagents/skills. See `coordinator-preset.md`.

## Full pipeline

Orient (bootstrap memory if missing) → Scout → Architect → Builder → Verifier → Critic → Security? → Handoff → offer /dream

## Artifacts

PipelinePlan, ContextMap, TouchPointPlan, **ImprovementPlan**, TestReport, ReviewFindings, SessionHandoff, DreamReport

## Handoff

Always `.cursor/memory/handoffs/latest.md` on large/full/coordinator/**improve** sessions.

## Skill chains

All skills have explicit `after:` in frontmatter. Empty = conductor-owned next step.
