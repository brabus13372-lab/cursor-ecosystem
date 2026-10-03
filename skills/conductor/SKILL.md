---
name: conductor
description: >-
  Explicit multi-phase pipeline for non-trivial work: scout → plan → build →
  verify → review, with fixed presets (full, fix, discover, improve, gate).
  Run only when the user types /eco:conductor or names a preset
  («Preset: full», «прогони pipeline», «перед PR проверь всё»).
argument-hint: "[full|fix|discover|improve|gate] <goal>"
disable-model-invocation: true
---

# Conductor

A pipeline, not a router. Claude Code already picks skills by their
descriptions and delegates to subagents on its own — this skill only adds a
**fixed phase order, artifact formats and stop rules** for work that needs them.

Request: $ARGUMENTS

## 1. Pick the preset

First word of the request wins if it is a preset name (case-insensitive;
typos like `impove` → `improve`). Otherwise infer:

| Preset | When | Phases |
|--------|------|--------|
| `full` | New feature, cross-cutting or unfamiliar area (default) | Scout → Plan → Build → Verify → Review → Security? |
| `fix` | Known bug, familiar area | Build → Verify → Review only if sensitive |
| `discover` | «как работает», «где лежит» — no changes | Scout → stop |
| `improve` | «что улучшить», health check, tech debt | Scout → ImprovementPlan → stop. See [improve.md](improve.md) |
| `gate` | Changes already made, «перед PR / merge» | Verify → Review → Security? → DB review if SQL changed |

Trivial task (one known file, full context)? Say so and just do it — no pipeline.

Start with one line: `Preset: full — goal… — phases…`, then a 2–5 step plan.

## 2. Phases

**Scout** — only if context is partial or missing. Delegate to the built-in
`Explore` agent (thoroughness by repo size); for FSD frontends use the
`fsd-map` skill. For large repos run 2–3 Explore agents in parallel on
**disjoint** scopes (e.g. backend · frontend · tests/CI). Normalize results
into a ContextMap — never paste raw agent output.

**Plan** — write a TouchPointPlan before touching code on `full`. Skip it only
if the user already gave exact files and scope.

**Build** — main thread writes code, minimal diffs, inside TouchPointPlan
scope. Domain skills (bot, db, motion, tests) load on their own when relevant;
for heavy single-domain work (≥3 files) delegate to `eco:bot-designer` or
`eco:motion-designer` with a brief. Never run two writers on the same files.

**Verify** — run the project's real test / lint / typecheck commands; add or
fix tests via the `tests` skill when logic changed. Report a TestReport.

**Review** — delegate to `eco:code-reviewer` on the diff. Add
`eco:security-reviewer` when auth, API input, secrets, payments or shell calls
were touched; `eco:database-reviewer` when SQL, migrations or transactions
changed. Independent reviewers can run in parallel.

**Fix loop** — if any review says *Ship ready: no*: fix Critical + Medium,
re-verify, re-review the changed parts. **Max 2 rounds**, then stop and show
the user what is still open.

## 3. Artifacts

Keep each short. They are for the user and for the next phase — not ceremony.

```markdown
## ContextMap
**Answer:** 1–3 sentences
**Files:** `path` — role in this task
**Patterns:** how the repo already solves similar things
**Entry point:** where Build should start
**Assumptions / open questions:** max 2
```

```markdown
## TouchPointPlan
**Goal slice:** what this pass covers
**Create:** new files · **Modify:** existing files · **Do not touch:** exclusions
**Contracts:** new APIs, types, env vars
**Verification:** commands that must pass
```

```markdown
## TestReport
**Status:** pass | fail | no test infra
**Commands:** exact commands run
**Failures:** test — error excerpt
```

Reviewers return their own formats; summarize them as
`Ship ready: yes/no — N critical, N medium` plus the items you will fix.

## 4. Brief template for any subagent

```
Objective: one focused question or task
Scope: directories/files to use — and what to avoid
Deliverable: <artifact name or reviewer format>
Constraints: read-only? max length; file paths required
```

## 5. Close-out

End with:

1. What was done (files, behavior) — short.
2. What was verified and how (exact commands).
3. Self-check: changed files list, imports resolve, no leftover debug code,
   no hardcoded paths or secrets, nothing outside TouchPointPlan touched.
4. Open risks, if any. One natural next step, if there is a real one.

## Do not

- Do not run Review before Build, except preset `gate`.
- Do not start Build on `full` without a TouchPointPlan.
- Do not ask «продолжать?» between phases — continue unless blocked, the fix
  loop is exhausted, or an irreversible decision is needed.
- Do not spawn subagents for trivial edits or for things one Grep answers.
- Do not forward raw subagent transcripts.
