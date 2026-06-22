# Orchestrate Subagents

Trigger the **subagent-orchestrator** skill — **delegation phase only**, not task routing.

Conductor (`/conductor`) decides *what* to run. This command defines *how* to parallelize and brief subagents.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` (skill name: `subagent-orchestrator`).
2. If ecosystem-conductor is already routing this task, follow conductor's pipeline — use this skill only for the delegation phase.
3. Check activation criteria. If they do not apply, do the work directly in the main thread instead.
4. Stay the orchestrator: plan delegation, write clear subagent briefs, synthesize results before acting.
5. Choose sequential or parallel delegation per the skill. Never send multiple writers to the same files concurrently.
6. Summarize subagent output for the user — no raw dumps.

## User context

Apply the skill to whatever the user describes after invoking this command. If no extra context was provided, assess the current task, propose a delegation plan (which subagents, in what order), then execute it.
