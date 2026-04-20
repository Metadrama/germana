# Driver Side Major Resurface - Full Implementation Plan

Date: 2026-04-20
Scope: Driver product surface, cross-flow coupling with passenger booking and ledger
Codebase: Flutter prototype in this repository

## 1. Executive Summary

The driver side has good foundations (listing form, basic dashboard, fair-rate calculator) but it is not yet a production-ready operating surface. Core lifecycle logic is split across local widget state and in-memory app state, payout visibility is missing, and transaction outcomes are not fully coupled across Driver, My Rides, and Ledger.

This resurface plan upgrades the driver side into a coherent operating system for campus carpooling:

1. One lifecycle model from listing draft to trip completion.
2. One transaction model from escrow hold to refund or payout release.
3. One driver workspace for requests, seat inventory, trip control, and earnings.
4. Strong trust and legal framing aligned with the institutional, maintenance-fee narrative.

## 2. Current State Audit (Code-Verified)

## 2.1 What Already Exists

1. Driver listing flow with route, pickup points, vehicle selection, and fair-rate breakdown.
2. Driver mode in shell with dedicated tabs for Dashboard, List, Profile.
3. Driver dashboard with mock request actions (accept/reject) and status toggles.
4. Passenger booking entry that routes to payment and booking confirmation.
5. Fuel-price snapshots and fair-rate computation service.

## 2.2 Critical Gaps Blocking Driver Maturity

1. Driver lifecycle is in-memory only:
   - Driver rides/requests are not persisted in hydrate/persist paths.
   - App restart loses active operational context.
2. Listing success depends on local widget flag:
   - Publish outcome is shown via local boolean instead of durable source of truth.
3. Booking/payment path is still simulated:
   - Payment uses a delay-based fake confirmation.
   - No explicit timeout/auto-refund state machine in transaction model.
4. Ledger is mock-backed and detached from live operations:
   - No mutation from real booking/request/ride lifecycle events.
5. Driver financial visibility is absent:
   - No earnings summary, payout state timeline, or per-ride net detail.
6. Car capacity validation is weak:
   - Seat count can be set independently from selected car capacity.
7. Dead/underused profile assets:
   - Vehicle chooser exists but is not wired into active profile flow.
8. Test coverage is minimal:
   - No dedicated driver lifecycle unit/widget/integration tests.

## 3. Product Direction To Preserve

Derived from project strategy docs and current UX principles:

1. Escrow-first passenger flow and masked identity pre-payment.
2. Institutional closed-loop access and trust framing.
3. Maintenance fee wording (not commission language).
4. Fair-rate-first positioning with transparent cost breakdown.
5. One-tap, low-cognitive-load interaction style.

## 4. Target End State (Driver MVP+)

A driver can complete this full journey in one coherent flow:

1. Create listing draft.
2. Pass fair-rate guardrail validation.
3. Publish listing.
4. Receive and handle join requests.
5. Start boarding and trip execution.
6. Complete trip.
7. See net earnings and payout status.
8. Audit every transition in timeline/ledger.

Negative paths are first-class:

1. Passenger timeout.
2. Driver reject.
3. Rider cancel.
4. Driver cancel.
5. Auto-refund and payout cancellation branches.

## 5. Architecture Blueprint

## 5.1 Domain Entities To Add

Add dedicated driver/booking domain models instead of overloading one ride model.

1. DriverRide
   - id, driverId, route, vehicle, pricing, capacity, status, createdAt, publishedAt
2. DriverRideStatus
   - draft, published, paused, request_pending, matched, boarding, in_progress, completed, cancelled
3. JoinRequest
   - id, rideId, passengerId, status, requestedAt, expiresAt, decisionAt, reason
4. BookingRecord
   - id, rideId, passengerId, status, escrowAmount, holdAt, acceptedAt, timeoutAt, refundAt
5. DriverEarningRecord
   - id, rideId, gross, platformFee, net, state, createdAt, payoutBatchId
6. PayoutRecord
   - id, driverId, amount, state, initiatedAt, processedAt, failedAt, failureReason
