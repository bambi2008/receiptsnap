# ReceiptSnap — Design System Specification

## 1. Design Principles

| Principle          | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **Zero Friction**  | Camera is live on app open. One tap to capture. No menus, no delays.        |
| **Clarity**        | Every screen has one purpose. Information hierarchy guides the eye.         |
| **Confidence**     | Users trust the AI. Show results immediately; allow correction, not friction.|
| **iOS-Native**     | Follow Apple HIG. SF Pro, system spacings, standard navigation patterns.    |
| **Delight**        | Micro-interactions: shutter animation, processing sparkle, subtle haptics.  |

---

## 2. Color System

### 2.1 Brand Colors

| Token            | Hex       | Usage                                  |
|------------------|-----------|----------------------------------------|
| `blue` (Primary) | `#007AFF` | Buttons, links, active states, tab bar |
| `blue-dark`      | `#0056CC` | Pressed button states                  |
| `blue-light`     | `#E8F2FF` | Selected backgrounds, highlights       |

### 2.2 Semantic Colors

| Token    | Hex       | Usage                        |
|----------|-----------|------------------------------|
| `green`  | `#34C759` | Success states, Pro tier     |
| `orange` | `#FF9500` | Warnings, free tier accent   |
| `red`    | `#FF3B30` | Destructive actions, errors  |
| `purple` | `#AF52DE` | Premium/Pro accents          |

### 2.3 Neutrals

| Token         | Hex       | Usage                              |
|---------------|-----------|------------------------------------|
| `bg`          | `#F2F2F7` | App background (systemBackground)  |
| `bg-card`     | `#FFFFFF` | Card / sheet backgrounds           |
| `bg-header`   | `#F9F9FB` | Navigation bar / header bg         |
| `separator`   | `#E5E5EA` | Dividers, borders (opaque)         |
| `text`        | `#1C1C1E` | Primary text (label)               |
| `text-sec`    | `#8E8E93` | Secondary text (secondaryLabel)    |
| `text-tert`   | `#C7C7CC` | Tertiary / placeholder text        |

### 2.4 IRS Schedule C Category Colors

Each IRS Schedule C expense category maps to a distinct color for visual scanning in receipt lists.

| Category                  | Hex       | Icon  | Schedule C Line |
|---------------------------|-----------|-------|-----------------|
| **Meals & Entertainment** | `#FF9500` | 🍽    | Line 24b        |
| **Software & Tools**      | `#007AFF` | 💻    | Line 18         |
| **Office Expenses**       | `#34C759` | 🏢    | Line 18         |
| **Travel**                | `#5856D6` | ✈️    | Line 24a        |
| **Phone & Internet**      | `#5AC8FA` | 📱    | Line 25         |
| **Supplies & Materials**  | `#AF52DE` | 📦    | Line 22         |
| **Rent & Lease**          | `#FF3B30` | 🏠    | Line 20a        |
| **Advertising/Marketing** | `#FF2D55` | 📣    | Line 8          |
| **Insurance**             | `#FFCC00` | 🛡    | Line 15         |
| **Other Expenses**        | `#8E8E93` | 📋    | Line 27a        |

---

## 3. Typography

### 3.1 Font Family

```
Primary: SF Pro Display / SF Pro Text (iOS system font)
Fallback: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif
Monospace (amounts, codes): SF Mono / Menlo
```

### 3.2 Type Scale

| Token       | Size / Leading | Weight   | Usage                              |
|-------------|----------------|----------|------------------------------------|
| `largeTitle`| 34 / 41        | Bold 700 | Onboarding headlines               |
| `title1`    | 28 / 34        | Bold 700 | Screen titles (onboarding)         |
| `title2`    | 22 / 28        | Bold 700 | Summary card main numbers          |
| `title3`    | 20 / 25        | Semibold 600 | Section headers               |
| `headline`  | 17 / 22        | Semibold 600 | Navigation titles, card headers|
| `body`      | 17 / 22        | Regular 400| Primary body text                  |
| `callout`   | 16 / 21        | Semibold 600| Receipt vendor names, buttons   |
| `subhead`   | 15 / 20        | Medium 500 | Field values, list subtitles       |
| `footnote`  | 13 / 18        | Regular 400| Secondary metadata, timestamps     |
| `caption1`  | 12 / 16        | Medium 500 | Badges, labels, overline text      |
| `caption2`  | 11 / 13        | Semibold 600| Tab bar labels, tiny annotations  |

