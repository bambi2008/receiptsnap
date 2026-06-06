# ReceiptSnap — User Flow Diagrams

## Overview

ReceiptSnap is an AI-powered receipt scanner for US freelancers earning $50K+. The core UX principle is **"Zero friction. Open, snap, done."** — the camera is live the instant the app opens.

---

## Flow 1: First Launch → Onboarding → First Snap

```
┌──────────────────────────────────────────────────────────────────────┐
│                        FIRST LAUNCH EXPERIENCE                       │
└──────────────────────────────────────────────────────────────────────┘

    [User taps app icon]
         │
         ▼
    ┌─────────────────────┐
    │   ONBOARD SLIDE 1   │
    │                     │
    │  Illustration:      │
    │  scattered receipts │
    │  with "$" flying    │
    │  away (lost deduc-  │
    │  tions)             │
    │                     │
    │  "Stop losing tax   │
    │   deductions"       │
    │                     │
    │  [ ● ○ ○ ] ← dots  │
    │  [  Next →  ]       │
    └─────────┬───────────┘
              │ tap "Next" or swipe left
              ▼
    ┌─────────────────────┐
    │   ONBOARD SLIDE 2   │
    │                     │
    │  Illustration:      │
    │  phone snapping     │
    │  receipt → AI       │
    │  magic sparkle      │
    │                     │
    │  "Snap a receipt.   │
    │   We handle the     │
    │   rest."            │
    │                     │
    │  [ ○ ● ○ ]         │
    │  [  Next →  ]       │
    └─────────┬───────────┘
              │ tap "Next" or swipe left
              ▼
    ┌─────────────────────┐
    │   ONBOARD SLIDE 3   │
    │                     │
    │  Illustration:      │
    │  "50" badge with    │
    │  receipt icons      │
    │                     │
    │  "Try 50 receipts   │
    │   free. No credit   │
    │   card required."   │
    │                     │
    │  [ ○ ○ ● ]         │
    │  ┌────────────────┐ │
    │  │  Get Started → │ │
    │  └────────────────┘ │
    │  "Restore Purchase" │
    └─────────┬───────────┘
              │ tap "Get Started"
              ▼
    ┌─────────────────────┐
    │  CAMERA PERMISSION  │
    │  (iOS system dialog)│
    │                     │
    │  "ReceiptSnap would │
    │   like to access    │
    │   the camera"        │
    │                     │
    │  [Don't Allow]      │
    │  [     OK      ]    │
    └─────────┬───────────┘
              │ tap "OK"
              ▼
    ┌─────────────────────┐
    │   CAMERA SCREEN     │
    │   (LIVE VIEWFINDER) │
    │                     │
    │  [Free: 50 left]    │
    │                     │
    │   ┌─────────────┐   │
    │   │             │   │
    │   │  viewfinder │   │
    │   │  with corner│   │
    │   │  brackets   │   │
    │   │             │   │
    │   └─────────────┘   │
    │                     │
    │  [📷]  large white  │
    │   ○    shutter btn  │
    └─────────┬───────────┘
              │ user taps shutter (or gallery thumbnail)
              ▼
         [FLOW 2: CAPTURE → PROCESS]
```

---

## Flow 2: Capture Receipt → AI Processing → Result

