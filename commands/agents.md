# Subagents hub

See **[~/.cursor/agents/AGENTS.md](../agents/AGENTS.md)** for full table, roles, and Task brief templates.

## Quick invoke

| /command | Agent | Writes? |
|----------|-------|---------|
| `/research` | codebase-research | no |
| `/review` | code-reviewer | no |
| `/security` | security-reviewer | no |
| `/db-review` | database-reviewer | no |
| `/ctf-audit` | ctf-web-infra-auditor | no |
| `/refactor` | refactoring | yes (named files) |
| `/bot-agent` | bot-designer | yes (bot scope) |
| `/motion-agent` | motion-designer | yes (motion scope) |

Conductor routes critics after `full` / `coordinator` / `gate`. Coordinator preset: main agent does **not** implement — delegates to builders.

## User context

Apply to user message; launch Task with matching subagent_type and structured brief.
