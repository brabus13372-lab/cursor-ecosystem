# Motion Designer (Subagent)

Launch the **motion-designer** subagent for frontend animation work only.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize output.
2. Read `~/.cursor/agents/motion-designer.md` — animation-only scope.
3. Read `~/.cursor/skills/motion-system-builder/SKILL.md` — the subagent must follow this for implementation.
4. Launch the **Task** tool with:
   - `subagent_type`: `"generalPurpose"`
   - `description`: short title (e.g. "Add modal enter/exit animation")
   - `prompt`: structured brief + instruction to act strictly as motion-designer per `~/.cursor/agents/motion-designer.md`; animation scope only
5. Summarize motion changes or audit findings before unrelated work continues.

## Subagent brief (put in Task `prompt`)

- **Objective**: implement, fix, or audit the specified animation work
- **Scope**: components/files to touch; motion module path if known
- **Deliverable**: motion changes summary or audit report per motion-designer output format
- **Constraints**: animations only; follow motion-system-builder skill; no new libraries without approval

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, audit the project's animation setup and propose one high-impact improvement.
