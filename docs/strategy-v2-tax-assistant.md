# SnapDeduct v2 — Tax Assistant（税务助手）

> Branch: demo2 | Date: 2026-06-21
> Trigger: Signal #1 — real freelancer fined $8,000 by IRS for not knowing about quarterly estimated taxes
> Decision: Pivot from "receipt scanner" to "tax assistant" (receipt scanning becomes a feature, not the product)

---

## What Changed and Why

### Signal #1 (the $8,000 story)
A real post from r/freelance:
> "I ended up having to hire a CPA because I got fined $8,000 by the IRS for underpaying taxes. I freelanced for 4 years, and TurboTax NEVER told me I needed to pay quarterly estimated taxes. Not once. I genuinely thought if I owed taxes, it would tell me. $8,000 lesson that should have been free."

### The Insight
```
OLD ASSUMPTION:   Freelancers' pain = lost receipts
REAL TRUTH:       Freelancers' pain = tax ignorance + fear of penalties
                  "I don't know what I don't know, and it's costing me thousands."

Implications:
  • Willingness to pay: "avoid $8,000 penalty" >>> "organize receipts"
  • Frequency: quarterly tax reminders (4×/year + year-round anxiety) >>> annual tax season
  • Moat: tax knowledge base + reminder engine >>> receipt OCR (anyone can do it)
  • Competitor framing: we're not vs Expensify. We're vs TurboTax's failure to teach.
```

---

## Product Pivot

### From → To

| Dimension | v1 (Receipt Scanner) | v2 (Tax Assistant) |
|-----------|---------------------|-------------------|
| Core promise | "Never lose a receipt" | "Never get fined by the IRS" |
| Hero feature | Camera → OCR → categorize | Tax reminders + receipt scanning |
| Emotional hook | Organization | Safety / protection |
| Frequency | Tax season (1×/year) | Quarterly reminders (4×/year) + ongoing |
| Value prop | Save time at tax season | Save money by avoiding penalties |
| Competitor | Expensify, Foreceipt | TurboTax (its failure to warn you) |

### Feature Pyramid (V2)

```
                    ┌──────────────┐
                    │  Tax Export   │  ← CPA-ready report
                    │  (existing)   │
                    ├──────────────┤
                    │  Receipt Scan │  ← downgraded to feature
                    │  + Auto-Sort  │     (still core, but not THE product)
                    ├──────────────┤
                    │  Quarterly    │  ← NEW: proactive reminders
                    │  Tax Alerts   │     "Q2 estimated tax due in 14 days"
                    ├──────────────┤
                    │  Tax Savings  │  ← NEW: visible progress
                    │  Dashboard    │     "You've saved $4,200 this year"
                    ├──────────────┤
                    │  Deduction    │  ← NEW: education layer
                    │  Discovery    │     "You might be missing home office / SEP-IRA / depreciation"
                    └──────────────┘
```

---

## Updated Positioning

### Tagline
```
OLD: "Stop losing tax deductions"
NEW: "Don't get fined by the IRS. Know what you owe, before they do."
```

### Elevator Pitch
```
SnapDeduct is a tax assistant for US freelancers.

It scans receipts, auto-categorizes them for IRS Schedule C, and — most importantly —
reminds you about quarterly estimated taxes so you never get surprised by penalties.

TurboTax won't warn you. We will.
```

### Who This Is For (unchanged but sharper)
```
US freelancers and self-employed workers who:
• File Schedule C or 1099
• Earn $50K–$150K/year
• Do their own taxes or have a CPA
• Are vaguely anxious about making a costly tax mistake
• Don't have an MBA in tax law
```

---

## Updated Landing Page Copy

### Hero Headline
```
Don't get fined by the IRS for taxes you didn't know you owed.
```

### Sub-headline
```
SnapDeduct tracks expenses, reminds you about quarterly taxes, and exports
CPA-ready reports. Built for freelancers tired of expensive surprises.
```

### New Section: "The $8,000 Mistake"
```
A freelancer got fined $8,000 because TurboTax never told them about
quarterly estimated taxes. Not once. In four years.

This happens more than you think. The IRS doesn't care that you "didn't know."
SnapDeduct makes sure you never learn this lesson the expensive way.
```

### How It Works (updated)
```
1. SNAP — Photograph any business receipt. We read the vendor, amount, and
   date, then file it under the right IRS category.

2. KNOW — Get reminders before quarterly estimated taxes are due.
   No more "I had no idea I was supposed to pay."

3. SAVE — See exactly how much you've saved in deductions, all year.
   Export a clean report for your CPA in April.
```

---

## Pricing (unchanged from triangle revision)

```
Free: 50 receipts
Pro Annual: $39.99/year ($3.33/month) — Save 52% vs monthly
Pro Monthly: $6.99/month
```

The value framing shifts: "$40/year to avoid an $8,000 penalty" is a 200× ROI story.

---

## What This Means for Development

### Code changes needed (on Mac)

| Change | Priority | Effort |
|--------|----------|--------|
| Add quarterly tax reminder engine | v2 P0 | 3-4 days |
| Add "Tax Savings" dashboard | v2 P0 | 2 days |
| Add deduction discovery layer (education tips) | v2 P1 | 2 days |
| Update onboarding copy | v2 P1 | 0.5 day |
| Update paywall: reframe as "tax protection" | v2 P1 | 0.5 day |
| Vision OCR integration (from ML Kit) | v1 P1 | 1 day |

### What stays the same
- Receipt scanning + OCR (moves from "the product" to "feature 1 of 4")
- Export (PDF/CSV for CPA)
- Hive local storage
- Provider state management
- StoreKit 2 IAP
- Pricing

---

## Competitive Repositioning

```
v1 positioning:    Receipt scanner (vs Expensify / Foreceipt / Smart Receipts)
                    → Narrow market, low frequency, weak moat

v2 positioning:    Tax assistant (vs the IRS + TurboTax's failures)
                    → Broader fear/anxiety market, higher frequency, unique angle
                    → TurboTax isn't a competitor — it's the problem
```

### New Competitor Map
```
PROACTIVE (reminds you)        REACTIVE (you figure it out)
       │
   SnapDeduct v2               TurboTax
   (WE ARE HERE)               QuickBooks Self-Employed
       │                       
   ────┼────────────────────
       │
   Expensify                   Paper shoebox
   Foreceipt                   Camera roll
       │
     SIMPLE                      COMPLEX
```

---

## Risks of This Pivot

| Risk | Mitigation |
|------|-----------|
| Feature creep — adding quarterly reminders makes the app more complex | Keep v2 simple: reminders are ONE screen, not a full accounting suite |
| Tax advice liability — we're not CPAs, can't give official tax advice | Frame as "reminders + education," not "tax advice." Standard disclaimer. |
| Development time — adds 5-7 days to build | Worth it if it unlocks 10× willingness to pay. Validate with questionnaire first. |
| Users wanted a SIMPLE scanner, not tax software | Test this with the questionnaire. If they hate the idea, pivot back. |

---

## Next Decision Gate

```
WHEN THE QUESTIONNAIRE COMES BACK:
  If they hit "quarterly tax / fear of penalty" as a top pain → proceed with v2
  If they say "no, just lost receipts" → keep v1 direction, v2 becomes a future feature
  If both → v2 with receipt scanning as the entry hook
```
