---
name: ecosystem-conductor
description: >-
  Единый auto-router экосистемы Cursor: triage задачи и маршрутизация в skills,
  slash-команды и subagents. Use when the user wants autonomous orchestration,
  /conductor, or phrases like «разберись сам», «сделай всё», «полный pipeline»,
  «исследуй → сделай → тесты → review», «/autonomous», or non-trivial tasks
  spanning exploration, implementation, tests, and review. This skill is the
  only skill that may self-activate for routing; all other ecosystem skills
  require explicit slash or conductor delegation.
---

# Ecosystem Conductor

Meta-orchestration skill — **единственный auto-router** экосystem. Understand what the user wants, what the codebase needs, and which tools in `~/.cursor/skills/`, `~/.cursor/commands/`, and `~/.cursor/agents/` to invoke — then execute without unnecessary back-and-forth.

## Hierarchy (who is in charge)

| Role | Tool | Rule |
|------|------|------|
| **Router** | `ecosystem-conductor` (this skill) | Decides *what* runs and in what order |
| **Delegation how-to** | `subagent-orchestrator` | Runs **only when conductor invokes it** for parallel/large delegation — never self-starts routing |
| **Domain skills** | `/bot`, `/db`, `/motion`, etc. | Run when conductor routes or user typed slash |
| **Phase subagents** | `/review`, `/security`, etc. | Run in pipeline phases — never before implement unless user asked review-only |

When this skill is active, **do not** let `subagent-orchestrator` triage or compete for control.

## Activation Criteria

Activate when any of the following apply:

- The user starts a non-trivial task without naming a specific skill or command.
- The request needs multiple phases: understand → implement → verify → review.
- You are unsure which layer, file, pattern, or tool owns the work.
- The user wants you to "figure it out", work autonomously, or use the ecosystem.
- A prior step finished and the natural next step is another skill/subagent (e.g. after implement → tests → review).

Do **not** activate when:

- The task is a one-line fix in a known file with full context already in thread.
- The user explicitly named one command/skill and only that should run.
- The answer is a short explanation with no code changes or investigation.

## Ecosystem inventory

### Skills (`~/.cursor/skills/`)

| Skill | Slash command | Role |
|-------|---------------|------|
| `fsd-project-explorer` | `/fsd-map` | FSD/layer map, placement guide (read-only) |
| `motion-system-builder` | `/motion` | Centralized Framer Motion system (skill) |
| `motion-designer` (agent) | `/motion-agent` | Animation-only subagent implementation |
| `test-writer` | `/tests` | Tests using existing project stack |
| `database-engineer` | `/db` | PostgreSQL + Python transactions, SQL, migrations |
| `database-reviewer` (agent) | `/db-review` | Atomicity/SQL/migration audit |
| `telegram-bot-builder` | `/bot` | aiogram 3 bot handlers, router, scheduler |
| `bot-designer` (agent) | `/bot-agent` | Telegram bot-only implementation |
| `subagent-orchestrator` | `/orchestrate` | Delegation rules, briefs, synthesis |
| `project-idea-generator` | `/ideas` | Production-ready project ideas from constraints |
| `ecosystem-conductor` | `/conductor` | This skill — autonomous routing |

### Built-in Cursor review (PR / branch diff)

Use when the user mentions **PR, pull request, GitHub link, branch diff**, or explicitly asks for Bugbot:

| Command | Subagent | Role |
|---------|----------|------|
| `/review-bugbot` | `bugbot` | PR-style diff review (Cursor built-in) |
| `/review-security` | `security-review` | PR-style security diff (Cursor built-in) |

### Custom review agents (local / session diff)

Default for **conductor pipeline** and pre-commit review of current workspace changes:

| Command | Subagent | Role |
|---------|----------|------|
| `/review` | `code-reviewer` | Quality review of current `git diff` |
| `/security` | `security-reviewer` | Security audit of current changes |
| `/db-review` | `database-reviewer` | Postgres atomicity/SQL audit |

**Routing rule:** PR/GitHub/branch → built-in stack. Local implement → custom agents. User typed `/review` or `/security` → always honor that command.

### Subagents (`~/.cursor/agents/` + Task tool)

