# Cursor Ecosystem

Route across **skills** (`~/.cursor/skills/`), **subagents** (`~/.cursor/agents/`), **commands** (`~/.cursor/commands/`).

**Router:** `/conductor` — единственный auto-router.

**Memory:** `.cursor/memory/` per project + `~/.cursor/memory/` global. Hook `sessionStart` injects MEMORY. `/dream` consolidates.

**Hub:** [agents/AGENTS.md](~/.cursor/agents/AGENTS.md)

## Presets (`/conductor`)

| Preset | When |
|--------|------|
| `full` | Default large implement |
| `coordinator` | Multi-domain — main routes, subagents build |
| `fix` | Known bug |
| `discover` | Research only |
| `gate` | Pre-merge verify |
| `parallel_discover` | Parallel scouts |
| `ideate` | `/ideas` → pick → continue |
| `improve` | `/improve` — Scout → ImprovementPlan |
| `ctf` | CTF web pipeline |
| `dream` | Memory consolidation |

## Skills → `/command`

| Command | Skill | `after:` chain |
|---------|-------|----------------|
| `/conductor` | ecosystem-conductor | — |
| `/dream` | memory-dream | — |
| `/fsd-map` | fsd-project-explorer | — |
| `/motion` | motion-system-builder | → `/tests` |
| `/tests` | test-writer | conductor → verify → review |
| `/db` | database-engineer | → `/tests` → `/db-review` |
| `/bot` | telegram-bot-builder | → `/tests` |
| `/orchestrate` | subagent-orchestrator | — |
| `/ideas` | project-idea-generator | → user picks preset |
| `/improve` | ecosystem-conductor (`improve`) | → user picks → `full` |

## Subagents → `/command`

| Command | Agent | readonly |
|---------|-------|----------|
| `/research` | codebase-research | yes |
| `/review` | code-reviewer | yes |
| `/security` | security-reviewer | yes |
| `/db-review` | database-reviewer | yes |
| `/ctf-audit` | ctf-web-infra-auditor | yes |
| `/refactor` | refactoring | bounded write |
| `/bot-agent` | bot-designer | bot scope |
| `/motion-agent` | motion-designer | motion scope |
| `/explore` | explore | yes |
| `/terminal` | shell | — |
| `/ci` | ci-investigator | — |

## Workflows

```
/conductor Preset: coordinator  — delegate builders, no feature code in main
/conductor Preset: improve     — Scout → ImprovementPlan → pick → full
/conductor Preset: full         — Orient → pipeline → handoff → /dream?
/dream                          — consolidate memory
/db → auto /tests → /db-review
/bot, /motion → auto /tests
```

## User context

Route and execute per user message.
