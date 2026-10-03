# Project Idea Generator — Examples

## Example 1: Solo Python dev, B2B automation

**User input:**
> Python, PostgreSQL, немного React. 10 ч/нед, бюджет ~$15/мес. Хочу side project с реальными деньгами. Работал с парсингом и Telegram. Не хочу crypto и игры.

**Brief (normalized):**
- Skills: Python, Postgres, light React, scraping, Telegram bots
- Stack: Python backend, simple web UI
- Time: ~10 h/week → 2–3 week MVP slices
- Budget: bootstrap hosting
- Goal: revenue side project
- Audience: B2B micro-SaaS
- Constraints: no crypto/games; solo

**🥇 Promo Terms Diff Watcher for e-com managers**

**For whom:** Brand managers at DTC shops (Shopify/Woo) running 5+ influencer promo codes.

**Pain:** Influencers change bio links; promo terms (discount %, expiry) drift across Notion, email, and storefront — overspend and angry partners.

**Product:** Monitors influencer landing pages + coupon fields; diffs terms; alerts in Telegram with "approve / revert" checklist.

**Why now / wedge:** Generic price monitors ignore *promo semantics*; spreadsheets don't alert in-channel where managers already live.

**MVP:**
1. Add shop + list of promo URLs/codes
2. Daily diff on discount %, dates, copy
3. Telegram alert with before/after

**Stack fit:** Python + Postgres + aiogram; Playwright only if needed for JS-heavy pages.

**Monetization:** $29–49/mo per brand, 3 shops tier.

**Production notes:** Per-tenant data isolation; webhook retry; audit log of diffs.

**Validate in 48h:** Interview 5 Shopify ops people in TG/Reddit; mock alert screenshot.

**Scores:** 4 | 4 | 4 | 4 | 3

---

## Example 2: Frontend-heavy, portfolio + learn

**User input:**
> React, TypeScript, хочу что-то визуально крутое для портфолио. 1 месяц. Можно без монетизации.

**Brief:**
- Skills: React, TS
- Goal: portfolio + motion/UI craft
- Time: 1 month
- Monetization: optional

**🥇 Local Run Club Pace Board (public display mode)**

**For whom:** Amateur run clubs that meet weekly in parks.

**Pain:** Paper signup + WhatsApp pace groups are chaotic before the start.

**Product:** Kiosk/tablet UI: pick distance → auto pace groups → big-type countdown + route card; organizer phone edits on the fly.

**MVP:** Static pace algorithm, offline-first PWA, Framer Motion transitions, export attendance CSV.

**Why interesting:** Real-world physical UX + motion design showcase, not another dashboard.

**Monetization:** Optional later — $5/event for branded export.

**Validate in 48h:** Ask one local club organizer; film 30s demo GIF for portfolio.
