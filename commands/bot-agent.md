# Bot Designer (Subagent)

Launch the **bot-designer** subagent for Telegram bot implementation only (aiogram 3).

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — stay orchestrator, synthesize output.
2. Read `~/.cursor/agents/bot-designer.md` — Telegram bot scope only.
3. Read `~/.cursor/skills/telegram-bot-builder/SKILL.md` — subagent must follow this.
4. Launch the **Task** tool with:
   - `subagent_type`: `"generalPurpose"`
   - `description`: short title (e.g. "Add /stats command handler")
   - `prompt`: structured brief + act strictly as bot-designer per `~/.cursor/agents/bot-designer.md`
5. Summarize bot changes before unrelated work continues.

## Subagent brief (put in Task `prompt`)

- **Objective**: implement, fix, or audit the specified bot feature
- **Scope**: handler files, router factory, notify/scheduler if wired; no unrelated modules
- **Deliverable**: bot changes summary or audit per bot-designer output format
- **Constraints**: aiogram 3; thin handlers; auth on admin commands; tokens from env only

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, extend the project's bot with one useful command following existing patterns.
