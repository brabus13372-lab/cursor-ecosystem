---
name: tests
description: >-
  Write, update or fix tests in the project's existing stack (pytest +
  pytest-asyncio, FastAPI/httpx, Vitest, Jest, React Testing Library,
  Playwright). Use when adding regression coverage after a change, fixing a
  failing test, or when the user mentions «тесты», «напиши тест», «pytest»,
  «vitest», «jest», «coverage», «упавший тест».
---

# Tests

Add and fix tests that look like the project's existing tests. Never
introduce a new framework when one exists. If the repo has **no** test
infrastructure, propose the minimal setup and wait for the user's OK.

## 1. Detect the stack

| Signal | Where |
|--------|-------|
| Python | `pyproject.toml` `[tool.pytest.ini_options]`, `pytest.ini`, `conftest.py` |
| Async Python | `pytest-asyncio` (`asyncio_mode = "auto"`?), `anyio` |
| JS runner | `package.json` scripts, `vitest.config.*`, `jest.config.*` |
| Components | `@testing-library/react`, `user-event`, `jest-dom` |
| E2E | `playwright.config.*`, `cypress.config.*` |
| Mocking | `unittest.mock`, `pytest-mock`, `respx`, `vi.mock`, `jest.mock`, MSW |

Read 2–3 tests nearest to the code under test and copy their conventions:
file naming and location, fixtures/helpers, how async and network are handled.

## 2. What to cover

1. **Happy path** of the public behavior.
2. **Edges:** empty, boundary values, `None`, invalid input, error paths.
3. **Regression:** the exact scenario of the bug being fixed.
4. Behavior, not implementation — no asserts on private helpers or internal
   state names.

Choose the narrowest level that proves the behavior: unit → integration →
E2E (E2E only if the project already has it).

## 3. Bug fixes: prove the test catches the bug

When adding a regression test for a fix, make sure it **fails without the
fix** (run it before applying the fix, or temporarily revert). A test that
passes on broken code proves nothing.

## 4. Python specifics

- Async code: follow the project's `pytest-asyncio` mode; don't mix `anyio`
  and `asyncio` markers.
- FastAPI: `httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test")`;
  override dependencies with `app.dependency_overrides`, clear them after.
- DB: reuse the project's session fixture; prefer a per-test transaction that
  rolls back over truncating tables.
- External HTTP: mock at the boundary (`respx`, `responses`) — never hit real
  services in unit tests.
- aiogram: test the service layer; handlers only with `AsyncMock` messages if
  the project already does so.

## 5. JS / React specifics

- Query by role / label / text before `data-testid`:
  `screen.getByRole('button', { name: /submit/i })`.
- `await` `user-event` interactions; use `findBy*` / `waitFor` for async UI.
- Fake timers only if neighbors use them; restore after.
- Reset mocks and MSW handlers between tests.

## 6. Run, fix, report

Run only the affected scope first, then the related suite:

```bash
pytest path/to/test_file.py -k name -q
npx vitest run path/to/file.test.ts
```

On failure: read the full output; fix the test if the expectation was wrong,
fix the code if behavior is wrong; re-run until green. Never "fix" by
loosening an assertion until it passes meaninglessly.

Report: files touched, behaviors covered, exact commands and results,
intentional gaps.

## Do not

- Add a second test framework or assertion library.
- Snapshot large components unless the project already does that.
- Mock the unit under test; mock only external boundaries.
- Leave `.only`, `fit`, `@pytest.mark.skip` without a reason, or debug prints.
- Make tests depend on order, real time, network or random seeds.