### 3.3 Usage Rules

- **Never** go below `caption2` (11pt) — accessibility minimum.
- Amounts always use **tabular figures** (`font-variant-numeric: tabular-nums`) for alignment.
- Section headers use **SF Pro Text Semibold 13pt, tracked +0.5**, uppercase, `#8E8E93`.
- Large titles (onboarding) get `letter-spacing: -0.3px` for tighter rendering.

---

## 4. Spacing Grid

All spacing is based on a **4-point grid**. Use these tokens, not arbitrary values.

| Token      | px  | pt   | Usage                                       |
|------------|-----|------|---------------------------------------------|
| `space-0`  | 0   | 0    | No spacing                                  |
| `space-1`  | 4   | 3    | Icon-to-text gap, tight padding             |
| `space-2`  | 8   | 6    | Internal card padding, small gaps           |
| `space-3`  | 12  | 9    | List item padding, card-to-card gap         |
| `space-4`  | 16  | 12   | Standard screen margin, card padding        |
| `space-5`  | 20  | 15   | Section spacing                             |
| `space-6`  | 24  | 18   | Large section padding, sheet top padding    |
| `space-8`  | 32  | 24   | Hero spacing, onboarding margins            |
| `space-10` | 40  | 30   | Onboarding illustration spacing             |
| `space-12` | 48  | 36   | Full-screen breathing room                  |

### Layout Constants

| Element            | Value       |
|--------------------|-------------|
| Screen margin      | 16px (space-4) |
| Card border radius | 12px (radius-md) |
| Sheet border radius| 16px (radius-lg) top only |
| Button height      | 50px        |
| Minimum tap target | 44×44pt (Apple HIG) |
| Tab bar height     | 84px (includes safe area) |
| Status bar height  | 54px (dynamic island) |
| Navigation bar     | 44px + status |

---

## 5. Component Styles

### 5.1 Primary Button

```
Background:     #007AFF
Text:           #FFFFFF
Font:           SF Pro Text Semibold 17pt
Height:         50px
Radius:         12px (radius-md)
Padding H:      16px
Shadow:         none (flat iOS style)
Pressed:        scale(0.97), opacity 0.85
Disabled:       40% opacity
```

### 5.2 Secondary Button

```
Background:     #F2F2F7 (bg)
Text:           #007AFF
Font:           SF Pro Text Semibold 17pt
Height:         50px
Radius:         12px
Border:         none
Pressed:        background darkens to #E5E5EA
```

### 5.3 Tab Bar

```
Background:     #FFFFFF (with 0.5px #E5E5EA top border)
Height:         84px (49px + 35px safe area inset)
Layout:         Flex row, 3 equal columns
Active:         #007AFF, SF Pro Text Semibold 10pt
Inactive:       #8E8E93, SF Pro Text Medium 10pt
Icon size:      24px (SF Symbols style)
```

### 5.4 Receipt Card (List)

```
Background:     #FFFFFF
Radius:         12px
Padding:        12px H, 12px V
Layout:         Row: [44px icon] [flex info] [amount]
Shadow:         0 1px 3px rgba(0,0,0,0.04)
Margin:         0 16px 8px

-- Icon slot --
Size:           44×44px
Radius:         8px
Background:     tinted 12% of category color
Icon:           22px emoji or SF Symbol, category color

-- Info --
Vendor:         SF Pro Text Semibold 16pt, #1C1C1E
Meta:           SF Pro Text Regular 13pt, #8E8E93
                (shows date or "category · date")

-- Amount --
Font:           SF Pro Text Bold 16pt, tabular-nums, #1C1C1E
```

### 5.5 Summary Card (Receipts tab)

```
Background:     #007AFF (blue gradient)
Radius:         12px
Padding:        16px
Text:           all white

-- Title --
Font:           SF Pro Text Medium 13pt, 80% opacity white
                uppercase, tracked

-- Main number --
Font:           SF Pro Display Bold 22pt, white

-- Subtitle --
Font:           SF Pro Text Regular 13pt, 85% opacity white
```

### 5.6 Search Bar

```
Background:     #E5E5EA (systemFill)
Radius:         10px
Padding:        10px 12px
Height:         36px
Layout:         Row: [🔍 16px] [input flex]

-- Input --
Font:           SF Pro Text Regular 15pt, #1C1C1E
Placeholder:    "Search receipts", #8E8E93
```

### 5.7 Result Sheet (Camera → After Scan)

