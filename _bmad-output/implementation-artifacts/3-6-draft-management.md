# Story 3.6: Draft Management

Status: review

## Story

As a seller,
I want to save my listing as a draft and manage multiple drafts simultaneously,
so that I can prepare several listings at my own pace before publishing them.

## Acceptance Criteria (BDD)

**Given** a seller is creating a listing
**When** they click "Sauvegarder le brouillon" (FR5)
**Then** the listing is saved with status `Draft` in the `Listing` CDS entity
**And** all data (certified fields, declared fields, photos, score) is preserved
**And** a confirmation toast is displayed

**Given** a seller has multiple drafts (FR6)
**When** they access their drafts page (`(dashboard)/seller/drafts/`)
**Then** all drafts are listed with: vehicle info (brand, model), creation date, completion %, visibility score, photo count
**And** they can edit, duplicate, or delete any draft

**Given** a seller opens a saved draft
**When** the listing form loads
**Then** all previously saved data is restored including certified fields, declared fields, photos, and score
**And** the seller can continue editing where they left off

## Tasks / Subtasks

### Task 1: Backend - Draft Save Action (AC1)
- [x] 1.1. Create CAP action `saveDraft(listingId?)` in the seller service:
  - If `listingId` is provided, update the existing draft
  - If no `listingId`, create a new `Listing` entity with status = `Draft`
  - Save all current form data: certified fields, declared fields, visibility score
  - Associate all uploaded photos with the listing
  - Return the saved listing ID and a success flag
- [x] 1.2. Implement auto-save logic trigger point: backend action that the frontend can call periodically (auto-save interval managed client-side)
- [x] 1.3. Add `completionPercentage` computed field on `Listing` entity:
  - Calculate based on number of filled fields vs. total expected fields
  - Include photo count in calculation
- [x] 1.4. Write unit tests for save, update, and completion percentage calculation

### Task 2: Backend - Draft List and Management Actions (AC2)
- [x] 2.1. Create CAP query handler for listing drafts: `GET /odata/v4/seller/Listings?$filter=status eq 'Draft'&$orderby=modifiedAt desc`
  - Return: id, brand, model, createdAt, modifiedAt, completionPercentage, visibilityScore, photoCount
  - Filter by current seller (authorization scoping)
- [x] 2.2. Create CAP action `duplicateDraft(listingId)`:
  - Deep-copy the listing with all declared fields and photos
  - Do NOT copy certified fields (they should be re-fetched via auto-fill for the new listing)
  - Set status = `Draft`, clear any declaration records
  - Return the new listing ID
- [x] 2.3. Create CAP action `deleteDraft(listingId)`:
  - Verify status is `Draft` (cannot delete published/sold listings via this action)
  - Delete listing, associated certified fields, photos (including blob storage), and any cached data
  - Cascade delete all related entities
- [x] 2.4. Write unit tests for list, duplicate, and delete actions

### Task 3: Backend - Draft Restore Logic (AC3)
- [x] 3.1. Create CAP action `loadDraft(listingId)` for full draft loading:
  - Return complete listing data with all relationships expanded
  - Include computed fields: completionPercentage, visibilityScore
- [x] 3.2. Ensure certified fields maintain their source and timestamp information when loaded
- [x] 3.3. Ensure photo sort order is preserved on load
- [x] 3.4. Write unit tests for draft restore with various data states (empty, partial, fully filled)

### Task 4: Frontend - Save Draft Button and Toast (AC1)
- [x] 4.1. Add "Sauvegarder le brouillon" button to the listing form:
  - Primary position in form footer (always visible)
  - Disabled state when no changes have been made since last save
- [x] 4.2. On click, call backend `saveDraft` action with current form data
- [x] 4.3. Display confirmation toast on success: "Brouillon sauvegardé" with timestamp
- [x] 4.4. Implement auto-save: debounced save every 60 seconds when changes are detected (configurable interval)
  - Show subtle indicator: "Sauvegarde automatique..." during save
  - Show "Dernière sauvegarde: [time]" in form header
