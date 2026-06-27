# Conductor preferences

## Presets

`full` · `coordinator` · `fix` · `discover` · `gate` · `parallel_discover` · `ideate` · `ctf` · `dream`

## Coordinator

Main agent routes only — Builders are subagents/skills. See `coordinator-preset.md`.

## Full pipeline

Orient (bootstrap memory if missing) → Scout → Architect → Builder → Verifier → Critic → Security? → Handoff → offer /dream

## Artifacts

PipelinePlan, ContextMap, TouchPointPlan, TestReport, ReviewFindings, SessionHandoff, DreamReport

## Handoff

Always `.cursor/memory/handoffs/latest.md` on large/full/coordinator sessions.

## Skill chains

All skills have explicit `after:` in frontmatter. Empty = conductor-owned next step.
