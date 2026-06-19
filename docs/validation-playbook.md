# SnapDeduct — Demand Validation Playbook

> Purpose: Prove (or kill) the idea BEFORE investing more in the product.
> Principle we violated and are now fixing: "Validate before you build."
> Timeline: 1 week. Cost: ~$50-100.

---

## Why We're Doing This

The triangle assessment exposed it: we built a full app without a single real user saying "I'd pay for this." This playbook fixes that with a **fake door test** — a landing page that looks like a real product, measures real intent, costs almost nothing.

**The landing page is built** (`website/index.html`). It has:
- Clear value prop + pricing ($39.99/yr annual-led)
- Email capture form (the "fake door")
- Success modal + waitlist counter
- Pain-point section that mirrors our personas

---

## Step 1: Wire Up Real Email Capture (30 min)

The page currently stores emails in browser localStorage (demo only). Replace with a real backend so you actually collect emails.

**Easiest option — Formspree (free tier, 50 submissions/mo):**

1. Sign up at formspree.io, create a form, get your form ID
2. In `website/index.html`, find the `handleSignup` function
3. Replace the localStorage block with:
```javascript
fetch('https://formspree.io/f/YOUR_FORM_ID', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({email})
});
```

**Alternatives:** Mailchimp (free to 500), ConvertKit, Google Forms embed, Tally.so

---

## Step 2: Add Analytics (15 min)

You need to measure **conversion rate**, not just signups. Add Plausible (privacy-friendly, ~$9/mo) or Google Analytics (free):

```html
<!-- Add to <head> -->
<script defer data-domain="snapdeduct.com" src="https://plausible.io/js/script.js"></script>
```

The page already fires `plausible('Waitlist Signup')` on submit — so you'll see:
- Total visitors
- Signup conversions
- **Conversion rate = the number that matters**

---

## Step 3: Deploy the Page (20 min)

Free hosting options:
- **GitHub Pages** — already have the repo, enable Pages on the `website/` folder
- **Netlify / Vercel** — drag-drop deploy, free, custom domain
- **Cloudflare Pages** — free, fast

Buy `snapdeduct.com` (~$12/yr on Namecheap/Cloudflare) — or use the free `*.netlify.app` subdomain for the test.

---

## Step 4: Drive Traffic (the real test) — $50-100

You need ~300-500 targeted visitors to get a statistically meaningful read.

### Channel A: Reddit (free, but careful)
Post in r/freelance, r/juststart, r/digitalnomad. **Don't spam** — tell a story:
> "I'm building a receipt tracker for freelancers because I kept losing deductions. Would love feedback before I finish it: [link]"

### Channel B: Reddit/Facebook Ads ($50)
- Target: US, interests = freelancing, self-employed, Uber/Lyft drivers, Etsy sellers
- Run $10/day for 5 days
- Send straight to the landing page

### Channel C: Twitter/X (free)
- Reply to freelance-tax threads
- Post in #freelance #indiehackers

### Channel D: Cold outreach (free, highest signal)
- DM 20 freelancers: "Building this, would you use it?" + link
- Their unfiltered reactions = gold

---

## Step 5: Read the Results — The Decision Gate

After ~300-500 visitors, look at the conversion rate:

```
┌─────────────────────────────────────────────────────────┐
│  CONVERSION RATE   →   VERDICT                            │
├─────────────────────────────────────────────────────────┤
│  > 8%              →   🟢 STRONG. Build & launch hard.    │
│  4-8%              →   🟡 OK. Real but niche. Proceed     │
│                        cautiously, sharpen positioning.   │
│  2-4%              →   🟠 WEAK. Rethink value prop or     │
│                        target a sharper niche.            │
│  < 2%              →   🔴 KILL or PIVOT. Demand isn't     │
│                        there at this price/positioning.   │
└─────────────────────────────────────────────────────────┘

Benchmark: a good waitlist landing page converts 5-15% of
targeted traffic. Below 2% on targeted traffic = the market
is telling you no.
```

### Beyond the number — qualitative signals
- **Do people reply to the welcome email?** Engaged users = real demand
- **What do they say their #1 pain is?** Validates or breaks your persona
- **Will anyone pre-pay?** The ultimate test — offer a "lock in 50% off lifetime" pre-order. Even 3 pre-orders = massive signal.

---

## Step 6: Talk to 5 Humans (do this regardless)

Numbers tell you IF. Conversations tell you WHY. Find 5 US freelancers (Reddit DMs, friends-of-friends, Upwork) and ask:

1. "Walk me through how you handle receipts and taxes right now."
2. "What's the most painful part of tax season for you?"
3. "What do you currently use? What do you hate about it?"
4. "If something fixed [their stated pain], what would you pay?"
5. "Would you pay $40/year? Why or why not?"

**Listen for:** Do they describe OUR pain unprompted? Do they already pay for a solution? Does $40 make them flinch?

---

## What Success Looks Like (Go/No-Go)

```
PROCEED TO LAUNCH if:
  ✓ Conversion rate ≥ 4% on targeted traffic
  ✓ At least 30-50 real emails collected
  ✓ 3+ people say "yes I'd pay" in interviews
  ✓ Bonus: 1+ pre-order

PIVOT/RETHINK if:
  ✗ Conversion < 2%
  ✗ Interviews reveal they don't see the pain
  ✗ Everyone says "I'd use it if free" but won't pay
  ✗ They're happy with their current solution
```

---

## Cost & Time Summary

| Item | Cost | Time |
|------|------|------|
| Formspree | Free | 30 min |
| Analytics | Free-$9 | 15 min |
| Hosting | Free | 20 min |
| Domain | ~$12/yr | 10 min |
| Ad spend | $50-100 | 5 days running |
| Interviews | Free | 5 × 15 min |
| **Total** | **~$60-120** | **~1 week** |

**Compare:** This is 1 week + $100 to find out if the idea works. The alternative — launching blind and grinding for 3 months — costs you 3 months and the same money, with worse information.

---

## The Honest Framing

This validation step might tell you the idea won't hit $1,000 MRR in 3 months. That's not failure — that's the test working. Better to learn it in a week for $100 than in 3 months of building and marketing.

If it converts well → you launch with confidence and real emails to seed day-one users.
If it converts poorly → you saved yourself a quarter of wasted effort and can pivot to a better idea.

Either outcome is a win.
