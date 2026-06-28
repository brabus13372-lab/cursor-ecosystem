# Improve preset

Evidence-based **improvement proposals for the current repo** — not greenfield ideas (`ideate`), not locate-only (`discover`), not pre-merge diff review (`gate`).

## When to use

| Signal | Preset |
|--------|--------|
| User writes `Preset: improve` | Explicit |
| `/improve` | Explicit |
| «что улучшить», «health check», «tech debt», «audit репо», «предложи улучшения», «как прокачать проект» | Inferred |
| User wants conductor's own improvement plan before implement | Inferred |

**Do NOT use when:**

- Greenfield / startup / side-project brainstorm → `ideate` (`/ideas`)
- «Как работает X», «где лежит Y» without recommendations → `discover`
- «Проверь diff / перед PR» → `gate`
- User already picked one improvement and wants code → `full` or `fix`

## vs other presets

| Preset | Question answered |
|--------|-------------------|
| `discover` | Where / how does it work? |
| `ideate` | What **new** product could I build? |
| `improve` | What should I **improve in this repo**? |
| `gate` | Is **current change** safe to merge? |

## Role split

| Role | Who | Writes code? |
|------|-----|--------------|
| **Router** | Conductor | No |
| **Orient** | Conductor | No — `.cursor/memory/` |
| **Scout** | `/research`, `/explore`, `/fsd-map` | No |
| **Advisor** | Main agent | No — emits `ImprovementPlan` |
| **Closer** | Conductor | No — short SessionHandoff |

No Builder, Verifier, or Critic unless user picks an item and continues with `Preset: full`.

## Phase graph

```
PipelinePlan
  → Orient (.cursor/memory/ + handoffs/latest.md)
  → Scout → ContextMap (with Health signals)
  → Advisor → ImprovementPlan
  → stop — offer: pick one → Preset: full
  → SessionHandoff (short) + handoffs/latest.md
  → offer /dream if durable findings
```

## Scout selection

| Repo shape | Scout |
|------------|-------|
| FSD / layered frontend | `/fsd-map` then `/research` on weak layers |
| Small / familiar | `/research` — breadth scan |
| Large / multi-domain | `/orchestrate` parallel scouts (architecture · tests/CI · security skim) → merge ContextMap |

**Scout scope limit:** breadth over deep dive — max ~25 lines in ContextMap; cite paths as evidence.

## Scout brief (improve preset)

```
Objective: Map repo health for improvement proposals — structure, gaps, smells, not feature implementation.
Scope: [repo root or user-named dirs] — avoid node_modules, vendor, build artifacts.
Deliverable: ContextMap artifact with required **Health signals** section (template in ecosystem-conductor skill).
Constraints: read-only; max ~25 lines total; every signal must cite a file path or observable fact.
Return: ContextMap only — no ranked recommendations (Advisor synthesizes those).
```

## Advisor rules

1. Every recommendation must trace to Scout **Health signals** or Orient memory — no generic «add tests» without evidence.
2. Group by category: architecture · tests/CI · DX · security · perf · docs · deps.
3. Score each item: **impact** (high/med/low) · **effort** (S/M/L) · **risk if ignored** (optional).
4. Separate **Quick wins** (effort S, high impact) from **Strategic** (effort M/L).
5. **Do-not-touch** — areas that look bad but should stay (legacy, out of scope, working fine).
6. End with **Recommended next** — 1–3 items; include ready-made `/conductor` one-liner for top pick.

## Transition to implement

When user picks an improvement:

```
/conductor Preset: full
Goal: [chosen item from ImprovementPlan]
Context: ImprovementPlan attached; TouchPointPlan should cover only this slice.
```

Advisor may pre-fill a draft **TouchPointPlan** inside ImprovementPlan for the top recommendation to speed up `full`.

## Optional canvas tail

If user asks «в canvas» or findings are large (10+ items), after `ImprovementPlan` read `~/.cursor/skills-cursor/canvas/SKILL.md` and render `canvases/project-improvements.canvas.tsx`. Canvas is **optional** — not part of default `improve` graph.
