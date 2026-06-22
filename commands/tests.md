# Write Tests

Trigger the **test-writer** skill ecosystem workflow.

## Steps

1. Read `~/.cursor/skills/test-writer/SKILL.md` (skill name: `test-writer`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. Detect the project's existing test stack — do not introduce a new framework.
4. Match project conventions from 2–3 nearby test files.
5. Write or update tests, then run them and report results.

## User context

Apply the skill to whatever the user describes after invoking this command. If no extra context was provided, add tests for the most recent or currently relevant code changes in this session.
