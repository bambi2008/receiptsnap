# ReceiptSnap — Flutter Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.
> **Goal:** Build ReceiptSnap iOS app with Flutter — AI receipt scanner for US freelancers
> **Architecture:** Flutter + Provider state management + Vision OCR via native bridge
> **Tech Stack:** Flutter 3.38, Dart, camera plugin, purchase_flutter (StoreKit 2)
> **Target:** iOS 16+, iPhone

---

## Project Setup

```
ReceiptSnap/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── app.dart                   # MaterialApp + theme
│   ├── config/
│   │   ├── theme.dart             # Colors, text styles
│   │   ├── categories.dart        # IRS Schedule C categories
│   │   └── constants.dart         # App constants
│   ├── models/
│   │   └── receipt.dart           # Receipt data model
│   ├── services/
│   │   ├── ocr_service.dart       # Vision OCR native bridge
│   │   ├── storage_service.dart   # Local DB (Hive/sqflite)
│   │   └── export_service.dart    # PDF/CSV generation
│   ├── providers/
│   │   ├── receipt_provider.dart  # Receipt CRUD state
│   │   ├── camera_provider.dart   # Camera state
│   │   └── subscription_provider.dart # Subscription state
│   ├── screens/
│   │   ├── camera_screen.dart     # Camera + capture
│   │   ├── receipts_screen.dart   # Receipt list
│   │   ├── detail_screen.dart     # Receipt detail
│   │   ├── settings_screen.dart   # More/settings
│   │   └── onboarding_screen.dart # First-launch onboarding
│   └── widgets/
│       ├── receipt_card.dart      # List item card
│       ├── summary_card.dart      # Monthly summary
│       ├── category_picker.dart   # Category selector
│       ├── paywall_sheet.dart     # Subscription bottom sheet
│       └── result_sheet.dart      # Post-scan result overlay
├── ios/                           # iOS native code (for Vision bridge)
├── pubspec.yaml
└── ...
```

---

## Tasks

### Task 1: Flutter Project Scaffold

**Objective:** Create Flutter project with basic structure and dependencies.

**Files:**
- Create: All project files via `flutter create`
- Modify: `pubspec.yaml` — add dependencies
- Create: `lib/main.dart`, `lib/app.dart`, `lib/config/theme.dart`

**Dependencies to add:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0
  camera: ^0.11.0
  image_picker: ^1.1.0
  path_provider: ^2.1.0
  share_plus: ^10.0.0
  purchase_flutter: ^3.0.0  # StoreKit 2 IAP
  hive_flutter: ^2.0.0      # Local storage
  csv: ^6.0.0               # CSV export
  pdf: ^3.11.0              # PDF generation
  intl: ^0.19.0             # Date formatting
  flutter_slidable: ^3.1.0  # Swipe actions on receipts
