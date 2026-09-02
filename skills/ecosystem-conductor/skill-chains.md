# Skill chains (`after:` frontmatter)

When a domain skill completes successfully, conductor checks its YAML `after:` list and schedules the next phase **without asking** (unless user said stop).

## All skills — `after:` registry

| Skill | `after:` | Conductor notes |
|-------|----------|-----------------|
| `ecosystem-conductor` | `[]` | Router only |
| `memory-dream` | `[]` | Standalone |
| `subagent-orchestrator` | `[]` | Phase skill |
| `fsd-project-explorer` | `[]` | Discover → user/conductor continues |
| `project-idea-generator` | `[]` | User picks → `full` or `coordinator` |
| `test-writer` | `[]` | Conductor → `shell` verify → `/review` on `full` |
| `database-engineer` | `test-writer`, `database-reviewer` | Auto-chain after `/db` |
| `telegram-bot-builder` | `test-writer` | Auto-chain after `/bot` |
| `motion-system-builder` | `test-writer` | Auto-chain after `/motion` |

Empty `after: []` means **conductor owns** the next step via preset graph — not “no follow-up”.

## Default pipeline chains (conductor-owned)

Every **named preset** from the SKILL.md preset table must appear here:

```
full:               Orient? → Scout? → Architect → Builder → Verifier → Critic → Security? → Handoff → offer /dream
coordinator:        Orient → parallel_discover|Scout → TouchPointPlan → delegate Builders → gate → Handoff → offer /dream
fix:                Builder → Verifier? → Critic if sensitive → Handoff (short)
discover:           Scout → ContextMap → stop
gate:               Verifier → Critic → Security? → DB-review if SQL → Handoff
improve:            Orient → Scout → ContextMap (+ Health signals) → Advisor → ImprovementPlan → stop → Handoff → offer /dream
                    (user picks item → new full)
```

Aliases (`Scout`→`discover`, `Impove`→`improve`) normalize **before** selecting a chain — see SKILL.md.

## Skill / command / phase routing (not named presets)

Same graphs as before — they are **not** peer rows in the Preset table / PipelinePlan enum:

```
parallel_discover:  /orchestrate parallel Scouts → merge ContextMap → TouchPointPlan → full | stop (user OK)
                    (Scout/orchestrate phase inside coordinator, or optional parallel scouts)
/ideas:             project-idea-generator (/ideas) → user picks → full
/ctf-audit:         /ctf-audit (ctf-web-infra-auditor) → main fix solve/DNS → shell verify → re-audit if needed
/dream:             memory-dream → DreamReport → stop
```

After **any** `test-writer` pass on `full`/`coordinator`: run `shell` with project's test command if not already green.

## Adding `after:` to a skill

```yaml
---
name: my-skill
description: ...
disable-model-invocation: true
after: [test-writer, code-reviewer]
---
```

Conductor reads `after:` only when **it routed** the skill (slash or delegation).

## Subagent chains (post-Builder)

| Trigger | Critic | Condition |
|---------|--------|-----------|
| `full` / `coordinator` done | `code-reviewer` | non-trivial ChangeSet |
| risk ≥ medium | `security-reviewer` | auth/api/data/secrets |
| SQL changed | `database-reviewer` | migrations, queries |

Scouts never auto-chain to Builder on `discover` preset.