| Subagent type | Slash command | Agent file | Role |
|---------------|---------------|------------|------|
| `explore` | `/explore` | — | Fast read-only scan |
| `codebase-research` | `/research` | `codebase-research.md` | Evidence-based how/where answers |
| `code-reviewer` | `/review` | `code-reviewer.md` | Quality review of changes |
| `security-reviewer` | `/security` | `security-reviewer.md` | Auth, secrets, injection, data |
| `refactoring` | `/refactor` | `refactoring.md` | Safe simplification |
| `ci-investigator` | `/ci` | — | Single CI failure root cause |
| `shell` | `/terminal` | — | Builds, tests, noisy CLI |
| `generalPurpose` + `motion-designer.md` | `/motion-agent` | `motion-designer.md` | Frontend animations only |
| `generalPurpose` + `database-reviewer.md` | `/db-review` | `database-reviewer.md` | Postgres + Python DB audit |
| `generalPurpose` + `bot-designer.md` | `/bot-agent` | `bot-designer.md` | Telegram bot code only |
| `explore` + `shell` (readonly) + `ctf-web-infra-auditor.md` | `/ctf-audit` | `ctf-web-infra-auditor.md` | CTF web: remote chall + admin bot + OOB — infra audit before exploit fixes |

Commands in `~/.cursor/commands/` mirror the above. Prefer **reading the skill/agent file** and **following its workflow** over improvising.

## Instructions

### 1. Triage the request (30 seconds, in your head)

Classify along four axes:

| Axis | Options |
|------|---------|
| **Intent** | explore · implement · fix · refactor · test · review · security · ci · motion · database · bot · ctf · ideate · architect |
| **Complexity** | trivial (1 file, known) · medium (2–5 files) · large (cross-cutting, unfamiliar) |
| **Context** | sufficient in thread · partial · missing (need repo discovery) |
| **Risk** | low · medium (auth/api/data) · high (secrets, payments, prod config) |

Announce a **one-line plan** to the user before executing non-trivial work:

> План: preset `full` — `/research` → TouchPointPlan → implement → `/tests` → `/review`

Skip the plan line for trivial fixes.

**Pick a pipeline preset** (explicit user request wins; else infer from triage):

| Preset | When | Phases |
|--------|------|--------|
| `full` | Large/cross-cutting feature, unfamiliar area, multi-domain | Scout → Architect → Builder → Verifier → Critic → Security? → Handoff |
| `fix` | Known bug, familiar area, clear file | Builder → Verifier? → Critic if sensitive |
| `discover` | «Как работает», «где лежит», no implement yet | Scout only → ContextMap |
| `gate` | «Перед PR», «проверь перед merge», implement already done | Verifier → Critic → Security? → DB-review if SQL |
| `parallel_discover` | Backend + frontend + security skim in parallel | `/orchestrate` Scouts → Synthesis → TouchPointPlan → `full` or stop |
| `ideate` | Project ideas, MVP brainstorm | `/ideas` → user picks → `full` on chosen idea |
| `ctf` | CTF web + bot + OOB | See CTF delegation pattern below |

User may pass preset in prompt: `Preset: full`. Default for medium/large implement: `full`. Trivial tasks: no preset — direct edit.

### 2. Route to tools

Use this routing table. Pick the **first matching row**, then append follow-up steps from the pipeline column.

