# Mac Handoff Checklist — ReceiptSnap

> When you're ready to continue development on your Mac, follow this checklist.

---

## Step 1: Prerequisites on Mac

```bash
# 1. Install Hermes Agent
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# 2. Install Flutter (macOS)
# Option A: Direct download
# https://docs.flutter.dev/get-started/install/macos
# 
# Option B: Homebrew
brew install --cask flutter

# 3. Install Xcode (from App Store)
# Required for iOS build + simulator + signing
# Search "Xcode" in Mac App Store

# 4. After Xcode install, run:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

---

## Step 2: Copy Project to Mac

```bash
# On Windows, copy this folder:
D:\hermes-workspace\projects\receipt-scanner\

# To Mac (any path, e.g.):
~/Projects/receipt-scanner/

# Or use git:
git clone <your-repo-url>
```

---

## Step 3: First Build on Mac

```bash
cd ~/Projects/receipt-scanner/app

# Get dependencies
flutter pub get

# Verify everything compiles
flutter analyze

# Run tests
flutter test

# Open iOS simulator + run
open -a Simulator
flutter run
```

---

## Step 4: What Hermes Can Do on Mac

Once Hermes is running on your Mac, I can directly:

### iOS Build & Test
- `flutter run` — launch in iOS simulator
- `flutter build ios` — build for device/archive
- Xcode project configuration
- Code signing + provisioning profiles

### Vision OCR Integration (Real OCR)
- Replace current placeholder with native Vision framework
- Create Method Channel bridge: Flutter ↔ Swift
- Real-time receipt text extraction
- High accuracy for printed receipts

### StoreKit 2 IAP Testing
- Configure products in App Store Connect
- Test purchases in sandbox
- Verify receipts with App Store server
- Handle subscription states (active, expired, grace period)

### TestFlight Distribution
- Archive build
- Upload to App Store Connect
- Distribute to internal/external testers

---

## Step 5: Key Files to Modify on Mac

| File | What to Do |
|------|-----------|
| `ios/Runner/` | Add Swift code for Vision OCR bridge |
| `ios/Runner/Info.plist` | Add camera usage description, Photo Library |
| `lib/services/ocr_service.dart` | Wire up to native Vision bridge |
| `lib/providers/subscription_provider.dart` | Replace simulation with real StoreKit 2 |

---

## Step 6: App Store Connect Setup

Visit https://appstoreconnect.apple.com

1. **Create App ID** in Certificates, Identifiers & Profiles
2. **Create App** in App Store Connect
   - Bundle ID: com.receiptsnap.app
   - SKU: receiptsnap-001
3. **Configure In-App Purchases:**
   - Monthly: com.receiptsnap.pro.monthly ($4.99)
   - Annual: com.receiptsnap.pro.annual ($39.99)
4. **Upload screenshots** (use ASO guide: docs/aso-strategy.md)
5. **Fill in app description** (from aso-strategy.md)
6. **Set privacy policy URL** (from docs/privacy-policy.md)
7. **Set terms URL** (from docs/terms-of-service.md)

---

## Step 7: Current Status Summary

```
✅ flutter analyze: 0 issues
✅ flutter test:    54 tests, all pass
✅ Dart code:       19 source files complete
✅ ASO strategy:    keywords, description, screenshot plan
✅ Legal:           privacy policy + terms of service
⏳ Mac:             Hermes install, Flutter install, Xcode setup
⏳ iOS native:      Vision OCR bridge, StoreKit 2 integration
⏳ App Store:       listing, IAP configuration, TestFlight
```

---

## Quick Start Command for Hermes on Mac

After installing Hermes + Flutter + Xcode, tell me in a new session:

```
Project is at ~/Projects/receipt-scanner/app on my Mac.
Let's: 1) integrate Vision OCR, 2) test in simulator.
```

I'll pick up from there.