```

**Step 1: Create project**
```bash
cd /d/hermes-workspace/projects/receipt-scanner
flutter create --org com.receiptsnap --project-name receiptsnap .
```

**Step 2: Add dependencies to pubspec.yaml**

**Step 3: Run `flutter pub get`**

**Step 4: Create app.dart with theme**

**Step 5: Verify project builds for iOS**
```bash
flutter build ios --no-codesign
```

---

### Task 2: Receipt Data Model + Category Definitions

**Objective:** Create data model and IRS Schedule C category system.

**Files:**
- Create: `lib/models/receipt.dart`
- Create: `lib/config/categories.dart`
- Create: `lib/config/constants.dart`

**Receipt model:**
```dart
class Receipt {
  final String id;
  final String vendorName;
  final double amount;
  final DateTime date;
  final String category;       // Schedule C category key
  final String? imagePath;     // local file path
  final String? note;
  // ... toJson/fromJson for Hive
}
```

**IRS Schedule C categories:**
```dart
const categories = {
  'advertising':    Category('Advertising',      Icons.campaign,       Color(0xFFFF9500)),
  'meals':          Category('Meals',             Icons.restaurant,     Color(0xFFFF3B30)),
  'travel':         Category('Travel',            Icons.flight,         Color(0xFF5856D6)),
  'office_supplies':Category('Office Supplies',   Icons.print,         Color(0xFF34C759)),
  'software':       Category('Software/Tools',    Icons.computer,      Color(0xFF007AFF)),
  'utilities':      Category('Utilities/Phone',   Icons.phone,         Color(0xFF5AC8FA)),
  'rent':           Category('Rent/Workspace',    Icons.business,      Color(0xFFAF52DE)),
  'shipping':       Category('Shipping/Postage',  Icons.local_shipping,Color(0xFF8E8E93)),
  'insurance':      Category('Insurance',         Icons.shield,        Color(0xFF34C759)),
  'other':          Category('Other',             Icons.more_horiz,    Color(0xFF8E8E93)),
};
```

**Step 1:** Write receipt.dart model with Hive annotations  
**Step 2:** Write categories.dart with all 10 IRS categories  
**Step 3:** Write constants.dart (free limit = 50, pricing)  
**Step 4:** Verify: `flutter analyze` — no errors

---

### Task 3: App Shell + Tab Navigation

**Objective:** Build the 3-tab scaffold: Camera, Receipts, Settings.

**Files:**
- Modify: `lib/app.dart` — add StatefulWidget with tab controller
- Create: `lib/screens/camera_screen.dart` — placeholder
- Create: `lib/screens/receipts_screen.dart` — placeholder with summary card
- Create: `lib/screens/settings_screen.dart` — placeholder with subscription card

**Step 1:** Create app.dart with BottomNavigationBar (3 tabs)  
**Step 2:** Create camera_screen.dart — just a centered "Camera" text + shutter button placeholder  
**Step 3:** Create receipts_screen.dart — static summary card + empty state  
**Step 4:** Create settings_screen.dart — subscription card (hardcoded "3 of 50") + menu items  
**Step 5:** Verify: tab switching works, correct icons and labels

---

### Task 4: Onboarding Screen (First Launch)

**Objective:** 3-slide onboarding with skip and completion.

**Files:**
- Create: `lib/screens/onboarding_screen.dart`

**Step 1:** Create PageView with 3 onboarding slides
  - Slide 1: "Stop losing tax deductions" + money illustration
  - Slide 2: "Snap a receipt. We handle the rest." + camera illustration
  - Slide 3: "Try 50 receipts free." + receipt illustration
**Step 2:** Add dot indicator below slides  
**Step 3:** Add "Next" / "Get Started" button logic  
**Step 4:** Add "Skip" button on all slides  
**Step 5:** Save "onboarded" flag to Hive on completion/skip  
**Step 6:** Verify: fresh launch shows onboarding, second launch goes to camera

---

### Task 5: Camera Screen + Capture

**Objective:** Real camera preview with capture functionality.

**Files:**
- Modify: `lib/screens/camera_screen.dart`
- Create: `lib/providers/camera_provider.dart`

**Step 1:** Initialize camera controller on screen init  
**Step 2:** Show live camera preview in viewfinder frame  
**Step 3:** Add corner bracket overlays (4 L-shaped white corners)  
**Step 4:** Add "Free: X left" badge top-right  
**Step 5:** Add "Position receipt in frame" hint text  
**Step 6:** Add large shutter button (white circle) at bottom center  
**Step 7:** Add gallery picker button (for selecting existing photo)  
**Step 8:** Verify: camera opens, shutter captures photo, photo saved to temp path

---

### Task 6: OCR Processing + Post-Capture Result Sheet

**Objective:** Process captured image with OCR, extract vendor/amount/date, show result sheet.

**Files:**
- Create: `lib/services/ocr_service.dart`
- Create: `lib/widgets/result_sheet.dart`

**OCR approach:**
- Use Apple's Vision text recognition through a native Flutter method channel — works on-device
- For better accuracy, consider Vision framework via Method Channel (future optimization)

**Step 1:** Implement `ocr_service.dart` — take image path, run Apple Vision, return raw text
**Step 2:** Implement result parsing — regex extract vendor name, amount ($XX.XX), date  
**Step 3:** Show processing overlay ("Reading receipt…" + spinner) after capture  
**Step 4:** Create `result_sheet.dart` — bottom sheet showing extracted info: vendor, amount, category, date  
**Step 5:** Auto-assign best-guess category based on vendor name rules  
**Step 6:** Add "Edit" button (opens fields for editing) and "Done" button (saves receipt)  
**Step 7:** On "Done": save receipt to Hive, show toast "Saved!", go back to camera  
**Step 8:** Verify: capture real receipt image → OCR extracts text → result shows → save works

---

### Task 7: Receipt List Screen + Summary Card

**Objective:** Chronological receipt list with monthly grouping and search.

**Files:**
- Modify: `lib/screens/receipts_screen.dart`
- Create: `lib/widgets/receipt_card.dart`
- Create: `lib/widgets/summary_card.dart`
- Create: `lib/providers/receipt_provider.dart`

**Step 1:** Create `receipt_provider.dart` — loads/saves receipts from Hive, provides list  
**Step 2:** Create `summary_card.dart` — blue card showing "THIS MONTH / X receipts / $X,XXX in deductions"  
**Step 3:** Create `receipt_card.dart` — category-colored icon, vendor, date, amount  
**Step 4:** Build `receipts_screen.dart`:
  - Summary card at top
  - Search bar below
  - ListView grouped by month (JUNE 2026 / MAY 2026 headers)
  - Empty state: "No receipts yet. Start snapping!" + camera illustration
**Step 5:** Implement search — filter by vendor name  
**Step 6:** Implement swipe-to-edit-category (flutter_slidable)  
**Step 7:** Verify: captured receipts appear in list, search works, categories show correct colors

---

### Task 8: Receipt Detail Screen + Edit

**Objective:** Full receipt detail view with edit capability and export.

**Files:**
- Create: `lib/screens/detail_screen.dart`

**Step 1:** Build detail screen:
  - Receipt image (zoomable with InteractiveViewer)
  - Editable fields: vendor, amount, category, date, note
**Step 2:** Tapping category opens `category_picker.dart` bottom sheet  
**Step 3:** Add "Export as PDF" and "Export as CSV" buttons  
**Step 4:** Implement navigation: tap receipt card → push detail screen  
**Step 5:** Implement back navigation and save on changes  
**Step 6:** Verify: tap receipt → see detail → edit category → back → list reflects change

---

### Task 9: Export Service (PDF + CSV)

**Objective:** Generate PDF report and CSV spreadsheet of receipts.

**Files:**
- Create: `lib/services/export_service.dart`

**Step 1:** Implement CSV export — headers: Date,Vendor,Category,Amount,Note  
**Step 2:** Implement PDF export — grouped by IRS Schedule C category, with totals per category  
**Step 3:** Add "Share" button — opens iOS share sheet with generated file  
**Step 4:** Wire export buttons in detail screen and settings  
**Step 5:** Verify: tap Export PDF → generates file → share sheet opens → file contains correct data

---

### Task 10: Free Tier Limits + Subscription Paywall

**Objective:** Free tier (50 receipts), upgrade prompt, IAP integration.

**Files:**
- Create: `lib/providers/subscription_provider.dart`
- Create: `lib/widgets/paywall_sheet.dart`

**Step 1:** Create `subscription_provider.dart` — track receipt count, check limit  
**Step 2:** Show "X of 50 free receipts used" on settings screen with progress bar  
**Step 3:** After 50th receipt, show upgrade prompt on camera screen  
**Step 4:** Create `paywall_sheet.dart` — bottom sheet with:
  - Monthly $4.99 / Annual $39.99 plan selection
  - Feature comparison list
  - "Subscribe" button → triggers StoreKit 2 purchase  
**Step 5:** Integrate purchase_flutter for IAP (configure products in App Store Connect later)  
**Step 6:** On purchase success: update subscription state, unlock unlimited, show confetti  
**Step 7:** Handle restore purchases button  
**Step 8:** Verify: receipt count increments, limit reached shows paywall, purchase simulated

---

### Task 11: Settings Screen (Full)

**Objective:** Complete the More/Settings screen.

**Files:**
- Modify: `lib/screens/settings_screen.dart`

**Step 1:** Subscription card: tier badge + progress bar + upgrade button (from Task 10)  
**Step 2:** Export history menu row  
**Step 3:** App Settings menu row → notification toggle  
**Step 4:** Help & Support → opens email  
**Step 5:** Privacy Policy → opens URL  
**Step 6:** Terms of Service → opens URL  
**Step 7:** App version footer: "ReceiptSnap v1.0.0 · Made with ❤️ for freelancers"  
**Step 8:** Verify: all menu items tappable, subscription card updates after upgrade

---

### Task 12: Polish + Final Assembly

**Objective:** Animate transitions, add haptics, dark mode, final testing.

**Step 1:** Add Hero animation on receipt card → detail transition  
**Step 2:** Add haptic feedback on shutter press and save (HapticFeedback.mediumImpact)  
**Step 3:** Verify dark mode works (theme already supports system setting)  
**Step 4:** Add loading/error states to all screens  
**Step 5:** Test all flows end-to-end: onboard → snap → process → browse → edit → export → settings → upgrade  
**Step 6:** Run `flutter analyze` — zero errors, zero warnings  
**Step 7:** Run `flutter test` — all tests pass

---

## Task Dependency Map

```
T1 (Scaffold)
 │
 ├──► T2 (Models) ──► T4 (Onboarding)
 │         │
 │         ├──► T3 (Tab Shell)
 │         │       │
 │         │       ├──► T5 (Camera)
 │         │       │       │
 │         │       │       └──► T6 (OCR + Result)
 │         │       │               │
 │         │       │               └──► T7 (Receipt List)
 │         │       │                       │
 │         │       │                       └──► T8 (Detail + Edit)
 │         │       │                               │
 │         │       │                               └──► T9 (Export)
 │         │       │
 │         │       └──► T10 (Subscription) ──► T11 (Settings)
 │         │
 │         └──► T12 (Polish) ← depends on ALL above
```

## Estimated Effort

| Task | Days |
|------|------|
| T1: Scaffold | 1 |
| T2: Models | 0.5 |
| T3: Tab Shell | 1 |
| T4: Onboarding | 1 |
| T5: Camera | 2 |
| T6: OCR + Result | 2 |
| T7: Receipt List | 1.5 |
| T8: Detail + Edit | 1 |
| T9: Export | 1 |
| T10: Subscription | 2 |
| T11: Settings | 0.5 |
| T12: Polish | 1 |
| **Total** | **14.5 days** |