```
    [User taps shutter button]
         │
         ▼
    ┌─────────────────────┐
    │   CAPTURE FRAME     │
    │   (brief flash)     │
    └─────────┬───────────┘
              │ instant
              ▼
    ┌─────────────────────┐
    │   PROCESSING STATE  │
    │                     │
    │   captured image    │
    │   shown frozen      │
    │                     │
    │   ┌─────────────┐   │
    │   │  ◠◠◠◠◠◠◠◠  │   │
    │   │  scanning    │   │
    │   │  animation   │   │
    │   │  "Reading    │   │
    │   │   receipt…"  │   │
    │   └─────────────┘   │
    │                     │
    │   (1-2 seconds)     │
    └─────────┬───────────┘
              │ AI extraction complete
              ▼
    ┌─────────────────────┐
    │   RESULT OVERLAY    │
    │   (sheet from       │
    │    bottom)          │
    │                     │
    │   ┌─────────────┐   │
    │   │ Vendor      │   │
    │   │ Starbucks   │   │
    │   │             │   │
    │   │ Amount      │   │
    │   │ $4.75       │   │
    │   │             │   │
    │   │ Category    │   │
    │   │ 🍽 Meals    │   │
    │   │             │   │
    │   │ Date        │   │
    │   │ Jun 5, 2026 │   │
    │   │             │   │
    │   │ [Edit ✏️]   │   │
    │   │ [✓ Done]    │   │
    │   └─────────────┘   │
    └─────────┬───────────┘
              │
      ┌───────┴───────┐
      ▼               ▼
  tap "Done"     tap "Edit"
      │               │
      ▼               ▼
  ┌─────────┐   ┌──────────────┐
  │ Returns │   │ EDIT SCREEN  │
  │ to      │   │              │
  │ Camera  │   │ Vendor: [___]│
  │ (ready  │   │ Amount: [___]│
  │ for     │   │ Category: [v]│
  │ next)   │   │ Date:    [v] │
  │         │   │ Note:  [____]│
  │ Toast:  │   │              │
  │ "Saved!"│   │ [Save Changes]│
  └─────────┘   └──────┬───────┘
                       │
                       ▼
                  Returns to Camera
                  (ready for next)
```

---

## Flow 3: Browse Receipts → Search → Edit

```
    [User taps "Receipts" tab]
         │
         ▼
    ┌─────────────────────┐
    │   RECEIPTS LIST     │
    │                     │
    │  ┌────────────────┐ │
    │  │ This month:    │ │
    │  │ 23 receipts    │ │
    │  │ $1,847 deduc-  │ │
    │  │ tions          │ │
    │  └────────────────┘ │
    │                     │
    │  🔍 Search receipts │
    │                     │
    │  ── JUNE 2026 ──    │
    │  ┌────────────────┐ │
    │  │ 🍽 Starbucks   │ │
    │  │   $4.75   Jun 5│ │
    │  └────────────────┘ │
    │  ┌────────────────┐ │
    │  │ 💻 Adobe CC    │ │
    │  │   $59.99  Jun 4│ │
    │  └────────────────┘ │
    │  ┌────────────────┐ │
    │  │ 🏢 WeWork      │ │
    │  │   $29.00  Jun 3│ │
    │  └────────────────┘ │
    │  ... (scroll) ...   │
    │                     │
    │  ── MAY 2026 ──     │
    │  ...                │
    └─────────┬───────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         ▼         ▼
  Tap       Search    Swipe
  receipt   bar       left on
            │         receipt
            ▼         │
  ┌──────────────┐    ▼
  │RECEIPT DETAIL│  ┌──────────────┐
  │(see Flow 4)  │  │QUICK ACTIONS │
  └──────────────┘  │              │
                    │ 🏷 Change    │
                    │   category   │
                    │ 🗑 Delete    │
                    │ 📤 Export   │
                    └──────────────┘
```

---

## Flow 4: Receipt Detail → Edit → Export