```
Position:       Bottom sheet, slides up
Background:     #FFFFFF
Radius:         16px top-left, 16px top-right (0 bottom)
Padding:        20px 20px 100px (extra bottom for safe area)
Handle:         36×5px, #E5E5EA, centered

-- Rows --
Layout:         Flex row, space-between
Padding:        12px 0
Border-bottom:  0.5px #E5E5EA (except last)
Label:          SF Pro Text Regular 13pt, #8E8E93
Value:          SF Pro Text Medium 15pt, #1C1C1E

-- Actions --
Layout:         Flex row, 10px gap
Spacing:        20px margin-top
```

### 5.8 Subscription Card (More tab)

```
Background:     #FFFFFF
Radius:         16px
Padding:        20px
Margin:         16px

-- Tier badge --
Font:           SF Pro Text Semibold 13pt, #8E8E93, uppercase tracked

-- Status --
Font:           SF Pro Display Bold 20pt, #1C1C1E

-- Progress bar --
Height:         6px
Background:     #F2F2F7
Fill:           #007AFF (or #34C759 for Pro)
Radius:         3px

-- Upgrade button --
Same as Primary Button, full width
Text:           "✨ Upgrade to Pro — $7.99/mo"
```

### 5.9 Receipt Image Placeholder

```
Aspect Ratio:   3:4 (portrait receipt)
Background:     #E8E8EA
Radius:         12px
Center:         🧾 emoji (60px, 60% opacity)
Overlay:        "Pinch to zoom" badge (bottom-right)
```

### 5.10 Viewfinder (Camera)

```
Aspect Ratio:   3:4
Background:     #1C1C1E (simulated camera dark)
Corners:        4 corner brackets, 24×24px each
                rgba(255,255,255,0.6), 2px stroke
Position:       12px inset from viewfinder edges
```

### 5.11 Shutter Button

```
Size:           72×72px
Shape:          Circle
Fill:           #FFFFFF
Border:         5px rgba(255,255,255,0.3)
Outer ring:     2px rgba(255,255,255,0.15), 8px outset
Pressed:        scale(0.92), fill #E0E0E0
```

### 5.12 Onboarding Slides

```
Background:     #FFFFFF
Layout:         Column, centered
Illustration:   80px emoji, 32px margin-bottom
Title:          SF Pro Display Bold 28pt, #1C1C1E, centered
Subtitle:       SF Pro Text Regular 16pt, #8E8E93, centered, max 280px

-- Dots --
Size:           8×8px, 8px gap
Active:         #007AFF, scale(1.3)
Inactive:       #C7C7CC

-- Button --
Same as Primary Button, 320px max-width
```

---

## 6. Iconography

### 6.1 Category Icons (Emoji primary, SF Symbols fallback)

| Category    | Emoji | SF Symbol          |
|-------------|-------|--------------------|
| Meals       | 🍽    | fork.knife         |
| Software    | 💻    | laptopcomputer     |
| Office      | 🏢    | building.2         |
| Travel      | ✈️    | airplane           |
| Phone       | 📱    | iphone             |
| Supplies    | 📦    | shippingbox        |
| Rent        | 🏠    | house              |
| Marketing   | 📣    | megaphone          |
| Insurance   | 🛡    | shield             |
| Other       | 📋    | doc.text           |

### 6.2 UI Icons

| Context       | SF Symbol         | Size  |
|---------------|-------------------|-------|
| Camera tab    | camera.fill       | 24pt  |
| Receipts tab  | doc.text.fill     | 24pt  |
| More tab      | ellipsis.circle   | 24pt  |
| Back          | chevron.left      | 20pt  |
| Search        | magnifyingglass   | 16pt  |
| Export PDF    | doc.richtext      | 16pt  |
| Export CSV    | tablecells        | 16pt  |
| Edit          | pencil            | 16pt  |
| Checkmark     | checkmark         | 16pt  |
| Settings      | gear              | 16pt  |
| Privacy       | lock              | 16pt  |
| Help          | questionmark.circle| 16pt |

---

## 7. Motion & Animation

### 7.1 Screen Transitions

| Transition        | Duration | Easing                          |
|-------------------|----------|---------------------------------|
| Tab switch        | 300ms    | cubic-bezier(0.25, 0.46, 0.45, 0.94) |
| Push detail       | 350ms    | ease-in-out                     |
| Bottom sheet up   | 350ms    | cubic-bezier(0.32, 0.72, 0, 1)  |
| Modal appear      | 300ms    | ease-out                        |
| Onboarding slide  | 400ms    | cubic-bezier(0.25, 0.46, 0.45, 0.94) |

