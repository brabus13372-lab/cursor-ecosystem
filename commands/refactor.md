# Refactor (Subagent)

Launch the **refactoring** subagent to simplify code without changing behavior.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator; do not run another writer on the same files in parallel.
2. Read `~/.cursor/agents/refactoring.md` — follow its plan-then-minimal-diff workflow.
3. Launch the **Task** tool with:
   - `subagent_type`: `"refactoring"`
   - `description`: short title (e.g. "Refactor auth helpers")
   - `prompt`: structured brief (see below)
4. Summarize what was refactored and confirm behavior is unchanged.

## Subagent brief (put in Task `prompt`)

- **Objective**: simplify the target code without changing business logic
- **Scope**: exact files or modules to refactor; what not to touch
- **Deliverable**: brief plan, then minimal diffs — duplication removed, naming improved, structure clearer
- **Constraints**: no new abstractions unless they clearly reduce complexity; preserve behavior

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, refactor the messiest recently touched files from the current session or `git diff`.
