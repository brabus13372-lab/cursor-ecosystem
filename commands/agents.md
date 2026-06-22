# Subagents Ecosystem

Route to subagents in `~/.cursor/agents/` + Task tool. **Routing** is owned by `/conductor` — this hub is reference only.

## Slash commands → subagents

| Command | Subagent type | Custom agent | Use when |
|---------|---------------|--------------|----------|
| `/explore` | `explore` | — | Fast read-only discovery |
| `/research` | `codebase-research` | `codebase-research.md` | How/where with evidence |
| `/review` | `code-reviewer` | `code-reviewer.md` | **Local** git diff review |
| `/security` | `security-reviewer` | `security-reviewer.md` | **Local** security audit |
| `/review-bugbot` | `bugbot` | — | **PR / branch** diff (built-in) |
| `/review-security` | `security-review` | — | **PR** security (built-in) |
| `/refactor` | `refactoring` | `refactoring.md` | Simplify without behavior change |
| `/ci` | `ci-investigator` | — | Single failing CI check |
| `/terminal` | `shell` | — | Builds, tests, noisy CLI |
| `/motion-agent` | `generalPurpose` | `motion-designer.md` | Heavy animation (≥3 files) |
| `/db-review` | `generalPurpose` | `database-reviewer.md` | Postgres audit (not implement) |
| `/bot-agent` | `generalPurpose` | `bot-designer.md` | Heavy bot work (≥3 files) |
| `/ctf-audit` | `explore` + `shell` | `ctf-web-infra-auditor.md` | CTF web infra audit |

Subagents invoke via slash, conductor pipeline phase, or explicit user request — **not** proactive auto-start.

## Orchestration

1. `/conductor` triages and picks subagents.
2. `/orchestrate` = delegation how-to for parallel work (phase skill).
3. Read `~/.cursor/agents/*.md` before Task launch.
4. Summarize subagent output — no raw dumps.

## Typical chains

```
/conductor — full pipeline
/research → implement → /tests → /review → /security
/db → /tests → /db-review
/bot → /tests → /review
PR → /review-bugbot → /review-security
/ctf-audit → fix → /terminal → /ctf-audit
```

## User context

The user's message after this command. Route per `/conductor` or matching slash command.