| Signals | Start with | Pipeline (when applicable) |
|---------|------------|----------------------------|
| "Where does X live?", FSD, layers, placement | `fsd-project-explorer` | → implement |
| "How does X work?", patterns, architecture | `codebase-research` subagent | → implement |
| Unfamiliar repo, broad scan | `explore` subagent | → `codebase-research` if deeper answer needed |
| Animation: ≤2 files, one component, preset/variant on existing UI | `motion-system-builder` skill | → `test-writer` if logic touched |
| Animation: ≥3 files, new motion module, full audit, unfamiliar codebase | `motion-designer` subagent | → `test-writer` |
| Write/fix tests, coverage | `test-writer` | → `shell` subagent to run tests |
| SQL **implement**: transactions, migrations, writes, Postgres + Python | `database-engineer` skill | → `test-writer` → `database-reviewer` |
| SQL **audit only**: check diff, atomicity, race, locking — no new code | `database-reviewer` subagent | before commit/PR |
| Bot: ≤2 files, one handler/command/keyboard | `telegram-bot-builder` skill | → `test-writer` → `database-engineer` if DB writes |
| Bot: ≥3 files, FSM flows, scheduler, multi-handler refactor | `bot-designer` subagent | → `test-writer` → `database-engineer` if DB writes |
| Bot handler + Postgres in one flow | `telegram-bot-builder` or `bot-designer` | → `database-engineer` → `database-reviewer` |
| Large task needing **parallel** subagents (conductor already chose pipeline) | `subagent-orchestrator` skill | fan out per its patterns — conductor stays router |
| PR / GitHub review requested | `/review-bugbot` or `/review-security` | per user intent |
| After non-trivial implement | `code-reviewer` subagent | → `security-reviewer` if auth/api/data |
| Auth, API, SQL, secrets, permissions | `security-reviewer` subagent | before commit/PR |
| Messy/duplicated code, cleanup | `refactoring` subagent | → `code-reviewer` |
| CI/check failed | `ci-investigator` subagent | → `shell` to verify fix |
| Build/test/logs heavy | `shell` subagent | summarize, don't dump |
| CTF web: chall + bot + OOB/DNS exfil, remote flaky, s1/s2 without flag | `ctf-web-infra-auditor` via `/ctf-audit` | → main agent fix solve/DNS → `shell` verify → re-audit if needed |
| CTF exploit iteration, "bot 200 but no flag" | `ctf-web-infra-auditor` | before editing solve.py or spamming /report |
| Project ideas, startup/side-project brainstorm, MVP concepts, "что можно сделать" | `project-idea-generator` | → `/conductor` + domain skill if user picks one to build |
| Default medium task, unclear entry | `explore` or `codebase-research` | → implement → `test-writer` → `code-reviewer` |

**Trivial** (one known file, full context): implement directly — no skill, no subagent.

## Multi-agent pipeline

Conductor owns **pipeline state** across phases. Subagents return **artifacts** (structured blocks), not raw logs. Main agent **writes code**; scouts and critics are read-only unless preset says otherwise.

### Roles

| Role | Who | Writes code? | Output artifact |
|------|-----|--------------|-----------------|
| **Router** | Conductor (this skill) | No | `PipelinePlan` |
| **Scout** | `/explore`, `/research`, `/fsd-map` | No | `ContextMap` |
| **Architect** | Main agent | No | `TouchPointPlan` |
| **Builder** | Main agent | Yes | `ChangeSet` (implicit: git diff) |
| **Verifier** | `/tests`, `/terminal` | Tests only | `TestReport` |
| **Critic** | `/review`, `/security`, `/db-review` | No | `ReviewFindings` |
| **Fixer** | Main agent | Yes | patched `ChangeSet` |
| **Closer** | Conductor | No | `SessionHandoff` |

**Agent ↔ tool split:** agents judge and summarize; tools verify (`shell` for tests/build, MCP/GitHub for PR). Pattern: Builder → tool verify → Fixer if fail → re-verify.

### Pipeline state (mental model)

Track across phases — do not re-explore the whole repo each step:

```
intent, constraints, done_criteria, risk, preset
current_phase
artifacts: { PipelinePlan?, ContextMap?, TouchPointPlan?, TestReport?, ReviewFindings? }
decisions_log: [{ phase, decision, why }]
```

Builder proceeds from **TouchPointPlan** (or user-provided scope). Scout output is normalized into **ContextMap** before Architect.

### Artifact templates

Require these formats in subagent briefs (`Deliverable:` field) and in synthesis output.

**PipelinePlan** (conductor, start of non-trivial work):

```markdown
## PipelinePlan
**Preset:** full | fix | discover | gate | parallel_discover | ideate | ctf
**Goal:** [one sentence]
**Constraints:** [do-not-touch, stack limits]
**Done criteria:** [how we know it's finished]
**Phases:** Scout? → Architect → Builder → Verifier → Critic → Security?
**Risk:** low | medium | high
```

**ContextMap** (Scout — max ~25 lines):