- [x] 4.5. Handle save errors: show error toast with retry option
- [x] 4.6. Write unit tests for save button state, auto-save timing, and toast behavior

### Task 5: Frontend - Drafts List Page (AC2)
- [x] 5.1. Create `src/app/(dashboard)/seller/drafts/page.tsx`:
  - Grid or list layout showing all drafts
  - Each draft card shows: vehicle brand + model (or "Nouveau véhicule" if not yet filled), creation date, completion percentage (progress bar), visibility score (mini gauge), photo count
- [x] 5.2. Implement draft actions:
  - "Modifier" button -> navigates to listing form with draft data loaded
  - "Dupliquer" button -> calls `duplicateDraft` action, shows new draft in list
  - "Supprimer" button -> confirmation dialog, then calls `deleteDraft` action
- [x] 5.3. Implement empty state: "Aucun brouillon. Créez votre première annonce !" with CTA button
- [x] 5.4. Write unit tests for draft list rendering, actions, and empty state

### Task 6: Frontend - Draft Restore in Form (AC3)
- [x] 6.1. When navigating to listing form with a draft ID, load full draft data from backend
- [x] 6.2. Populate all form sections with saved data:
  - Certified fields with source info
  - Declared fields
  - Photos in their saved order
  - Visibility score at saved value
- [x] 6.3. Ensure the form state tracks modifications from the restored baseline (for save/auto-save detection)
- [x] 6.4. Write unit tests for draft restoration with various data combinations

### Task 7: Integration Tests
- [x] 7.1. Full flow: create listing -> fill fields -> save draft -> auto-save -> verify all data preserved
- [x] 7.2. Test restore with certified fields and photos -> verify all data correctly populated
- [x] 7.3. Test restore -> modify -> save round-trip
- [x] 7.4. Test state reset for new listing after working on a draft
- [x] 7.5. Backend integration: create→save→load, duplicate→no certified fields, delete→cascade, cross-seller access prevention

## Dev Notes

### Architecture & Patterns
- Draft management is the intermediate state between auto-fill (Story 3.2) and publication (Story 3.9). All listing data passes through the draft state.
- The `completionPercentage` is a computed field that provides a quick overview of how complete a listing is. It is calculated from filled fields vs. total expected fields.
- Auto-save is implemented client-side with debouncing. The backend receives the same `saveDraft` action regardless of manual or auto-save trigger.
- When duplicating a draft, certified fields are intentionally NOT copied because they are tied to a specific API lookup for a specific vehicle. The seller should re-run auto-fill for the new listing.
- The drafts page is part of the seller dashboard at `(dashboard)/seller/drafts/`. It uses Next.js App Router layout groups.

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
- **Task 1 complete**: saveDraft action implemented with create/update, certified field persistence, field sanitization (whitelist + numeric conversion), visibility score + completion percentage calculation, audit logging. Auto-save is the same endpoint called periodically by frontend. 18 backend tests + 10 shared tests added.
- **Task 2 complete**: duplicateDraft copies declared fields + photos (not certified fields), resets status to draft. deleteDraft verifies draft status, cascade deletes photos (blob + DB), certified fields, listing. Draft listing via existing OData $filter on Listings entity with authorization scoping. 13 new tests.
- **Task 3 complete**: loadDraft action returns full listing data, certified fields (with source/timestamp preserved), and photos (ordered by sortOrder) as JSON strings. Ownership verification, 404/403 handling. 7 new tests.
- **Task 4 complete**: Frontend draft-api client (saveDraft, loadDraft, duplicateDraft, deleteDraft, fetchSellerDrafts). Listing store extended with isDirty, isSaving, lastSavedAt, visibilityLabel, completionPercentage, resetDraftState. use-draft-save hook with manual save + 60s auto-save. draft-save-footer sticky component. Toaster added to root layout. 44 new frontend tests (824 total).
- **Task 5 complete**: Drafts list page at (dashboard)/seller/drafts/ with grid layout, draft-card component (vehicle info, completion progress bar, visibility score badge, photo count, edit/duplicate/delete actions), delete confirmation dialog, empty state, loading skeleton. 32 new frontend tests (856 total).
- **Task 6 complete**: use-draft-restore hook loads full draft via loadDraft API, populates listing store fields with correct status (certified/declared/empty) and certified source/timestamp, sets photos in photo store, marks isDirty false as clean baseline. hasRestored ref prevents duplicate loading. 13 new frontend tests (869 total).
- **Task 7 complete**: 4 frontend integration tests (create→save→auto-save, restore with full data, restore→modify→save round-trip, state reset). 6 backend integration tests (create→save→load, duplicate→no certified fields, delete→cascade, save→update, non-draft delete prevention, cross-seller access prevention). 873 frontend + 853 backend + 367 shared = **2,093 total tests green**.

