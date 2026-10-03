# Eco — плагин для Claude Code

![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-7-green)
![Agents](https://img.shields.io/badge/agents-7-purple)

Персональная экосистема разработки в виде **плагина Claude Code**: доменные
скиллы, субагенты для ревью и реализации и облегчённый pipeline `/conductor`.

Эта ветка (`claude-code`) — порт Cursor-экосистемы из `master`. Доменные
знания сохранены, а всё, что Claude Code умеет сам (выбор скиллов, обёртки
slash-команд, встроенные агенты исследования, память между сессиями), убрано.

**English:** [README.md](README.md)

---

## Установка

В Claude Code:

```
/plugin marketplace add brabus13372-lab/cursor-ecosystem@claude-code
/plugin install eco@brabus-lab
```

После установки перезапусти сессию Claude Code. Чтобы
попробовать без установки, склонируй ветку и запусти
`claude --plugin-dir ./cursor-ecosystem`.

По желанию скопируй [`examples/CLAUDE.md`](examples/CLAUDE.md) в
`~/.claude/CLAUDE.md` — общие правила работы (сначала план, минимальные диффы,
самопроверка, соглашения по README). Плагин сам подключать CLAUDE.md не может.

---

## Скиллы

Все компоненты плагина в пространстве имён `eco`: скиллы вызываются как
`/eco:<имя>`, агенты называются `eco:<имя>`.

| Скилл | Вызов | Назначение |
|-------|-------|------------|
| `bot` | авто + `/eco:bot` | Telegram-боты на aiogram 3: роутеры, DI, фильтры, FSM, типизированные callback, вебхуки, рассылки |
| `db` | авто + `/eco:db` | PostgreSQL из Python: транзакции, блокировки, гонки, идемпотентность, безопасные миграции |
| `tests` | авто + `/eco:tests` | Тесты на существующем стеке проекта (pytest, FastAPI, Vitest/Jest, RTL) |
| `motion` | авто + `/eco:motion` | Централизованная система анимаций на Motion / Framer Motion для React |
| `fsd-map` | авто + `/eco:fsd-map` | Read-only карта слоёв FSD; выполняется в отдельном контексте Explore |
| `ideas` | только `/eco:ideas` | Идеи проектов с оценкой, включая юридическую и платёжную реализуемость |
| `conductor` | только `/eco:conductor` | Фазовый pipeline с пресетами `full`, `fix`, `discover`, `improve`, `gate` |

«Авто» значит, что Claude сам подгружает скилл, когда задача совпадает с его
описанием, — отдельный роутер не нужен.

## Агенты

| Агент | Пишет код | Назначение |
|-------|-----------|------------|
| `code-reviewer` | нет | Ревью локального диффа: корректность, архитектура, дублирование, тесты |
| `security-reviewer` | нет | Секреты, авторизация, инъекции, валидация, логирование |
| `database-reviewer` | нет | Атомарность, гонки, блокировки, безопасность SQL, миграции |
| `ctf-auditor` | нет | CTF web: диагностика цепочки remote chall + admin bot + OOB |
| `refactoring` | да | Рефакторинг без изменения поведения в заданных файлах |
| `bot-designer` | да | Крупная работа с aiogram (3+ файлов, FSM, планировщик, рассылки) |
| `motion-designer` | да | Крупная работа с анимациями (3+ файлов, модуль motion, аудит) |

Read-only у агентов обеспечивается списком инструментов (нет `Write`/`Edit`),
а не формулировкой в промпте. Вызов явно — `@agent-eco:code-reviewer`, либо
Claude делегирует сам по описанию.

## Conductor

```
/eco:conductor full добавить реферальную систему в бота
/eco:conductor fix двойные платежи при повторе вебхука
/eco:conductor discover как продлеваются подписки
/eco:conductor improve backend и тесты
/eco:conductor gate
```

| Пресет | Фазы |
|--------|------|
| `full` | Scout → TouchPointPlan → Build → Verify → Review → Security? |
| `fix` | Build → Verify → Review, если затронуто чувствительное |
| `discover` | Scout → ContextMap → стоп |
| `improve` | Scout → ImprovementPlan → стоп ([подробнее](skills/conductor/improve.md)) |
| `gate` | Verify → Review → Security? → DB review, если менялся SQL |

Цикл исправлений после ревью ограничен двумя раундами. Разведка идёт через
встроенный агент `Explore`, ревью — через агентов `eco:*-reviewer`.

---

## Что изменилось относительно Cursor-версии (`master`)

| Cursor | Claude Code | Почему |
|--------|-------------|--------|
| 23 slash-команды | удалены | Скиллы сами являются slash-командами |
| `ecosystem-conductor` (26 КБ + 5 документов) как авто-роутер | `conductor` (~5 КБ), только явный вызов | Claude Code сам выбирает скиллы по описаниям |
| `subagent-orchestrator` | влит в conductor (шаблон брифа) | Делегирование встроено |
| `codebase-research`, `/explore`, `/research`, `/terminal` | удалены | Встроенные агенты `Explore` / `Plan` |
| `memory-dream`, хуки, `.cursor/memory/` | удалены | Встроенная память |
| цепочки `after:` | разделы «After this skill» | Такого поля в Claude Code нет |
| `readonly: true` | `tools` / `disallowedTools` | Реально ограничивает агента |
| `disable-model-invocation` у всех скиллов | только у `conductor` и `ideas` | Доменные скиллы должны подгружаться сами |
| `install.ps1` / `install.sh` | маркетплейс плагинов | `/plugin install`, обновления из коробки |
| `/ci` → несуществующий агент `ci-investigator` | удалён | Битая ссылка |

Что улучшено в содержимом скиллов:

- **bot** — DI через workflow data, авторизация фильтрами на уровне роутера,
  типизированный `CallbackData`, HTML с экранированием вместо устаревшего
  Markdown, вебхук на FastAPI с проверкой секрета, повторная доставка апдейтов
  и идемпотентность, лимиты рассылок (`TelegramRetryAfter`,
  `TelegramForbiddenError`), выбор хранилища FSM.
- **db** — исправлен пример upsert (`postgresql.insert` + `stmt.excluded`),
  повтор всей транзакции по SQLSTATE (`40001`, `40P01`),
  `expire_on_commit=False`, один владелец commit, `lock_timeout`,
  `CONCURRENTLY` в Alembic через `autocommit_block`, ограничения `NOT VALID`,
  PgBouncer и prepared statements у asyncpg.
- **tests** — регрессионный тест обязан падать без фикса, pytest-asyncio,
  FastAPI через `ASGITransport`, dependency overrides, моки только на границах.
- **motion** — определение пакета `motion` или `framer-motion`,
  `MotionConfig reducedMotion="user"`, `LazyMotion`, ключи в `AnimatePresence`.
- **fsd-map** — выполняется в отдельном контексте Explore; проверки public API и Steiger.
- **ideas** — юрисдикция во входных данных и жёсткий фильтр по юридическим и платёжным рискам.

## Структура

```
.claude-plugin/
  plugin.json         # манифест плагина (name: eco)
  marketplace.json    # маркетплейс из одного плагина (name: brabus-lab)
skills/
  bot/ db/ tests/ motion/ fsd-map/ ideas/ conductor/
agents/
  code-reviewer.md security-reviewer.md database-reviewer.md
  refactoring.md bot-designer.md motion-designer.md ctf-auditor.md
examples/
  CLAUDE.md           # шаблон для ~/.claude/CLAUDE.md
```

## Проверка

```
claude plugin validate .
```

## Лицензия

MIT