7. DriverEvent
   - id, entityType, entityId, eventType, timestamp, actor, metadata

## 5.2 Transaction and Lifecycle State Machines

Driver ride state machine:

1. draft -> published
2. published -> paused
3. paused -> published
4. published -> request_pending (first pending request arrives)
5. request_pending -> matched (at least one accepted booking)
6. matched -> boarding
7. boarding -> in_progress
8. in_progress -> completed
9. published|request_pending|matched|boarding -> cancelled

Booking state machine:

1. initiated -> escrow_held
2. escrow_held -> pending_driver
3. pending_driver -> accepted | rejected | timed_out
4. accepted -> in_trip -> completed
5. rejected|timed_out -> refund_pending -> refunded

Guardrail invariant examples:

1. seatsLeft never below zero.
2. accepted bookings count cannot exceed seat capacity.
3. completed ride cannot re-open for new requests.
4. cancellation from completed state is forbidden.

## 5.3 Store and Repository Layer

Current AppState remains top-level notifier but delegates driver logic into dedicated stores.

New layers:

1. DriverOperationsStore
   - owns driver rides, requests, lifecycle transitions
2. BookingStore
   - owns escrow/approval/refund states
3. LedgerStore
   - owns ledger entries from real mutations
4. EarningsStore
   - owns driver earnings aggregation and payout status
5. Repositories (local-first)
   - interfaces + shared_preferences JSON implementation for prototype persistence

Persistence requirement:

1. Driver rides, requests, bookings, ledger, payouts all serializable.
2. Hydration on app start must reconstruct active operations safely.

## 6. UI/UX Resurface Plan

## 6.1 Driver Workspace Information Architecture

Driver mode tabs become:

1. Hub
   - KPIs, urgent actions, next departures, pending requests
2. Listings
   - list view of draft/published/paused/completed rides
3. Earnings
   - net earnings, payout timeline, per-ride detail
4. Profile
   - driver identity, vehicle, trust settings

## 6.2 New/Resurfaced Screens

1. DriverHubScreen (new)
2. DriverListingsScreen (new)
3. DriverRideDetailScreen (new command center)
4. DriverRequestInboxSheet (new)
5. DriverEarningsScreen (new)
6. PayoutDetailsScreen (new)
7. IncidentAndDisputeFlow (new)
8. ListRideScreen (resurfaced, step-based)
9. BookingConfirmedScreen (resurfaced with status-aware variants)

## 6.3 Listing Flow Improvements

1. Move to stepper flow:
   - Route -> Vehicle -> Capacity & Price -> Review & Publish
2. Enforce seat cap from selected car profile.
3. Introduce driver ask price input with guardrail logic:
   - recommended range shown
   - above +15 percent requires justification
   - extreme values blocked
4. Add preview card that mirrors passenger card exactly.

## 6.4 Request Handling UX

1. Pending requests are timestamped with expiry countdown.
2. Accept/reject action requires optional reason templates.
3. Auto-expired requests become immutable with audit label.
4. Batch actions for multi-request rides (accept top N by policy).

## 7. Ledger and Earnings Coupling Rules

Each lifecycle transition emits financial mutations:

1. Payment confirmed -> escrow hold ledger entry.
2. Driver accepts -> booking status accepted (no payout yet).
3. Timeout/reject/cancel before trip -> refund ledger entry.
4. Trip completed -> release to driver + platform maintenance entries.
5. Payout processing events -> payout timeline updates.

Driver net formula:

1. gross = accepted passengers * perSeatPrice
2. platform_fee = per-ride maintenance fee policy
3. net = gross - platform_fee - refund_adjustments

## 8. File-Level Implementation Map

## 8.1 Existing Files To Refactor

1. lib/core/app_state.dart
   - delegate driver logic to dedicated stores and persist new domains
2. lib/app_shell.dart
   - new driver IA tabs and routing
3. lib/screens/driver/list_ride_screen.dart
   - stepper, guardrails, capacity enforcement, durable publish success
