# Story 3.9: Batch Publication & Payment via Stripe

Status: ready-for-dev

## Story

As a seller,
I want to select multiple drafts for batch publication and pay for them in a single grouped transaction,
so that I can efficiently publish multiple listings at once.

## Acceptance Criteria (BDD)

**Given** a seller has ready drafts (declaration completed)
**When** they access the Publish page (`(dashboard)/seller/publish/`) (FR7)
**Then** all eligible drafts are listed with checkboxes for selection
**And** a running total is displayed: "[N] annonces x [price] = [total]" (price from `ConfigParameter`)

**Given** a seller selects drafts and clicks "Publier et payer"
**When** the payment flow initiates (FR55)
**Then** a Stripe Checkout Session is created via `IPaymentAdapter` -> `StripePaymentAdapter`
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

## Tasks / Subtasks

### Task 1: Backend - Stripe Payment Adapter Implementation (AC2)
1.1. Implement `StripePaymentAdapter` in `srv/adapters/stripe/`:
  - Implements `IPaymentAdapter` interface (defined in Story 3.1)
  - Uses Stripe Node.js SDK (`stripe` npm package)
  - Configure Stripe API keys from environment variables (STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET)
1.2. Implement `createCheckoutSession(params)` method:
  - Input: listingIds[], unitPrice, totalAmount, sellerId, successUrl, cancelUrl
  - Create Stripe Checkout Session with:
    - `mode: 'payment'`
    - `line_items`: one line item per listing or a single grouped item "[N] annonces"
    - `metadata`: JSON with listingIds, sellerId for webhook processing
    - `payment_method_types: ['card']`
    - SCA/3D Secure automatically handled by Stripe Checkout
  - Return: sessionId, checkoutUrl
1.3. Log the checkout session creation via `api-logger` middleware
1.4. Write unit tests with Stripe mock/test mode

### Task 2: Backend - Listing Price Configuration (AC1)
2.1. Create/extend `ConfigParameter` entry: `LISTING_PRICE_EUR` (e.g., 4.99)
2.2. Create CAP action `getPublishableListings()`:
  - Filter listings by: status = 'Draft', declarationId IS NOT NULL (declaration completed), seller = current user
  - Return listing summaries with: id, brand, model, visibilityScore, photoCount
  - Include unit price from ConfigParameter
2.3. Create CAP action `calculateBatchTotal(listingIds[])`:
  - Validate all listings are eligible (status, declaration, ownership)
  - Calculate total: count x unit price
  - Return: { count, unitPrice, total, listingIds }
2.4. Write unit tests for eligibility filtering and price calculation

### Task 3: Backend - Webhook Handler for Payment Confirmation (AC3, AC4)
3.1. Create webhook endpoint: `POST /api/stripe/webhook`
  - Parse raw request body (required by Stripe signature validation)
  - Validate webhook signature using `STRIPE_WEBHOOK_SECRET`
  - Handle event types:
    - `checkout.session.completed`: process successful payment
    - `payment_intent.payment_failed`: handle payment failure
3.2. Implement atomic batch publication on success:
  - Extract listingIds from session metadata
  - Begin database transaction
  - For each listing: validate status is still Draft, update status to Published, set publishedAt timestamp
  - If ANY listing fails validation/update, rollback entire transaction (NFR37 atomicity)
  - Commit transaction only if all listings succeed
  - Create payment record: PaymentTransaction entity with sessionId, amount, status, listingIds
  - Create audit trail entries for each published listing
3.3. Implement failure handling:
  - On payment failure event, log the failure
  - Do not modify any listing status
  - Create failed payment record for audit
3.4. Send seller notification on success: "Vos [N] annonces sont en ligne" (via notification system or email)
3.5. Write unit tests for webhook signature validation, atomic publication, rollback scenarios, and failure handling

### Task 4: Backend - Payment Transaction Entity (AC3)
4.1. Define CDS entity `PaymentTransaction`:
  - id (UUID)
  - sellerId (association to User)
  - stripeSessionId (String)
  - stripePaymentIntentId (String)
  - amount (Decimal)
  - currency (String, default 'EUR')
  - status (enum: Pending, Succeeded, Failed, Refunded)
  - listingIds (JSON array)
  - listingCount (Integer)
  - processedAt (Timestamp)
  - webhookReceivedAt (Timestamp)
  - createdAt, updatedAt
4.2. Ensure payment records are immutable after creation (status can only move forward: Pending -> Succeeded/Failed)
4.3. Write unit tests for entity constraints

### Task 5: Frontend - Publish Page with Batch Selection (AC1)
5.1. Create `src/app/(dashboard)/seller/publish/page.tsx`:
  - Load eligible drafts from backend `getPublishableListings()`
  - Display each draft as a selectable card with checkbox:
    - Vehicle info (brand, model, year)
    - Visibility score mini gauge
    - Photo count with primary thumbnail
    - Declaration status checkmark
  - "Select All" / "Deselect All" toggle
