# Story 3.6: Draft Management

Status: ready-for-dev

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
1.1. Create CAP action `saveDraft(listingId?)` in the seller service:
  - If `listingId` is provided, update the existing draft
  - If no `listingId`, create a new `Listing` entity with status = `Draft`
  - Save all current form data: certified fields, declared fields, visibility score
  - Associate all uploaded photos with the listing
  - Return the saved listing ID and a success flag
1.2. Implement auto-save logic trigger point: backend action that the frontend can call periodically (auto-save interval managed client-side)
1.3. Add `completionPercentage` computed field on `Listing` entity:
  - Calculate based on number of filled fields vs. total expected fields
  - Include photo count in calculation
1.4. Write unit tests for save, update, and completion percentage calculation

### Task 2: Backend - Draft List and Management Actions (AC2)
2.1. Create CAP query handler for listing drafts: `GET /odata/v4/seller/Listings?$filter=status eq 'Draft'&$orderby=modifiedAt desc`
  - Return: id, brand, model, createdAt, modifiedAt, completionPercentage, visibilityScore, photoCount
  - Filter by current seller (authorization scoping)
2.2. Create CAP action `duplicateDraft(listingId)`:
  - Deep-copy the listing with all declared fields and photos
  - Do NOT copy certified fields (they should be re-fetched via auto-fill for the new listing)
  - Set status = `Draft`, clear any declaration records
  - Return the new listing ID
2.3. Create CAP action `deleteDraft(listingId)`:
  - Verify status is `Draft` (cannot delete published/sold listings via this action)
  - Delete listing, associated certified fields, photos (including blob storage), and any cached data
  - Cascade delete all related entities
2.4. Write unit tests for list, duplicate, and delete actions

### Task 3: Backend - Draft Restore Logic (AC3)
3.1. Create CAP query handler for full draft loading: `GET /odata/v4/seller/Listings({id})?$expand=certifiedFields,photos,declaration`
  - Return complete listing data with all relationships expanded
  - Include computed fields: completionPercentage, visibilityScore
3.2. Ensure certified fields maintain their source and timestamp information when loaded
3.3. Ensure photo sort order is preserved on load
3.4. Write unit tests for draft restore with various data states (empty, partial, fully filled)

### Task 4: Frontend - Save Draft Button and Toast (AC1)
4.1. Add "Sauvegarder le brouillon" button to the listing form:
  - Primary position in form footer (always visible)
  - Disabled state when no changes have been made since last save
4.2. On click, call backend `saveDraft` action with current form data
4.3. Display confirmation toast on success: "Brouillon sauvegarde" with timestamp
4.4. Implement auto-save: debounced save every 60 seconds when changes are detected (configurable interval)
  - Show subtle indicator: "Sauvegarde automatique..." during save
  - Show "Derniere sauvegarde: [time]" in form header
4.5. Handle save errors: show error toast with retry option
4.6. Write unit tests for save button state, auto-save timing, and toast behavior

### Task 5: Frontend - Drafts List Page (AC2)
5.1. Create `src/app/(dashboard)/seller/drafts/page.tsx`:
  - Grid or list layout showing all drafts
  - Each draft card shows: vehicle brand + model (or "Nouveau vehicule" if not yet filled), creation date, completion percentage (progress bar), visibility score (mini gauge), photo count with thumbnail of primary photo
5.2. Implement draft actions:
  - "Modifier" button -> navigates to listing form with draft data loaded
  - "Dupliquer" button -> calls `duplicateDraft` action, shows new draft in list
  - "Supprimer" button -> confirmation dialog, then calls `deleteDraft` action
5.3. Implement empty state: "Aucun brouillon. Creez votre premiere annonce!" with CTA button
5.4. Implement pagination or infinite scroll for sellers with many drafts
5.5. Write unit tests for draft list rendering, actions, and empty state

### Task 6: Frontend - Draft Restore in Form (AC3)
6.1. When navigating to listing form with a draft ID, load full draft data from backend
6.2. Populate all form sections with saved data:
  - Certified fields with their green badges and source info
  - Declared fields with yellow badges
  - Photos in their saved order
  - Visibility score gauge at saved value
6.3. Ensure the form state tracks modifications from the restored baseline (for save/auto-save detection)
6.4. Handle stale certified data: if certified field cache has expired, show note suggesting re-sync
6.5. Write unit tests for draft restoration with various data combinations

### Task 7: Integration Tests
7.1. Full flow: create listing -> fill fields -> save draft -> navigate away -> return to drafts -> open draft -> verify all data restored
7.2. Test duplicate: duplicate draft -> verify new draft has declared fields and photos but not certified fields
7.3. Test delete: delete draft -> verify all related data removed (including blob storage photos)
7.4. Test auto-save: modify field -> wait for auto-save interval -> verify draft updated in DB
7.5. Test multiple drafts: create 5+ drafts -> verify list displays all with correct metadata

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
### Completion Notes List
### Change Log
### File List
