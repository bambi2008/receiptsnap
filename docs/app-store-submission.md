# App Store Connect — Submission Checklist

> Use this checklist when submitting ReceiptSnap to the App Store.

---

## Pre-Submission: App Store Connect Setup

### App Information
- [ ] **App Name:** ReceiptSnap: AI Receipt Scanner
- [ ] **Subtitle:** Tax-Time Receipt Organizer
- [ ] **Category:** Finance
- [ ] **Secondary Category:** Business
- [ ] **Bundle ID:** com.receiptsnap.app
- [ ] **SKU:** receiptsnap-001
- [ ] **Primary Language:** English (U.S.)

### Pricing
- [ ] **Price:** Free
- [ ] **Availability:** United States (primary), expand later

### In-App Purchases
- [ ] **Monthly Pro:** com.receiptsnap.pro.monthly — $4.99 USD (Auto-Renewable Subscription)
- [ ] **Annual Pro:** com.receiptsnap.pro.annual — $39.99 USD (Auto-Renewable Subscription)
- [ ] Subscription group: Pro (Level 2 → Level 1 upgrade path)

### App Privacy
- [ ] Privacy Policy URL: https://receiptsnap.com/privacy
- [ ] Privacy Nutrition Labels filled (see docs/privacy-policy.md § Privacy Nutrition Labels)
- [ ] Data Collection: Receipt images stored on-device only (NOT collected)
- [ ] Data Collection: Anonymous usage statistics (NOT linked to identity)
- [ ] No third-party analytics SDKs

### App Icon
- [ ] 1024×1024 App Store icon: `assets/app-icon-1024.png` (generated)
- [ ] All iOS sizes (40×40, 60×60, 58×58, 87×87, 80×80, 120×120, 180×180, 1024×1024)
  - **On Mac:** Use Xcode asset catalog or `flutter_launcher_icons` package

### Screenshots (6.7" iPhone — Required)
6.7" display (iPhone 15 Pro Max / 16 Pro Max): 1290×2796 px

> **Do not upload the legacy files currently under `assets/screenshots/`.** They contain obsolete tax claims, corrupted text, and hard-coded prices. Recapture every screenshot from the final app build using App Store sandbox products and the safe captions below.

- [ ] **Screenshot 1:** Camera view — "Position receipt in frame"
- [ ] **Screenshot 2:** OCR result — "Starbucks · $12.50 · Suggested: Meals"
- [ ] **Screenshot 3:** Receipt list — "THIS MONTH · 23 receipts · $847.50 recorded"
- [ ] **Screenshot 4:** Export — "One-tap PDF or CSV"
- [ ] **Screenshot 5:** Paywall — "Unlimited scanning · $4.99/month"

### Screenshots (6.1" iPhone — Required)
- [ ] Same 5 screenshots resized for 6.1" (iPhone 15 Pro / 16 Pro)

### Screenshots (5.5" iPhone — Optional)
- [ ] Skip for now, focus on larger sizes

### App Review Information
- [ ] **Contact:** support@receiptsnap.com
- [ ] **Phone:** (your number)
- [ ] **Demo Account:** Create test account if needed (not needed for free tier)
- [ ] **Notes for Reviewer:** "ReceiptSnap is a receipt scanner for freelancers. Free tier: 50 receipts. Pro: $4.99/mo or $39.99/yr. All data stored on-device. No server backend. OCR uses Apple Vision framework (on-device)."

### Version Information
- [ ] **Version:** 1.0.0
- [ ] **Build:** 1
- [ ] **Copyright:** © 2026 ReceiptSnap

### App Description (from docs/aso-strategy.md)
- [ ] Full description pasted
- [x] Keywords set: receipt,scan,tax,expense,freelance,self-employed,business,tracker,ocr,1099,records,invoice
- [ ] Promotional text set

### General Information
- [ ] **Rating:** 4+ (no objectionable content)
- [ ] **Trade Representative Contact:** Not applicable (US app)

### App Review Attachments
- [ ] No special attachments needed (no user registration, no adult content)

---

## Pre-Submission: Code Quality

- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 54 tests, all pass
- [ ] iOS build succeeds without errors (`flutter build ios --release`)
- [ ] Test on physical iPhone device
- [ ] Test on iOS simulator (multiple screen sizes)
- [ ] Test subscription flow (sandbox)
- [ ] Test free tier limit enforcement
- [ ] Test PDF/CSV export
- [ ] Test dark mode
- [ ] Verify no crash on cold launch
- [ ] Verify app state restoration

---

## Post-Submission: Marketing

- [ ] Product Hunt launch page
- [ ] Reddit: r/freelance, r/selfemployed, r/smallbusiness
- [ ] Indie Hackers post
- [ ] Twitter/X announcement
- [ ] Hacker News Show HN
- [ ] Freelancer Facebook groups
- [ ] Email list signup on receiptsnap.com

---

## Legal Compliance

- [x] Privacy Policy written (docs/privacy-policy.md)
- [x] Terms of Service written (docs/terms-of-service.md)
- [ ] Privacy Policy hosted at https://receiptsnap.com/privacy
- [ ] Terms of Service hosted at https://receiptsnap.com/terms

---

## File Reference

| File | Location |
|------|----------|
| App Icon (1024px) | `assets/app-icon-1024.png` |
| ASO Strategy | `docs/aso-strategy.md` |
| Privacy Policy | `docs/privacy-policy.md` |
| Terms of Service | `docs/terms-of-service.md` |
| Mac Handoff Guide | `docs/mac-handoff.md` |
| Implementation Plan | `docs/implementation-plan.md` |

---

## Quick Mac Commands (After Setup)

```bash
# 1. Clone the repo
git clone https://github.com/bambi2008/receiptsnap.git
cd receiptsnap/app

# 2. Install deps
flutter pub get

# 3. Verify
flutter analyze && flutter test

# 4. Generate all icon sizes from 1024px master
# Option A: Use flutter_launcher_icons
# Option B: Use Xcode asset catalog (File → New → Image Set → App Icon)

# 5. Open iOS project in Xcode
open ios/Runner.xcworkspace

# 6. Build for release
flutter build ios --release
```