5.2. Implement running total calculation:
  - Display: "[N] annonces x [price] EUR = [total] EUR"
  - Update dynamically as checkboxes change
  - Highlight total with clear formatting
5.3. Implement "Publier et payer" button:
  - Disabled when no drafts selected
  - Shows selected count: "Publier [N] annonces"
  - Loading state during checkout session creation
5.4. Handle empty state: "Aucun brouillon eligible. Completez vos annonces et signez la declaration."
5.5. Write unit tests for selection, total calculation, and button states

### Task 6: Frontend - Stripe Checkout Redirect (AC2)
6.1. On "Publier et payer" click:
  - Call backend to create Stripe Checkout Session
  - Redirect to Stripe Checkout using `stripe.redirectToCheckout({ sessionId })`
  - Use Stripe.js loaded via `@stripe/stripe-js`
6.2. Configure return URLs:
  - Success URL: `/(dashboard)/seller/publish/success?session_id={CHECKOUT_SESSION_ID}`
  - Cancel URL: `/(dashboard)/seller/publish/` (return to selection page)
6.3. Write unit test for checkout redirect flow

### Task 7: Frontend - Success and Error Pages (AC3, AC4)
7.1. Create `src/app/(dashboard)/seller/publish/success/page.tsx`:
  - On load, verify payment session status with backend
  - Display success message: "Vos [N] annonces sont en ligne!"
  - Show published listing cards with links to view each listing
  - CTA: "Voir mes annonces" -> seller dashboard
7.2. Implement error handling on return from Stripe:
  - If session status is not complete, show error message: "Le paiement n'a pas abouti"
  - Offer retry: "Reessayer le paiement" button
  - Show contact support option for persistent issues
7.3. Handle edge case: user returns to success page but webhook hasn't processed yet
  - Show "Publication en cours..." with polling until listings are confirmed published
7.4. Write unit tests for success, error, and pending states

### Task 8: Integration Tests
8.1. Full flow with Stripe test mode: select drafts -> create checkout -> simulate successful payment -> verify listings published
8.2. Test atomicity: set up scenario where one listing is invalid -> verify entire batch rolls back
8.3. Test payment failure: simulate failed payment -> verify no listings published
8.4. Test webhook signature validation: send invalid signature -> verify rejection
8.5. Test concurrent webhook handling: send duplicate webhooks -> verify idempotent processing
8.6. Test price calculation: verify total matches ConfigParameter price x listing count

## Dev Notes

### Architecture & Patterns
- Stripe Checkout is used (not Stripe Elements) to minimize PCI-DSS scope. All card data is handled by Stripe's hosted page, so the platform never touches sensitive payment data.
- Atomicity (NFR37) is critical: either ALL listings in a batch are published, or NONE are. This is implemented via a database transaction wrapping all status updates.
- The webhook is the source of truth for payment confirmation, not the redirect URL. The success page polls/waits for webhook confirmation before showing final success.
- Webhook idempotency: the handler must check if the payment has already been processed (by stripeSessionId) to handle duplicate webhook deliveries gracefully.
- Payment pricing is loaded from `ConfigParameter`, not hardcoded. This allows price changes without redeployment.

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 frontend, PostgreSQL, Azure
- **Adapter Pattern:** 8 interfaces (IVehicleLookupAdapter, IEmissionAdapter, IRecallAdapter, ICritAirCalculator, IVINTechnicalAdapter, IHistoryAdapter, IValuationAdapter, IPaymentAdapter). Factory resolves from ConfigApiProvider.
- **Auto-fill flow:** Seller enters plate -> POST /odata/v4/seller/autoFillByPlate -> AdapterFactory resolves adapters -> parallel API calls -> certification.ts marks fields -> visibility-score.ts calculates -> cached in api_cached_data
- **Certification:** Each field tracked to source (API + timestamp). CertifiedField entity in CDS.
- **Visibility Score:** Real-time calculation via lib/visibility-score.ts, SignalR /live-score hub for live updates
- **Photo management:** Azure Blob Storage upload, Azure CDN serving, Next.js Image optimization
- **Payment:** Stripe checkout, atomic publish (NFR37), IPaymentAdapter interface
- **Batch publish:** Select drafts -> calculate total -> Stripe Checkout Session -> webhook confirms -> atomic status update
- **API resilience:** PostgreSQL api_cached_data table with TTL, mode degrade (manual input fallback), auto re-sync
- **Declaration:** Digital declaration of honor, timestamped, archived as proof
- **Testing:** >=90% unit, >=80% integration coverage

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Direct external API calls (MUST use Adapter Pattern)
- Hardcoded values (use config tables)
- Skipping audit trail/API logging

### Project Structure Notes
Backend: srv/adapters/ (interfaces + implementations), srv/lib/certification.ts, srv/lib/visibility-score.ts, srv/middleware/api-logger.ts
Frontend: src/components/listing/ (auto-fill-trigger, certified-field, visibility-score, listing-form, declaration-form), src/hooks/useVehicleLookup.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
