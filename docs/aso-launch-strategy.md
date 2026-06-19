# SnapDeduct — ASO & Launch Strategy

> Phase 4 Deliverable | Ready to copy-paste into App Store Connect
> Product: SnapDeduct — AI receipt scanner for US freelancers
> Goal: $1,000 MRR within 3 months

---

# PART 1: APP STORE LISTING (Copy-Paste Ready)

## App Name (30 char max)
```
SnapDeduct: Tax Savings Tracker
```
*(29 chars — repositions from "scanner" to ongoing value)*

## Subtitle (30 char max)
```
See your tax savings grow
```
*(25 chars — monthly habit hook)*

**Alternate subtitle options to A/B test:**
- `Snap receipts, save on taxes` (28)
- `Expense tracker for freelancers` (31 — too long, trim)
- `Scan receipts, track expenses` (29)

---

## Keywords Field (100 char max, comma-separated, NO spaces)

```
receipt,scanner,expense,tracker,tax,deduction,freelancer,mileage,1099,schedule c,business,write off
```
*(99 chars — every char counts; do NOT repeat words from the app name/subtitle)*

**Keyword research rationale:**

| Keyword | Search Volume | Competition | Why Include |
|---------|--------------|-------------|-------------|
| receipt | High | High | Core term, must rank |
| scanner | High | Med | Pairs with receipt |
| expense | High | High | Broad intent |
| tracker | High | Med | "expense tracker" combo |
| tax | High | High | Seasonal spike |
| deduction | Med | Low | High intent, our niche |
| freelancer | Med | Low | Our exact audience |
| mileage | Med | Low | Gig worker hook |
| 1099 | Med | Low | US freelancer tax form |
| schedule c | Low | Low | Self-employed tax form |
| business | High | High | Broad |
| write off | Med | Low | Emotional, our angle |

**Note:** Apple combines name + subtitle + keywords field for indexing. Words already in name ("receipt", "scanner") and subtitle ("tax", "write-off") don't need repeating — but I've included some for combination ranking (e.g. "receipt scanner" + "receipt tracker").

---

## Promotional Text (170 char max — changeable anytime without review)

```
Tax season is coming. Stop digging through your camera roll. Snap every receipt, let AI sort it into IRS categories, and export a clean report for your CPA in seconds.
```
*(167 chars — update this seasonally; push hard Jan-April)*

---

## Description (4000 char max)

```
Stop losing money to lost receipts.

If you're a freelancer, contractor, or self-employed, every receipt you can't find at tax time is money left on the table. SnapDeduct makes tracking business expenses effortless — so you keep more of what you earn.

HOW IT WORKS
1. Snap — Open the app, the camera's already on. Photograph any receipt.
2. Sort — AI instantly reads the vendor, amount, and date, then files it under the right IRS Schedule C category.
3. Export — At tax time, tap once to export a clean PDF or CSV for your accountant.

That's it. No accounting degree required.

BUILT FOR FREELANCERS, NOT CORPORATIONS
Most expense apps are bloated tools built for 500-person companies with approval workflows you'll never use. SnapDeduct does one thing brilliantly: capture your deductible expenses so you're ready for tax season.

• Designers, writers, photographers, consultants
• Uber & Lyft drivers, DoorDash & Instacart couriers
• Etsy sellers, coaches, and every 1099 worker

SMART AI CATEGORIZATION
SnapDeduct auto-sorts receipts into the categories the IRS actually uses — Advertising, Meals, Travel, Office Supplies, Software, and more. Correct it once, and it learns your habits.

TAX-READY EXPORTS
Generate professional PDF reports grouped by category with totals, or export a CSV your CPA can drop straight into their software. IRS-compliant digital recordkeeping (Rev. Proc. 97-22).

YOUR DATA STAYS YOURS
Receipts are stored on your device. We never sell your data. No bank account linking required.

PRICING
• Free: Scan up to 50 receipts — no credit card, no time limit
• Pro Annual: $39.99/year ($3.33/month) — best value, save 52% vs monthly
• Pro Monthly: $6.99/month — full access, cancel anytime

Start with 50 free receipts today. See how much you've been missing.

—

Questions? support@snapdeduct.com
Privacy Policy: https://snapdeduct.com/privacy
Terms of Use: https://snapdeduct.com/terms
```

