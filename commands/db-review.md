# Database Review (Subagent)

Launch the **database-reviewer** subagent for PostgreSQL + Python atomicity and SQL audit.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize output.
2. Read `~/.cursor/agents/database-reviewer.md` — database scope only.
3. Read `~/.cursor/skills/database-engineer/SKILL.md` — expected patterns reference.
4. Launch the **Task** tool with:
   - `subagent_type`: `"generalPurpose"`
   - `description`: short title (e.g. "Review payment transaction atomicity")
   - `prompt`: structured brief + act strictly as database-reviewer per `~/.cursor/agents/database-reviewer.md`
5. Summarize findings by severity before implementing fixes (unless user asked to fix immediately).

## Subagent brief (put in Task `prompt`)

- **Objective**: audit changed database code for atomicity, races, SQL safety, migrations
- **Scope**: files or `git diff` range; note SQLAlchemy/asyncpg/psycopg if known
- **Deliverable**: database review report per database-reviewer output format
- **Constraints**: review only unless fixes explicitly requested; Postgres + Python focus

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, review current `git diff` for database-layer risks.