```
    [User taps receipt from list]
         │
         ▼
    ┌─────────────────────┐
    │   RECEIPT DETAIL    │
    │                     │
    │  ┌────────────────┐ │
    │  │                │ │
    │  │  RECEIPT       │ │
    │  │  IMAGE         │ │
    │  │  (zoomable)    │ │
    │  │                │ │
    │  │  pinch to zoom │ │
    │  └────────────────┘ │
    │                     │
    │  ── DETAILS ──      │
    │  Vendor             │
    │  Starbucks          │
    │                     │
    │  Amount             │
    │  $4.75              │
    │                     │
    │  Category    [Edit] │
    │  🍽 Meals           │
    │                     │
    │  Date               │
    │  June 5, 2026       │
    │                     │
    │  Note               │
    │  Client meeting     │
    │                     │
    │  ┌────────────────┐ │
    │  │ 📤 Export PDF  │ │
    │  └────────────────┘ │
    │  ┌────────────────┐ │
    │  │ 📊 Export CSV  │ │
    │  └────────────────┘ │
    └─────────┬───────────┘
              │
    ┌─────────┼──────────┐
    ▼         ▼          ▼
  Export    Export    Edit
  PDF       CSV       Category
    │         │          │
    ▼         ▼          ▼
  ┌──────┐ ┌──────┐  ┌──────────┐
  │Share │ │Share │  │Category  │
  │Sheet │ │Sheet │  │Picker    │
  │      │ │      │  │          │
  │ Air- │ │.csv  │  │🍽 Meals  │
  │ Drop │ │file  │  │💻 Software│
  │ Mail │ │      │  │🏢 Office │
  │Files │ │      │  │🚗 Travel │
  │...   │ │      │  │📱 Phone  │
  └──────┘ └──────┘  │✈️ Travel │
                     │...       │
                     └──────────┘
```

---

## Flow 5: Settings → Subscription → Export All

```
    [User taps "More" tab]
         │
         ▼
    ┌─────────────────────────┐
    │      MORE SCREEN        │
    │                         │
    │  ┌───────────────────┐  │
    │  │ SUBSCRIPTION      │  │
    │  │                   │  │
    │  │ 🆓 Free Tier      │  │
    │  │ 32 of 50 receipts │  │
    │  │ used this month   │  │
    │  │                   │  │
    │  │ [████████░░░░░░░] │  │
    │  │                   │  │
    │  │ [ Upgrade to Pro ]│  │
    │  │ $7.99/mo · Unlim- │  │
    │  │ ited · CSV/PDF    │  │
    │  │ · Schedule C      │  │
    │  └───────────────────┘  │
    │                         │
    │  ┌───────────────────┐  │
    │  │ 📤 Export History │  │
    │  │    View past →    │  │
    │  └───────────────────┘  │
    │  ┌───────────────────┐  │
    │  │ ⚙️  App Settings  │  │
    │  │    →              │  │
    │  └───────────────────┘  │
    │  ┌───────────────────┐  │
    │  │ ❓ Help & Support │  │
    │  └───────────────────┘  │
    │  ┌───────────────────┐  │
    │  │ 📄 Privacy Policy │  │
    │  └───────────────────┘  │
    └─────────┬───────────────┘
              │
    ┌─────────┼──────────────┐
    ▼         ▼              ▼
  Upgrade   Export        Settings
  Flow      History
    │         │
    ▼         ▼
  ┌────────┐ ┌──────────────┐
  │PAYWALL │ │EXPORT HISTORY│
  │        │ │              │
  │ Pro    │ │ Jan 2026 Q1  │
  │ $7.99/ │ │ Feb 2026 Q1  │
  │ month  │ │ Mar 2026 Q1  │
  │        │ │ ...          │
  │ Annual │ │              │
  │ $59.99 │ │ Tap to re-   │
  │ /year  │ │ download     │
  │        │ │              │
  │[Sub-   │ └──────────────┘
  │ scribe]│
  └────────┘
```

---

## Flow 6: Upgrade to Pro (Subscription Paywall)

