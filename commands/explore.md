# Explore (Subagent)

Launch the built-in **explore** subagent for fast, read-only codebase discovery.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize output, no raw dumps.
2. Launch the **Task** tool with:
   - `subagent_type`: `"explore"`
   - `readonly`: `true`
   - `description`: short title for the exploration
   - `prompt`: structured brief (see below)
3. When the subagent returns, summarize key findings (paths, patterns, answers) before editing anything.

## Subagent brief (put in Task `prompt`)

- **Objective**: one sentence — what you need to find or understand
- **Scope**: directories, file patterns, keywords; what to skip
- **Deliverable**: concise summary with repo-relative file paths (not a full tree dump)
- **Constraints**: read-only, no file edits

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, explore the current project structure relevant to the active task and report the top touch-points.
