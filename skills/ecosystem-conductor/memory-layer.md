# Memory layer (conductor integration)

Cross-session continuity inspired by Claude Code `autoDream` + `memdir`.

## Locations

| Scope | Path | Purpose |
|-------|------|---------|
| Project | `.cursor/memory/MEMORY.md` | Index for current repo |
| Project | `.cursor/memory/*.md` | Topic files |
| Project | `.cursor/memory/handoffs/latest.md` | Last SessionHandoff |
| Global | `~/.cursor/memory/MEMORY.md` | Ecosystem/skills/hooks meta |

## Bootstrap (auto)

When preset is `full`, `fix`, `coordinator`, or `improve` and `.cursor/memory/MEMORY.md` **missing**:

1. Create `.cursor/memory/`, `handoffs/`
2. Copy index from `~/.cursor/skills/memory-dream/templates/MEMORY.md`
3. Add minimal `architecture.md` / `decisions.md` stubs if task needs them
4. Do not block pipeline — bootstrap then Orient

## Orient phase

When preset is `full`, `fix`, `coordinator`, or `improve` on an active project:

1. Bootstrap if missing (above)
2. Read `MEMORY.md` + up to 3 linked topic files for the goal
3. Skim `handoffs/latest.md` if present
4. Fold into context — do not re-ask known decisions

Skip Orient if user pasted full SessionHandoff.

## Handoff persistence

At **SessionHandoff** (`full`, `coordinator`, `improve`, large `fix`):

1. Emit artifact to user
2. Write `.cursor/memory/handoffs/latest.md`
3. Suggest `/dream` when durable decisions were made

## Dream routing

| Trigger | Action |
|---------|--------|
| User `/dream` | Run `memory-dream` skill |
| Preset `dream` | memory-dream only → DreamReport |
| End of `full` / `coordinator` / `improve` | Offer `/dream` |
| `dream-gate.mjs` exit 0 | Conductor may suggest `/dream` |

## What memory is NOT

- Not a replacement for git or docs/
- Not for secrets
- Not loaded for trivial one-liner fixes
