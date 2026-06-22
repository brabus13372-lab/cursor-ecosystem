---
name: database-engineer
description: >-
  Implements PostgreSQL data access in Python: transactions, atomicity, locking,
  migrations. SQLAlchemy, asyncpg, psycopg, Alembic, raw SQL. Use when writing
  or changing queries, migrations, multi-step writes, fixing race conditions,
  or user mentions: /db, «база», «postgres», «SQL», «миграция», «транзакция»,
  «Alembic», «SQLAlchemy», «race condition», «атомарность». For audit-only
  diff review use /db-review (database-reviewer), not this skill.
disable-model-invocation: true
---

# Database Engineer (PostgreSQL + Python)

Workflow skill for correct, atomic PostgreSQL access from Python. Match the project's existing DB layer — do not introduce a new ORM or driver without need.

## Activation Criteria

Activate when any of the following apply:

- The user writes or changes SQL, ORM models, repositories, or migrations.
- Multiple rows/tables must update together (atomicity, consistency).
- Race conditions, double-spend, duplicate inserts, or lost updates are possible.
- The user asks about transactions, isolation, `FOR UPDATE`, deadlocks, or retries.
- Alembic/raw migration or schema change is involved.

Do **not** activate when:

- The user asks to **audit or review** a DB diff without implementing — use `database-reviewer` (`/db-review`) instead.
- The task is pure frontend/UI with no data layer.
- A single read-only query needs no transaction context.
- The project uses a non-Postgres database unless the user wants Postgres-specific guidance anyway.

## Instructions

### 1. Detect the project's DB stack

Inspect before writing code:

| Signal | Where to look |
|--------|----------------|
| ORM | `sqlalchemy`, `django`, `tortoise` in `requirements*.txt`, `pyproject.toml` |
| Drivers | `asyncpg`, `psycopg`, `psycopg2`, `psycopg[binary]` |
| Migrations | `alembic/`, `alembic.ini`, Django `migrations/` |
| Session pattern | `Session`, `AsyncSession`, `get_db()`, repository modules |
| Raw SQL | `execute(text(...))`, `cursor.execute`, `asyncpg` queries |

Record which stack is in use and follow its conventions.

### 2. Default transaction rules

Every multi-step write must be inside an explicit transaction:

**SQLAlchemy 2.x (sync)**

```python
with session.begin():
    session.execute(...)
    session.execute(...)
```

**SQLAlchemy 2.x (async)**

```python
async with session.begin():
    await session.execute(...)
```

**asyncpg**

```python
async with conn.transaction():
    await conn.execute(...)
```

Rules:

- One business operation = one transaction boundary unless a documented saga/outbox pattern exists.
- Never rely on implicit autocommit for multi-statement logic.
- On exception: rollback is automatic inside context managers — do not swallow errors without re-raise.
- Keep transactions **short** — no network calls, sleep, or heavy computation inside.

### 3. Choose isolation level when it matters

| Scenario | Level | Mechanism |
|----------|-------|-----------|
| Default OLTP writes | `READ COMMITTED` | Postgres default — usually enough |
| Read-then-write race (balance, inventory) | `READ COMMITTED` + row lock | `SELECT ... FOR UPDATE` |
| Consistent snapshot read across multiple queries | `REPEATABLE READ` | explicit `isolation_level` on transaction |
| Strict serializability (rare) | `SERIALIZABLE` | only when contention model demands it |

Prefer **row-level locks** (`FOR UPDATE`, `FOR UPDATE SKIP LOCKED`) over bumping isolation globally.

Example (SQLAlchemy):

```python
stmt = select(Account).where(Account.id == account_id).with_for_update()
```

### 4. Prevent common race patterns

| Problem | Fix |
|---------|-----|
| Lost update | `FOR UPDATE` or optimistic locking (`version` column + `WHERE version = :v`) |
| Duplicate insert | `UNIQUE` constraint + handle `IntegrityError`, or `INSERT ... ON CONFLICT` |
| Double processing job | `FOR UPDATE SKIP LOCKED` on job queue rows |
| Idempotent API | idempotency key table with unique constraint inside same transaction |

Always design for **constraint + handling**, not hope.

### 5. SQL safety

- **Always** parameterize: SQLAlchemy `bindparam`, `text()` with params, asyncpg `$1`, psycopg `%s`.
- Never interpolate user input into SQL strings (including f-strings and `.format`).
- Dynamic identifiers (table/column names) — allowlist only, never from user input directly.

### 6. Migrations (Alembic / SQL)

Before writing a migration:

1. Prefer backward-compatible steps for zero-downtime when production-bound.
2. Large table changes: consider batching, `CONCURRENTLY` indexes, avoid full-table locks when possible.
3. Destructive ops (`DROP`, `TRUNCATE`, mass `DELETE`) — flag explicitly; require user approval.
4. Include `downgrade()` when the project uses Alembic reversibility.

Never run destructive migrations without explicit user request.

### 7. Queries and performance basics

- Fix obvious N+1: `joinedload`, `selectinload`, or a single query with join.
- Add indexes for `WHERE`, `JOIN`, and `ORDER BY` columns used at scale — name them in migration.
- Use `EXPLAIN (ANALYZE, BUFFERS)` when the user reports slow queries (read-only).
- Paginate large lists — no unbounded `SELECT *`.

### 8. Testing database code

Match project test setup:

- pytest fixtures for DB session / test database
- transaction rollback per test (`SAVEPOINT` / nested transaction) when the project already does this
- test atomicity: assert rollback on failure, assert constraint violations, test concurrent cases when races matter

Run tests after non-trivial DB changes when a runner exists.

### 9. Close-out checklist

```
- [ ] Multi-step writes wrapped in explicit transaction
- [ ] Row locks or unique constraints where races exist
- [ ] Parameterized queries only
- [ ] Transaction scope is short
- [ ] Migration is reversible or explicitly one-way with user approval
- [ ] Tests cover happy path + failure/rollback where relevant
```

## Do Not

- Do **not** mix sync and async session patterns in the same flow.
- Do **not** hold DB connections across `await` on external APIs inside a transaction.
- Do **not** use `SERIALIZABLE` as default — it increases deadlocks and retries.
- Do **not** catch `IntegrityError` and ignore — handle or re-raise with context.
- Do **not** run `TRUNCATE`, `DROP TABLE`, or mass deletes without explicit user approval.
- Do **not** add a second ORM/driver if the project already standardized on one.

## Quick reference

```python
# Idempotent upsert (Postgres)
insert(Account).values(...).on_conflict_do_update(
    index_elements=["email"],
    set_={"name": excluded.name},
)
```

```python
# Retry on deadlock (only when measured need)
from sqlalchemy.exc import OperationalError

for attempt in range(3):
    try:
        with session.begin():
            ...
        break
    except OperationalError as e:
        if "deadlock" not in str(e).lower() or attempt == 2:
            raise
```
