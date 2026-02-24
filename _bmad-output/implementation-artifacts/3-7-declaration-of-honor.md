# Story 3.7: Declaration of Honor & Archival

Status: done

## Story

As a seller,
I want to complete a digital declaration of honor before publishing each listing,
so that I formally attest to the accuracy of my declared data, and this attestation is archived as proof.

## Acceptance Criteria (BDD)

**Given** a seller has completed their listing and wants to publish
**When** they reach the declaration step (FR8)
**Then** structured checkboxes are displayed (each representing a specific attestation point)
**And** all checkboxes must be checked to proceed
**And** the declaration text is configurable admin (zero-hardcode)

**Given** a seller completes the declaration
**When** they sign digitally
**Then** a `Declaration` CDS record is created with: seller ID, listing ID, timestamp (ISO 8601), declaration version, IP address, all checkbox states (FR12)
**And** the declaration is immutable and archived permanently
**And** an audit trail entry is created

**Given** someone needs to verify a declaration
**When** they access the listing or moderation view
**Then** the declaration is accessible with its full timestamp and attestation details

## Tasks / Subtasks

### Task 1: Backend - Declaration Data Model (AC1, AC2)
- [x] 1.1. Define CDS entity `Declaration`:
  - id (UUID)
  - listingId (association to Listing)
  - sellerId (association to User)
  - declarationVersion (String - version identifier of the declaration template)
  - checkboxStates (JSON array - each checkbox label + checked boolean)
  - ipAddress (String)
  - signedAt (Timestamp, ISO 8601)
  - createdAt (Timestamp)
  - Annotate entity as immutable: `@readonly` after creation, no update/delete operations
- [x] 1.2. Define CDS entity `ConfigDeclarationTemplate`:
  - id (UUID)
  - version (String, e.g., "v1.0")
  - isActive (Boolean)
  - checkboxItems (JSON array of checkbox labels/descriptions)
  - introText (String - preamble text)
  - legalNotice (String - footer legal text)
  - createdAt, updatedAt
- [x] 1.3. Seed initial declaration template with attestation points:
  - "J'atteste que les informations declarees sont exactes"
  - "J'atteste etre le proprietaire ou mandataire autorise"
  - "J'atteste que le vehicule n'a pas de gage ni d'opposition"
  - "J'accepte les conditions generales de vente"
  - (All text from config, not hardcoded)
- [x] 1.4. Write unit tests for entity creation and immutability constraint

### Task 2: Backend - Declaration Service Actions (AC1, AC2)
- [x] 2.1. Create CAP action `getDeclarationTemplate()`:
  - Returns the active `ConfigDeclarationTemplate` (version, checkboxItems, introText, legalNotice)
  - Validates that exactly one active template exists
- [x] 2.2. Create CAP action `submitDeclaration(listingId, checkboxStates)`:
  - Validate all checkboxes are checked (reject if any unchecked)
  - Validate listing exists and belongs to current seller
  - Validate listing status is `Draft` (cannot re-declare a published listing)
  - Capture IP address from request headers (`x-forwarded-for` or `req.ip`)
  - Create `Declaration` record with all required fields
  - Create audit trail entry: "Declaration submitted for listing {id} by seller {id}"
  - Update listing to mark declaration as complete (add `declarationId` to Listing entity)
  - Return declaration confirmation with timestamp
- [x] 2.3. Implement immutability enforcement: reject any UPDATE or DELETE on Declaration entity at the CDS handler level
- [x] 2.4. Write unit tests for submission, validation, and immutability

### Task 3: Backend - Declaration Verification Query (AC3)
- [x] 3.1. Create CAP query handler for declaration retrieval: `GET /odata/v4/admin/Declarations({id})?$expand=listing,seller`
  - Available to admin/moderation roles only
  - Returns full declaration details including all checkbox states and timestamps
- [x] 3.2. Add declaration summary to listing detail endpoint for buyer view:
  - "Declaration du vendeur le [date]" with version reference
  - Do NOT expose checkbox details to buyers (only confirmation that declaration was made)
- [x] 3.3. Write unit tests for authorization (admin can view, buyer sees summary only, other sellers cannot view)

