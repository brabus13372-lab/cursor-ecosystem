---
name: subagent-orchestrator
description: >-
  Phase skill: как делегировать subagents (briefs, parallel fan-out, synthesis).
  Use only when ecosystem-conductor routes here, user typed /orchestrate, or
  phrases like «параллельно исследуй», «оркестрируй subagents», «раздели задачу».
  Do NOT use for task triage or choosing which skill to run — that is conductor.
disable-model-invocation: true
---

# Subagent Orchestrator

Phase skill — teaches **how** to delegate subagents effectively. **Not a router.** `ecosystem-conductor` decides *what* to run; this skill defines *how* to brief, parallelize, and synthesize subagent output.

## Activation Criteria

Activate this skill when **all** of the following apply:

- Delegation is needed (parallel exploration, noisy terminal, specialized review subagent).
- **And** one of: user typed `/orchestrate`, ecosystem-conductor routed to this phase, or user explicitly asked to split/parallelize subagent work.

Do **not** activate when:

- **ecosystem-conductor is triaging or routing** the task — conductor owns tool selection; this skill only runs when conductor (or `/orchestrate`) invokes delegation.
- The task is a trivial local edit (rename, one-line fix, single known file).
- You already have sufficient context in the current thread to act immediately.
- The change touches one file and requires no discovery.
- Delegation would cost more coordination overhead than doing the work directly.
- You need to decide *which* skill or domain tool to use — use conductor instead.

## Instructions

### 1. Stay the orchestrator

The main agent owns:

- Understanding the user's goal and constraints.
- Choosing what to delegate and what to keep.
- Synthesizing subagent results into a coherent plan.
- Making final implementation decisions and applying edits (unless a subagent is explicitly tasked with a bounded, non-overlapping write).
- Reporting outcomes to the user in clear, condensed form.

The main agent does **not** need to re-run every search, read every file, or paste every subagent log into the conversation.

### 2. Decide whether to delegate

Before launching a subagent, ask:

| Question | If yes → |
|----------|----------|
| Will this produce large raw output (logs, file trees, search dumps)? | Delegate |
| Is this read-only exploration across many files? | Delegate to explore/research |
| Is this a specialized review (security, code quality, tests)? | Delegate to matching specialist |
| CTF web: remote chall + bot + OOB, no exfil yet? | Delegate to `ctf-web-infra-auditor` (readonly) before exploit edits |
| Does it require external systems (GitHub, Jira, browser, MCP)? | Delegate to MCP/terminal subagent |
| Is it a single known fix in one file? | Do it in main thread |
| Would delegation take longer than ~2 minutes of direct work? | Skip delegation |

When uncertain, prefer one focused subagent over doing everything in the main thread.

### 3. Write a clear delegation brief

Every subagent invocation must include:

1. **Objective** — one sentence: what decision or artifact you need.
2. **Scope** — directories, file patterns, or systems to touch (and what to avoid).
3. **Deliverable** — expected output format. When **ecosystem-conductor** invoked this phase (`parallel_discover` preset), scouts must return **ContextMap** artifact (see `ecosystem-conductor/SKILL.md` → Multi-agent pipeline → Artifact templates). Otherwise: summary, file list, findings table, or test plan.
4. **Constraints** — read-only vs write, time/depth limit, do-not-modify areas.
5. **Return criteria** — what to include in the final message back (findings + recommended next step, not raw dumps).

Bad brief: "Explore the codebase."
Good brief: "Map how authentication works: entry middleware, session storage, and API routes. Return a 15-line summary with file paths. Read-only. Do not propose refactors."

### 4. Choose sequential vs parallel delegation

**Sequential** — use when steps depend on each other:

```
research → plan → implement → review
```

**Parallel** — use when workstreams are independent:

```
explore (API layer)  ─┐
explore (UI layer)   ─┼→ main agent synthesizes → implement
security skim (auth) ─┘
```

Rules:

- Parallelize only independent scopes (different directories, different concerns).
- Wait for exploration results before launching implementation subagents.
- Cap parallel fan-out at what the user/task actually needs (typically 2–4 subagents).

### 5. Summarize before acting

When a subagent returns:

1. Normalize scout output to **ContextMap** when conductor pipeline is active; else extract **facts** (paths, function names, config keys, failure causes).
2. Extract **recommendations** (what to change and why).
3. **Validate** against the codebase or a quick spot-check if the claim is high-impact.
4. Discard raw logs, redundant file listings, and exploratory dead ends.
5. If parallel scouts: **merge** into one combined ContextMap before TouchPointPlan / implement.
6. State your synthesized conclusion in the main thread before editing code.

Never implement directly from an unverified subagent dump.

### 6. Separate workstreams on large tasks

For multi-step features or refactors, structure work as:

| Phase | Owner | Output |
|-------|-------|--------|
| Explore | explore/research subagent | Architecture map, touch-point list |
| Implement | main agent (or bounded writer) | Code changes |
| Review | code-reviewer / security-reviewer | Findings and severity |
| Test | test-writer subagent or skill | Test files or test plan |
| Verify | shell subagent or main agent | Command output, pass/fail |

Skip phases that add no value for small tasks.

### 7. Fall back gracefully

If no suitable subagent type exists:

- Do the work in the main thread using direct tools.
- Narrow scope instead of forcing a poor delegation match.
- Tell the user briefly that no specialist was available and what you did instead.

Do not fail or stall waiting for a subagent type that is not offered.

### 8. Close the loop

After delegated work completes:

- Report what was delegated, what came back, and what you decided.
- List remaining risks or open questions.
- Run verification (tests, lint) when implementation occurred.

## Delegation Patterns

