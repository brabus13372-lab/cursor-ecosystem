# Coordinator preset

Inspired by Claude Code `COORDINATOR_MODE`: main agent **routes and synthesizes**; **Builders** are subagents/skills with bounded write scope.

## When to use

| Signal | Preset |
|--------|--------|
| User writes `Preset: coordinator` | Explicit |
| «только делегируй», «координатор», «orchestrate implement» | Inferred |
| Large cross-cutting task + user wants parallel builders | Inferred |
| Single-file trivial fix | **Do not** use — use `fix` or direct edit |

## Role split

| Role | Who | Writes code? |
|------|-----|--------------|
| **Coordinator** | Main agent (this thread) | **No** — only glue, config, conductor files |
| **Scout** | `explore`, `codebase-research`, `/fsd-map` | No |
| **Architect** | Coordinator | No — emits TouchPointPlan |
| **Builder** | `bot-designer`, `motion-designer`, `refactoring`, or main only if single-domain & small | Yes — within scope |
| **Verifier** | `test-writer` + `shell` | Tests only |
| **Critic** | `code-reviewer`, `security-reviewer`, `database-reviewer` | No |

## Phase graph

```
PipelinePlan
  → Orient (.cursor/memory/)
  → parallel_discover (/orchestrate) OR single Scout → ContextMap
  → Architect → TouchPointPlan (file list per Builder)
  → Delegate Builders (Task, disjoint scopes, one agent per domain)
  → Synthesize ChangeSet summary
  → preset gate (Verifier → Critics)
  → SessionHandoff + handoffs/latest.md → offer /dream
```

## Delegation rules

1. **Coordinator never implements feature code** — only ecosystem/meta files if the task is ecosystem work.
2. Each Builder Task brief must include: Objective, Scope paths, Deliverable, **scope** from agent frontmatter, Do-not-touch.
3. **No overlapping writers** — split by directory or layer (frontend / bot / db).
4. Light work (≤2 files) → domain **skill** (`/bot`, `/motion`, `/db`) instead of subagent.
5. Heavy work (≥3 files, FSM, motion module) → **subagent** (`bot-designer`, `motion-designer`).
6. After domain skill completes → honor `after:` chain (tests, db-review).

## Builder routing

| Domain | Light (skill) | Heavy (subagent) |
|--------|---------------|------------------|
| Bot | `/bot` | `/bot-agent` |
| Motion | `/motion` | `/motion-agent` |
| DB | `/db` | main or dedicated (no db-designer — use skill) |
| Refactor cleanup | — | `/refactor` (named files only) |
| Generic multi-area | — | `generalPurpose` with tight brief |

## Coordinator vs `full`

| | `full` | `coordinator` |
|---|--------|----------------|
| Main agent implements | Yes, default | **No** — delegates |
| Scouts | Optional | Almost always |
| Parallel builders | Rare | Expected |
| Best for | Solo feature, familiar stack | Multi-domain, large, team-style split |

## Example prompt

```
/conductor
Preset: coordinator
Цель: auth + bot handler + motion onboarding
Ограничения: coordinator не пишет feature code
Готово когда: gate pass, handoff written
```
