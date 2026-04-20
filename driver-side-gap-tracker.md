# Driver-Side Gap Tracker (MVP)

## Scope
Focused on driver journey quality and production readiness:
- list a ride
- manage active rides
- handle requests and passenger states
- execute trip lifecycle
- receive payouts and reconcile earnings
- trust/safety and reliability

## Current Coverage Snapshot

### Implemented (Good Foundation)
- Ride listing form with route, pickup plan, vehicle details, and fair-rate guidance.
  - File: lib/screens/driver/list_ride_screen.dart
- Driver identity and profile editing surfaces are present.
  - File: lib/screens/profile/profile_screen.dart
- Booked/upcoming ride cards exist for user-facing timeline/history.
  - File: lib/screens/my_rides/my_rides_screen.dart
- Ledger/history UI is present.
  - File: lib/screens/ledger/ledger_screen.dart

### Underdeveloped / Missing

#### P0: Core Driver Operations (Highest Risk)
- No dedicated driver mode/dashboard to manage posted rides.
- No request inbox for approve/reject passenger requests.
- No live seat inventory and waitlist handling per ride.
- No trip status state machine for driver execution:
  - draft -> published -> matched -> boarding -> in_progress -> completed
  - cancellation branches with reason and consequences.

#### P0: Data Integrity / Real State Coupling
- Listing success is local UI state only; no persistent ride lifecycle store.
- My Rides and Ledger are not transaction-coupled to driver actions.
- Payment/escrow outcomes are not integrated with driver payout release logic.

#### P1: Driver Financials and Earnings Transparency
- No driver earnings screen (daily/weekly/monthly breakdown).
- No payout status model (pending, processing, paid, failed).
- No per-ride earnings detail (fare, fees, toll adjustment, net payout).

#### P1: Safety and Trust Controls
- No guardrail enforcement in listing submission (soft warning only pattern in plan).
- No cancellation policy UX for driver and passenger sides.
- No dispute/report incidents workflow.

#### P2: Operational UX Polish
- Limited error states for route API failures, publish failures, stale fuel prices.
- No offline/retry strategy and status banners.
- No notification center for driver events (new request, cancellation, payout updates).

## Evidence Pointers
- Driver listing flow exists but ends at local listed state:
  - lib/screens/driver/list_ride_screen.dart
- App shell does not expose a dedicated driver operations tab:
  - lib/app_shell.dart
- Ledger screen is history-only and currently mock-backed:
  - lib/screens/ledger/ledger_screen.dart
- Existing plan already notes transaction-coupling gaps:
  - mvp-uiux-resurface-plan.md

## Recommended Build Sequence

### Sprint A: Driver Lifecycle Backbone (P0)
1. Introduce DriverRide entity + status state machine.
2. Add Driver Dashboard screen:
   - Active Listings
   - Requests Pending
   - Trips Today
3. Implement request handling actions:
   - accept/reject/auto-expire
4. Connect seat inventory and booking transitions to shared app state.

### Sprint B: Earnings and Payouts (P1)
1. Add Earnings screen with aggregated cards + ride-level entries.
2. Add payout timeline states and payout detail sheet.
3. Link completed rides to ledger mutations (both rider and driver perspectives).

### Sprint C: Reliability and Trust (P1/P2)
1. Enforce fair-rate guardrail at publish time with rationale capture.
2. Add cancellation/dispute UX branches and corresponding ledger outcomes.
3. Add robust loading/error/offline states in listing and dashboard.
4. Add notification surfaces and badges for driver events.

## Definition of Done (Driver Side MVP)
- Driver can publish, receive request, accept, start, complete, and see net earnings in one coherent flow.
- Every state transition is reflected in both My Rides and Ledger.
- Negative paths (cancel, timeout, refund) are visible and auditable.
- No critical operation depends on mock-only local flags.

## Next Immediate Implementation Tasks
1. Add Driver Dashboard screen and route entry from profile.
2. Introduce in-memory DriverRideStore to replace local listed booleans.
3. Wire request acceptance and seat decrement transitions.
4. Add driver earnings summary panel backed by same store.
