---
name: fsd-project-explorer
description: >-
  Read-only FSD/layered frontend map (app, pages, widgets, features, entities,
  shared) and placement guidance. Use when exploring FSD codebase, layer
  boundaries, or user mentions: /fsd-map, «FSD», «Feature-Sliced», «слои»,
  «куда положить», «shared/features», «архитектура фронта», «slice».
disable-model-invocation: true
after: []
---

# FSD Project Explorer

Read-only exploration skill for repositories organized with Feature-Sliced Design or a comparable layered frontend structure.

## Activation Criteria

Activate this skill when any of the following apply:

- The user asks where code should live in an FSD or layered frontend project.
- You need to understand project structure before adding, moving, or refactoring frontend code.
- The repo contains top-level slices such as `app`, `pages`, `widgets`, `features`, `entities`, or `shared` (or close equivalents like `modules`, `core`, `common`).
- The user mentions Feature-Sliced Design, FSD, slice architecture, or layer boundaries.
- You are unsure which layer owns a component, hook, API client, or utility.

Do **not** activate when:

- The task is purely backend, infrastructure, or non-frontend work with no slice context.
- You already have a confirmed layer map from this session and only need a small localized edit.
- The user explicitly asks you to modify files (this skill is exploration-only).

## Instructions

### 1. Confirm read-only mode

This skill is **read-only**. Do not create, edit, delete, or rename files. Use search, glob, and read tools only.

### 2. Locate the frontend root

Find where the sliced frontend lives. Common roots:

- `src/`
- `apps/web/src/`, `packages/ui/src/` (monorepos)
- `frontend/src/`

Record the resolved root path before continuing.

### 3. Detect architecture variant

Scan the frontend root for layer directories. Map names to FSD equivalents when they differ:

| Common folder | FSD layer |
|---------------|-----------|
| `app` | App — bootstrap, providers, routing shell |
| `pages` | Pages — route-level composition |
| `widgets` | Widgets — composite UI blocks |
| `features` | Features — user interactions and use cases |
| `entities` | Entities — business nouns (User, Product) |
| `shared` | Shared — reusable UI, lib, api, config |
| `modules` | Often maps to `features` or `entities` |
| `core` / `common` | Often maps to `shared` |

If the project uses a partial or hybrid layout, note deviations explicitly instead of forcing standard FSD names.

### 4. Build the layer map

For each detected layer, document:

1. **Path** — absolute or repo-relative directory.
2. **Purpose** — one sentence describing what belongs there in *this* repo.
3. **Key contents** — 3–8 representative folders or files (not an exhaustive listing).
4. **Public API** — how the layer exposes code (`index.ts` barrels, `public-api` segments, direct imports).

Use glob and grep to sample real structure. Prefer breadth over depth: one level of subfolders per layer is enough for the map.

### 5. Trace import rules

Infer layer dependency direction from existing code:

- Search for cross-layer imports (e.g. `from '@/features/`, `from 'shared/ui'`).
- Note whether the project uses ESLint boundaries, `eslint-plugin-boundaries`, Steiger, or custom path aliases.
- Summarize allowed import direction (typically: upper layers may import lower layers, never the reverse).

If boundary tooling exists, read its config and quote the enforced rules.

### 6. Identify placement patterns

Answer these placement questions using evidence from the repo:

- Where do API calls live? (`shared/api`, `entities/*/api`, feature-local?)
- Where do global stores or context providers live?
- Where are design-system / primitive UI components?
- Where are route definitions vs page compositions?
- Where are types, constants, and formatters?

Cite 1–2 real examples per pattern when possible.

### 7. Produce the exploration report

Return a concise report in this format:

```markdown
## FSD Map: [project or app name]

**Frontend root:** `path/to/src`
**Architecture:** Full FSD | Partial FSD | FSD-like hybrid

### Layer overview

| Layer | Path | Role in this repo |
|-------|------|-------------------|
| app | ... | ... |
| ... | ... | ... |

### Import boundaries

- Allowed: ...
- Forbidden / observed violations: ...

### Placement guide

- New page/route → ...
- New user action / flow → ...
- New business entity → ...
- Reusable button/input/hook → ...
- API client / fetcher → ...

### Notable deviations

- ...

### Suggested location for current task

[If the user has a specific feature in mind, recommend exactly one primary layer
and optional supporting layers, with reasoning tied to repo evidence.]
```

Keep the report under ~80 lines unless the user asks for exhaustive detail.

### 8. Hand off to implementation

After delivering the map, state which layer should own the requested change and which layers must **not** be used. Do not start implementing unless the user asks.

## Do Not

- Do not modify any files while using this skill.
- Do not assume strict FSD if the repo uses a documented hybrid; describe what exists.
- Do not dump full directory trees; summarize with representative examples.
- Do not recommend placing business logic in `shared` unless the repo already does so consistently.
- Do not skip the import-boundary step; layer rules are as important as folder names.
