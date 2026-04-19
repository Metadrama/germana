# Germana MVP UI/UX Resurfacing Plan

## 1) Current State Snapshot

The prototype already has a strong visual identity and coherent IA:
- Explore, My Rides, Ledger, Profile tabs are implemented.
- Escrow-first flow concept is visible in Ride Detail -> Payment -> Booking Confirmed.
- Driver listing and fair-rate framing are present.

## 2) Gaps Blocking MVP Readiness

### A. UX logic gaps
- Explore filters are cosmetic and do not filter results yet.
- Destination search selection does not alter feed ranking/filtering.
- Payment confirmation is simulated and always succeeds.
- Booking confirmation uses hardcoded revealed driver identity.
- My Rides and Ledger are not transaction-coupled to booking/listing actions.

### B. Trust and safety gaps
- No in-product messaging for institutional closed-loop access in onboarding/session.
- Price guardrails (+15% threshold, warning, reason capture) are not present in listing flow.
- No explicit timeout/reject/refund UX branch from escrow flow.

### C. Product polish gaps
- README does not describe product purpose, setup targets, or UX principles.
- Empty states and error states are limited (network, location, payment, listing failures).
- Android device run depends on USB auth state; good enough for dev, but no dev guide note.

## 3) MVP UX Principles To Keep
- Keep one-tap, low-cognitive-load interactions.
- Keep masked-driver pre-payment privacy model.
- Keep transparent fee breakdown everywhere user commits money.
- Keep Malay-first tone and concise copy.

## 4) Resurfacing Sequence (Suggested)

### Sprint 1: Flow Integrity (Highest ROI)
1. Wire Explore filters to actual list transforms.
2. Make destination search affect feed content.
3. Add booking state machine (initiated, paid, accepted, timeout, refunded).
4. Drive My Rides and Ledger from that shared state.

### Sprint 2: Trust and Guardrails
1. Add driver listing increment guardrail:
   - base fair rate,
   - +15% cap warning,
   - reason required above cap.
2. Add escrow timeout and auto-refund screens/messages.
3. Add institutional trust markers in key points (profile, checkout, confirmation).

### Sprint 3: MVP Polish
1. Expand empty/error/loading states on all primary screens.
2. Add instrumentation-friendly event hooks in UI actions.
3. Update README with:
   - product intent,
   - supported run targets,
   - known prototype assumptions.

## 5) Immediate Build Tasks (What to implement first)
- Task A: Explore filters and destination-aware feed.
- Task B: In-memory booking store + ledger mutation hooks.
- Task C: Driver listing guardrail micro-flow.

## 6) Success Criteria
- A user can discover, pay, confirm, and see resulting ride/ledger updates in one session.
- A driver can list with transparent fair-rate logic and pricing guardrails.
- Key negative path (timeout/refund) is visible and understandable in UI.
