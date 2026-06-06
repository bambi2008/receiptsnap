# User Personas — US Freelancer Receipt Scanner

> Date: June 2026 | Phase 0 Deliverable

---

## Persona A: Creative Freelancer

### Sarah Chen — Freelance UX Designer

```
Age: 32 | Location: Austin, TX | Income: $85,000/yr
Filing: Schedule C, sole proprietor
Clients: 4-5 active at any time
```

**Daily Life:**
Sarah works from home and a co-working space. She invoices clients monthly through QuickBooks Simple Start ($15/mo). She buys design software, hardware, co-working day passes, coffee meetings, and conference tickets — all deductible. But she tracks nothing until tax season.

**Current Receipt "System":**
- Takes photos of receipts on her iPhone
- They sit in Camera Roll mixed with cat photos
- Every March, spends a weekend scrolling through photos, manually adding up totals in a spreadsheet
- Usually misses 20-30% of deductions because she can't find the receipt

**Pain Points:**
1. "I KNOW I'm losing money every tax season because I can't find receipts"
2. "Expensify feels like it was built for a 500-person company, not me"
3. "I don't want to learn accounting — I want to take a photo and forget about it"
4. "My CPA charges $300/hour and gets annoyed when I hand her a shoebox"

**Willingness to Pay:** $5-10/month — "That's one coffee. If it saves me 3 hours in March, it's a no-brainer."

**What Would Make Her Switch:**
- Open app → camera is already on (zero taps to start)
- AI auto-categorizes everything without asking
- One-tap "Export for CPA" in March
- Doesn't feel like "doing accounting"

**Decision Trigger:**
"Tax season panic" — she'll search "receipt scanner for freelancers" in late February.

---

## Persona B: Gig Worker

### Marcus Johnson — Rideshare Driver + Delivery

```
Age: 28 | Location: Atlanta, GA | Income: $52,000/yr
Filing: Schedule C, sole proprietor
Platforms: Uber, DoorDash, Instacart
```

**Daily Life:**
Marcus drives 40-50 hours/week across 3 platforms. His deductible expenses: gas, car maintenance, phone bill, snacks/water for passengers, car washes, phone mount, charging cables. He also tracks mileage (critical for his tax return — $0.67/mile adds up fast).

**Current Receipt "System":**
- Gas receipts go in the glove box until it overflows
- Sometimes takes photos, usually loses them
- End of year: dumps everything on his cousin who "knows QuickBooks"
- Has no idea what his actual profit margin is month-to-month

**Pain Points:**
1. "I don't have time for this — I'm driving 10 hours a day"
2. "Mileage tracking + receipt tracking should be one thing"
3. "I need to know if I'm actually making money this month"
4. "Tax season is terrifying — I never know if I'll owe $2,000 or get a refund"

**Willingness to Pay:** $3-5/month — price-sensitive but will pay if it directly saves him money on taxes.

**What Would Make Him Switch:**
- Fastest possible receipt capture (1-2 seconds)
- Auto-detects gas vs maintenance vs supplies
- Shows simple monthly profit/loss summary
- Reminds him to track mileage (or integrates with mileage tracker)

**Decision Trigger:**
Word of mouth from other drivers — or a TikTok video showing how much he could save on taxes.

---

## Persona C: Independent Consultant

### David Park — Fractional CFO / Business Consultant

```
Age: 45 | Location: Chicago, IL | Income: $185,000/yr
Filing: LLC (S-Corp election), monthly payroll to self
Clients: 3 retainer clients, occasional project work
```

**Daily Life:**
David runs a real consulting business. He has a CPA, a business bank account, and a basic understanding of accounting. He travels for client meetings (flights, hotels, meals), buys software subscriptions, and attends industry conferences. His receipts are a mix of paper and email.

**Current Receipt "System":**
- Uses Expensify "because that's what everyone uses"
- Hates it — too many features, confusing approval workflows he doesn't need
- Forwards email receipts to Expensify, takes photos of paper receipts
- Monthly: exports to CSV, sends to CPA
- CPA still finds errors in categorization

**Pain Points:**
1. "Expensify is overkill but I don't know what else to use"
2. "My CPA bills me to fix categorization mistakes that an AI should catch"
3. "I want clean monthly reports, not a bloated expense management platform"
4. "I travel internationally — multi-currency support is essential"

**Willingness to Pay:** $10-15/month — values time over money. "If it saves my CPA 1 hour/month at $300/hr, it pays for itself 20x over."

**What Would Make Him Switch:**
- Clean, professional-looking reports for CPA
- Multi-currency with automatic conversion
- Email forwarding for digital receipts
- Integrates with QuickBooks Online (which his CPA uses)
- AI that actually learns his categories (travel, software, meals, office)

**Decision Trigger:**
His CPA recommends it — or he sees it mentioned in a professional community (r/consulting, Indie Hackers).

---

## Persona Summary Matrix

| Dimension | Sarah (Creative) | Marcus (Gig) | David (Consultant) |
|-----------|-----------------|--------------|-------------------|
| Income | $85K | $52K | $185K |
| Tax complexity | Medium | Low-Medium | High |
| Current solution | Camera roll | Glove box | Expensify (reluctantly) |
| Primary pain | Lost deductions | No time | CPA costs |
| WTP monthly | $5-10 | $3-5 | $10-15 |
| Decision trigger | Tax season panic | Peer recommendation | CPA recommendation |
| Must-have feature | Instant camera, CPA export | Speed, mileage integration | Clean reports, multi-currency |
| Risk of churn | Low (sticky during tax year) | High (price sensitive) | Low (deeply integrated) |

---

## Target Prioritization

**Primary: Sarah (Creative Freelancer)**
- Largest segment (designers, writers, developers, photographers, marketers)
- Strong willingness to pay
- Tax season = natural acquisition funnel
- "I hate bookkeeping" emotional hook is powerful

**Secondary: David (Independent Consultant)**
- Highest revenue per user
- Influences others (CPA recommendation flywheel)
- Feature requests align with product roadmap (reports, integrations)

**Tertiary: Marcus (Gig Worker)**
- Largest absolute numbers but lowest conversion rate
- Better targeted after we have product-market fit
- May need separate "gig worker" SKU with mileage tracking