4. lib/screens/driver/driver_dashboard_screen.dart
   - replace with new Hub/Listings model
5. lib/screens/explore/payment_screen.dart
   - replace fake wait with real booking state pipeline
6. lib/screens/explore/booking_confirmed_screen.dart
   - render accepted/pending/rejected/timeout/refunded variants
7. lib/screens/my_rides/my_rides_screen.dart
   - consume booking store, remove mock coupling for active records
8. lib/screens/ledger/ledger_screen.dart
   - consume ledger store instead of static mock list
9. lib/screens/profile/profile_screen.dart
   - add driver quick links: Vehicle, Payout setup, Trust center
10. lib/screens/profile/edit_profile_screen.dart
   - link to vehicle chooser and verification status
11. lib/l10n/app_localizations.dart
   - add strings for request states, payout states, guardrail prompts, errors

## 8.2 Existing Assets To Integrate or Retire

1. lib/screens/profile/vehicle_chooser_screen.dart
   - integrate into profile flow as source of truth for car + seat capacity
   - if not integrated in Sprint 1, retire to reduce dead code

## 8.3 New Files (Proposed)

1. lib/models/driver_ride.dart
2. lib/models/join_request.dart
3. lib/models/booking_record.dart
4. lib/models/earning_record.dart
5. lib/models/payout_record.dart
6. lib/models/driver_event.dart
7. lib/stores/driver_operations_store.dart
8. lib/stores/booking_store.dart
9. lib/stores/ledger_store.dart
10. lib/stores/earnings_store.dart
11. lib/repositories/driver_repository.dart
12. lib/repositories/local_driver_repository.dart
13. lib/screens/driver/driver_hub_screen.dart
14. lib/screens/driver/driver_listings_screen.dart
15. lib/screens/driver/driver_ride_detail_screen.dart
16. lib/screens/driver/driver_earnings_screen.dart
17. lib/screens/driver/payout_details_screen.dart

## 9. Phased Execution Plan

## Phase 0 - Alignment and Baseline (2-3 days)

Goals:

1. Lock scope and acceptance criteria.
2. Finalize state machines and event naming.
3. Add feature flags for staged rollout.

Deliverables:

1. Technical spec for domain models.
2. Transition matrix with allowed/forbidden paths.
3. Rollout toggles in config layer.

## Phase 1 - Domain and Persistence Backbone (5-7 days)

Goals:

1. Introduce dedicated driver/booking/ledger/earnings stores.
2. Persist operational state across app restarts.

Tasks:

1. Create models and serializers.
2. Build repository interfaces + local implementations.
3. Migrate AppState mutation methods to store delegates.
4. Add migration adapter from old in-memory structures.

Exit criteria:

1. Active listings/requests survive restart.
2. Existing passenger browse flow still works.

## Phase 2 - Driver Surface Restructure (6-8 days)

Goals:

1. Replace current dashboard/listing experience with operational hub.
2. Make request handling first-class.

Tasks:

1. Build DriverHubScreen + DriverListingsScreen.
2. Build DriverRideDetailScreen command center.
3. Refactor ListRideScreen to stepper + guardrails + seat constraints.
4. Integrate vehicle chooser and capacity sync.

Exit criteria:

1. Driver can publish, pause, resume, request-handle from one workspace.
2. No critical actions depend on local widget booleans.

## Phase 3 - Booking and Financial Coupling (5-7 days)

Goals:

1. Connect payment outcomes to request lifecycle and ledger mutations.
2. Surface status-aware booking confirmation.

Tasks:

1. Replace simulated payment confirmation path.
2. Add pending/accepted/rejected/timeout/refunded booking states.
3. Drive My Rides from booking store.
4. Drive Ledger from real events.

Exit criteria:

1. Every booking outcome is visible in My Rides and Ledger.
2. Refund path is explicit and testable.

## Phase 4 - Earnings and Payouts (4-6 days)

Goals:

1. Give drivers transparent earnings and payout visibility.

Tasks:

1. Add DriverEarningsScreen summary cards and filters.
2. Add per-ride earning detail sheet.
3. Add payout status timeline and failure states.

