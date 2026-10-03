---
name: db
description: >-
  Correct PostgreSQL access from Python: transactions, atomicity, row locks,
  race conditions, idempotency, migrations (Alembic), SQLAlchemy 2.x, asyncpg,
  psycopg. Use when writing or changing queries, repositories, models,
  migrations or multi-step writes, or when the user mentions «база»,
  «postgres», «SQL», «миграция», «транзакция», «race condition»,
  «атомарность». For review-only of an existing diff use the
  eco:database-reviewer subagent instead.
---

# PostgreSQL + Python

Match the project's existing DB layer. Never add a second ORM or driver.

## 1. Detect the stack

| Signal | Where |
|--------|-------|
| ORM | `sqlalchemy`, `django`, `tortoise` in deps |
| Driver | `asyncpg`, `psycopg` (3), `psycopg2` |
| Migrations | `alembic/`, `alembic.ini`, Django `migrations/` |
| Session pattern | `async_sessionmaker`, `get_session()`, repositories, unit of work |
| Pooling | asyncpg pool, SQLAlchemy engine pool, PgBouncer in config/compose |

Write down what you found before changing code.

## 2. Transaction rules

One business operation = one transaction. Keep it short: **no network calls,
sleeps or heavy computation inside**.

```python
# SQLAlchemy 2.x async — the unit of work owns the transaction
async with session_factory() as session, session.begin():
    await repo.debit(session, from_id, amount)
    await repo.credit(session, to_id, amount)
# commit on exit, rollback on exception

# asyncpg
async with pool.acquire() as conn, conn.transaction():
    await conn.execute(...)
```

- Decide **one** owner of commit/rollback (service or unit of work). Repos
  don't commit.
- SQLAlchemy autobegins on first use — `session.begin()` must wrap the work
  from the start, or use `begin_nested()` for a savepoint inside it.
- Async SQLAlchemy: `async_sessionmaker(..., expire_on_commit=False)`,
  otherwise accessing attributes after commit triggers lazy loads that fail.
- Never mix sync and async sessions in one flow.
- Don't swallow exceptions inside the transaction block.

## 3. Races: constraint + lock, not hope

| Problem | Fix |
|---------|-----|
| Lost update (balance, stock) | `SELECT … FOR UPDATE` on the row, or optimistic `version` column with `WHERE version = :v` |
| Check-then-insert duplicates | `UNIQUE` constraint + `INSERT … ON CONFLICT` |
| Job processed twice | `FOR UPDATE SKIP LOCKED` when claiming queue rows |
| Retried request / redelivered webhook | idempotency key with a unique constraint, written in the same transaction |
| Deadlocks | lock rows in a consistent order (e.g. by id) |

Prefer row locks over raising isolation. `READ COMMITTED` (default) + locks
covers most cases; `REPEATABLE READ` for consistent multi-query reads;
`SERIALIZABLE` only with a retry loop and a real reason.

```python
stmt = select(Account).where(Account.id == account_id).with_for_update()
```

Upsert (note the Postgres dialect `insert` and `stmt.excluded`):

```python
from sqlalchemy.dialects.postgresql import insert

stmt = insert(User).values(tg_id=tg_id, name=name)
stmt = stmt.on_conflict_do_update(
    index_elements=[User.tg_id],
    set_={"name": stmt.excluded.name},
)
await session.execute(stmt)
```

Retry only serialization failures / deadlocks, and retry the **whole**
transaction, by SQLSTATE — not by matching error text:

```python
RETRYABLE = {"40001", "40P01"}  # serialization_failure, deadlock_detected

for attempt in range(3):
    try:
        async with session_factory() as session, session.begin():
            await do_work(session)
        break
    except DBAPIError as e:
        code = getattr(e.orig, "sqlstate", None) or getattr(e.orig, "pgcode", None)
        if code not in RETRYABLE or attempt == 2:
            raise
```

## 4. SQL safety

- Always bind parameters: `text("… WHERE id = :id")` + params, asyncpg `$1`,
  psycopg `%s`. No f-strings or `.format` with values.
- Dynamic identifiers (column for ORDER BY, table name): allowlist only.
- `LIKE` with user input: escape `%` and `_`.

## 5. Migrations (Alembic)

1. Autogenerate is a draft — read and fix it (enum changes, renames, server
   defaults are often wrong).
2. Production-bound changes go in backward-compatible steps: add nullable
   column → backfill in batches → add constraint → switch code → drop old.
3. Locks: set `SET lock_timeout = '5s'` in risky migrations so they fail
   instead of blocking the whole table.
4. Indexes on big tables: `CREATE INDEX CONCURRENTLY` — in Alembic inside
   `with op.get_context().autocommit_block():`.
5. New FK / CHECK on big tables: add `NOT VALID`, then `VALIDATE CONSTRAINT`
   in a separate step.
6. Write `downgrade()` when the project keeps migrations reversible.
7. `DROP`, `TRUNCATE`, mass `DELETE`/`UPDATE`: flag explicitly and get the
   user's approval before writing or running them.

## 6. Queries and performance

- Fix N+1: `selectinload` for collections, `joinedload` for many-to-one.
- Index columns used in `WHERE` / `JOIN` / `ORDER BY` at scale; name indexes.
- Paginate (keyset pagination for large tables); no unbounded `SELECT *`.
- Slow query report → `EXPLAIN (ANALYZE, BUFFERS)` on a safe environment.
- asyncpg behind PgBouncer in transaction mode → disable prepared statement
  cache (`statement_cache_size=0` / SQLAlchemy `prepared_statement_cache_size=0`).
- Size the pool for the real concurrency; release connections promptly.

## 7. Tests

- Use the project's fixtures; per-test transaction rollback if it already
  does that.
- Cover: happy path, rollback on failure (no partial writes), constraint
  violations, and the concurrent case when a race was the reason for the change.

## Close-out checklist

```
- [ ] Every multi-step write inside one explicit transaction with one owner
- [ ] Races handled by constraint and/or row lock
- [ ] Only bound parameters; identifiers allowlisted
- [ ] No I/O to external services inside a transaction
- [ ] Migration reviewed by hand; risky ops have lock_timeout / CONCURRENTLY
- [ ] Destructive ops approved by the user
- [ ] Tests cover rollback and the race that motivated the change
```

## After this skill

Non-trivial transaction or migration changes → run the tests (`tests` skill),
then a `eco:database-reviewer` pass on the diff.
