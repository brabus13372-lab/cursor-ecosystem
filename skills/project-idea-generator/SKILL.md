---
name: project-idea-generator
description: >-
  Generates production-ready project ideas from constraints (stack, budget,
  timeline, audience). Use when user asks for ideas, MVP brainstorm, or
  mentions: /ideas, «идеи для проекта», «что можно сделать», «side project»,
  «стартап», «MVP», «придумай проект», «чем заняться».
disable-model-invocation: true
after: []
---

# Project Idea Generator

Turn user inputs into **interesting, shippable, production-viable** project ideas — not generic brainstorm fluff.

## Activation Criteria

Activate when any of the following apply:

- User asks for project / startup / side-project / MVP ideas.
- User provides constraints: skills, stack, budget, time, audience, domain, region.
- User wants to pick what to build next from a shortlist of directions.
- User asks "что можно сделать", "придумай идею", "идеи для проекта".

Do **not** activate when:

- User already chose a specific product and wants implementation (use domain skills instead).
- User only wants market research on one named product (answer directly).
- Request is purely theoretical with no intent to build.

## Instructions

### 1. Collect and normalize inputs

Parse everything the user gave. If critical gaps exist, infer reasonable defaults and **state assumptions explicitly** — do not block on a questionnaire unless the request is completely empty.

| Input | What to extract | Default if missing |
|-------|-----------------|-------------------|
| **Skills** | Languages, frameworks, infra experience | Infer from workspace or "full-stack web" |
| **Stack preference** | Must-use / avoid tech | Pragmatic modern defaults |
| **Time** | Hours/week, deadline | MVP in 2–4 weeks part-time |
| **Budget** | Hosting, APIs, ads | $0–20/mo bootstrap |
| **Goal** | Learn, portfolio, revenue, automate own pain | Revenue + portfolio |
| **Audience** | B2B, B2C, devs, local, niche | Pick one sharp segment |
| **Domain** | Industry, hobby, problem space | Cross with user's skills |
| **Constraints** | Solo vs team, no mobile, EU-only, etc. | Solo, web-first |
| **Anti-goals** | "Not another X", saturated niches to skip | Respect strictly |

**Normalize** into a short "Brief" block at the top of the response (5–8 bullets).

### 2. Generate ideas (internal process)

Produce **5–7 candidates**, then surface **3–4 best** after scoring. Never dump 20 vague one-liners.

For each candidate, force specificity:

- **Named user** — who exactly pays or uses daily (role, company size, geography).
- **Pain** — concrete workflow failure, not "people need better X".
- **Wedge** — why this beats spreadsheets, ChatGPT copy-paste, or incumbents *for this user*.
- **MVP** — one core loop shippable in the stated timeline.
- **Production angle** — auth, billing, data retention, or ops concern that makes it "real product", not a demo.

**Idea sources** (mix at least 3):

1. **Painkiller** — automate a tedious job the user or their domain already does.
2. **Aggregator** — unify fragmented tools/APIs into one actionable view.
3. **Vertical SaaS** — narrow industry + compliance/workflow depth.
4. **Developer tool** — CLI, MCP, bot, webhook glue for a painful integration.
5. **Content → product** — newsletter/community insight turned into tooling.
6. **Regulatory / platform shift** — new API, law, or platform rule creates fresh gap.

**Reject** ideas that fail any hard filter:

- No clear payer or retention hook.
- MVP needs > stated time by 2×.
- Commodity without wedge (e.g. "another todo app").
- Depends on scraping/ToS gray area without user OK.
- Requires team or capital the brief rules out.

### 3. Score before presenting

Score each surfaced idea 1–5 on:

| Criterion | Question |
|-----------|----------|
| **Interest** | Non-obvious, fun to build and talk about? |
| **Production fit** | Real users, data, payments, or ops on day 30? |
| **Feasibility** | Solo MVP in timeline with given stack? |
| **Monetization** | Plausible path to $ within 3–6 months? |
| **Defensibility** | Workflow lock-in, data, niche, or distribution edge? |

Present only ideas with **average ≥ 3.5**. If none qualify, say so and show best 2 with honest gaps + how to adjust inputs.

### 4. Format the response

Use the template below. Write in the **user's language** (Russian if they wrote in Russian).

Rank ideas: **🥇 recommended** → **🥈 strong alternative** → **🥉 experimental**.

After ideas, add:

- **Quick pick** — one sentence: which idea if they want revenue vs learning vs portfolio.
- **Next step** — single concrete action (e.g. "5 customer interviews with X role" or "spike: API X + auth in 1 evening").

### 5. Optional deep dive

If the user picks one idea, expand with:

- User stories (3) for MVP.
- Data model sketch (entities only).
- Week-by-week build plan matching their time budget.
- Validation checklist before writing production code.

Do not auto-start implementation unless asked.

## Output Template

```markdown
## Brief (normalized)
- Skills: …
- Stack: …
- Time: …
- Goal: …
- Audience: …
- Constraints: …
- Assumptions: …

---

## 🥇 [Idea Name] — one-liner

**For whom:** …
**Pain:** …
**Product:** …
**Why now / wedge:** …

**MVP (2–4 weeks):**
1. …
2. …
3. …

**Stack fit:** …
**Monetization:** …
**Production notes:** auth / billing / data / ops …
**Risks:** …
**Validate in 48h:** …

**Scores:** Interest X | Production X | Feasibility X | Money X | Moat X

---

(repeat for 🥈 🥉 …)

## Quick pick
…

## Next step
…
```

## Quality Bar

**Good idea signals:**

- You can describe the first paying customer by name and job title.
- MVP is one workflow, not a platform.
- Monetization ties to usage, seats, or saved hours — not "ads later".
- Interesting = specific insight about a niche, not clever branding.

**Bad patterns to avoid:**

- "AI wrapper" with no workflow ownership.
- "Marketplace" needing supply and demand on day one.
- "Social network" for broad audience.
- Feature lists without a single activation metric.

## Examples

See [examples.md](examples.md) for two full brief → output samples.
