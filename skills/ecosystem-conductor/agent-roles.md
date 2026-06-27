# Agent roles and tool boundaries

Coordinator-style split inspired by Claude Code `coordinatorMode` — **who may write code**.

Hub: `~/.cursor/agents/AGENTS.md`

## Role matrix

| Role | Who | `writes_code` | `readonly` | Tools / mode |
|------|-----|---------------|------------|--------------|
| Router | Conductor | No | — | Routes only |
| Coordinator | Main agent (`coordinator` preset) | **No** (feature code) | — | Task briefs, synthesis |
| Scout | `explore`, `codebase-research`, `fsd-project-explorer` | No | Yes | Read, grep, search |
| Architect | Main agent | No | — | TouchPointPlan |
| Builder | Main (`full`/`fix`) or subagents | Yes | — | Bounded by scope |
| Verifier | `test-writer`, `shell` | Tests only | — | Run tests/builds |
| Critic | `code-reviewer`, `security-reviewer`, `database-reviewer`, `ctf-web-infra-auditor` | No | Yes | `git diff`, read |
| Fixer | Main agent | Yes | — | Critical/Medium from critics |
| Closer | Conductor | No | — | SessionHandoff + handoffs/latest.md |
| Dreamer | `memory-dream` | Memory files only | — | `.cursor/memory/*` |

## Builder agents (bounded write)

| Agent | `scope` |
|-------|---------|
| `bot-designer` | bot handlers, routers, FSM, keyboards, scheduler |
| `motion-designer` | motion modules, animation components, shared/lib/motion |
| `refactoring` | user-named files only; no drive-by refactors |

## Coordinator preset

When `Preset: coordinator`: Coordinator = main thread. All feature edits go to Builder subagents or domain skills. See [coordinator-preset.md](coordinator-preset.md).

## Subagent brief constraints

Scouts/critics:

```
Constraints: read-only; do not edit project source files.
Deliverable: [artifact template from ecosystem-conductor]
```

Builders: include **scope** paths from agent frontmatter + explicit do-not-touch.

## Parallel writers

Never run two `writes_code: true` agents on overlapping files. Merge **ContextMap** before Builder delegation.

## MCP / shell

- `shell` — commands only, not architecture decisions
- Critics may use shell for `git diff`; no feature implementation
