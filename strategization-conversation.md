This is the finalized **UX Design Specification** for the platform, integrating the **Escrow-First** model, **Pre-Set Pricing Logic**, and **Legal Safeguards**.

---

## I. Core Identity & Legal Guardrails

- **Project Status:** Framed as an "Institutional R&D Project" (e.g., _UniKL Green Mobility Initiative_).
- **Access Control:** Strictly restricted to `@smail.unikl.edu.my` or equivalent institutional emails.
- **Monetization Terminology:** All fees are labeled as "Platform Maintenance Fees" (to cover server, API, and gateway costs), not "Commission."

---

## II. Information Architecture (IA)

| Tab          | Primary UX Function     | Key Components                                            |
| :----------- | :---------------------- | :-------------------------------------------------------- |
| **Explore**  | Discovery (AFA-Style)   | Search bars, Route cards, "Secure Seat" CTA.              |
| **My Rides** | Management & Scheduling | Active Trip Status, Recurring Trip Manager, Ride History. |
| **Ledger**   | Financial Transparency  | "Maintenance Fee" breakdown, Refund status, Withdrawals.  |
| **Profile**  | Trust & Verification    | Car Profile (for fuel math), Faculty badge, Ratings.      |

---

## III. The "Pre-Set" Driver Listing Flow

Before a ride appears in the feed, the price is locked between the Platform and the Driver.

1.  **Route Setup:** Driver selects Point A to Point B.
2.  **Car Selection:** Driver picks their car (e.g., _S70, Myvi, Axia_).
3.  **The "Platform Offer":** \* The system calculates the **Fair Rate**:
    $$Fair Rate = \frac{(\text{Fuel consumption } L/100km \times \text{Distance} \times \text{Fuel Price}) + \text{Tolls}}{\text{Total Seats}}$$
4.  **The Negotiation Guardrail:** \* Driver sees the suggested price (e.g., RM4.50/seat).
    - Driver can **"Ask for Increment"** (Max +15% for traffic/wear-and-tear).
    - Anything above +15% triggers a "High Price Warning" and requires justification.

---

## IV. The "Escrow-First" Passenger Flow

This flow ensures the platform captures the transaction before any contact info is leaked.

1.  **AFA-Style Discovery:**
    - Passenger sees cards with Origin, Destination, Time, and the Fixed Price.
    - Driver Identity is **masked** (e.g., _Verified Driver @ UniKL MIIT_).
2.  **Pay-to-Unlock:**
    - Passenger clicks **"Secure Seat."**
    - Immediate payment via **DuitNow/FPX** (Total = Fair Rate + Platform Maintenance Fee).
3.  **The Bridge:**
    - Only once payment is confirmed, the Driver is notified.
    - If Driver accepts: Names, Car Plate, and Chat are **unlocked**.
    - If Driver rejects/times out: **Auto-Refund** triggers immediately.

---

## V. Bypass Mitigation Strategy

- **Information Asymmetry:** Zero contact/name details are provided for free. By the time a passenger knows who the driver is, the money is already in Escrow.
- **Automation Bias:** The app handles the "Awkward Math." Students prefer paying the app RM5.00 over manually calculating tolls and gas prices on WhatsApp.
- **Self-Destructing Chat:** In-app chat is disabled 1 hour post-ride to prevent long-term "off-platform" coordination.

---

## VI. Visual & Interaction Design

- **Feed Cards:** Mimic the **AFA app** layout—bold text, clear departure timers, and status badges (e.g., "Confirmed," "2 Seats Left").
- **Transparency Tooltip:** A small "i" icon next to the price that shows the breakdown:
  - _Fuel Contribution:_ RM3.20
  - _Toll Share:_ RM0.80
  - _Platform Maintenance:_ RM1.00
- **The "Vending Machine" Feel:** Every interaction is a "one-tap" action. No complex forms.

---

## VII. Post-Ride Settlement

1.  **Confirmation:** Passenger clicks "Arrived" or system detects GPS proximity.
2.  **Release:** Platform releases the **Fuel/Toll** portion to the Driver's bank account.
3.  **Audit Trail:** A digital receipt is generated for both parties, providing the necessary "Social Proof" for their parents or the university if needed.

---

## VIII. Final Legal Note

By strictly maintaining the **"Maintenance Fee"** narrative and keeping the community **Closed-Loop (Uni-only)**, you create a defensive layer against external interrogation. You are not a taxi company; you are a student-led sustainability initiative.

Since the design is now fully mapped, are we moving into the **API Schema** for the pricing engine next?
