# Improve (repo health & recommendations)

Trigger **ecosystem-conductor** with preset **`improve`** — Scout the current repo, then emit evidence-based improvement proposals. Read-only; no code changes unless user picks an item and continues with `Preset: full`.

## When to use

- «Что улучшить в этом проекте?»
- Health check, tech debt scan, architecture/DX/test gaps
- Want a prioritized plan before implementing

**Not for:** greenfield ideas (`/ideas`), locate-only research (`Preset: discover`), pre-PR review (`Preset: gate`).

## Steps

1. Read `~/.cursor/skills/ecosystem-conductor/SKILL.md` and [improve-preset.md](~/.cursor/skills/ecosystem-conductor/improve-preset.md).
2. Run preset `improve`: Orient → Scout → Advisor → **ImprovementPlan** → stop.
3. Offer transition: user picks item → `/conductor Preset: full` with chosen goal.
4. Short SessionHandoff → `handoffs/latest.md` → offer `/dream` if durable findings.

## Example

```
/improve
Scope: backend + tests only
```

```
/conductor Preset: improve
что улучшить в архитектуре и CI
```

## User context

Apply to whatever the user writes after this command.