### 7.2 Micro-Interactions

| Interaction        | Effect                                           |
|--------------------|--------------------------------------------------|
| Shutter press      | Viewfinder flash (brightness ➚➘, 150ms)          |
| Processing         | Spinner + "Reading receipt…" text, 1-2s          |
| Result appear      | Sheet slides up from bottom                      |
| Receipt saved      | Toast: "Saved! ✓", 2s then auto-dismiss          |
| Button press       | scale(0.97) + 15% opacity dip, 150ms             |
| Card tap           | scale(0.98) with subtle highlight                |
| Pull to refresh    | Standard iOS spinner                             |
| Category change    | Dot color transitions (300ms ease)               |

### 7.3 Haptics (iOS UIFeedbackGenerator)

| Event              | Haptic Type         |
|--------------------|---------------------|
| Shutter capture    | `impact` — medium   |
| Scan complete      | `notification` — success |
| Receipt saved      | `impact` — light    |
| Limit reached      | `notification` — warning |
| Upgrade confirmed  | `notification` — success |

---

## 8. Data Display Conventions

### 8.1 Amounts

- Always prefixed with `$`
- Two decimal places: `$4.75`, `$59.99`, `$1,847.32`
- Negative values (refunds) in red: `-$12.50` in `#FF3B30`
- Large amounts use comma separators: `$1,847` not `$1847`

### 8.2 Dates

| Context            | Format              | Example            |
|--------------------|---------------------|--------------------|
| Receipt card meta  | `MMM D, YYYY`       | Jun 5, 2026        |
| Detail screen      | `Month D, YYYY`     | June 5, 2026       |
| Section headers    | `MONTH YYYY` (all caps) | JUNE 2026      |
| Relative (future)  | "Today", "Yesterday"| —                  |

### 8.3 Vendor Names

- Display full name, no truncation unless >30 chars
- If truncated: "Adobe Creative Cl…"
- Standardize common vendors: "Starbucks" not "STARBUCKS #04231"

### 8.4 Receipt Count Display

```
Free tier:  "32 of 50 receipts used" or "18 free remaining"
Limit hit:  "50/50 — Upgrade to Pro for unlimited"
Pro:        "Pro — Unlimited"
```

---

## 9. Screen Specifications

### 9.1 Camera Screen (Home Tab)

```
┌──────────────────────────────────┐
│  Status Bar (54px)               │
│  9:41              ●●●●○ WiFi 🔋│
├──────────────────────────────────┤
│                                  │
│          ┌────────────┐          │
│          │            │  [Free:  │
│          │ ┌────────┐ │   47     │
│          │ │ receipt │ │  left]  │
│          │ │ silhou- │ │         │
│          │ │ ette    │ │         │
│          │ └────────┘ │         │
│          │            │          │
│          └────────────┘          │
│      Position receipt in frame   │
│                                  │
│     [🖼]      ◉━━━━━━━◉          │
│    gallery   shutter (72px)      │
├──────────────────────────────────┤
│  📷 Camera  │  📋 Receipts │ ⋯  │
│             │              │     │
└──────────────────────────────────┘
```

**Key specs:**
- Viewfinder: 3:4 aspect ratio, max 460px height, 24px horizontal margins
- Shutter: 72px circle, centered, 16px above tab bar
- Gallery thumbnail: 40×40px, positioned 40px from left edge
- Free badge: top-right of viewfinder, 12px inset

