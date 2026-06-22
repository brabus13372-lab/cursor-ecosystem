# Motion System

Trigger the **motion-system-builder** skill. For hands-off implementation, prefer `/motion-agent` (delegates to `motion-designer` subagent).

## Steps

1. Read `~/.cursor/skills/motion-system-builder/SKILL.md` (skill name: `motion-system-builder`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. If the task is multi-file, unfamiliar, or implementation-heavy → delegate via `/motion-agent` instead of doing everything in main thread.
4. Otherwise inspect the project's animation setup and follow the skill: centralize variants/transitions; avoid anti-patterns.

## User context

Apply to whatever the user describes after invoking this command. If nothing extra was provided, audit existing animation usage and propose or extend the shared motion module.
