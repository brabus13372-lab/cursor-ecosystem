# CI Investigator (Subagent)

Launch the **ci-investigator** subagent to diagnose a single failing CI check.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, summarize root cause.
2. Launch the **Task** tool with:
   - `subagent_type`: `"ci-investigator"`
   - `description`: short title (e.g. "Diagnose lint CI failure")
   - `prompt`: structured brief (see below)
3. Return a short root-cause summary and the minimal fix path — not full log dumps.

## Subagent brief (put in Task `prompt`)

- **Objective**: find root cause of the specified failing CI check
- **Scope**: check name, PR/branch, relevant workflow file, error excerpt
- **Deliverable**: root cause (1–3 sentences) + recommended fix + files to change
- **Constraints**: focus on one failing check, not the entire CI history

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, ask which CI check failed or inspect the most recent failure the user mentioned in the conversation.
