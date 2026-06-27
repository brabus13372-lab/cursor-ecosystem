---
name: motion-system-builder
description: >-
  Centralized Framer Motion system for React + TypeScript: variants, transitions,
  micro-interactions. Use when adding animations, motion tokens, or user
  mentions: /motion, «анимация», «Framer Motion», «transition», «fadeIn»,
  «variants», «AnimatePresence», «микро-интеракции». For ≥3 files or full
  motion-module audit conductor may delegate to /motion-agent.
disable-model-invocation: true
after: [test-writer]
---

# Motion System Builder

Establishes and extends a single source of truth for animation in React + TypeScript projects using Framer Motion.

## Activation Criteria

Activate this skill when any of the following apply:

- The user wants animations, transitions, or micro-interactions in a React app.
- Framer Motion (`framer-motion`) is installed or the user wants to adopt it.
- Inline `motion` props, variants, or `transition` objects are duplicated across components.
- The user asks for a motion system, animation tokens, or shared variants.
- You are reviewing or refactoring existing Framer Motion usage.

Do **not** activate when:

- The project uses a different animation library exclusively (GSAP-only, React Spring-only) and the user did not ask to migrate.
- The change is a one-off CSS transition with no Framer Motion involved.
- The target is not React (e.g. Vue, Svelte, native mobile) unless the user wants a React-specific reference.

## Instructions

### 1. Inspect the current setup

Before writing code:

1. Confirm `framer-motion` is in `package.json`. If missing, ask before adding it.
2. Search for existing motion modules: `motion.ts`, `animations.ts`, `variants.ts`, `shared/lib/motion`, `shared/ui/motion`.
3. List how components currently animate: inline props, local variants, `AnimatePresence`, layout animations.
4. Note the project's path aliases and folder conventions (FSD `shared/lib`, `src/lib`, etc.).

Reuse and extend existing modules. Do not create a parallel motion folder if one already exists.

### 2. Choose the canonical module location

Prefer the project's established shared layer:

- FSD: `src/shared/lib/motion.ts` or `src/shared/lib/motion/index.ts`
- Non-FSD: `src/lib/motion.ts` or `src/shared/motion/index.ts`

Export a small, stable public API from one entry point. Split into sibling files only when the module grows beyond ~150 lines:

```
shared/lib/motion/
├── index.ts        # public exports
├── transitions.ts  # duration, easing tokens
├── variants.ts     # enter/exit/stagger presets
└── gestures.ts     # hover/tap presets (for focusable/interactive targets)
```

### 3. Define motion tokens

Create shared transition defaults before variants:

```typescript
export const motionDurations = {
  fast: 0.15,
  normal: 0.25,
  slow: 0.4,
} as const;

export const motionEasings = {
  standard: [0.4, 0, 0.2, 1],
  emphasized: [0.2, 0, 0, 1],
} as const;

export const baseTransition = {
  duration: motionDurations.normal,
  ease: motionEasings.standard,
};
```

Match project naming and export style (`export const` vs default export).

### 4. Create reusable variants

Define variants for common patterns. Name by behavior, not by component:

- `fadeIn`, `fadeOut`, `slideUp`, `slideDown`
- `scaleIn`, `staggerContainer`, `staggerItem`
- `modalOverlay`, `modalContent`, `dropdown`

Example shape:

```typescript
export const fadeIn = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
};
```

Rules:

- Keep variants pure data (no hooks, no side effects).
- Use `transition` at variant or child level, referencing shared tokens.
- Prefer `variants` + `initial`/`animate`/`exit` over repeating raw props in consumers.

### 5. Add micro-interaction presets

For interactive elements, export small motion wrappers or prop presets:

```typescript
export const tapScale = { whileTap: { scale: 0.97 } };
export const subtleHover = { whileHover: { scale: 1.02 } };
```

Apply presets only to elements that are naturally interactive (`button`, `a`, `[role="button"]`, or components that forward refs and keyboard handlers).

### 6. Wire consumers to the shared module

When adding or updating component animations:

1. Import from the canonical motion module.
2. Replace duplicated inline animation objects with shared variants or presets.
3. Use `AnimatePresence` at the lowest layout owner that controls mount/unmount.
4. Keep component files focused on structure; motion config lives in the shared module.

```typescript
import { fadeIn, baseTransition } from '@/shared/lib/motion';

<motion.div variants={fadeIn} initial="initial" animate="animate" exit="exit" transition={baseTransition} />
```

### 7. Respect accessibility and performance

Every implementation must follow these constraints:

- Respect `prefers-reduced-motion`: wrap animated sections with `useReducedMotion()` and fall back to static or opacity-only states.
- Do not animate `width`, `height`, `top`, `left`, or `margin` for frequent UI updates; prefer `transform` and `opacity`.
- Use `layout` prop sparingly; never on large lists or page shells without explicit need.
- Avoid `layout` + `AnimatePresence` combinations that cause visible layout thrash.
- Keep exit animations shorter than or equal to enter animations for modals and toasts.

### 8. Validate the change

After implementation:

1. Grep for leftover duplicate transition/variant literals in touched feature areas.
2. Confirm all new exports are re-exported from the motion entry point.
3. Run the project typecheck or tests if available.
4. Summarize what was centralized and which presets were added.

## Do Not

- Do **not** put `whileFocus`, `whileFocusWithin`, or focus-driven gestures on non-focusable elements (`div`, `span`, `p` without `tabIndex` and keyboard handling).
- Do **not** use `whileHover` / `whileTap` on static text blocks or layout containers that are not interactive.
- Do **not** copy-paste the same `transition={{ duration: 0.3 }}` across files; extract to shared tokens.
- Do **not** animate layout-affecting properties (width, height, margin, padding) for hover effects or list items.
- Do **not** create component-specific variant names inside the shared module (e.g. `profileCardFade`); keep variants generic and compose in the component.
- Do **not** block pointer events or break keyboard navigation for the sake of animation.
- Do **not** introduce Framer Motion when the project standardizes on another animation stack unless migration is explicitly requested.

## Anti-pattern reference

| Bad | Why | Prefer |
|-----|-----|--------|
| `whileFocus` on `<div>` | Div is not focusable; gesture never fires correctly | Use `whileHover`/`whileTap` on buttons, or make element properly focusable |
| `animate={{ width: '100%' }}` on resize | Triggers layout recalc every frame | `scaleX` transform or CSS flex |
| `layout` on every list item | Expensive layout measurements | Animate opacity/transform only, or isolate `layout` to a single wrapper |
| Inline variants in 5+ files | Drift in timing and easing | Import from `shared/lib/motion` |
