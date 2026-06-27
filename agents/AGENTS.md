# Agents hub

Subagents in `~/.cursor/agents/` — invoked via Task tool, slash commands, or `ecosystem-conductor` pipeline phases.

Full role matrix and orchestration rules: [agent-roles.md](../skills/ecosystem-conductor/agent-roles.md)

## Роли: Scout · Builder · Critic

| Role | Purpose | Agents |
|------|---------|--------|
| **Scout** | Read-only exploration, evidence with file paths | `codebase-research` |
| **Builder** | Bounded writes in named domain paths | `refactoring`, `bot-designer`, `motion-designer` |
| **Critic** | Read-only review/audit of diffs or infra | `code-reviewer`, `security-reviewer`, `database-reviewer`, `ctf-web-infra-auditor` |

Scouts and critics never edit project source. Builders write only within their `scope`. Never run two `writes_code: true` agents on overlapping files.

## Все агенты

| Agent | `readonly` | `writes_code` | `scope` |
|-------|------------|---------------|---------|
| `codebase-research` | true | false | — (research anywhere, no edits) |
| `code-reviewer` | true | false | — (local/session diff review) |
| `security-reviewer` | true | false | — (auth, secrets, injection, validation) |
| `database-reviewer` | true | false | — (Postgres + Python data layer) |
| `ctf-web-infra-auditor` | true | false | — (chall + bot + OOB infra audit) |
| `refactoring` | — | true | user-named files only; no drive-by refactors |
| `bot-designer` | — | true | bot handlers, routers, FSM, keyboards, scheduler paths only |
| `motion-designer` | — | true | motion modules, animation components, shared/lib/motion only |

## Task brief (readonly agents)

Include in every Scout/Critic Task `prompt`:

```
Constraints: read-only; do not edit project source files.
Deliverable: findings with file paths and concise evidence; stop when scope is answered.
```

For critics, add the diff context (`branch changes`, `uncommitted changes`) and any domain focus (security, SQL, CTF infra).

## Invocation

| Agent | Typical trigger |
|-------|-----------------|
| `codebase-research` | `/research`, conductor discover phase |
| `code-reviewer` | `/review`, conductor review phase |
| `security-reviewer` | `/security`, conductor security phase |
| `database-reviewer` | `/db-review`, post-implement DB phase |
| `ctf-web-infra-auditor` | `/ctf-audit`, CTF pipeline before solve edits |
| `refactoring` | `/refactor`, conductor cleanup phase |
| `bot-designer` | `/bot-agent`, heavy bot work (≥3 files, FSM, scheduler) |
| `motion-designer` | `/motion-agent`, ≥3 files or full motion-module work |
