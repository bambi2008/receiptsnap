# Pricing Strategy — ReceiptSnap

> Date: June 2026 | Phase 0 Deliverable

---

## Pricing Recommendation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FREE TRIAL          PRO (Monthly)        PRO (Annual)
  50 receipts         $4.99/month          $39.99/year
  Full features       Full features        Full features
  No time limit       Unlimited receipts   Unlimited receipts
  Watermark on PDF                         Save 33%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Why This Model

### Why Freemium (not Hard Paywall)?

1. **Trust building**: Users need to experience the AI accuracy before paying. "It actually reads my receipts correctly" is the conversion trigger.
2. **App Store discovery**: Free apps get 10x more downloads than paid apps. Can't build a funnel if nobody downloads.
3. **Competitor benchmark**: Every competitor uses freemium. Hard paywall = dead on arrival.

### Why 50 Receipts (not Time-Limited)?

1. **Value-based limit**: User hits the wall when they've experienced value, not when a timer expires.
2. **Sarah uses ~20-25 receipts/month** → 50 receipts = ~2 months of usage = enough time to get hooked.
3. **No dark patterns**: Foreceipt deletes data after 12 months. We never delete data. Ethical differentiation.
4. **Natural conversion trigger**: "You've scanned 50 receipts! Unlock unlimited to keep going." — not "Your trial expired."

### Why $4.99/month?

| Price Point | Users Needed for $1,000 MRR | Pros | Cons |
|------------|---------------------------|------|------|
| $2.99 | 335 | Low barrier, more volume | Need 2x users; may signal "cheap" |
| **$4.99** | **201** | **Sweet spot — 1 coffee/month** | None |
| $6.99 | 144 | Fewer users needed | Price resistance for gig workers |
| $9.99 | 101 | Lowest user count needed | Too close to Expensify; limits TAM |

**$4.99 is the sweet spot because:**
- Psychologically = "one coffee per month" — easy to justify
- Below Expensify ($5/mo minimum, but with hidden costs) — competitive
- Above "too cheap to trust" threshold ($2.99)
- 201 users to $1,000 MRR is achievable with ASO alone
- Leaves room for annual discount ($39.99 = $3.33/mo)

---

## Unit Economics

### Revenue Math

```
Target: $1,000 MRR by Month 3

Scenario A (Conservative):
  Month 1: 500 downloads → 5% trial → 40% convert = 10 paid → $50 MRR
  Month 2: 800 downloads → 6% trial → 42% convert = 20 paid → $100 MRR (+$50)
  Month 3: 1,200 downloads → 7% trial → 45% convert = 38 paid → $190 MRR (+$90)
  TOTALS: 2,500 downloads, 68 paid users, $340 MRR
  
  ❌ This won't hit $1,000. Need additional acquisition channels.

Scenario B (ASO + Reddit + Product Hunt):
  Month 1: 500 downloads + Reddit launch = 1,200 total → 50 paid → $250 MRR
  Month 2: Organic 800 + word of mouth = 1,500 → 60 paid → $300 MRR (+$50)
  Month 3: Tax season bump (March) + organic = 3,000 → 120 paid → $600 MRR (+$300)
  TOTALS: 5,700 downloads, 230 paid users, $1,150 MRR
  
  ✅ Hits $1,000 with a tax-season tailwind.

Scenario C (Optimistic — viral TikTok/Reel):
  Month 1: Reddit + TikTok = 3,000 downloads → 120 paid → $600 MRR
  Month 2: Viral sustain = 5,000 → 200 paid → $1,000 MRR ✨
  
  🚀 Low probability but shows what's possible.
```

### CAC Estimation

| Channel | Est. CPI / Cost | Conversion Rate | Effective CAC |
|---------|----------------|-----------------|---------------|
| Apple Search Ads | $1.50-2.50 | 40% trial → paid | $3.75-6.25 |
| Organic ASO | $0 (time) | 40% | $0 |
| Reddit (organic posts) | $0 (time) | 35% | $0 |
| Product Hunt launch | $0 | 30% | $0 |
| TikTok/UGC content | $0 (time) | 25% | $0 |

**Strategy:** Lean heavily on organic channels. No paid acquisition until LTV is proven.

### LTV Calculation

```
Monthly churn assumption (based on productivity app benchmarks):
  Month 1: 30% churn (trial hoppers)
  Month 2-6: 8% monthly churn  
  Month 7+: 5% monthly churn

Average user lifespan: ~14 months
LTV = $4.99 × 14 = ~$70
LTV:CAC ratio (organic): ∞ (no CAC)
LTV:CAC ratio (paid): 11-19x ✅ (target >3x)
```

---

## Competitor Pricing Comparison

| App | Free Tier | Monthly | Annual (per mo) | Key Limitation |
|-----|-----------|---------|-----------------|----------------|
| Expensify | "Free" (limited) | $5.00 | — | Categorization needs paid |
| Foreceipt | 100 receipts | $5.00 | — | Data deleted after 12mo on free |
| Smart Receipts | Ad-supported | $4.99 | $2.99 | Ads on free tier |
| SimplyWise | 50 receipts | — | $3.33-7.50 | Export locked behind $90/yr |
| Wave Receipts | — | $8.00 | — | Must use Wave accounting |
| QuickBooks SE | — | $15.00 | $12.50 | Full accounting, overkill |
| **ReceiptSnap** | **50 receipts** | **$4.99** | **$3.33** | **No data deletion, no dark patterns** |

---

## Pricing Psychology Tactics

1. **"50 receipts, not 30 days"** — Value-based limit feels fairer. Time-based trials feel like traps.
2. **Annual discount = 33%** — Standard SaaS discount rate. Drives LTV and reduces churn.
3. **No "Pro" branding** — Don't make free users feel like second-class. Just "ReceiptSnap" with a limit counter.
4. **Conversion screen design**: When user hits 50 receipts, show their stats — "You've captured $2,340 in deductible expenses. Unlock unlimited to keep saving." — value-first, not guilt.
5. **Price anchoring**: Show $4.99/month next to $39.99/year ($3.33/mo) → annual looks like a deal.

---

## Revenue Milestone Timeline

```
Week 0:     Launch on App Store
Week 1:     Reddit launch (r/freelance, r/iosapps, r/smallbusiness)
Week 2:     Product Hunt launch
Week 4:     First revenue milestone: $100 MRR
Week 8:     Feature drop (v1.1) + ASO optimization round 1
Week 10:    Tax season ramp starts (late February) ← KEY MOMENT
Week 12:    Target: $1,000 MRR 🎯
Week 16:    Tax season peak → potential $2,000-3,000 MRR spike
Week 20:    Post-tax-season stabilization → $800-1,200 MRR steady state
```

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Tax season spike, then churn cliff | Medium | High | Build habit before tax season. Dashboard, monthly summaries. |
| Apple rejects IAP implementation | Low | Medium | TestFlight thoroughly. Use StoreKit 2 best practices. |
| Competitor drops price | Low | Medium | We're already the value option. Compete on AI quality, not price. |
| Low conversion rate (<20%) | Medium | High | A/B test paywall timing. Move from 50→30 receipts if needed. |
| User expects "completely free forever" | High | Low | Clear messaging in onboarding. "50 free receipts, then $4.99/mo." |
