# Product Strategy Revision — Post Triangle Assessment

> Date: June 2026 | Revises: pricing-strategy.md, mvp-features.md
> Trigger: Desirability × Viability × Feasibility assessment exposed a frequency/monetization mismatch.

---

## The Core Problem (from Triangle Assessment)

```
做得出 (9) ████████████████████░  Feasibility — strongest
要不要 (7) ██████████████░░░░░░░  Desirability — frequency is the weak point
能不能赚(5) ██████████░░░░░░░░░░░  Viability — weakest, subscription model at risk

ONE-SENTENCE DIAGNOSIS:
A tool used a few times a year, wrapped in a monthly subscription.
```

**Root issue:** Receipt scanning is a low-frequency task (peaks at tax season, near-zero the rest of the year). Monthly subscriptions reward high-frequency apps. Users would subscribe in March, export, and immediately cancel → MRR collapses after tax season.

---

## The Fix: Two Coordinated Moves

### Move 1 — Reframe from "Receipt Scanner" to "Year-Round Tax Savings Tracker"

Turn the low-frequency "scan receipts" job into a high-frequency "see my money" habit by adding a **Monthly Tax Dashboard** (already scoped as feature S1 in mvp-features.md — now promoted to MUST-have for v1.1).

The dashboard gives users a reason to open the app every month, not just in April:
- "This month: $1,847 in deductible expenses tracked"
- "Estimated tax savings this year: $4,200"
- Category breakdown (pie chart)
- Month-over-month spending trend

**Frequency lever:** A monthly push notification — "You saved $340 in taxes last month" — creates a recurring ritual. Low-frequency tool → monthly habit.

### Move 2 — Pricing: Lead with Annual, De-emphasize Monthly

---

## REVISED Pricing (replaces pricing-strategy.md recommendation)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FREE                 PRO ANNUAL ★          PRO MONTHLY
  50 receipts          $39.99/year           $6.99/month
  Core scanning        = $3.33/month         (was $4.99)
  No time limit        BEST VALUE            
                       Save 52% vs monthly   
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         ↑ DEFAULT SELECTED / HIGHLIGHTED
```

### What Changed and Why

| Change | Before | After | Rationale |
|--------|--------|-------|-----------|
| Annual is the hero | Equal billing | **Annual default-selected & highlighted** | Locks in low-frequency users for a full year before they can churn |
| Monthly price raised | $4.99 | **$6.99** | Makes annual look like a steal (52% savings), and discourages "subscribe-export-cancel" abuse during tax season |
| Annual price held | $39.99 | $39.99 | Sweet spot — under $40 psychological barrier, $3.33/mo feels trivial |
| Framing | "Receipt scanner" | **"Tax savings tracker"** | Higher perceived year-round value justifies annual commitment |

### Why Raise Monthly to $6.99?

The monthly plan is now a **deliberate trap for the wrong behavior.** A user who only needs the app for tax season will:
- See $6.99/mo monthly vs $39.99/year
- Do the math: 2 months of monthly ($13.98) is already 35% of the annual price
- Most rational users → choose annual → locked in for 12 months

This converts the frequency weakness into a pricing advantage.

---

## Revised Revenue Math to $1,000 MRR

```
KEY INSIGHT: Annual subscriptions amortize to MRR.
$39.99/year = $3.33 MRR per user (recognized monthly)

To hit $1,000 MRR:
  Pure annual:   300 annual subscribers × $3.33 = $1,000 MRR
  Mixed (realistic):
    220 annual ($733 MRR) + 38 monthly ($266 MRR) = ~$1,000 MRR

Why this is MORE achievable than the old plan:
  ✓ Annual subscribers don't churn mid-year → MRR is STABLE
  ✓ Old plan: 200 monthly subs, but ~40% churn after tax season → real MRR ~$600
  ✓ New plan: annual locks revenue through the trough months
```

### The Critical Difference: Churn Resistance

```
OLD MODEL (monthly-led):
Mar ████████████ $1,000  ← tax season spike
Apr ██████████   $850
May ██████       $500     ← post-tax cliff
Jun ███          $300     ← users canceled after exporting
                 ↓ DEATH SPIRAL

NEW MODEL (annual-led):
Mar ████████████ $1,000  ← tax season annual signups
Apr ████████████ $1,000  ← annual users locked in
May ████████████ $980    ← stable
Jun ███████████  $950     ← dashboard keeps them engaged
                 ↓ SUSTAINABLE
```

---

## Feature Priority Changes (revises mvp-features.md)

| Feature | Old Priority | New Priority | Why |
|---------|-------------|--------------|-----|
| S1: Monthly Tax Dashboard | SHOULD (v1.1) | **MUST (v1.0 or fast-follow)** | This is the frequency fix — it's now core to the value prop, not a nice-to-have |
| Monthly push notifications | Not planned | **MUST (v1.1)** | "You saved $X last month" — the retention engine |
| S4: Rating prompt | SHOULD | SHOULD | Unchanged |

**Everything else in the MVP stays the same.** The triangle assessment didn't break the product — it exposed that the *monetization and framing* were misaligned with *usage frequency*. The fix is positioning + pricing + one promoted feature, not a rebuild.

---

## Updated Positioning Statement

| | Before | After |
|--|--------|-------|
| Tagline | "AI receipt scanner for freelancers" | "Track every tax deduction, all year long" |
| Category | Receipt scanner (low frequency) | Tax savings tracker (monthly habit) |
| Hero metric | Receipts scanned | **Dollars saved on taxes** |
| Subtitle | "Tax write-offs made simple" | "See your tax savings grow" |

---

## Revised Triangle (Target State)

```
                  DESIRABILITY (8) ↑
                  Dashboard + push = monthly habit
                       ▲
                      ╱ ╲
                     ╱ 8 ╲     ← was 7
                    ╱     ╲
                   ╱───────╲
       VIABILITY ─────────── FEASIBILITY
        (7) ↑                    (9)
   Annual lock-in =         Already built,
   churn-resistant MRR      dashboard is
   was 5                    low-effort add

   COMPOSITE: 7 → 8. Triangle rebalanced.
   The weak corner (Viability) is now propped up by
   annual-led pricing; frequency lifted by the dashboard.
```

---

## Action Items

1. ✅ This revision document (done)
2. ⬜ Update `lib/config/constants.dart`: monthlyPrice 4.99 → 6.99
3. ⬜ Update `lib/widgets/paywall_sheet.dart`: annual default-selected, "Save 52%" badge
4. ⬜ Update App Store copy: reposition as "tax savings tracker"
5. ⬜ Build Monthly Dashboard (feature S1) as v1.0 fast-follow
6. ⬜ Add monthly push notification scaffold
