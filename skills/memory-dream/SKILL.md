---
name: memory-dream
description: >-
  Consolidates durable project memory across sessions (MEMORY.md, topic files,
  handoffs, logs). Inspired by Claude Code autoDream. Use when user types
  /dream, «консолидируй память», «обнови MEMORY», after large sessions, or
  when conductor routes dream phase. Read-only on source code unless fixing
  stale memory facts in .cursor/memory/.
disable-model-invocation: true
after: []
---

# Memory Dream

Background-style **memory consolidation** for Cursor projects. Synthesize recent signal into durable files under `.cursor/memory/` so the next `/conductor` session orients in seconds.

## Activation

- User typed `/dream`
- Conductor preset `dream` or end of large `full` when handoff exists but memory is stale
- `.cursor/memory/.dream-state.json` says consolidation is due (see `scripts/dream-gate.mjs`)

Do **not** run when:
- No project workspace open
- User only wants a one-off answer with no persistence

## Memory layout (project)

```
.cursor/memory/
├── MEMORY.md              # Index only (~25 lines max) — pointers, not dumps
├── architecture.md        # Topic files (create as needed)
├── decisions.md
├── conventions.md
├── handoffs/
│   └── latest.md          # Last SessionHandoff from conductor
├── logs/
│   └── YYYY/MM/YYYY-MM-DD.md   # Append-only daily notes (optional)
└── .dream-state.json      # lastConsolidatedAt, sessionCount hint
```

Bootstrap: if `.cursor/memory/` missing, create it from [templates/MEMORY.md](templates/MEMORY.md). **Conductor** also auto-bootstraps on `full`/`fix`/`coordinator` — see `ecosystem-conductor/memory-layer.md`.

Global ecosystem memory (cross-project): `~/.cursor/memory/MEMORY.md` — update only when changing the Cursor skills/agents/hooks setup itself.

## Workflow (4 phases)

### Phase 1 — Orient

1. List `.cursor/memory/` (and `~/.cursor/memory/` if ecosystem work happened)
2. Read `MEMORY.md` index
3. Skim existing topic files — merge, don't duplicate
4. Read `handoffs/latest.md` if present

### Phase 2 — Gather signal

Priority order:

1. **Today's log** in `logs/` if it exists
2. **Latest handoff** — decisions, files touched, verify commands
3. **Agent transcripts** — grep narrowly only when needed:
   - Path: `~/.cursor/projects/*/agent-transcripts/**/*.jsonl`
   - Example: search for error strings, decision keywords — never read whole JSONL files
4. **Codebase spot-check** — only to fix memories that contradict current code

### Phase 3 — Consolidate

Write or update topic files. Each file: facts, decisions, conventions — not chat fluff.

**Save:**
- Architecture choices and why
- Non-obvious conventions (naming, layers, stack)
- Recurring pitfalls and fixes
- Env/commands that are project-specific

**Do NOT save:**
- Secrets, tokens, passwords
- Huge code snippets (link paths instead)
- Obvious framework defaults
- Temporary debug notes

Convert relative dates to absolute (`2026-06-27`, not "yesterday").

### Phase 4 — Prune and index

Update `MEMORY.md`:
- One line per topic: `- [Title](file.md) — hook under ~150 chars`
- Max ~25 lines, index not dump
- Remove stale pointers; resolve contradictions in topic files

Update `.dream-state.json`:

```json
{
  "lastConsolidatedAt": "2026-06-27T12:00:00.000Z",
  "note": "optional one-line summary"
}
```

## Output

Return a short **DreamReport** artifact:

```markdown
## DreamReport
**Status:** updated | noop
**Files touched:** [paths under .cursor/memory/]
**Merged:** [1–3 bullets — what was consolidated]
**Pruned:** [stale items removed, or "none"]
**Next dream:** when handoffs accumulate or weekly
```

## Gates (optional)

Run before a full dream pass on idle consolidation:

```bash
node ~/.cursor/skills/memory-dream/scripts/dream-gate.mjs
```

Exit `0` = due, `1` = skip (too soon). Conductor may ignore gate when user explicitly runs `/dream`.

## Additional resources

- Format rules: [memory-format.md](memory-format.md)
- Index template: [templates/MEMORY.md](templates/MEMORY.md)
