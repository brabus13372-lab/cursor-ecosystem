# Global working rules

Copy into `~/.claude/CLAUDE.md` (all projects) or a project's `CLAUDE.md`.
Plugin files are not loaded as CLAUDE.md, so these rules live here as a template.

## How to work

- Complex tasks start with a short plan of 2–5 steps; trivial ones don't.
- Minimal diffs: change only what the task needs, no drive-by refactors.
- Follow the patterns already in the repo before introducing new ones.
- No hardcoded absolute paths, tokens or secrets — config and env only.
- Never restore files that were cleaned of logs or junk data.

## Finishing a task

End every code change with a self-check:

- list of changed files and what changed in each;
- imports resolve, no unused or missing ones;
- tests / lint / typecheck that exist in the project were run, with results;
- no leftover debug prints, temporary files or commented-out code.

## Documentation

- Two READMEs: `README.md` in English (primary) and `README.ru.md` in Russian.
- Keep the existing README structure; write in a detailed, official tone.

## Stack defaults (when the project doesn't say otherwise)

- Telegram bots: Python, aiogram 3.x.
- Backend: FastAPI, PostgreSQL.
