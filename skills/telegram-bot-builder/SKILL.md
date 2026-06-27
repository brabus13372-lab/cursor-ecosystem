---
name: telegram-bot-builder
description: >-
  Builds Telegram bots in Python with aiogram 3.x: Router, handlers, FSM,
  middleware, schedulers, notifications. Use when adding bot commands, handlers,
  keyboards, scheduler jobs, or user mentions: /bot, «телеграм бот», «aiogram»,
  «handler», «команда бота», «callback», «клавиатура», «inline-кнопки»,
  «рассылка», «бот». For heavy multi-file bot work conductor may delegate to
  /bot-agent (bot-designer subagent).
disable-model-invocation: true
after: [test-writer]
---

# Telegram Bot Builder (Python + aiogram 3)

Workflow skill for Telegram bot work in Python. Default stack: **aiogram 3.x**. Use pyrogram only if the project already uses it.

## Activation Criteria

Activate when any of the following apply:

- The user adds or changes Telegram bot commands, handlers, callbacks, or keyboards.
- Bot bootstrap, `Dispatcher`, `Router`, middleware, or scheduler integration is involved.
- Notifications/alerts via Telegram Bot API need wiring.
- A new bot module or handler file is requested.
- FSM flows, inline buttons, or chat authorization are needed.

Do **not** activate when:

- The task is pure parser/DB/frontend with no Telegram touchpoints.
- The user only wants Telegram API theory with no code.
- The project is not Python.

## Instructions

### 1. Detect the project's bot stack

| Signal | Where to look |
|--------|----------------|
| Framework | `aiogram` in `pyproject.toml` / `requirements.txt` |
| Entry | `main.py`, `__main__.py`, `run_bot`, `Dispatcher` |
| Handlers | `bot/handlers.py`, `routers/`, `build_router` factories |
| Config | `Settings`, `TELEGRAM_BOT_TOKEN`, `allowed_chat_ids` |
| Notify | `notify/telegram.py`, `AlertNotifier`, outbound messages |
| Scheduler | `scheduler/`, `asyncio` tasks alongside polling/webhook |
| Storage | sqlite/Postgres repos injected into handlers |

Record patterns before adding code. **Extend existing structure — do not invent a parallel bot folder.**

### 2. Preferred project layout

Match established projects (e.g. `promo_watcher` style):

```
project/
├── main.py              # bootstrap: Bot, Dispatcher, context setup
├── bot/
│   ├── handlers.py      # build_router(...) → Router
│   └── __init__.py
├── notify/
│   └── telegram.py      # outbound alerts (optional)
├── scheduler/
│   └── runner.py        # periodic jobs (optional)
├── config.py            # Settings from env
└── storage/             # DB layer (inject, don't couple handlers to SQL)
```

Adapt paths to the repo — the **pattern** matters: factory router, injected deps, thin handlers.

### 3. Router and handler pattern

Use aiogram 3 `Router` with a factory:

```python
def build_router(*, db: Database, allowed_chat_ids: list[int]) -> Router:
    router = Router()

    def _authorized(message: Message) -> bool:
        if not allowed_chat_ids:
            return True
        return message.chat is not None and message.chat.id in allowed_chat_ids

    @router.message(Command("start"))
    async def cmd_start(message: Message) -> None:
        if not _authorized(message):
            await message.answer("Unauthorized chat.")
            return
        await message.answer("...")

    return router
```

Rules:

- Handlers stay thin: validate → call service/repo → format reply.
- Business logic lives in services/modules — not 80-line handler bodies.
- Reuse `_authorized` or middleware — don't copy-paste auth per handler.
- Register router in bootstrap: `dp.include_router(build_router(...))`.

### 4. Bootstrap checklist

```python
bot = Bot(token=settings.telegram_bot_token, default=DefaultBotProperties(parse_mode=ParseMode.MARKDOWN))
dp = Dispatcher()
dp.include_router(build_router(...))
await dp.start_polling(bot)  # or webhook setup if project uses it
```

- Token from **env/settings only** — never hardcode.
- Set `ParseMode` explicitly if project uses Markdown/HTML.
- Close `bot.session` and DB connections on shutdown.
- If scheduler runs with bot: start after `setup()`, stop before session close.

### 5. Commands and UX

- Register with `@router.message(Command("name"))` or `Command("a", "b")` for aliases.
- `/start` should list available commands when the project has multiple commands.
- Long operations: ack first (`"Scan started…"`), then result — avoid silent hangs.
- Use `disable_web_page_preview=True` for link-heavy replies when appropriate.
- Escape Markdown/HTML special chars in dynamic content or switch parse mode safely.

### 6. FSM (when multi-step input is needed)

Use aiogram FSM only when the flow requires sequential user input:

```python
class MyStates(StatesGroup):
    waiting_input = State()

@router.message(Command("setup"))
async def cmd_setup(message: Message, state: FSMContext) -> None:
    await state.set_state(MyStates.waiting_input)
    await message.answer("Send value:")
```

- Clear state on cancel, timeout, or completion.
- Do not add FSM for single-shot commands.

### 7. Callbacks and keyboards

- `InlineKeyboardMarkup` for actions; `CallbackQuery` handlers in same router module or `callbacks.py`.
- Always `await callback.answer()` to clear loading state.
- Prefix `callback_data` consistently (`"mute:123"`) and validate parsed data.

### 8. Outbound notifications

Separate **inbound handlers** from **outbound notify** when the project already does:

- `AlertNotifier` / `notify/telegram.py` for pushes
- Handlers for user commands
- Shared `Bot` instance injected into both

Catch `TelegramAPIError`; log and continue for non-critical alerts — don't crash the scheduler.

### 9. Authorization and safety

- Restrict admin commands via `allowed_chat_ids` or role checks from settings/DB.
- Empty allowlist = open bot only if that is an explicit project choice — prefer restricting destructive commands.
- Never log bot tokens or full webhook secrets.
- Validate user-supplied IDs and text before DB writes.

### 10. Database and atomicity

When handlers touch Postgres/SQLite, read `~/.cursor/skills/database-engineer/SKILL.md`:

- multi-step writes in a transaction
- idempotent handler actions where Telegram may retry delivery

### 11. Testing and verification

- Run existing tests if present.
- For new commands: at least test handler logic (service layer) if the project has pytest.
- Manually verify: unauthorized chat denied, command list updated, long tasks ack early.

### 12. Close-out checklist

```
- [ ] Handler registered on Router; router included in Dispatcher
- [ ] Auth check on sensitive commands
- [ ] Token from env; no secrets in code
- [ ] Thin handler → service/repo delegation
- [ ] Shutdown closes bot session (and scheduler if used)
- [ ] /start or help text lists new commands
```

## Do Not

- Do **not** add pyrogram if the project uses aiogram.
- Do **not** put SQL or HTTP fetch logic inline in handlers when the project has services/repos.
- Do **not** block the event loop with sync I/O — use async drivers and `asyncio.to_thread` for rare sync work.
- Do **not** create a second `Dispatcher` or duplicate bot entrypoint.
- Do **not** skip authorization on destructive or admin commands.
- Do **not** use `Markdown` with unescaped dynamic strings containing `_`, `*`, `` ` ``.

## Stack escape hatch

If the project uses **pyrogram** instead of aiogram, follow its existing client/session patterns — do not migrate frameworks unless explicitly requested.
