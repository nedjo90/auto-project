# Story 3.3: Listing Form & Declared Fields

Status: review

## Story

As a seller,
I want to complete, modify, or correct the remaining fields of my listing (price, description, condition, options),
so that my listing is comprehensive with both certified and declared data clearly distinguished.

## Acceptance Criteria (BDD)

**Given** auto-fill has populated the certified fields
**When** the seller views the listing form
**Then** remaining empty fields are highlighted as "A completer" and marked as Declared (yellow indicator) when filled (FR3)
**And** the form is a single scrollable page with sections and anchors (not multi-page)
**And** all fields have accessible labels and error messages (NFR26)

**Given** a seller fills in a declared field (e.g., price, mileage adjustment, description)
**When** they enter a value
**Then** the field is marked Declared (yellow indicator) with text "Declare vendeur"
**And** the visibility score updates in real time (< 500ms, NFR3)

**Given** a seller wants to override a certified field
**When** they modify a certified value
**Then** the field status changes from Certified (green) to Declared (yellow) with a warning: "La valeur certifiee sera remplacee par votre saisie"
**And** the original certified value is preserved in `CertifiedField` history

**Given** the listing form is rendered
**When** checked for accessibility
**Then** the form passes WCAG 2.1 AA: labels associated, errors linked via `aria-describedby`, focus management correct, badges have text equivalents (NFR25)

## Tasks / Subtasks

### Task 1: Backend - Listing Form Data Model (AC1)
- [x] 1.1. Review and extend the `Listing` CDS entity to include all declared fields: price, mileage, description, condition, options (JSON array), interiorColor, exteriorColor, numberOfDoors, transmission, driveType, etc.
- [x] 1.2. Define field metadata (which fields are declaredOnly vs. certifiable) in a configuration or constants file
- [x] 1.3. Implement validation rules for declared fields: price (positive number, EUR), mileage (positive integer, km), description (min/max length), condition enum (Excellent, Bon, Correct, A restaurer)

### Task 2: Backend - Certified Field Override Logic (AC3)
- [x] 2.1. Extend `srv/lib/certification.ts` with `overrideCertifiedField(listingId, fieldName, newValue)`:
  - Preserve the original CertifiedField record (set `isOverridden = true`, keep original value)
  - Create a new field record with `isCertified = false`, source = 'seller_declared'
  - Return the previous certified value for UI display
- [x] 2.2. Add `CertifiedFieldHistory` tracking: original value, override timestamp, seller ID
- [x] 2.3. Write unit tests for override logic ensuring original value is never lost

### Task 3: Backend - Real-Time Score Update on Field Change (AC2)
- [x] 3.1. Create CAP action `updateListingField` that handles individual field updates:
  - Validates field value
  - Saves to Listing entity
  - If overriding certified field, calls override logic (Task 2)
  - Triggers visibility score recalculation via `srv/lib/visibility-score.ts`
  - Returns updated score and field status
- [x] 3.2. Ensure score recalculation completes within 500ms (NFR3) by keeping the calculation in-process (no external calls)
- [x] 3.3. Write unit tests for field update scenarios

### Task 4: Frontend - Listing Form Component (AC1, AC4)
- [x] 4.1. Create `src/components/listing/listing-form.tsx` as a single scrollable page with section anchors:
  - Section: Vehicle Identity (auto-filled, certified fields)
  - Section: Technical Details (mix of certified and declared)
  - Section: Condition & Description (declared)
  - Section: Pricing (declared)
  - Section: Options & Equipment (declared)
- [x] 4.2. Implement sticky section navigation (anchor links) for quick scroll between sections
- [x] 4.3. For each field, render the appropriate badge: Certified (green) or Declared (yellow) or "A completer" (grey/outline)
- [x] 4.4. Implement WCAG 2.1 AA accessibility:
  - All inputs have associated `<label>` elements
  - Validation errors use `aria-describedby` linking to error message elements
  - Focus management: on error, focus moves to first invalid field
  - Badge indicators have text equivalents (`aria-label="Certifie par [source]"` or `aria-label="Declare par le vendeur"`)
  - Keyboard navigation through all form sections
- [x] 4.5. Write unit tests for form rendering, section navigation, and accessibility attributes

### Task 5: Frontend - Declared Field Component (AC2)
- [x] 5.1. Create or extend `src/components/listing/certified-field.tsx` to handle both certified and declared states:
  - Declared state: yellow indicator badge with text "Declare vendeur"
  - "A completer" state: grey outline badge prompting input
  - Transition animation from "A completer" to "Declare vendeur" on input
- [x] 5.2. On field value change, call backend `updateListingField` action
- [x] 5.3. Receive updated visibility score from response and emit to score component (via React context or state management)
- [x] 5.4. Ensure score UI updates within 500ms of keystroke (debounce input at ~300ms, backend responds within ~200ms)