### Pattern A: research → implement → review

Use for unfamiliar areas or cross-cutting changes.

1. **explore** subagent: map relevant modules, entry points, and conventions. Read-only.
2. **Main agent**: implement using the map; keep diffs minimal.
3. **code-reviewer** subagent: review the diff for correctness and convention fit.

### Pattern B: security review for auth / API / database changes

Use when changes touch auth, permissions, input handling, SQL, secrets, or external integrations.

1. **Main agent**: implement or draft the change.
2. **security-reviewer** subagent: check injection, auth bypass, data exposure, unsafe defaults.
3. **Main agent**: fix critical findings, summarize residual risk.

### Pattern C: test-writer after non-trivial logic changes

Use after new behavior, bug fixes, or refactors with testable contracts.

1. **Main agent**: complete implementation.
2. **test-writer** skill/subagent: detect stack, add behavior + edge-case + regression tests.
3. **shell** subagent or main agent: run tests, report results.

### Pattern D: MCP operator for external actions

Use for GitHub PRs, issue triage, CI logs, Linear/Jira, Slack, or other MCP-connected systems.

1. **MCP-capable or shell subagent**: perform the external action with explicit parameters.
2. **Main agent**: summarize outcome; never paste full API responses unless the user asks.

### Pattern E: parallel discovery

Use when the question spans disconnected areas.

- Subagent 1: trace data model and migrations.
- Subagent 2: trace UI consumption of that data.
- Subagent 3: find existing test coverage.

Main agent merges into a single plan before any edits.

### Pattern F: terminal-heavy verification

Use for build failures, test suites, log parsing, or long-running commands.

- **shell** subagent: run commands, return exit code + relevant stderr/stdout excerpts.
- **Main agent**: interpret and decide fixes; do not stream full build logs to the user.

### Pattern G: CTF web infra audit → fix → verify

Use for remote chall + admin bot + OOB (DNS/HTTP) when exploit fails, remote is flaky, or s1/s2 DNS appeared without flag.

1. Read `~/.cursor/agents/ctf-web-infra-auditor.md`.
2. **explore** (readonly): local `index.php`, bot source, `solve.py`, `PHASE*.txt`.
3. **shell** (readonly probes): curl chall/bot, dig @1.1.1.1 TXT — ≤3 bot POST per session.
4. **Main agent**: fix URL prefix, TXT, or solve flags from audit — no exploit rewrite unless audit says so.
5. **shell**: `solve.py --dry-run`, one controlled bot trigger.
6. Re-delegate audit only if OOB exfil still missing.

## Built-in Subagent Types (when available)

Match task to subagent:

| Subagent | Use for |
|----------|---------|
| `explore` | Fast read-only codebase search, file patterns, keyword discovery |
| `generalPurpose` | Multi-step research that is not pure exploration |
| `shell` | Git, builds, tests, CLI, log extraction |
| `code-reviewer` | Post-implementation quality and maintainability review |
| `security-reviewer` | Threat modeling, unsafe patterns, auth/data exposure |
| `ci-investigator` | Single failing CI check root cause |
| `codebase-research` | Deep architectural questions |
| `refactoring` | Large structured refactors with clear scope |

Custom agents in `~/.cursor/agents/` extend specialists — read the matching `.md` before Task:

| Agent file | Slash | Role |
|------------|-------|------|
| `ctf-web-infra-auditor.md` | `/ctf-audit` | Read-only chall/bot/OOB infra audit before exploit iteration |

If the environment exposes additional specialists (test design, browser, MCP), prefer them over generic agents for matching tasks.

## Do Not

- Do **not** use subagents for tiny local edits (typo, import fix, one-line conditional).
- Do **not** send multiple write-capable subagents to edit the **same files** at the same time.
- Do **not** delegate without a clear question, scope, and deliverable.
- Do **not** blindly trust subagent output — summarize and spot-check first.
- Do **not** paste full subagent transcripts into the user-facing reply.
- Do **not** delegate implementation and review to the same subagent on the same diff without a fresh pass.
- Do **not** parallelize dependent steps (e.g. implement before exploration finishes).
- Do **not** launch subagents when the main thread already has complete, verified context.
- Do **not** use exploration subagents for destructive or write operations unless explicitly scoped.
- Do **not** treat subagent failure as task failure — fall back to direct tools and report the blocker.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Subagent for a 3-line fix | Coordination overhead exceeds benefit | Edit directly in main thread |
| Two writers on `auth/` concurrently | Merge conflicts, inconsistent style | Serialize writes or split by file ownership |
| "Look around and fix things" brief | Unbounded scope, noisy output | Named deliverable + directory scope |
| Implement from 500-line explore dump | Context pollution, wrong assumptions | Require 10–20 line synthesized summary |
| Explore + implement in one subagent on huge tasks | Loses orchestration control | Split explore (subagent) and implement (main) |
| Skipping review on auth/API changes | Ships security regressions | Run security-reviewer pattern |
| Re-running identical explore twice | Wasted tokens and time | Reuse prior summary; delegate only the delta |

## Orchestration Checklist

Before delegating:

```
- [ ] Task is non-trivial (multi-file, unfamiliar, or specialized)
- [ ] Brief includes objective, scope, deliverable, constraints
- [ ] Chosen subagent type matches the work
- [ ] Parallel tasks do not overlap the same files
- [ ] Main thread will synthesize results before editing
```

After subagent returns:

```
- [ ] Key findings extracted (not raw dump forwarded)
- [ ] High-impact claims spot-checked
- [ ] Next action chosen (implement, review, ask user)
- [ ] User sees concise summary, not subagent transcript
```
