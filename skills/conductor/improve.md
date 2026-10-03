# Preset: improve

Evidence-based improvement proposals for **this repo**. Read-only: no code
changes until the user picks an item.

Not this preset: new product ideas (`ideas` skill), «как работает X»
(`discover`), checking a finished diff (`gate`).

## Scout

| Repo shape | Scout |
|------------|-------|
| Small / familiar | one `Explore` agent, breadth over depth |
| FSD frontend | `fsd-map` skill, then `Explore` on weak layers |
| Large / multi-domain | 2–3 parallel `Explore` agents: architecture · tests/CI · security skim |

Brief for each scout:

```
Objective: map repo health for improvement proposals — structure, gaps, smells.
Scope: <dirs> — skip node_modules, vendor, build output, lockfiles.
Deliverable: ContextMap + "Health signals": one line each,
  "<category> — `path` — observable gap".
Constraints: read-only; ≤ 25 lines; every signal cites a path or fact.
```

Cheap facts worth checking directly: is there CI, do tests run and pass,
dependency age, `.env.example` vs real env usage, README accuracy, TODO/FIXME
density, largest files, obvious dead code.

## ImprovementPlan

Rules:

1. Every item traces to a Health signal — no generic «add more tests».
2. Categories: architecture · tests/CI · DX · security · perf · docs · deps.
3. Each item: impact (high/med/low) · effort (S/M/L) · evidence path.
4. Name what should be left alone and why.

```markdown
## ImprovementPlan
**Scope:** repo or dirs
**Quick wins** (S effort, real impact):
- item — impact/effort — `evidence`
**Medium:**
- …
**Strategic:**
- …
**Leave alone:**
- area — why
**Recommended next:**
1. top pick — `/eco:conductor full <one-line goal>`
**Draft TouchPointPlan** (top pick only, optional)
```

Stop after the plan. When the user picks an item, start a new `full` run
scoped to that item only.
