# Code Review (Subagent)

Launch the **code-reviewer** subagent for **local/session** changes (`git diff`).

For **GitHub PR / branch diff** use `/review-bugbot` instead.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize findings.
2. Read `~/.cursor/agents/code-reviewer.md` — follow its review checklist and severity grouping.
3. Launch the **Task** tool with:
   - `subagent_type`: `"code-reviewer"`
   - `description`: short title (e.g. "Review auth changes")
   - `prompt`: structured brief (see below)
4. Present findings grouped by critical / medium / low. Do not implement fixes unless the user asks.

## Subagent brief (put in Task `prompt`)

- **Objective**: review the specified change set for correctness, architecture, duplication, complexity, missing tests
- **Scope**: files or `git diff` range to review; mention branch/base if relevant
- **Deliverable**: findings table with file, issue, reason, suggested fix — by severity
- **Constraints**: review only unless fixes are explicitly requested

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, review the current unstaged/staged changes via `git diff` and `git status`.