### 9.2 Receipts List Screen

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │ THIS MONTH                 │  │
│  │ 23 receipts                │  │
│  │ $1,847.32 in deductions    │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 🔍 Search receipts        │  │
│  └────────────────────────────┘  │
│  JUNE 2026                       │
│  ┌────────────────────────────┐  │
│  │ 🍽 Starbucks      $4.75   │  │
│  │    Jun 5, 2026             │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 💻 Adobe CC       $59.99  │  │
│  │    Jun 4, 2026             │  │
│  └────────────────────────────┘  │
│  ...scrollable...                │
└──────────────────────────────────┘
```

### 9.3 Receipt Detail Screen

```
┌──────────────────────────────────┐
│  ← Starbucks                     │
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │        🧾                  │  │
│  │    (receipt image)         │  │
│  │                    Pinch↗  │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ Vendor        Starbucks   │  │
│  │ Amount        $4.75       │  │
│  │ Category   ● Meals  [Edit]│  │
│  │ Date     June 5, 2026     │  │
│  │ Note     Client meeting   │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │    📄 Export as PDF       │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │    📊 Export as CSV       │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 9.4 More / Settings Screen

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │ 🆓 FREE TIER              │  │
│  │ 32 of 50 receipts used    │  │
│  │ ┌────────────────────┐    │  │
│  │ │████████░░░░░░░░░░░░│    │  │
│  │ └────────────────────┘    │  │
│  │ 18 free remaining         │  │
│  │ ┌────────────────────┐    │  │
│  │ │✨ Upgrade to Pro   │    │  │
│  │ │   $7.99/mo         │    │  │
│  │ └────────────────────┘    │  │
│  │ Pro: Unlimited, CSV/PDF,  │  │
│  │ Schedule C, Priority      │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 📤 Export History      ›  │  │
│  │ ⚙️ App Settings         ›  │  │
│  │ ❓ Help & Support      ›  │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 🔒 Privacy Policy      ›  │  │
│  │ 📄 Terms of Service    ›  │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 10. Accessibility

| Requirement              | Implementation                               |
|--------------------------|----------------------------------------------|
| Minimum tap target       | 44×44pt (Apple HIG)                          |
| Minimum font size        | 11pt (caption2), only for non-critical text  |
| Color contrast           | All text meets WCAG AA (4.5:1 for body text) |
| Dynamic Type             | Support all iOS text size adjustments        |
| VoiceOver labels         | Every interactive element has accessibilityLabel |
| Reduced motion           | Respect `prefers-reduced-motion` — disable animations |
| Haptic feedback          | System haptics for key actions (shutter, save, error) |

---

## 11. Error & Empty States

### 11.1 Empty Receipt List (new user)

```
┌──────────────────────────────────┐
│                                  │
│            🧾                    │
│                                  │
│     No receipts yet              │
│                                  │
│  Tap the Camera tab to snap      │
│  your first business expense.    │
│                                  │
│     ┌──────────────────┐         │
│     │ 📷 Snap Receipt  │         │
│     └──────────────────┘         │
│                                  │
└──────────────────────────────────┘
```

### 11.2 Free Limit Reached

```
┌──────────────────────────────────┐
│                                  │
│           📸 50/50               │
│                                  │
│   You've used all your free      │
│   receipts this month.           │
│                                  │
│   Upgrade to Pro for unlimited   │
│   scanning and exports.          │
│                                  │
│   ┌────────────────────────┐     │
│   │ ✨ Upgrade to Pro      │     │
│   └────────────────────────┘     │
│        Maybe Later               │
│                                  │
└──────────────────────────────────┘
```

### 11.3 Camera Permission Denied

```
┌──────────────────────────────────┐
│                                  │
│           📷 ⊘                   │
│                                  │
│   Camera access needed           │
│                                  │
│   ReceiptSnap needs camera       │
│   access to scan receipts.       │
│                                  │
│   ┌────────────────────────┐     │
│   │ Open Settings →        │     │
│   └────────────────────────┘     │
│                                  │
└──────────────────────────────────┘
```

### 11.4 Network Error (AI processing fails)

```
┌──────────────────────────────────┐
│                                  │
│           ⚠️                     │
│                                  │
│   Couldn't read receipt          │
│                                  │
│   Please try again. Make sure    │
│   the receipt is well-lit and    │
│   all text is visible.           │
│                                  │
│   ┌────────────────────────┐     │
│   │ Try Again              │     │
│   └────────────────────────┘     │
│   Enter details manually         │
│                                  │
└──────────────────────────────────┘
```

---

## 12. Pro / Free Tier Differentiators

| Feature               | Free Tier                    | Pro ($7.99/mo or $59.99/yr) |
|-----------------------|------------------------------|-----------------------------|
| Receipts / month      | 50                           | Unlimited                   |
| AI auto-categorize    | ✓                            | ✓                           |
| Category editing      | ✓                            | ✓                           |
| Export PDF            | — (watermarked preview only) | ✓ Clean PDF                 |
| Export CSV            | —                            | ✓                           |
| Schedule C mapping    | —                            | ✓ Auto-mapped               |
| Search receipts       | ✓ (last 3 months)            | ✓ All time                  |
| Priority support      | —                            | ✓                           |
| Receipt image storage | 90 days                      | Forever                     |
| Watermark             | Yes on exports               | None                        |
