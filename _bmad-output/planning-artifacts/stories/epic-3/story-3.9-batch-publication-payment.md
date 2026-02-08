# Story 3.9: Batch Publication & Payment via Stripe

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR7, FR55, FR56, FR57
**NFRs:** NFR11 (PCI-DSS), NFR12 (PSD2/SCA), NFR37 (atomicity)

## User Story

As a seller,
I want to select multiple drafts for batch publication and pay for them in a single grouped transaction,
So that I can efficiently publish multiple listings at once.

## Acceptance Criteria

**Given** a seller has ready drafts (declaration completed)
**When** they access the Publish page (`(dashboard)/seller/publish/`) (FR7)
**Then** all eligible drafts are listed with checkboxes for selection
**And** a running total is displayed: "[N] annonces × €[price] = €[total]" (price from `ConfigParameter`)

**Given** a seller selects drafts and clicks "Publier et payer"
**When** the payment flow initiates (FR55)
**Then** a Stripe Checkout Session is created via `IPaymentAdapter` → `StripePaymentAdapter`
**And** the seller is redirected to Stripe for secure payment (PCI-DSS, PSD2/SCA compliant) (NFR11, NFR12)

**Given** the Stripe payment succeeds
**When** the webhook `payment_intent.succeeded` is received (FR56, FR57)
**Then** the webhook signature is validated
**And** all selected listings atomically transition from `Draft` to `Published` (NFR37)
**And** if any listing fails to publish, the entire batch is rolled back
**And** the seller receives a notification "Vos [N] annonces sont en ligne"
**And** the payment and publication are logged in the audit trail

**Given** the Stripe payment fails
**When** the webhook indicates failure
**Then** no listings are published (atomicity maintained)
**And** the seller sees a clear error message and can retry
