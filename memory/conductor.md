# Conductor preferences

## Presets

`full` · `coordinator` · `fix` · `discover` · `gate` · `parallel_discover` · `ideate` · **`improve`** · `ctf` · `dream`

## Aliases (2026-08-01)

| User wrote | Treat as |
|------------|----------|
| `Scout` | `discover` (role ≠ preset) |
| `Impove`, `improv`, `imporve` | `improve` |

Documented in `skills/ecosystem-conductor/SKILL.md` + slash commands + READMEs.

## Improve (2026-06-29)

Repo health — not greenfield (`ideate`), not locate-only (`discover`), not diff review (`gate`).

```
Orient → Scout → ContextMap (+ Health signals) → Advisor → ImprovementPlan → stop
```

- Slash: `/improve` or `Preset: improve`
- Doc: `skills/ecosystem-conductor/improve-preset.md`
- User picks item → `Preset: full`
- No Builder until user explicitly continues

## Skill chains

Default graph in `skill-chains.md` lists **all** presets (including improve / ctf / ideate / parallel_discover) as of 2026-08-01. Empty skill `after: []` → conductor owns next step via that graph.

## Full pipeline

Orient (bootstrap memory if missing) → Scout → Architect → Builder → Verifier → Critic → Security? → Handoff → offer /dream

## Artifacts

PipelinePlan, ContextMap, TouchPointPlan, **ImprovementPlan**, TestReport, ReviewFindings, SessionHandoff, DreamReport

## Handoff

Always `.cursor/memory/handoffs/latest.md` on large/full/coordinator/**improve** sessions.

## Project backlog (this ecosystem repo)

`.cursor/conductor-prompts.md` — prioritized paste-ready prompts (gitignored with `.cursor/`).