Exit criteria:

1. Driver can trace net earning for any completed trip.
2. Payout state is visible (pending, processing, paid, failed).

## Phase 5 - Trust, Safety, and Reliability (4-6 days)

Goals:

1. Enforce legal/trust guardrails and robust negative-path UX.

Tasks:

1. Cancellation policy flows for both sides.
2. Incident/dispute submission and timeline marker.
3. Better network/offline/error states.
4. Notification badges for request and payout updates.

Exit criteria:

1. No silent failure path for critical actions.
2. Trust/legal messaging appears at key points.

## Phase 6 - Testing, Hardening, and Launch (4-5 days)

Goals:

1. Reach stable release quality for driver surface.

Tasks:

1. Unit tests for state transitions and pricing guardrails.
2. Widget tests for listing, request inbox, earnings cards.
3. Integration tests for end-to-end publish -> request -> complete -> payout.
4. Regression sweep across Explore/My Rides/Ledger/Profile.

Exit criteria:

1. CI includes driver flow test suite.
2. No P0 defects in release checklist.

## 10. Testing Strategy

## 10.1 Unit Tests

1. DriverRide state transition validity.
2. JoinRequest expiry and decision handling.
3. Booking timeout/refund automations.
4. Earnings aggregation math and fee policies.
5. Guardrail validator (+15 percent logic and reason requirement).

## 10.2 Widget Tests

1. Listing stepper validation UX.
2. Request accept/reject actions.
3. Dashboard KPI consistency with store state.
4. Ledger rendering for live mutations.

## 10.3 Integration Tests

1. Driver publishes ride -> appears in Explore.
2. Passenger pays -> pending driver approval.
3. Driver accepts -> passenger sees accepted status.
4. Trip complete -> driver earnings and ledger entries update.
5. Timeout/reject -> refund appears in ledger and booking state.

## 11. Telemetry and Product Metrics

Instrument at minimum:

1. driver_listing_published
2. driver_request_received
3. driver_request_decided
4. booking_state_changed
5. ride_status_changed
6. payout_state_changed

Core success metrics:

1. Publish-to-first-request time.
2. Request response latency.
3. Request acceptance ratio.
4. Booking timeout ratio.
5. Trip completion ratio.
6. Refund ratio.
7. Payout completion latency.

## 12. Risk Register and Mitigations

1. Risk: Over-coupling changes break passenger flow.
   - Mitigation: feature flags + adapter layer in AppState.
2. Risk: Persistence migration corrupts active rides.
   - Mitigation: versioned payload schemas + fallback migration.
3. Risk: Guardrails too strict reduce supply.
   - Mitigation: monitor override justifications and adjust thresholds.
4. Risk: Timeline slips from overdesign.
   - Mitigation: phase gates with hard exit criteria and non-goal list.

## 13. Non-Goals For This Resurface

1. Full production backend implementation.
2. Real payment gateway integration with settlements.
3. Real push notification infrastructure.
4. Cross-institution expansion beyond closed-loop model.

These remain future tracks after the driver MVP+ surface is stable.

## 14. Definition of Done

The driver resurface is complete when all conditions below are true:

1. Driver can publish, manage requests, run trip lifecycle, and view net earnings.
2. Booking outcomes propagate consistently to Driver, My Rides, and Ledger.
3. Negative paths (reject, timeout, cancel, refund) are explicit and auditable.
4. State survives app restart with no critical data loss.
5. Driver flow has unit/widget/integration test coverage in CI.
6. Trust/legal narrative is visible and consistent in key UX checkpoints.

## 15. Immediate Next 7-Day Action Plan

1. Finalize transition matrix and model contracts.
2. Implement new domain models + local repository serialization.
3. Move driver ride/request mutation logic out of monolithic AppState.
4. Wire DriverHubScreen scaffold and list-backed dashboard cards.
5. Integrate vehicle chooser into profile and seat-capacity validation.
6. Add first lifecycle unit tests (publish, accept, complete, refund).
