# MVP Feature List — ReceiptSnap

> Date: June 2026 | Phase 0 Deliverable
> Principle: Ship in 6 weeks. Say NO to everything that doesn't directly serve the "snap → categorize → export" loop.

---

## MoSCoW Framework

| Priority | Meaning | Launch Requirement |
|----------|---------|-------------------|
| **MUST** | Cannot launch without it | Required for v1.0 |
| **SHOULD** | Important, can delay 1-2 weeks | v1.1 within 2 weeks of launch |
| **COULD** | Nice to have, post-MVP | v1.2+ |
| **WON'T** | Explicitly out of scope | Not in 2026 roadmap |

---

## MUST Have (v1.0 — Launch Week 6)

### M1: Instant Camera Capture
**What:** App opens directly to camera. One tap to capture receipt. No navigating menus.
**Why:** This is the core loop. Every extra tap = friction = user quits. Sarah's #1 need: "open app, snap, done."
**Effort:** 2 days

### M2: AI-Powered OCR + Auto-Categorization
**What:** Extract vendor name, date, total amount, tax amount from receipt photo. Auto-assign IRS Schedule C category (Advertising, Meals, Travel, Office Supplies, etc.).
**Why:** This is the AI value prop. Without it, we're just a camera app with folders. Must be accurate enough that users rarely need to correct.
**Effort:** 5 days (API integration + category mapping)

### M3: Receipt List + Search
**What:** Chronological list of all scanned receipts. Search by vendor name, date, amount, or category.
**Why:** Users need to find receipts later. Basic CRUD.
**Effort:** 3 days

### M4: Manual Category Correction
**What:** User can tap a receipt and change its category. AI learns from this correction for future similar receipts.
**Why:** No AI is 100% accurate. The correction loop is also our competitive moat — the more they use it, the smarter it gets.
**Effort:** 2 days

### M5: Export to PDF/CSV
**What:** One-tap export of selected receipts (by date range) as PDF report or CSV spreadsheet. Formatted for CPA review.
**Why:** This is the "moment of value delivery." Sarah opens the app in March, exports everything, hands it to her CPA. She realizes the app "worked" all year.
**Effort:** 2 days

### M6: Subscription Paywall
**What:** Free trial: 50 receipts. Then $4.99/month or $39.99/year. Implemented via Apple IAP (StoreKit 2).
**Why:** We need to make money. 50 receipts = ~2 months for an average freelancer = enough time to get hooked.
**Effort:** 3 days

### M7: Onboarding Flow (3 screens max)
**What:** Screen 1: "Stop losing tax deductions." Screen 2: "Snap a receipt, we handle the rest." Screen 3: "Try 50 receipts free." Then camera.
**Why:** First-run experience determines retention. Must communicate value in <15 seconds.
**Effort:** 1 day

**MUST Total: ~18 development days**

---

## SHOULD Have (v1.1 — Weeks 7-8)

### S1: Smart Tax Summary Dashboard
**What:** Home screen shows: total deductible expenses this quarter, category breakdown (pie chart), estimated tax savings.
**Why:** Turns the app from "receipt storage" into "tax savings tool." Shows value every time they open. Drives retention.
**Effort:** 3 days

### S2: Email Receipt Forwarding
**What:** User gets a unique @receiptsnap.com email address. Forward digital receipts, auto-processed same as photos.
**Why:** David (consultant) gets half his receipts by email. Without this, he won't switch from Expensify.
**Effort:** 3 days

### S3: Multi-Currency Detection
**What:** Auto-detect currency on receipt, convert to USD at current rate.
**Why:** David travels internationally. Sarah goes to conferences abroad. Required for consultant persona.
**Effort:** 1 day

### S4: App Store Rating Prompt
**What:** After 10th successful scan, show native SKStoreReviewController. Timing: after a success moment, not on launch.
**Why:** Early ratings drive ASO. Must be timed perfectly — annoying prompt = 1-star review.
**Effort:** 0.5 day

### S5: Dark Mode / Light Mode
**What:** Support iOS system appearance. Default to system setting.
**Why:** Table stakes for iOS apps in 2026. Users expect it.
**Effort:** 0.5 day

**SHOULD Total: ~8 development days**

---

## COULD Have (v1.2+ — Post-Launch)

### C1: iCloud Sync
**What:** Receipts synced across user's iPhone and iPad via iCloud.
**Why:** Nice for iPad users who want to review on larger screen. Not critical for v1.
**Effort:** 3 days

### C2: Receipt Photo Editing
**What:** Crop, rotate, adjust brightness before OCR.
**Why:** Edge case — most receipts are legible as-is. Adds complexity to the "snap and done" flow.
**Effort:** 2 days

### C3: Mileage Tracking
**What:** GPS-based automatic mileage logging. IRS rate calculation.
**Why:** Opens the gig worker persona (Marcus). But adds significant complexity — different core loop, different tech (GPS background).
**Effort:** 8 days

### C4: QuickBooks Online Integration
**What:** Auto-push categorized expenses to QuickBooks Online.
**Why:** David's CPA wants this. But requires OAuth, API integration, testing. High effort for a feature most Sarahs don't need.
**Effort:** 5 days

### C5: Widget
**What:** iOS home screen widget showing "X receipts scanned this month" or "Estimated tax savings."
**Why:** Top-of-mind awareness. Nice retention tool. Not critical for v1.
**Effort:** 2 days

---

## WON'T Have (Explicitly Out of Scope)

| Feature | Why NOT |
|---------|---------|
| Team/collaboration features | Expensify's territory. We're solo-first. |
| Full accounting (invoicing, P&L, balance sheet) | QuickBooks/Wave territory. Stay focused. |
| Bank account linking | Privacy concerns, complex integration, Yodlee/Plaid costs |
| Android app | Focus on iOS first. Prove PMF, then expand. |
| Custom expense categories | IRS Schedule C categories cover 95% of needs |
| Receipt "archiving" with timestamps | Legal compliance feature. Add later if requested. |
| Web dashboard | v1 is mobile-first. Add when users ask. |
| AI chatbot / assistant | Feature creep. Our AI is OCR + categorization, not conversation. |

---

## Feature Dependency Map

```
M1 (Camera) ──► M2 (OCR+AI) ──► M3 (Receipt List)
                                      │
                    ┌─────────────────┘
                    ▼
              M4 (Correction) ──► M5 (Export)
                    │
                    ▼
              M7 (Onboarding) ──► M6 (Paywall)
                    │
                    ▼
              S1 (Dashboard) ◄── S2 (Email In) ◄── S3 (Multi-Currency)
```

---

## Development Sequencing

```
Week 1-2: M1, M2, M3 (core scan → see → search loop)
Week 3-4: M4, M7, M5 (correction learning, onboarding, export)
Week 5:   M6 (paywall integration + IAP testing)
Week 6:   Polish, TestFlight, bug fixes, App Store submission
Week 7-8: S1-S5 (post-launch feature drop to drive retention)
```
