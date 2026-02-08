# Story 3.7: Declaration of Honor & Archival

Status: ready-for-dev

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
1.1. Define CDS entity `Declaration`:
  - id (UUID)
  - listingId (association to Listing)
  - sellerId (association to User)
  - declarationVersion (String - version identifier of the declaration template)
  - checkboxStates (JSON array - each checkbox label + checked boolean)
  - ipAddress (String)
  - signedAt (Timestamp, ISO 8601)
  - createdAt (Timestamp)
  - Annotate entity as immutable: `@readonly` after creation, no update/delete operations
1.2. Define CDS entity `ConfigDeclarationTemplate`:
  - id (UUID)
  - version (String, e.g., "v1.0")
  - isActive (Boolean)
  - checkboxItems (JSON array of checkbox labels/descriptions)
  - introText (String - preamble text)
  - legalNotice (String - footer legal text)
  - createdAt, updatedAt
1.3. Seed initial declaration template with attestation points:
  - "J'atteste que les informations declarees sont exactes"
  - "J'atteste etre le proprietaire ou mandataire autorise"
  - "J'atteste que le vehicule n'a pas de gage ni d'opposition"
  - "J'accepte les conditions generales de vente"
  - (All text from config, not hardcoded)
1.4. Write unit tests for entity creation and immutability constraint

### Task 2: Backend - Declaration Service Actions (AC1, AC2)
2.1. Create CAP action `getDeclarationTemplate()`:
  - Returns the active `ConfigDeclarationTemplate` (version, checkboxItems, introText, legalNotice)
  - Validates that exactly one active template exists
2.2. Create CAP action `submitDeclaration(listingId, checkboxStates)`:
  - Validate all checkboxes are checked (reject if any unchecked)
  - Validate listing exists and belongs to current seller
  - Validate listing status is `Draft` (cannot re-declare a published listing)
  - Capture IP address from request headers (`x-forwarded-for` or `req.ip`)
  - Create `Declaration` record with all required fields
  - Create audit trail entry: "Declaration submitted for listing {id} by seller {id}"
  - Update listing to mark declaration as complete (add `declarationId` to Listing entity)
  - Return declaration confirmation with timestamp
2.3. Implement immutability enforcement: reject any UPDATE or DELETE on Declaration entity at the CDS handler level
2.4. Write unit tests for submission, validation, and immutability

### Task 3: Backend - Declaration Verification Query (AC3)
3.1. Create CAP query handler for declaration retrieval: `GET /odata/v4/admin/Declarations({id})?$expand=listing,seller`
  - Available to admin/moderation roles only
  - Returns full declaration details including all checkbox states and timestamps
3.2. Add declaration summary to listing detail endpoint for buyer view:
  - "Declaration du vendeur le [date]" with version reference
  - Do NOT expose checkbox details to buyers (only confirmation that declaration was made)
3.3. Write unit tests for authorization (admin can view, buyer sees summary only, other sellers cannot view)

### Task 4: Frontend - Declaration Form Component (AC1)
4.1. Create `src/components/listing/declaration-form.tsx`:
  - Load active declaration template from backend
  - Display intro text at top
  - Render structured checkboxes from template data (dynamic, not hardcoded)
  - Each checkbox has clear, readable label text
  - Legal notice text at bottom
4.2. Implement validation: "Signer et continuer" button disabled until all checkboxes are checked
  - Visual progress: "3/4 attestations cochees" counter
  - Unchecked items highlighted when user attempts to proceed
4.3. Implement accessible form:
  - Each checkbox has proper `<label>` association
  - Error state announced to screen readers
  - Focus management on validation failure
4.4. Write unit tests for checkbox rendering, validation, and button state

### Task 5: Frontend - Digital Signature and Submission (AC2)
5.1. On "Signer et continuer" click:
  - Show confirmation modal: "En signant, vous attestez solennellement de l'exactitude des informations. Cette declaration est archivee."
  - On confirm, call backend `submitDeclaration` action
  - Show success state: "Declaration signee le [date] a [time]" with checkmark
  - Disable further modification of the declaration (read-only view)
5.2. After successful declaration, enable the "Publier" / "Payer et publier" action (transition to Story 3.9)
5.3. Handle submission errors: display clear error message, allow retry
5.4. Write unit tests for submission flow, confirmation modal, and success state

### Task 6: Frontend - Declaration View in Listing Detail (AC3)
6.1. In the listing detail view (seller dashboard), show declaration status:
  - If declared: "Declaration signee le [date]" with view details link
  - If not declared: "Declaration requise avant publication" with CTA
6.2. In the moderation/admin view, show full declaration details: all checkbox states, timestamp, IP, version
6.3. Write unit tests for declaration status display in different contexts

### Task 7: Integration Tests
7.1. Full flow: complete listing -> access declaration -> check all boxes -> sign -> verify Declaration record in DB with all fields
7.2. Test immutability: attempt to update/delete a declaration -> verify rejection
7.3. Test incomplete declaration: uncheck one box -> attempt submission -> verify rejection
7.4. Test admin view: verify full declaration details accessible to admin role
7.5. Test buyer view: verify only summary visible, not checkbox details
7.6. Test template configurability: change active template -> verify new checkboxes appear in form

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
### Completion Notes List
### Change Log
### File List
