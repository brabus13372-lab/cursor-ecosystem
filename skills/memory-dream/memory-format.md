# Memory file format

## MEMORY.md (index)

- Title: `# Project Memory`
- Sections: `## Topics`, `## Recent decisions`, `## Verify` (optional)
- Each topic entry: `- [name](file.md) — one-line hook`
- Never paste full memory content into the index

## Topic files

Use YAML-free markdown. Suggested sections:

```markdown
# Architecture

## Stack
- ...

## Key paths
- `src/...` — ...

## Decisions
- **2026-06-27** — Chose X over Y because ...
```

## Handoffs

`handoffs/latest.md` is the raw **SessionHandoff** from conductor. Dream merges durable facts into topic files; handoff can be trimmed after merge.

## Logs

Daily append-only. Format:

```markdown
# 2026-06-27

- Implemented auth middleware
- Blocker: Redis connection in CI
```

Dream promotes important log lines into topic files weekly.

## Global ecosystem memory

`~/.cursor/memory/MEMORY.md` tracks:
- Skills/commands/agents inventory changes
- Hook behavior
- Personal conductor preferences

Not for application project code.
