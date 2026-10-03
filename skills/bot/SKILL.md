---
name: bot
description: >-
  Telegram bots in Python on aiogram 3.x: routers, handlers, filters, FSM,
  inline keyboards, middleware, webhooks (FastAPI), schedulers, broadcasts.
  Use when adding or changing bot commands, handlers, callbacks, keyboards or
  bot bootstrap, or when the user mentions aiogram, «телеграм бот», «хендлер»,
  «команда бота», «inline-кнопки», «рассылка», «вебхук».
---

# Telegram Bot (Python + aiogram 3)

Default stack: **aiogram 3.x**. If the project uses pyrogram or another
framework, follow its patterns — never migrate unless asked.

Not for: pure parser / DB / frontend work with no Telegram touchpoint.

## 1. Read the project first

| Look for | Where |
|----------|-------|
| aiogram version | `pyproject.toml` / `requirements*.txt` |
| Entry point | `main.py`, `__main__.py`, `Dispatcher(...)` |
| Routers | `bot/handlers*.py`, `routers/`, `build_router(...)` factories |
| Dependency passing | `dp["db"] = …`, `start_polling(bot, db=…)`, middleware, closures |
| Config | `Settings` / pydantic-settings, `BOT_TOKEN`, allowed chat ids |
| Polling vs webhook | `start_polling` vs `feed_update` / `SimpleRequestHandler` |
| Outbound alerts | `notify/`, notifier classes |

**Extend the existing structure.** No parallel bot folder, no second
`Dispatcher`, no second entry point.

## 2. Structure

Typical layout (adapt names to the repo):

```
bot/
  routers/       # one Router per feature: start.py, admin.py, payments.py
  keyboards/     # keyboard builders + CallbackData classes
  middlewares/   # auth, db session, throttling
  states.py      # StatesGroup classes (only if FSM is used)
services/        # business logic — handlers call these
storage/         # repositories / DB access
config.py        # settings from env
main.py          # bootstrap
```

Handlers stay thin: **validate → call service → reply**. No SQL, HTTP calls
or 50-line bodies inside handlers.

## 3. Dependencies: pass, don't import globals

Prefer aiogram's workflow data — any keyword passed to the dispatcher is
injected into handlers by parameter name:

```python
dp = Dispatcher()
dp.include_routers(start.router, admin.router)
await dp.start_polling(bot, db=db, settings=settings)

# handler
@router.message(Command("stats"))
async def stats(message: Message, db: Database) -> None:
    ...
```

Per-request resources (a DB session per update) go in a middleware that puts
them into `data`. If the project already uses `build_router(**deps)` closures,
keep that style — consistency beats preference.

## 4. Authorization: filter at the router, not per handler

```python
admin_router = Router()
admin_router.message.filter(F.from_user.id.in_(settings.admin_ids))
admin_router.callback_query.filter(F.from_user.id.in_(settings.admin_ids))
```

- Admin/destructive actions always behind such a filter or a middleware.
- Check **user id** for permissions, chat id for "which chat may use the bot".
- Callback data is user-controlled: re-check permissions in callback handlers
  and validate every id parsed from it.

## 5. Text and parse mode

- Prefer `ParseMode.HTML` and escape all dynamic text (`html.escape`), or build
  messages with `aiogram.utils.formatting` (`Text`, `Bold`, `as_list`) which
  escapes for you.
- Avoid legacy `ParseMode.MARKDOWN` with dynamic strings — `_`, `*`, `` ` ``
  in user data break messages.
- Long messages: Telegram limit is 4096 chars — split or paginate.
- `link_preview_options=LinkPreviewOptions(is_disabled=True)` for link-heavy
  replies.

## 6. Keyboards and callbacks

Use typed `CallbackData` instead of hand-parsed strings:

```python
class OrderCb(CallbackData, prefix="order"):
    action: str
    order_id: int

builder = InlineKeyboardBuilder()
builder.button(text="Отменить", callback_data=OrderCb(action="cancel", order_id=order.id))

@router.callback_query(OrderCb.filter(F.action == "cancel"))
async def cancel(query: CallbackQuery, callback_data: OrderCb, orders: OrderService) -> None:
    await orders.cancel(callback_data.order_id, by_user=query.from_user.id)
    await query.answer("Отменено")
```

- Always `await query.answer()` — otherwise the button spinner hangs.
- `callback_data` max 64 bytes — keep payloads to ids, not text.

## 7. FSM — only for real multi-step input

```python
class Signup(StatesGroup):
    name = State()
    phone = State()
```

- Provide `/cancel` (and a cancel button) that clears state from any step.
- Validate each step; on bad input stay in the state and say what is wrong.
- Default `MemoryStorage` loses state on restart — use `RedisStorage` if the
  flow must survive restarts or the bot runs in several processes.

## 8. Long work, webhooks, idempotency

- Ack first («Запускаю…»), then do the work — never leave the user silent.
- **Webhook (FastAPI):** verify `X-Telegram-Bot-Api-Secret-Token`, then
  `await dp.feed_update(bot, Update.model_validate(payload, context={"bot": bot}))`.
  Return 200 fast; run heavy work in a background task, otherwise Telegram
  times out and **redelivers the update**.
- Because updates can be redelivered, make side-effecting handlers
  idempotent (unique constraint on `update_id` / business key, or check state
  before acting). For DB writes follow the `db` skill.

## 9. Broadcasts and outbound notifications

- Respect limits: roughly 30 messages/s overall, ~1 msg/s per chat, 20/min
  per group. Throttle broadcasts (e.g. `asyncio.sleep(0.05)` between sends).
- Catch `TelegramRetryAfter` → sleep `e.retry_after` and retry that message.
- Catch `TelegramForbiddenError` (user blocked the bot) → mark user inactive,
  continue. Never let one failure kill the loop or the scheduler.
- Reuse the single `Bot` instance for handlers, notifier and scheduler.

## 10. Bootstrap and shutdown

- Token only from settings/env; never log it or full webhook secrets.
- `DefaultBotProperties(parse_mode=ParseMode.HTML)` once in `Bot(...)`.
- Start scheduler after setup; on shutdown stop scheduler, then
  `await bot.session.close()`, then close DB pool.
- No blocking sync I/O in handlers — async drivers, `asyncio.to_thread` for
  rare sync calls.

## 11. Tests

Put logic in services and test those with pytest. Handlers can be tested by
calling them with `AsyncMock` messages when the project already does that.
Manually check: unauthorized user is denied, `/start` / help lists new
commands, long operations ack early.

## Close-out checklist

```
- [ ] Router included in Dispatcher; no second Dispatcher
- [ ] Admin/destructive handlers behind router filter or middleware
- [ ] Dynamic text escaped; message ≤ 4096 chars
- [ ] Callbacks answered; CallbackData typed; ids re-validated
- [ ] Side effects idempotent if updates can be redelivered
- [ ] Token/secrets from env; nothing logged
- [ ] Help text updated for new commands
```

## After this skill

- Logic changed → add/adjust tests (`tests` skill) and run them.
- Handlers write to the DB → follow the `db` skill; for non-trivial
  transactions get a `eco:database-reviewer` pass.
- Heavy multi-file bot work (≥3 files, new FSM flow, scheduler rework) →
  better delegated to the `eco:bot-designer` subagent.