### Task 4: Frontend - Declaration Form Component (AC1)
- [x] 4.1. Create `src/components/listing/declaration-form.tsx`:
  - Load active declaration template from backend
  - Display intro text at top
  - Render structured checkboxes from template data (dynamic, not hardcoded)
  - Each checkbox has clear, readable label text
  - Legal notice text at bottom
- [x] 4.2. Implement validation: "Signer et continuer" button disabled until all checkboxes are checked
  - Visual progress: "3/4 attestations cochees" counter
  - Unchecked items highlighted when user attempts to proceed
- [x] 4.3. Implement accessible form:
  - Each checkbox has proper `<label>` association
  - Error state announced to screen readers
  - Focus management on validation failure
- [x] 4.4. Write unit tests for checkbox rendering, validation, and button state

### Task 5: Frontend - Digital Signature and Submission (AC2)
- [x] 5.1. On "Signer et continuer" click:
  - Show confirmation modal: "En signant, vous attestez solennellement de l'exactitude des informations. Cette declaration est archivee."
  - On confirm, call backend `submitDeclaration` action
  - Show success state: "Declaration signee le [date] a [time]" with checkmark
  - Disable further modification of the declaration (read-only view)
- [x] 5.2. After successful declaration, enable the "Publier" / "Payer et publier" action (transition to Story 3.9)
- [x] 5.3. Handle submission errors: display clear error message, allow retry
- [x] 5.4. Write unit tests for submission flow, confirmation modal, and success state

### Task 6: Frontend - Declaration View in Listing Detail (AC3)
- [x] 6.1. In the listing detail view (seller dashboard), show declaration status:
  - If declared: "Declaration signee le [date]" with view details link
  - If not declared: "Declaration requise avant publication" with CTA
- [x] 6.2. In the moderation/admin view, show full declaration details: all checkbox states, timestamp, IP, version
- [x] 6.3. Write unit tests for declaration status display in different contexts

### Task 7: Integration Tests
- [x] 7.1. Full flow: complete listing -> access declaration -> check all boxes -> sign -> verify Declaration record in DB with all fields
- [x] 7.2. Test immutability: attempt to update/delete a declaration -> verify rejection
- [x] 7.3. Test incomplete declaration: uncheck one box -> attempt submission -> verify rejection
- [x] 7.4. Test admin view: verify full declaration details accessible to admin role
- [x] 7.5. Test buyer view: verify only summary visible, not checkbox details
- [x] 7.6. Test template configurability: change active template -> verify new checkboxes appear in form

## Dev Notes

### Architecture & Patterns
- The declaration of honor is a legal requirement for the platform. It must be immutable once created and permanently archived.
- Declaration templates are stored in `ConfigDeclarationTemplate` with versioning. When the template changes, a new version is created. Existing declarations retain their original version reference for legal consistency.
- IP address capture is required for legal proof. Use the appropriate request header (`x-forwarded-for` behind a proxy, `req.ip` otherwise).
- The declaration is a prerequisite for publication (Story 3.9). The listing form flow is: auto-fill -> declared fields -> photos -> declaration -> publish/pay.
- Audit trail entries for declarations are critical for compliance and dispute resolution.

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
- **Task 1 complete**: Declaration and ConfigDeclarationTemplate CDS entities defined in db/schema/declaration.cds. Declaration uses cuid (no managed - immutable, no updatedAt). ConfigDeclarationTemplate uses cuid + managed with unique version constraint. Listing entity extended with declarationId field. Seed data CSV with v1.0 template and 4 attestation points. 19 schema tests.
- **Task 2 complete**: getDeclarationTemplate action returns active template (404 if none). submitDeclaration validates ownership, draft status, all-checked, captures IP, creates Declaration record, updates listing.declarationId, logs audit. Immutability enforced via before handlers rejecting UPDATE/DELETE on Declarations entity. Fixed existing integration test mocks to include before() method. 19 handler tests.
- **Task 3 complete**: Admin service exposes Declarations as @readonly projection and ConfigDeclarationTemplates for management. getDeclarationSummary action returns hasDeclared/signedAt/version without exposing checkbox details or IP. 5 additional tests (24 total in handler test file).
- **Task 4 complete**: Declaration API client (getDeclarationTemplate, submitDeclaration, getDeclarationSummary) with JSON parsing. DeclarationForm component loads template dynamically, renders checkboxes with Radix Checkbox + labels, progress counter, validation, disabled/loading/error states. Accessible with proper label associations and aria attributes. 23 frontend tests (9 API + 14 component).
- **Task 5 complete**: useDeclarationSubmit hook manages submission state (isSubmitting, isSubmitted, declarationId, signedAt, error) with toast notifications. DeclarationStep component wraps form + confirmation dialog + success state with date/time formatting. 14 tests (7 hook + 7 component).
- **Task 6 complete**: DeclarationStatus component with seller view (signed date or "required" CTA) and admin view (full details: checkboxes, IP, version, timestamp). 8 tests.
- **Task 7 complete**: 8 backend integration tests (full flow, immutability x2, incomplete rejection, summary privacy, cross-seller prevention, non-draft rejection, template version). 4 frontend integration tests (complete flow, error-retry-success, no-listingId guard, submit-reset cycle). 367 shared + 904 backend + 922 frontend = **2,193 total tests green**.

