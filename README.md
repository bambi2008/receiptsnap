# ReceiptSnap 📸🧾

> AI receipt scanner for US freelancers. Snap → Categorize → Export. Tax deductions, simplified.

[![Flutter](https://img.shields.io/badge/Flutter-3.44-blue)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/iOS-16%2B-lightgrey)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## The Problem

US freelancers lose an average of **$5,000/year** in missed tax deductions because they can't be bothered to organize paper receipts. Shoeboxes. Spreadsheets. Manual data entry. It's 2026 — this should be instant.

## The Solution

ReceiptSnap opens directly to camera. One tap captures the receipt. AI extracts vendor, amount, and date — then automatically assigns the correct IRS Schedule C category. At tax time, export everything as a CPA-ready PDF or CSV with one tap.

**50 receipts free. Then $4.99/month or $39.99/year.**

## Features

- 📸 **Instant Capture** — App opens to camera. No menus. One tap.
- 🤖 **AI-Powered OCR** — Extracts vendor, amount, date from any receipt
- 🏷️ **Smart Categories** — Auto-mapped to IRS Schedule C (Advertising, Meals, Travel, Office Supplies, Software, Utilities, Rent, Shipping, Insurance, Other)
- 📊 **Monthly Summary** — "This month: 23 receipts · $847.50 in deductions"
- 📤 **CPA-Ready Export** — PDF report or CSV spreadsheet, organized by category
- 🌓 **Dark Mode** — Full light/dark theme, follows system preference
- 🔒 **On-Device Storage** — All data stays on your phone. No server, no privacy concerns.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.44 |
| Language | Dart 3.12 |
| State | Provider |
| Storage | Hive (local) |
| OCR | Vision (iOS native bridge) + ML Kit |
| IAP | StoreKit 2 via purchase_flutter |
| Export | pdf + csv packages |

## Architecture

```
lib/
├── main.dart                    # Entry point + provider initialization
├── app.dart                     # MaterialApp + 3-tab shell
├── config/
│   ├── theme.dart               # Light/dark theme + color system
│   ├── categories.dart          # 10 IRS Schedule C categories + AI guesser
│   └── constants.dart           # Pricing, limits, keys
├── models/
│   └── receipt.dart             # Data model + Hive adapter
├── providers/
│   ├── receipt_provider.dart    # CRUD + search + grouping
│   └── subscription_provider.dart # Free tier + Pro state
├── services/
│   └── export_service.dart      # CSV/PDF generation
├── screens/
│   ├── camera_screen.dart       # Viewfinder + shutter
│   ├── receipts_screen.dart     # List + search + swipe actions
│   ├── detail_screen.dart       # Edit + delete + share
│   ├── settings_screen.dart     # Subscription + menus
│   └── onboarding_screen.dart   # 3-slide first-launch
└── widgets/
    ├── result_sheet.dart        # Post-scan OCR results
    └── paywall_sheet.dart       # Subscription upgrade sheet
```

## Project Status

```
✅ Phase 0: Product Strategy
✅ Phase 1: UI/UX Design
✅ Phase 2: Core Flutter Code (19 files, 0 analyze issues, 54 tests)
🔜 Phase 3: iOS Native Integration (Vision OCR + StoreKit 2)
🔜 Phase 4: App Store Launch
```

### Quality Gates

| Metric | Status |
|--------|--------|
| `flutter analyze` | 0 issues |
| `flutter test` | 54 tests, all pass |
| Test coverage | Models, Providers, Categories, Widgets |

## Getting Started

### Prerequisites

- Flutter 3.44+
- Xcode 15+ (for iOS build)
- macOS (required for iOS development)

### Setup

```bash
# Clone
git clone https://github.com/bambi2008/receiptsnap.git
cd receiptsnap/app

# Install dependencies
flutter pub get

# Run analyzer
flutter analyze

# Run tests
flutter test

# Launch on iOS simulator
open -a Simulator
flutter run
```

### Building for Production

```bash
flutter build ios --release
# Then archive in Xcode → upload to App Store Connect
```

## Documentation

| Document | Description |
|----------|------------|
| [MVP Features](docs/mvp-features.md) | MoSCoW feature list |
| [User Personas](docs/user-personas.md) | Target user profiles |
| [Competitive Analysis](docs/competitive-analysis.md) | Competitor landscape |
| [Pricing Strategy](docs/pricing-strategy.md) | Pricing rationale |
| [Implementation Plan](docs/implementation-plan.md) | Task breakdown |
| [ASO Strategy](docs/aso-strategy.md) | Keywords + App Store copy |
| [Privacy Policy](docs/privacy-policy.md) | Legal compliance |
| [Terms of Service](docs/terms-of-service.md) | Legal compliance |
| [Mac Handoff](docs/mac-handoff.md) | Mac setup checklist |

## Pricing

| Tier | Price | Limit |
|------|-------|-------|
| Free | $0 | 50 receipts |
| Pro Monthly | $4.99/mo | Unlimited |
| Pro Annual | $39.99/yr (33% off) | Unlimited |

## Target Audience

- US-based freelancers (designers, developers, writers, consultants)
- Self-employed 1099 contractors
- Small business owners filing Schedule C
- Anyone who's ever lost a receipt and missed a deduction

## Team

Built by freelancers, for freelancers. We're a small team of 7 covering product strategy, design, iOS development, QA, and growth.

## License

MIT © 2026 ReceiptSnap
