# Cursor Ecosystem

Route across personal **skills** (`~/.cursor/skills/`) and **subagents** (`~/.cursor/agents/` + Task tool).

**Router:** `/conductor` — единственный auto-router. Остальные skills — только через slash или делегирование conductor.

## Skills → `/command`

| Command | Skill | Use when |
|---------|-------|----------|
| `/conductor` | `ecosystem-conductor` | **Auto-route** — triage, pipeline, pick tools |
| `/fsd-map` | `fsd-project-explorer` | FSD / layered frontend map (read-only) |
| `/motion` | `motion-system-builder` | ≤2 files, preset/variant, light animation |
| `/motion-agent` | `motion-designer` | ≥3 files, motion module, full audit |
| `/tests` | `test-writer` | Tests matching project stack |
| `/db` | `database-engineer` | **Implement** Postgres + Python (not audit) |
| `/bot` | `telegram-bot-builder` | ≤2 files, one handler/command |
| `/bot-agent` | `bot-designer` | ≥3 files, FSM, scheduler, multi-handler |
| `/orchestrate` | `subagent-orchestrator` | Parallel delegation **phase** (conductor invokes) |
| `/ideas` | `project-idea-generator` | Project ideas from constraints |

## Subagents → `/command`

| Command | Subagent | Use when |
|---------|----------|----------|
| `/explore` | `explore` | Fast read-only repo scan |
| `/research` | `codebase-research` | How/where/patterns with evidence |
| `/review` | `code-reviewer` | **Local** code review (`git diff`) |
| `/security` | `security-reviewer` | **Local** security audit |
| `/refactor` | `refactoring` | Safe simplification |
| `/ci` | `ci-investigator` | One failing CI check |
| `/terminal` | `shell` | Noisy builds/tests/git |
| `/db-review` | `database-reviewer` | Postgres **audit** (not implement) |
| `/bot-agent` | `bot-designer` | Heavy Telegram bot work |
| `/motion-agent` | `motion-designer` | Heavy animation work |
| `/ctf-audit` | `ctf-web-infra-auditor` | CTF web: chall + bot + OOB |
| `/agents` | hub | Subagent routing reference |

## Built-in PR review (Cursor)

| Command | Subagent | Use when |
|---------|----------|----------|
| `/review-bugbot` | `bugbot` | **GitHub PR / branch** diff review |
| `/review-security` | `security-review` | **PR** security diff |

Local pre-commit → `/review` + `/security`. GitHub PR → `/review-bugbot` + `/review-security`.

## Skill vs subagent (thresholds)

| Domain | Skill (light) | Subagent (heavy) |
|--------|---------------|------------------|
| Animation | `/motion` — ≤2 files, one component | `/motion-agent` — ≥3 files, new module |
| Bot | `/bot` — ≤2 files, one handler | `/bot-agent` — ≥3 files, FSM, scheduler |
| Database | `/db` — implement writes/migrations | `/db-review` — audit diff only |

## Full-stack workflows

```
/conductor [Preset: full] [Goal] [Constraints] [Done criteria] — multi-agent pipeline with artifacts
/conductor Preset: discover — ContextMap only
/conductor Preset: gate — tests + review before merge
/fsd-map → implement → /tests → /review
/research → TouchPointPlan → implement → /security → /review
/orchestrate — parallel scouts (conductor merges ContextMap)
/db → implement → /tests → /db-review
/bot → implement → /tests → /review
/ideas → (pick idea) → /conductor Preset: full
/ctf-audit → fix solve/DNS → /terminal → /ctf-audit
PR ready → /review-bugbot → /review-security (if sensitive)
```

## Steps

1. Non-trivial task without named tool → `/conductor` logic.
2. User typed slash → run that command directly.
3. `/orchestrate` = delegation how-to, not competing router.
4. Skills load on slash or conductor delegation (`disable-model-invocation: true` on domain skills).

## User context

The user's message after this command. Route and execute.