### Task 6: Frontend - Certified Field Override UX (AC3)
- [x] 6.1. When a seller focuses on a certified field, show the certified value as read-only with an "Modifier" button
- [x] 6.2. On click "Modifier", show confirmation warning: "La valeur certifiee sera remplacee par votre saisie"
- [x] 6.3. On confirmation, switch field to editable with Declared badge, preserving original certified value as reference text below the field
- [x] 6.4. Call backend override logic and update UI state
- [x] 6.5. Write unit tests for override flow including cancel scenario

### Task 7: Accessibility Audit (AC4)
- [x] 7.1. Run automated accessibility checks (axe-core) on the listing form
- [x] 7.2. Verify screen reader compatibility: all badges announce correctly, form sections are navigable, errors are announced
- [x] 7.3. Test keyboard-only navigation through the entire form
- [x] 7.4. Fix any WCAG 2.1 AA violations found

## Dev Notes

### Architecture & Patterns
- This story builds directly on Story 3.2's auto-fill output. The form displays both certified (from adapters) and declared (seller input) fields on the same page.
- The single-page scrollable form with section anchors avoids multi-step wizard complexity. Each section corresponds to a data domain (identity, technical, condition, pricing, options).
- The override mechanism is critical: sellers can correct certified data, but the original is NEVER deleted. This maintains audit trail integrity and allows buyers to see both values.
- Visibility score updates are triggered on every field change to provide immediate feedback (Story 3.5 handles the full score component).

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
Claude Opus 4.6

### Completion Notes List
- **Task 1:** Created `Listing` CDS entity with 35+ fields (certifiable + declaredOnly). Added `CertifiedFieldHistory` entity and `isOverridden` flag to `CertifiedField`. Created `LISTING_FIELDS` metadata constants and Zod validators in `@auto/shared`.
- **Task 2:** Extended `certification.ts` with `overrideCertifiedField()` — marks original as overridden, creates new seller_declared record, saves history. 6 unit tests.
- **Task 3:** Created `visibility-score.ts` with weighted field scoring (0-100). Added `updateListingField` CAP action to seller-service — validates field, saves, handles certified overrides, recalculates score. All in-process (no external calls) for < 500ms.
- **Task 4:** Created `listing-form.tsx` — single scrollable page with 5 sections, sticky nav, field badges (certified/declared/empty), visibility score display. `listing-form-field.tsx` handles all field types (text/number/select/textarea).
- **Task 5:** Created `use-listing-field` hook with 300ms debounce for backend sync, optimistic UI updates, and `listing-store.ts` (Zustand) for form state management.
- **Task 6:** Created `override-confirm-dialog.tsx` with warning message, certified value display, confirm/cancel flow. Override button on certified fields triggers dialog.
- **Task 7:** 18 accessibility tests covering WCAG 2.1 AA — labels/inputs association, error messages with aria-describedby/role=alert, badge aria-labels, section landmarks, keyboard navigation, focus indicators, color independence.

### Change Log
- 2026-02-23: Story 3.3 implemented — 199 new tests (345 shared + 695 backend + 661 frontend = 1701 total)

### File List
**auto-shared:**
- src/constants/listing.ts (NEW)
- src/constants/index.ts (MODIFIED)
- src/types/listing.ts (NEW)
- src/types/index.ts (MODIFIED)
- src/validators/listing.validator.ts (NEW)
- src/validators/index.ts (MODIFIED)
- tests/listing-constants.test.ts (NEW)
- tests/listing-validator.test.ts (NEW)
- tests/listing-types.test.ts (NEW)

**auto-backend:**
- db/schema/listing.cds (MODIFIED)
- srv/lib/certification.ts (MODIFIED)
- srv/lib/visibility-score.ts (NEW)
- srv/seller-service.cds (MODIFIED)
- srv/seller-service.ts (MODIFIED)
- test/db/listing-schema.test.ts (NEW)
- test/srv/lib/certification.test.ts (MODIFIED)
- test/srv/lib/visibility-score.test.ts (NEW)
- test/srv/handlers/listing-handler.test.ts (NEW)

**auto-frontend:**
- src/components/listing/listing-form.tsx (NEW)
- src/components/listing/listing-form-field.tsx (NEW)
- src/components/listing/override-confirm-dialog.tsx (NEW)
- src/stores/listing-store.ts (NEW)
- src/hooks/use-listing-field.ts (NEW)
- tests/components/listing/listing-form.test.tsx (NEW)
- tests/components/listing/listing-form-field.test.tsx (NEW)
- tests/components/listing/override-confirm-dialog.test.tsx (NEW)
- tests/components/listing/accessibility.test.tsx (NEW)
- tests/stores/listing-store.test.ts (NEW)
- tests/hooks/use-listing-field.test.ts (NEW)
