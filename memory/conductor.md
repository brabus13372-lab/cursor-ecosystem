# Conductor preferences

## Presets

`full` · `fix` · `discover` · `improve` · `gate` · `coordinator`

## Related (not named presets)

- `/dream` (`memory-dream`) — memory stale / weekly upkeep (Signals still route here)
- `/ideas` (`project-idea-generator`) — greenfield ideas; user may continue with `full`
- `/ctf-audit` — domain routing like `/bot`/`/db`
- `parallel_discover` — Scout/orchestrate **phase** inside `coordinator` (optional parallel scouts)

## Aliases (2026-08-01)

| User wrote | Treat as |
|------------|----------|
| `Scout` | `discover` (role ≠ preset) |
| `Impove`, `improv`, `imporve` | `improve` |

Documented in `skills/ecosystem-conductor/SKILL.md` + slash commands + READMEs.

## Improve (2026-06-29)

Repo health — not greenfield (`/ideas`), not locate-only (`discover`), not diff review (`gate`).

```
Orient → Scout → ContextMap (+ Health signals) → Advisor → ImprovementPlan → stop
```

- Slash: `/improve` or `Preset: improve`
- Doc: `skills/ecosystem-conductor/improve-preset.md`
- User picks item → `Preset: full`
- No Builder until user explicitly continues

## Skill chains

Default graph in `skill-chains.md` lists the **six named presets**. `/dream`, `/ideas`, `/ctf-audit`, and `parallel_discover` (phase) are routed separately — same graphs, not Preset-table peers. Empty skill `after: []` → conductor owns next step via that graph.

## Full pipeline

Orient (bootstrap memory if missing) → Scout → Architect → Builder → Verifier → Critic → Security? → Handoff → offer /dream

## Artifacts

PipelinePlan, ContextMap, TouchPointPlan, **ImprovementPlan**, TestReport, ReviewFindings, SessionHandoff, DreamReport

## Handoff

Always `.cursor/memory/handoffs/latest.md` on large/full/coordinator/**improve** sessions.

## Project backlog (this ecosystem repo)

`.cursor/conductor-prompts.md` — prioritized paste-ready prompts (gitignored with `.cursor/`).
