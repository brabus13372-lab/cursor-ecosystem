# Research (Subagent)

Launch the **codebase-research** subagent for focused, evidence-based repository questions.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize output.
2. Read `~/.cursor/agents/codebase-research.md` — follow its research workflow and output format.
3. Launch the **Task** tool with:
   - `subagent_type`: `"codebase-research"`
   - `readonly`: `true`
   - `description`: short title for the research task
   - `prompt`: structured brief (see below)
4. Summarize the subagent's evidence-backed answer before acting on it.

## Subagent brief (put in Task `prompt`)

- **Question**: the specific thing to answer (how/where/what pattern)
- **Scope**: which areas of the repo to search first
- **Deliverable**: answer + file paths + brief evidence quotes
- **Constraints**: read-only, no speculation without evidence

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, answer: "How is the core architecture organized in this repo, and where should new code likely live?"