```markdown
## ContextMap
**Answer:** [1–3 sentences]
**Files:**
- `path/to/file` — [role in this task]
**Patterns:** [how this repo already solves similar problems]
**Open questions:** [max 2, or state assumptions made]
**Recommended entry:** [where Builder should start]
```

**TouchPointPlan** (Architect — before Builder on `full` / `parallel_discover`):

```markdown
## TouchPointPlan
**Goal slice:** [what this implement pass covers]
**Create:** [new files/modules]
**Modify:** [existing files]
**Do not touch:** [explicit exclusions]
**Interface contracts:** [APIs, types, env vars introduced]
**Verification:** [what Verifier must pass]
```

**TestReport** (Verifier):

```markdown
## TestReport
**Status:** pass | fail | skipped (no test infra)
**Commands run:** [exact commands]
**Failures:** [file, test name, error excerpt — if any]
```

**ReviewFindings** (Critic — quality or security):

```markdown
## ReviewFindings
**Ship ready:** yes | no
**Critical:** [file — issue — suggested fix]
**Medium:** ...
**Low:** ...
```

**SessionHandoff** (Closer — end of `full` / large `fix`; offer to user always, write to file only if user asked):

```markdown
## SessionHandoff
**Done:** [bullet list]
**Decisions:** [non-obvious choices made]
**Files touched:** [paths]
**Verify:** `[command]`
**Next session:** `/conductor продолжи: [one line]. Context: [decisions above]`
```

Normalize `/research` or `/explore` output into **ContextMap** during synthesis — do not forward raw subagent transcripts.

### Preset phase graphs

**`full`:**

```
PipelinePlan → Scout (if context partial/missing) → ContextMap
  → Architect → TouchPointPlan
  → Builder → ChangeSet
  → Verifier → TestReport
  → Critic (/review) → ReviewFindings
  → Security? (/security if risk ≥ medium) → ReviewFindings
  → Fixer (if ship ready = no, max 2 rounds) → re-Verifier → re-Critic
  → SessionHandoff
```

**`fix`:** PipelinePlan (brief) → Builder → Verifier? → Critic if sensitive → SessionHandoff (short)

**`discover`:** PipelinePlan → Scout → ContextMap → stop (or ask user to continue with `full`)

**`gate`:** Verifier → Critic → Security? → DB-review if SQL changed → SessionHandoff

**`parallel_discover`:** invoke `subagent-orchestrator` → parallel Scouts (disjoint scopes) → merge into one ContextMap → TouchPointPlan → continue `full` or stop for user OK

**`ideate`:** `project-idea-generator` → user picks → new `full` pipeline

### Critic loop

When `ReviewFindings` has **Ship ready: no**:

1. Fixer (main agent) addresses **Critical** and **Medium** only.
2. Re-run Verifier on affected behavior.
3. Re-run Critic on updated diff.
4. **Max 2 fix rounds** — then escalate to user with open findings.

Never run Critic before Builder unless preset is `gate` or user asked review-only.

### Scout brief (copy into Task `prompt`)

```
Objective: [focused question or map request]
Scope: [directories — and what to avoid]
Deliverable: ContextMap artifact (template in ecosystem-conductor skill)
Constraints: read-only; max ~25 lines; file paths required
Return: ContextMap only — no implementation proposals beyond Recommended entry
```

### 3. Invoke correctly

For each selected tool:

**Skill** → read `~/.cursor/skills/<name>/SKILL.md`, check activation criteria, follow instructions.

**Subagent** → read `~/.cursor/agents/<name>.md` if it exists, launch Task with matching `subagent_type` and a structured brief (objective, scope, deliverable, constraints). Read `subagent-orchestrator` skill **only** when delegating parallel/noisy work — not for routing decisions.

**Parallel delegation** → invoke `subagent-orchestrator` as a **phase skill** (how to delegate), not as a competing router.

**Slash command** → equivalent to the skill/subagent above; use when the user typed `/` or when the command file is the clearest entry point.

Do not name a tool and stop — **execute** it.

### 4. Chain phases automatically

Default for preset **`full`** (medium/large implement):

```
Scout → ContextMap → Architect → TouchPointPlan → Builder → Verifier → Critic → Security? → SessionHandoff
```