### Change Log
- 2026-02-24: Task 1 - Declaration and ConfigDeclarationTemplate CDS entities, seed data, 19 tests
- 2026-02-24: Task 2 - getDeclarationTemplate, submitDeclaration actions, immutability, 19 tests
- 2026-02-24: Task 3 - Admin declaration access, buyer summary, 5 tests
- 2026-02-24: Task 4 - Declaration API client, DeclarationForm component, 23 tests
- 2026-02-24: Task 5 - useDeclarationSubmit hook, DeclarationStep component, 14 tests
- 2026-02-24: Task 6 - DeclarationStatus component, 8 tests
- 2026-02-24: Task 7 - Integration tests, 12 tests (8 backend + 4 frontend)

### File List
- auto-backend/db/schema/declaration.cds (new - Declaration + ConfigDeclarationTemplate entities)
- auto-backend/db/schema/listing.cds (modified - added declarationId field)
- auto-backend/db/schema.cds (modified - added declaration schema import)
- auto-backend/db/data/auto-ConfigDeclarationTemplate.csv (new - seed data v1.0 template)
- auto-backend/srv/seller-service.cds (modified - getDeclarationTemplate, submitDeclaration, getDeclarationSummary, Declarations entity)
- auto-backend/srv/seller-service.ts (modified - declaration handlers + immutability enforcement)
- auto-backend/srv/admin-service.cds (modified - Declarations readonly + ConfigDeclarationTemplates)
- auto-backend/test/db/declaration-schema.test.ts (new - 19 tests)
- auto-backend/test/srv/handlers/seller-declaration.test.ts (new - 24 tests)
- auto-backend/test/srv/handlers/declaration-integration.test.ts (new - 8 tests)
- auto-backend/test/srv/handlers/seller-integration.test.ts (modified - added before() to mock)
- auto-backend/test/srv/handlers/visibility-score-integration.test.ts (modified - added before() to mock)
- auto-frontend/src/lib/api/declaration-api.ts (new - declaration API client)
- auto-frontend/src/components/listing/declaration-form.tsx (new - declaration form component)
- auto-frontend/src/components/listing/declaration-step.tsx (new - declaration step with confirmation modal)
- auto-frontend/src/components/listing/declaration-status.tsx (new - declaration status display)
- auto-frontend/src/hooks/use-declaration-submit.ts (new - declaration submission hook)
- auto-frontend/tests/lib/api/declaration-api.test.ts (new - 9 tests)
- auto-frontend/tests/components/listing/declaration-form.test.tsx (new - 14 tests)
- auto-frontend/tests/components/listing/declaration-step.test.tsx (new - 7 tests)
- auto-frontend/tests/components/listing/declaration-status.test.tsx (new - 8 tests)
- auto-frontend/tests/hooks/use-declaration-submit.test.ts (new - 7 tests)
- auto-frontend/tests/integration/declaration-lifecycle.test.ts (new - 4 tests)