### Change Log
- 2026-02-23: Task 1 - saveDraft action, completionPercentage field, 28 new tests (367 shared, 827 backend)
- 2026-02-23: Task 2 - duplicateDraft, deleteDraft actions, 13 new tests (840 backend)
- 2026-02-23: Task 3 - loadDraft action, 7 new tests (847 backend)
- 2026-02-23: Task 4 - Frontend draft API, store, save hook, footer, toaster, 44 new tests (824 frontend)
- 2026-02-23: Task 5 - Drafts list page, card, delete dialog, 32 new tests (856 frontend)
- 2026-02-23: Task 6 - Draft restore hook, 13 new tests (869 frontend)
- 2026-02-23: Task 7 - Integration tests, 10 new tests (873 frontend, 853 backend)

### File List
- auto-shared/src/types/listing.ts (modified - SaveDraftResult, completionPercentage on IListing)
- auto-shared/src/types/index.ts (modified - export SaveDraftResult)
- auto-shared/src/utils/completion.ts (new - calculateCompletionPercentage)
- auto-shared/src/utils/index.ts (modified - export completion)
- auto-shared/tests/listing-types.test.ts (modified - new fields)
- auto-shared/tests/completion.test.ts (new - 10 tests)
- auto-backend/db/schema/listing.cds (modified - completionPercentage field)
- auto-backend/srv/seller-service.cds (modified - saveDraft, loadDraft, duplicateDraft, deleteDraft actions)
- auto-backend/srv/seller-service.ts (modified - all draft handlers)
- auto-backend/test/srv/handlers/seller-draft.test.ts (new - 44 tests)
- auto-frontend/src/lib/api/draft-api.ts (new - draft API client)
- auto-frontend/src/stores/listing-store.ts (modified - draft state fields and actions)
- auto-frontend/src/hooks/use-draft-save.ts (new - manual + auto-save hook)
- auto-frontend/src/hooks/use-draft-restore.ts (new - draft restore hook)
- auto-frontend/src/components/listing/draft-save-footer.tsx (new - sticky save footer)
- auto-frontend/src/components/listing/draft-card.tsx (new - draft card component)
- auto-frontend/src/components/listing/delete-draft-dialog.tsx (new - delete confirmation dialog)
- auto-frontend/src/app/(dashboard)/seller/drafts/page.tsx (new - drafts list page)
- auto-frontend/src/app/layout.tsx (modified - added Toaster)
- auto-frontend/tests/lib/api/draft-api.test.ts (new - 12 tests)
- auto-frontend/tests/hooks/use-draft-save.test.ts (new - 13 tests)
- auto-frontend/tests/hooks/use-draft-restore.test.ts (new - 13 tests)
- auto-frontend/tests/components/listing/draft-save-footer.test.tsx (new - 12 tests)
- auto-frontend/tests/components/listing/draft-card.test.tsx (new - 14 tests)
- auto-frontend/tests/components/listing/delete-draft-dialog.test.tsx (new - 6 tests)
- auto-frontend/tests/app/dashboard/seller/drafts/drafts-page.test.tsx (new - 12 tests)
- auto-frontend/tests/stores/listing-store.test.ts (modified - +7 draft state tests)
- auto-frontend/tests/integration/draft-lifecycle.test.ts (new - 4 integration tests)