```
    [User taps "Upgrade to Pro"]
         │
         ▼
    ┌─────────────────────────┐
    │    RECEIPTSNAP PRO      │
    │                         │
    │  ┌───────────────────┐  │
    │  │      🧾 PRO       │  │
    │  │                   │  │
    │  │ ✓ Unlimited       │  │
    │  │   receipts        │  │
    │  │ ✓ CSV & PDF       │  │
    │  │   export           │  │
    │  │ ✓ Schedule C      │  │
    │  │   categories       │  │
    │  │ ✓ Priority        │  │
    │  │   support          │  │
    │  │ ✓ No watermark    │  │
    │  └───────────────────┘  │
    │                         │
    │  ┌───────────────────┐  │
    │  │  Monthly          │  │
    │  │  $7.99/mo         │  │
    │  │  [  SELECT  ]     │  │
    │  └───────────────────┘  │
    │  ┌───────────────────┐  │
    │  │  Annual (Save 37%)│  │
    │  │  $59.99/yr        │  │
    │  │  [  SELECT  ]     │  │
    │  └───────────────────┘  │
    │                         │
    │  "Cancel anytime"       │
    │  [Restore Purchases]    │
    │  [Terms] [Privacy]      │
    └─────────────────────────┘
              │
              ▼
    ┌─────────────────────┐
    │ iOS Purchase Sheet  │
    │ (system dialog)     │
    │                     │
    │ Double-click to pay │
    └─────────┬───────────┘
              │ confirmed
              ▼
    ┌─────────────────────┐
    │  SUCCESS STATE      │
    │                     │
    │  🎉 Welcome to Pro! │
    │  Unlimited receipts │
    │  are now yours.     │
    │                     │
    │  [Start Scanning →] │
    └─────────────────────┘
```

---

## Flow 7: Free Tier Limit Reached

```
    [User snaps receipt #51 on Free tier]
         │
         ▼
    ┌─────────────────────────┐
    │    LIMIT REACHED        │
    │                         │
    │  ┌───────────────────┐  │
    │  │                   │  │
    │  │   📸 50/50        │  │
    │  │                   │  │
    │  │  You've used all  │  │
    │  │  your free        │  │
    │  │  receipts this    │  │
    │  │  month.           │  │
    │  │                   │  │
    │  │  Upgrade to       │  │
    │  │  Pro for unlim-   │  │
    │  │  ited scanning.   │  │
    │  │                   │  │
    │  └───────────────────┘  │
    │                         │
    │  [  Upgrade to Pro  ]   │
    │  [  Maybe Later     ]   │
    └─────────────────────────┘
```

---

## Summary: Core UX Metrics

| Metric                  | Target           |
|-------------------------|------------------|
| App open → camera ready | < 1 second       |
| Tap shutter → capture   | < 0.3 seconds    |
| Capture → result shown  | < 2 seconds      |
| Total: open → saved     | < 3 seconds      |
| Receipt list load       | < 0.5 seconds    |
| Export generation       | < 2 seconds      |

## Navigation Map (Bird's Eye)

```
                 ┌─────────────────┐
                 │   ONBOARDING    │
                 │  (first launch  │
                 │   only, 3       │
                 │   slides)       │
                 └────────┬────────┘
                          │ "Get Started"
                          ▼
    ┌────────────────────────────────────────────┐
    │              TAB BAR                       │
    │  📷 Camera  │  📋 Receipts  │  ⋯ More     │
    └──────┬────────────┬──────────────┬─────────┘
           │            │              │
           ▼            ▼              ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │ CAMERA   │  │ RECEIPTS │  │  MORE    │
    │ (default │  │  LIST    │  │          │
    │  tab)    │  │          │  │ Subscrip-│
    │          │  │ Search   │  │ tion     │
    │ Capture  │  │ Filter   │  │ Export   │
    │ →Process │  │          │  │ History  │
    │ →Result  │  │          │  │ Settings │
    └────┬─────┘  └────┬─────┘  │ Help     │
         │             │        └────┬─────┘
         │             │             │
         ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │ RECEIPT  │  │ RECEIPT  │  │ PAYWALL  │
    │ RESULT   │  │ DETAIL   │  │ (Pro)    │
    │ (overlay)│  │          │  │          │
    │          │  │ Image    │  │ Monthly/ │
    │ Edit or  │  │ Details  │  │ Annual   │
    │ Done     │  │ Export   │  │          │
    └──────────┘  └──────────┘  └──────────┘
```