Legacy shorthand (domain routing still applies):

```
discover (explore/research/fsd-map) → implement (main agent) → test (test-writer) → review (code-reviewer) → security (if risk ≥ medium)
```

Skip phases that don't apply. Never run parallel writers on the same files.

### 5. Synthesize between phases

After every subagent, exploration skill, or critic pass:

1. Normalize output to the matching **artifact template** (ContextMap, TouchPointPlan, ReviewFindings, TestReport).
2. Append one entry to **decisions_log** (phase, decision, why — 1–2 sentences).
3. State the next phase and scope in 2–4 sentences for the user.
4. Proceed — do not ask "want me to continue?" unless blocked or max critic rounds exceeded.

Do **not** forward raw subagent dumps. Do **not** start Builder on `full` without TouchPointPlan unless user gave explicit file list and scope.

### 6. Close the loop

End non-trivial work with:

1. Short summary (what ran, what changed, what verified).
2. **SessionHandoff** artifact (full template) for `full` / large tasks — so the user can paste into a new chat.
3. Open risks or gaps.

Checklist items:

- What was understood about the task/code
- Which preset and phases ran
- Which skills/subagents ran
- What changed or was found
- What was verified (tests, review)
- Open risks or gaps

## Delegation patterns

### Autonomous feature (unfamiliar area) — preset `full`

1. Scout (`codebase-research` or `fsd-project-explorer`) → **ContextMap**
2. Architect (main) → **TouchPointPlan**
3. Builder (main) — minimal implementation
4. Verifier (`test-writer` + `shell`) → **TestReport**
5. Critic (`code-reviewer`) → **ReviewFindings**
6. Critic (`security-reviewer`) — if auth/data/API touched
7. **SessionHandoff**

### Quick bug fix (known area)

1. Main agent — fix directly
2. `test-writer` — only if logic is non-trivial
3. Skip exploration and review unless fix touches sensitive surface

### Pre-PR gate (local changes)

1. `test-writer` or `shell` — green tests
2. `code-reviewer` — full diff (`/review`)
3. `security-reviewer` — if applicable (`/security`)
4. `database-reviewer` — if DB layer changed (`/db-review`)

### Pre-PR gate (GitHub PR / branch)

1. `/review-bugbot` — PR diff review
2. `/review-security` — if auth/api/data in PR

### CI red

1. `ci-investigator` — root cause
2. Main agent — fix
3. `shell` — reproduce CI command locally

### CTF web (chall + bot + OOB)

1. `ctf-web-infra-auditor` — remote API, DNS TXT, local vs remote drift (readonly)
2. Main agent — minimal fix to solve/DNS/URL prefix (not full rewrite)
3. `shell` — `solve.py --dry-run`, one controlled bot trigger
4. Re-run `/ctf-audit` only if exfil still missing

## Do Not

- Do **not** ask the user which slash command to use when routing is clear from triage.
- Do **not** list the entire ecosystem table unless they asked for help choosing.
- Do **not** skip discovery on unfamiliar cross-cutting tasks.
- Do **not** skip tests/review on non-trivial logic changes.
- Do **not** launch subagents for trivial one-file edits.
- Do **not** forward raw subagent transcripts to the user.
- Do **not** contradict a more specific skill's constraints when that skill is active.
- Do **not** start Builder on preset `full` without TouchPointPlan (unless user gave explicit scope).
- Do **not** run Critic before Builder except preset `gate` or review-only request.
- Do **not** exceed **2 critic fix rounds** without user escalation.

- Do **not** treat missing subagent types as failure — fall back to direct tools and note it briefly.

## Routing checklist

```
- [ ] Intent, complexity, context, risk classified
- [ ] Pipeline preset chosen (full/fix/discover/gate/…)
- [ ] PipelinePlan stated (if non-trivial)
- [ ] Scout → ContextMap before Architect (if preset full + context missing)
- [ ] TouchPointPlan before Builder (if preset full)
- [ ] Subagent briefs specify artifact deliverable
- [ ] Phases synthesized to artifacts — no raw dumps
- [ ] Critic loop ≤ 2 rounds
- [ ] SessionHandoff on large/full tasks
- [ ] User gets concise close-out summary
```
