# Security Review (Subagent)

Launch the **security-reviewer** subagent for **local/session** changes.

For **GitHub PR / branch security diff** use `/review-security` instead.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize findings.
2. Read `~/.cursor/agents/security-reviewer.md` — follow its security focus areas and severity rules.
3. Launch the **Task** tool with:
   - `subagent_type`: `"security-reviewer"`
   - `description`: short title (e.g. "Security review auth flow")
   - `prompt`: structured brief (see below)
4. Report only security-relevant findings by severity. If clean, say so explicitly.

## Subagent brief (put in Task `prompt`)

- **Objective**: security audit of the specified change set
- **Scope**: files, flows, or endpoints to trace; note trust boundaries and external inputs
- **Deliverable**: security findings by severity with file, issue, exploit scenario, fix
- **Constraints**: review only unless fixes are explicitly requested; ignore cosmetic style

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, security-review the current `git diff` with focus on secrets, auth, injection, validation, and logging.