---

## What's New (version notes for v1.0.0)
```
Welcome to SnapDeduct! 🎉

The simplest way for freelancers to track receipts and maximize tax deductions.

• Snap receipts with AI-powered scanning
• Auto-categorize into IRS Schedule C categories
• Export tax-ready PDF & CSV reports
• 50 free receipts to start

Built with ❤️ for freelancers. Got feedback? Email us — we read every message.
```

---

# PART 2: SCREENSHOTS PLAN (6.7" iPhone — required)

Apple shows the first 2-3 screenshots in search. They must sell in 2 seconds.

| # | Screenshot | Caption Overlay | Purpose |
|---|-----------|-----------------|---------|
| 1 | Camera scanning a receipt | "Snap any receipt in seconds" | Show the core action |
| 2 | Result sheet with AI-extracted data | "AI reads it instantly" | Show the magic |
| 3 | Receipt list with summary card | "$1,847 in deductions tracked" | Show the value/money |
| 4 | Category breakdown | "Auto-sorted for your taxes" | Show organization |
| 5 | Export/PDF screen | "One tap to send your CPA" | Show the payoff |
| 6 | Pricing/value | "50 receipts free. No card needed." | Remove friction |

**Design notes:**
- Bold caption at top, screenshot below (standard high-converting layout)
- Use brand blue (#007AFF) accents
- Show REAL-looking data (Starbucks $4.75, Adobe $59.99) not lorem ipsum
- First screenshot = the "snap" moment (most important)

**App Preview video (optional, 15-30s):**
Open app → snap receipt → watch AI fill in details → see it in list → tap export. Silent-friendly with captions.

---

# PART 3: PRE-LAUNCH CHECKLIST

## App Store Connect Setup
- [ ] Apple Developer account active ($99/yr paid)
- [ ] Bundle ID registered: com.snapdeduct.app
- [ ] App created in App Store Connect
- [ ] Banking info added (Hong Kong account)
- [ ] Tax forms completed (W-8BEN for non-US)
- [ ] Agreements signed (Paid Apps Agreement)

## In-App Purchases
- [ ] Create subscription group "SnapDeduct Pro"
- [ ] Monthly: com.snapdeduct.pro.monthly — $4.99
- [ ] Annual: com.snapdeduct.pro.annual — $39.99
- [ ] Add localized display names + descriptions
- [ ] Submit IAPs WITH the first app version (or they won't review)

## Legal (required or rejection)
- [ ] Privacy Policy live at snapdeduct.com/privacy
- [ ] Terms of Use live at snapdeduct.com/terms
- [ ] Privacy "nutrition label" filled in App Store Connect
  - Data collected: None linked to identity (receipts stay on-device)
- [ ] Add privacy/terms links in app Settings (already in code)

## Build
- [ ] Camera + photo permissions in Info.plist (DONE ✅)
- [ ] App icon (1024×1024, no alpha, no rounded corners)
- [ ] Launch screen
- [ ] Test on real device via TestFlight
- [ ] Demo account NOT needed (no login) — but add review notes explaining the 50-receipt free tier

## App Review Notes (paste in "Notes for Reviewer")
```
SnapDeduct is a receipt scanner for freelancers. No login required.

To test:
1. Open app, complete the 3-screen onboarding
2. Tap the shutter button on the Camera tab to scan a receipt (or pick from gallery)
3. AI extracts vendor/amount/category — edit if needed, tap Save
4. View saved receipts on the Receipts tab
5. Tap any receipt to see detail + export options

The free tier allows 50 receipts. Pro subscription ($4.99/mo or $39.99/yr) unlocks unlimited scans. IAPs are included in this submission.

Receipt data is stored locally on device. No accounts, no server.
```

---

# PART 4: LAUNCH SEQUENCE (Week by Week)

## Week 0: Soft Launch
- [ ] Submit to App Store (allow 1-3 days review)
- [ ] Set up landing page (snapdeduct.com) — simple, one CTA
- [ ] Set up @snapdeduct on X/Twitter + Instagram
- [ ] Prepare Reddit/PH assets

## Week 1: Reddit Launch (organic, free)
Target subreddits (read rules first, provide value, don't spam):
- r/freelance (500k+) — "I built a receipt app because I kept losing deductions"
- r/iosapps — show-and-tell
- r/SideProject — indie launch
- r/juststart, r/Entrepreneur — story angle
- r/tax (carefully — during tax season)

**Reddit post template:**
```
Title: I'm a freelancer who kept losing receipts at tax time, so I built an app to fix it

Body: [Personal story] Every March I'd scroll through 2,000 camera roll photos
hunting for receipts. Built SnapDeduct — snap a receipt, AI sorts it into IRS
categories, export for your CPA. 50 free receipts to try. Would love feedback
from other freelancers. [link]
```

## Week 2: Product Hunt Launch
- [ ] Schedule for Tuesday-Thursday (highest traffic)
- [ ] Prepare: tagline, gallery, first comment with story
- [ ] Rally 10-20 friends to upvote in first hour (critical for ranking)
- [ ] Offer PH-exclusive: extended free trial or lifetime discount
- [ ] Engage every comment within minutes

## Week 3-4: Content + SEO
- [ ] Blog posts: "Tax deductions freelancers miss", "Schedule C explained"
- [ ] TikTok/Reels: "POV: it's tax season and you tracked nothing" (relatable)
- [ ] Answer Quora/Reddit questions about freelance taxes, mention app naturally

## Week 5-8: Iterate
- [ ] Ship v1.1 with SHOULD features (dashboard, email forwarding)
- [ ] A/B test screenshots and subtitle
- [ ] Respond to ALL reviews (boosts rating + ASO)
- [ ] Double down on whatever channel converted best

## Week 9-12: Tax Season Ramp (THE big moment)
- [ ] Late Jan: update promo text for tax urgency
- [ ] Apple Search Ads: bid on "receipt scanner", "tax app", "expense tracker" ($5-10/day test budget)
- [ ] Push tax-season content hard across all channels
- [ ] Target: $1,000 MRR by end of Q1 tax season

---

# PART 5: APPLE SEARCH ADS (paid, optional — turn on after PMF)

| Campaign | Keywords | Budget | Goal |
|----------|----------|--------|------|
| Brand defense | snapdeduct | $2/day | Protect brand searches |
| Category | receipt scanner, expense tracker | $10/day | Acquire intent traffic |
| Tax season | tax app, tax deduction, 1099 | $10/day | Seasonal spike (Jan-Apr only) |

**Rule:** Only spend if CAC < $15 (LTV is ~$70, so 3x+ margin). Track conversion in App Store Connect. Kill keywords that don't convert within 2 weeks.

---

# PART 6: SUCCESS METRICS (track weekly)

| Metric | Week 4 Target | Week 8 | Week 12 (Goal) |
|--------|--------------|--------|----------------|
| Downloads (cumulative) | 1,000 | 3,000 | 6,000 |
| Free → Paid conversion | 3% | 4% | 5% |
| Paid users | 30 | 100 | 200+ |
| MRR | $150 | $500 | $1,000 🎯 |
| App Store rating | 4.0+ | 4.3+ | 4.5+ |
| Reviews | 10 | 40 | 100 |

**The single most important lever:** App Store rating. It drives both ranking (ASO) and conversion. Respond to every review, fix bugs fast, ask happy users to rate (in-app prompt after 10 successful scans — already in plan).
