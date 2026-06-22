# FSD Project Map

Trigger the **fsd-project-explorer** skill ecosystem workflow.

## Steps

1. Read `~/.cursor/skills/fsd-project-explorer/SKILL.md` (skill name: `fsd-project-explorer`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. Execute the skill in **read-only** mode — no file edits unless the user explicitly asks afterward.
4. Return the FSD map report using the skill's output template.

## User context

Apply the skill to whatever the user describes after invoking this command. If no extra context was provided, map the current project's frontend architecture and produce a placement guide.
