# Database Engineer (PostgreSQL + Python)

Trigger the **database-engineer** skill for Postgres **implementation** (writes, transactions, migrations).

For **audit-only** review use `/db-review` (database-reviewer), not this command.

## Steps

1. Read `~/.cursor/skills/database-engineer/SKILL.md` (skill name: `database-engineer`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. Detect the project's DB stack (SQLAlchemy, asyncpg, psycopg, Alembic, etc.) before writing code.
4. Follow the skill: explicit transactions, correct locking, parameterized SQL, safe migrations.
5. For post-change audit on non-trivial diffs, suggest or run `/db-review`.

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, review the most recent database-related code in the project or session and fix atomicity/SQL issues found.
