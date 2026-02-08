# Story 3.2: Vehicle Auto-Fill via License Plate or VIN

Status: ready-for-dev

## Story

As a seller,
I want to enter my vehicle's license plate or VIN and have the data fields automatically populated from official sources,
so that I save time and my listing has certified data that builds buyer trust.

## Acceptance Criteria (BDD)

**Given** a seller navigates to the "Create Listing" page
**When** the page loads
**Then** a single hero input field is displayed with label "Identifiez votre vehicule", placeholder `AA-123-BB ou numero VIN`, and sub-text explaining the auto-fill

**Given** a seller types 3+ characters in the input
**When** the system detects the format
**Then** a license plate format (XX-NNN-XX) triggers the label to update to "Plaque detectee" with auto-formatting of dashes
**And** a VIN format (17 alphanumeric, no I/O/Q) triggers the label to update to "VIN detecte" with grouping for readability

**Given** a seller confirms their plate/VIN and clicks "Rechercher"
**When** the auto-fill process starts
**Then** the button shows a spinner + "Recherche en cours..." + API source status indicators ("SIV ... ADEME ... ANTS ...")
**And** API calls are made in parallel via the adapter layer
**And** fields populate progressively in cascade (100ms micro-stagger per field within each API response block)
**And** each auto-filled field receives a Certified badge with source name and timestamp (FR1, FR2)
**And** source status indicators update as each API responds ("SIV done | ADEME done | ANTS pending")

**Given** the auto-fill completes
**When** all API responses are received
**Then** all returned data is cached in the `ApiCachedData` table with TTL configurable
**And** a `CertifiedField` record is created for each certified field (source, value, timestamp)
**And** the target aspiration time is ~3 seconds (NFR2)

**Given** a user with `prefers-reduced-motion` enabled
**When** the auto-fill cascade runs
**Then** all fields appear instantaneously without stagger animation

## Tasks / Subtasks

### Task 1: Backend - Auto-Fill Service Action (AC3, AC4)
1.1. Create CAP service action `autoFillByPlate` in the seller service: `POST /odata/v4/seller/autoFillByPlate`
  - Input: `{ identifier: string, identifierType: 'plate' | 'vin' }`
  - Output: `{ fields: CertifiedFieldResult[], sources: ApiSourceStatus[] }`
1.2. Implement identifier validation: plate format regex `^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$`, VIN format regex `^[A-HJ-NPR-Z0-9]{17}$`
1.3. Use `AdapterFactory` to resolve all relevant adapters: VehicleLookup, Emission, Recall, CritAir, VINTechnical
1.4. Execute adapter calls in parallel using `Promise.allSettled()` to handle partial failures gracefully
1.5. For each successful adapter response, call `certification.ts` to create `CertifiedField` records with source name and timestamp
1.6. Cache all API response data in `ApiCachedData` table with configurable TTL from `ConfigParameter`
1.7. Return aggregated results with per-source status (success/failure/cached)

### Task 2: Backend - CertifiedField Entity and Certification Logic (AC4)
2.1. Define CDS entity `CertifiedField`: id, listingId, fieldName, fieldValue, source, sourceTimestamp, isCertified, createdAt
2.2. Implement `srv/lib/certification.ts`:
  - `markFieldCertified(listingId, fieldName, value, source)` - creates CertifiedField record
  - `getCertifiedFields(listingId)` - returns all certified fields for a listing
  - `isCertified(listingId, fieldName)` - checks if a specific field is certified
2.3. Write unit tests for certification logic

### Task 3: Backend - ApiCachedData Entity and Caching Logic (AC4)
3.1. Define CDS entity `ApiCachedData`: id, vehicleIdentifier, identifierType, adapterName, responseData (JSON), fetchedAt, expiresAt, isValid
3.2. Implement cache lookup in auto-fill flow: before calling adapter, check cache for non-expired data
3.3. Implement cache write after successful adapter call
3.4. Implement TTL from `ConfigParameter` table (e.g., `API_CACHE_TTL_HOURS = 48`)
3.5. Write unit tests for cache hit/miss/expiry scenarios

### Task 4: Frontend - Hero Input Component (AC1, AC2)
4.1. Create `src/components/listing/auto-fill-trigger.tsx` component:
  - Single input field with label "Identifiez votre vehicule"
  - Placeholder: "AA-123-BB ou numero VIN"
  - Sub-text explaining the auto-fill benefit
4.2. Implement format detection logic (triggered at 3+ characters):
  - Plate regex detection with auto-dash formatting (e.g., "AB123CD" -> "AB-123-CD")
  - VIN detection with readability grouping
  - Update label dynamically: "Plaque detectee" / "VIN detecte"
4.3. Implement "Rechercher" button with validation (disabled until valid format detected)
4.4. Write unit tests for format detection and auto-formatting

### Task 5: Frontend - Progressive Auto-Fill UI (AC3, AC5)
5.1. Create `src/hooks/useVehicleLookup.ts` custom hook:
  - Manages auto-fill state (idle, loading, success, partial, error)
  - Calls backend `autoFillByPlate` action
  - Receives streaming source status updates
5.2. Implement API source status indicators component showing per-adapter progress (pending/done/failed)
5.3. Implement progressive field population with 100ms micro-stagger animation using CSS transitions
5.4. Implement `prefers-reduced-motion` media query check: if enabled, skip stagger and show all fields instantly (AC5)
5.5. Create `src/components/listing/certified-field.tsx` component:
  - Displays field value with Certified badge (green indicator + source name + timestamp)
  - Badge text: "Certifie [Source] - [date]"
  - Accessible: badge has `aria-label` with full description
5.6. Write unit tests for hook state transitions, stagger logic, and reduced-motion behavior

### Task 6: Integration Tests
6.1. End-to-end test: enter plate -> auto-fill -> verify certified fields created in DB
6.2. Test parallel adapter execution and partial failure handling
6.3. Test cache hit scenario (second lookup for same vehicle returns cached data)
6.4. Test NFR2 aspiration: auto-fill completes within ~3 seconds (with mocks)
6.5. Frontend integration test: verify progressive field population and source status updates

## Dev Notes

### Architecture & Patterns
- This story is the core auto-fill flow that ties together the Adapter Pattern (Story 3.1) with the frontend UX. It depends on Story 3.1 being complete.
- The backend action uses `Promise.allSettled()` (not `Promise.all()`) to ensure partial API failures do not block the entire auto-fill. Each adapter result is independent.
- The `certification.ts` library creates the source-of-truth records that distinguish certified vs. declared data throughout the platform.
- Caching in `ApiCachedData` serves two purposes: (1) avoid redundant API calls for the same vehicle, (2) provide data in degraded mode (Story 3.11).

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
