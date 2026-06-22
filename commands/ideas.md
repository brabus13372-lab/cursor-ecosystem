# Project Idea Generator

Trigger the **project-idea-generator** skill — production-ready project ideas from user constraints.

## Steps

1. Read `~/.cursor/skills/project-idea-generator/SKILL.md` (skill name: `project-idea-generator`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. Normalize user inputs into a Brief block (skills, stack, time, budget, goal, audience, constraints). State assumptions if data is missing.
4. Generate 5–7 candidates internally; present 3–4 best after scoring (Interest, Production, Feasibility, Monetization, Moat).
5. Use the skill output template: ranked ideas (🥇🥈🥉), Quick pick, Next step.
6. If the user picks one idea and asks to build it, hand off to `/conductor` or the relevant domain skill (`/bot`, `/db`, `/fsd-map`, etc.) — do not auto-implement unless asked.

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, infer from workspace (stack, past projects) and ask one clarifying question only if the brief would be empty.
