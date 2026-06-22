---
name: test-writer
description: >-
  Adds or updates tests matching the project's stack (Vitest, Jest, RTL,
  Playwright, pytest). Use when writing/fixing tests, coverage, TDD, or user
  mentions: /tests, «тесты», «напиши тест», «pytest», «vitest», «jest»,
  «coverage», «regression», «упавший тест».
disable-model-invocation: true
---

# Test Writer

Adds and updates tests that match the project's existing stack, layout, and style.

## Activation Criteria

Activate this skill when any of the following apply:

- The user asks to write, add, update, or fix tests.
- You implemented a feature or bug fix and need regression coverage.
- A test file is failing and needs correction.
- The user mentions coverage, TDD, test cases, or edge cases.
- You need to verify behavior before or after a refactor.

Do **not** activate when:

- The user only wants a manual test plan with no code.
- The repository has zero test infrastructure and the user has not approved introducing one.
- The task is exploratory debugging with no expectation of test changes.

## Instructions

### 1. Detect the testing stack

Inspect the repo before writing any test. Check, in order:

| Signal | Where to look |
|--------|----------------|
| Test runner | `package.json` scripts (`test`, `test:unit`, `vitest`, `jest`), `vitest.config.*`, `jest.config.*` |
| Frontend component testing | `@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom` |
| E2E | `playwright.config.*`, `cypress.config.*`, `e2e/` folder |
| Python | `pytest.ini`, `pyproject.toml` `[tool.pytest]`, `conftest.py`, `requirements*.txt` |
| Other | `go test`, `cargo test`, `dotnet test` — follow native conventions |

Record:

- **Runner** (e.g. Vitest 2.x, Jest 29, pytest 8)
- **Assertion library** (built-in, jest-dom, chai, etc.)
- **Mocking approach** (`vi.mock`, `jest.mock`, `unittest.mock`, MSW)
- **DOM environment** (`jsdom`, `happy-dom`, none)

**Never introduce a new framework** if the project already uses one. Extend what exists.

### 2. Learn project test conventions

Read 2–3 existing test files closest to the code under test. Note:

- File naming: `*.test.ts`, `*.spec.ts`, `__tests__/`, colocated vs `tests/` root
- Import style and path aliases
- Describe/it vs test blocks, nesting depth
- Setup patterns: `beforeEach`, custom render helpers, factory functions
- How async behavior is awaited (`waitFor`, `findBy*`, `act`)
- How API calls are mocked (MSW handlers, manual mocks, dependency injection)

Mirror these conventions exactly. Do not invent a new style.

### 3. Determine test scope

Choose the narrowest effective level:

| Level | When to use |
|-------|-------------|
| Unit | Pure functions, hooks with mocked deps, reducers, utilities |
| Component | UI behavior, user interactions, conditional rendering |
| Integration | Multiple modules wired together, API + state flow |
| E2E | Critical user journeys (only if project already has E2E setup) |

Ask or infer from the user's request. Default to unit + component for frontend changes.

### 4. Identify what to test

For each change or feature, cover:

1. **Happy path** — expected behavior under normal input.
2. **Edge cases** — empty state, boundary values, null/undefined, loading, error.
3. **Regressions** — the specific bug or scenario that broke before (if applicable).
4. **Public contract** — exported API behavior, not private implementation details.

Do not test:

- Third-party library internals.
- Trivial getters with no logic.
- Implementation details (internal state variable names, private functions) unless they affect observable behavior.

### 5. Write the tests

Follow this workflow:

1. Locate or create the test file using project naming and folder rules.
2. Import the module under test and shared test utilities (`renderWithProviders`, `createWrapper`, etc.).
3. Group related cases in `describe` blocks aligned with existing files.
4. Use clear test names: `it('shows error when email is invalid')` — behavior, not method names.
5. Arrange → Act → Assert. One logical assertion focus per test when possible.
6. Prefer `@testing-library/user-event` over `fireEvent` when the project already uses it.
7. Use `vi.mock` / `jest.mock` at module scope consistent with neighboring tests.

For React components, query by role, label, or text before `data-testid`:

```typescript
expect(screen.getByRole('button', { name: /submit/i })).toBeDisabled();
```

### 6. Handle async and timers

- Always `await` user interactions and `waitFor` when UI updates asynchronously.
- Use fake timers only if neighboring tests do; call `vi.useFakeTimers()` / `jest.useFakeTimers()` in setup and restore after.
- Clean up: `afterEach` cleanup from Testing Library, reset mocks, MSW server reset.

### 7. Run and fix

Execute the project's test command for the affected scope:

```bash
# Examples — use the script that exists in package.json
npm test -- path/to/file.test.ts
npx vitest run path/to/file.test.ts
pytest path/to/test_module.py -k "pattern"
```

If tests fail:

1. Read the failure output fully.
2. Fix the test if the expectation was wrong.
3. Fix the implementation if behavior is incorrect.
4. Re-run until green.

Report the exact command run and the result.

### 8. Summarize coverage added

End with a short summary:

- Files created or updated
- Behaviors covered (happy path, edge cases, regression)
- Any intentional gaps and why (e.g. E2E not in scope)

## Do Not

- Do **not** add Vitest if the project uses Jest, or vice versa.
- Do **not** add React Testing Library to a project that tests components with Enzyme or another established library without explicit migration request.
- Do **not** snapshot entire large components unless the project already relies on snapshots for that pattern.
- Do **not** mock everything; mock external boundaries (network, timers, browser APIs), not the unit under test.
- Do **not** write tests that depend on execution order across files.
- Do **not** hardcode implementation details that will break on harmless refactors.
- Do **not** leave `it.only`, `describe.only`, `fit`, or `fdescribe` in committed code.
- Do **not** skip running tests when a runner is available.

## Quick detection checklist

```
- [ ] Runner identified from config and package.json
- [ ] Sample tests read for style reference
- [ ] Test file path matches project layout
- [ ] Mocks match project patterns (MSW / vi.mock / jest.mock)
- [ ] Happy path + edge cases + regression (if applicable) covered
- [ ] Tests executed and passing
```
