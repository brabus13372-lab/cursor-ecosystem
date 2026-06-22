# Telegram Bot Builder

Trigger the **telegram-bot-builder** skill for aiogram 3 bot work in Python.

## Steps

1. Read `~/.cursor/skills/telegram-bot-builder/SKILL.md` (skill name: `telegram-bot-builder`).
2. Check activation criteria. If they do not apply, explain briefly and stop.
3. Detect project bot layout (`build_router`, handlers, notify, scheduler) before editing.
4. Follow the skill: thin handlers, injected deps, auth on sensitive commands, no hardcoded tokens.
5. If handlers touch DB writes, also follow `database-engineer` skill for transactions.
6. For heavy multi-file bot work, delegate via `/bot-agent`.

## User context

Apply to whatever the user writes after this command. If nothing extra was provided, audit the current project's bot module and suggest one high-value improvement.
