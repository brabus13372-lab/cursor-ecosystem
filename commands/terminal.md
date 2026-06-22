# Terminal (Subagent)

Launch the **shell** subagent for terminal-heavy work: builds, tests, git, log parsing.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator; offload noisy output here.
2. Launch the **Task** tool with:
   - `subagent_type`: `"shell"`
   - `description`: short title (e.g. "Run test suite")
   - `prompt`: structured brief (see below)
3. Summarize exit codes, key errors, and relevant output excerpts — do not paste full logs to the user.

## Subagent brief (put in Task `prompt`)

- **Objective**: run the specified commands and report results
- **Scope**: exact commands to run; working directory if not project root
- **Deliverable**: exit code + relevant stdout/stderr excerpts + interpretation
- **Constraints**: do not run destructive commands (push, deploy, rm -rf) without explicit user approval

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, run the project's standard test or build command and report pass/fail with key errors.
