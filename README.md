# Eco — Claude Code plugin

![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-7-green)
![Agents](https://img.shields.io/badge/agents-7-purple)

Personal development ecosystem packaged as a **Claude Code plugin**: domain
skills, review and builder subagents, and a lightweight `/conductor` pipeline.

This branch (`claude-code`) is the Claude Code port of the Cursor ecosystem on
`master`. It keeps the domain knowledge and drops everything Claude Code
already does natively (skill routing, slash-command wrappers, built-in
exploration agents, cross-session memory).

**Русский:** [README.ru.md](README.ru.md)

---

## Install

Inside Claude Code:

```
/plugin marketplace add brabus13372-lab/cursor-ecosystem@claude-code
/plugin install eco@brabus-lab
```

Restart the Claude Code session after installing. To try it
without installing, clone the branch and run `claude --plugin-dir ./cursor-ecosystem`.

Optionally copy [`examples/CLAUDE.md`](examples/CLAUDE.md) into
`~/.claude/CLAUDE.md` — general working rules (plan first, minimal diffs,
self-check, README conventions). Plugins cannot ship CLAUDE.md themselves.

---

## Skills

All plugin components are namespaced: skills run as `/eco:<name>`, agents are
`eco:<name>`.

| Skill | Invocation | Purpose |
|-------|------------|---------|
| `bot` | auto + `/eco:bot` | Telegram bots on aiogram 3: routers, DI, filters, FSM, typed callbacks, webhooks, broadcasts |
| `db` | auto + `/eco:db` | PostgreSQL from Python: transactions, locks, races, idempotency, safe migrations |
| `tests` | auto + `/eco:tests` | Tests in the project's existing stack (pytest, FastAPI, Vitest/Jest, RTL) |
| `motion` | auto + `/eco:motion` | Centralized Motion / Framer Motion system for React |
| `fsd-map` | auto + `/eco:fsd-map` | Read-only FSD layer map; runs in a forked Explore context |
| `ideas` | `/eco:ideas` only | Scored project ideas from constraints, incl. legal/payment feasibility |
| `conductor` | `/eco:conductor` only | Phase pipeline with presets `full`, `fix`, `discover`, `improve`, `gate` |

"auto" means Claude loads the skill on its own when the task matches its
description — no router needed.

## Agents

| Agent | Writes code | Purpose |
|-------|-------------|---------|
| `code-reviewer` | no | Review of local diff: correctness, architecture, duplication, tests |
| `security-reviewer` | no | Secrets, auth, injection, validation, logging |
| `database-reviewer` | no | Atomicity, races, locking, SQL safety, migrations |
| `ctf-auditor` | no | CTF web: remote chall + admin bot + OOB chain diagnosis |
| `refactoring` | yes | Behavior-preserving refactor of a named scope |
| `bot-designer` | yes | Heavy aiogram work (3+ files, FSM, scheduler, broadcasts) |
| `motion-designer` | yes | Heavy animation work (3+ files, motion module, audit) |

Read-only agents are enforced by their tool list (no `Write`/`Edit`), not by
prompt wording. Invoke explicitly with `@agent-eco:code-reviewer`, or let
Claude delegate by description.

## Conductor

```
/eco:conductor full add referral system to the bot
/eco:conductor fix duplicate payments on webhook retry
/eco:conductor discover how subscriptions are renewed
/eco:conductor improve backend and tests
/eco:conductor gate
```

| Preset | Phases |
|--------|--------|
| `full` | Scout → TouchPointPlan → Build → Verify → Review → Security? |
| `fix` | Build → Verify → Review if sensitive |
| `discover` | Scout → ContextMap → stop |
| `improve` | Scout → ImprovementPlan → stop ([details](skills/conductor/improve.md)) |
| `gate` | Verify → Review → Security? → DB review if SQL changed |

Review fix loop is capped at 2 rounds. Scouting uses the built-in `Explore`
agent; reviews use the `eco:*-reviewer` agents.

---

## What changed vs the Cursor version (`master`)

| Cursor | Claude Code | Why |
|--------|-------------|-----|
| 23 slash commands | removed | Skills are slash commands themselves |
| `ecosystem-conductor` (26 KB + 5 docs) as auto-router | `conductor` (~5 KB), explicit only | Claude Code routes by skill descriptions natively |
| `subagent-orchestrator` | folded into conductor (brief template) | Delegation is built in |
| `codebase-research`, `/explore`, `/research`, `/terminal` | removed | Built-in `Explore` / `Plan` agents |
| `memory-dream`, hooks, `.cursor/memory/` | removed | Built-in memory |
| `after:` chains | "After this skill" sections | Not a Claude Code field |
| `readonly: true` | `tools` / `disallowedTools` | Actually enforced |
| `disable-model-invocation` on every skill | only on `conductor`, `ideas` | Domain skills should auto-load; agents need that to rely on them |
| `install.ps1` / `install.sh` | plugin marketplace | `/plugin install`, updates included |
| `/ci` → missing `ci-investigator` agent | removed | Broken reference |

Skill content updates in this port:

- **bot** — workflow-data DI, router-level auth filters, typed `CallbackData`,
  HTML + escaping instead of legacy Markdown, FastAPI webhook with secret
  check, update redelivery and idempotency, broadcast rate limits
  (`TelegramRetryAfter`, `TelegramForbiddenError`), FSM storage choice.
- **db** — fixed upsert example (`postgresql.insert` + `stmt.excluded`),
  retries by SQLSTATE (`40001`, `40P01`) of the whole transaction,
  `expire_on_commit=False`, single commit owner, `lock_timeout`,
  `CONCURRENTLY` in Alembic `autocommit_block`, `NOT VALID` constraints,
  PgBouncer + asyncpg prepared statements.
- **tests** — "regression test must fail without the fix", pytest-asyncio,
  FastAPI `ASGITransport`, dependency overrides, boundary mocking.
- **motion** — `motion` vs `framer-motion` package detection,
  `MotionConfig reducedMotion="user"`, `LazyMotion`, keyed `AnimatePresence`.
- **fsd-map** — runs forked in the Explore agent; public-API and Steiger checks.
- **ideas** — jurisdiction input and a legal/payments hard filter.

## Layout

```
.claude-plugin/
  plugin.json         # plugin manifest (name: eco)
  marketplace.json    # single-plugin marketplace (name: brabus-lab)
skills/
  bot/ db/ tests/ motion/ fsd-map/ ideas/ conductor/
agents/
  code-reviewer.md security-reviewer.md database-reviewer.md
  refactoring.md bot-designer.md motion-designer.md ctf-auditor.md
examples/
  CLAUDE.md           # template for ~/.claude/CLAUDE.md
```

## Verify

```
claude plugin validate .
```

## License

MIT
