# Story 3.8: Vehicle History Report

Status: ready-for-dev

## Story

As a seller,
I want the platform to include a vehicle history report in my published listing,
so that buyers get comprehensive vehicle transparency included in the listing price.

## Acceptance Criteria (BDD)

**Given** a listing is being prepared for publication
**When** the system assembles the listing data (FR10)
**Then** the vehicle history report is fetched via `IHistoryAdapter` (mock in V1)
**And** the report data is cached in `ApiCachedData` with the listing
**And** the report cost is logged via `api-logger`

**Given** a published listing exists
**When** a registered buyer views the listing detail
**Then** the vehicle history report is displayed as an integrated section (not a separate download)
**And** report fields are marked Certified (green indicator) with their source

**Given** the `IHistoryAdapter` is in mock mode (V1)
**When** the report is generated
**Then** realistic mock data is displayed with clear indication of data availability
**And** the architecture is ready for real provider swap (CarVertical/AutoDNA/Autoviza) via config

## Tasks / Subtasks

### Task 1: Backend - History Report Fetching and Caching (AC1)
1.1. Implement the history report fetch flow triggered during listing preparation:
  - Use `AdapterFactory.getHistory()` to resolve the active `IHistoryAdapter` (mock in V1)
  - Call adapter with vehicle identifier (plate or VIN)
  - Cache the report data in `ApiCachedData` table with adapter-specific TTL
  - Log the API call via `api-logger` middleware including cost tracking
1.2. Define CDS entity `HistoryReport` (or extend Listing with composition):
  - id, listingId, reportData (JSON - structured report sections), source, fetchedAt, reportVersion
  - Report sections: ownershipHistory, accidentHistory, mileageRecords, registrationHistory, outstandingFinance, stolenStatus
1.3. Create CAP action `fetchHistoryReport(listingId)`:
  - Validates listing exists and belongs to current seller
  - Calls adapter via factory
  - Stores report and associates with listing
  - Returns report summary
1.4. Write unit tests for fetch, cache, and logging behavior

### Task 2: Backend - Mock History Adapter Enhancement (AC3)
2.1. Enhance `MockHistoryAdapter` (created in Story 3.1) with comprehensive realistic data:
  - Multiple ownership records with dates and locations
  - Accident/damage history (some vehicles with, some without)
  - Mileage records at various service points
  - Registration history (French departments)
  - Outstanding finance status (clear for most, flagged for some test vehicles)
  - Stolen status check (clear for most)
2.2. Ensure mock returns data in the same structure as planned real providers (CarVertical/AutoDNA/Autoviza)
2.3. Add a small configurable delay to mock to simulate real API latency
2.4. Document the expected provider interface for future real adapter implementation (CarVertical, AutoDNA, Autoviza)
2.5. Write unit tests for mock data completeness and structure

### Task 3: Backend - Buyer Access Control (AC2)
3.1. Create buyer-facing query handler for history report:
  - `GET /odata/v4/buyer/Listings({id})/historyReport`
  - Only accessible for published listings
  - Only accessible to registered/authenticated buyers
  - Return full report data with certified field metadata
3.2. Implement authorization check: anonymous users see "Rapport disponible - connectez-vous pour consulter"
3.3. Write unit tests for access control scenarios

### Task 4: Frontend - History Report Display for Buyer (AC2)
4.1. Create `src/components/listing/history-report.tsx`:
  - Integrated section within the listing detail page (not a separate download or popup)
  - Structured display of report sections:
    - Ownership history: timeline of owners with dates
    - Accident history: incidents with severity and dates (or "Aucun accident signale")
    - Mileage records: chart or table showing recorded mileages over time
    - Registration history: department/region timeline
    - Finance status: clear/flagged indicator
    - Stolen status: clear/flagged indicator
4.2. Each report field displays Certified badge (green indicator) with source name
4.3. Handle partial report data gracefully: if a section has no data, show "Information non disponible" rather than empty space
4.4. Responsive design: report sections stack vertically on mobile
4.5. Write unit tests for report rendering with full, partial, and empty data

### Task 5: Frontend - History Report in Seller View (AC1)
5.1. In the seller's listing form, show a "Rapport historique" section:
  - If report fetched: show summary with "Rapport genere le [date]" and key highlights
  - If not yet fetched: show "Le rapport sera genere lors de la publication"
  - Allow manual trigger: "Generer le rapport maintenant" button (calls `fetchHistoryReport`)
5.2. Show report cost information if applicable (for future paid providers)
5.3. Write unit tests for seller-side report section states

### Task 6: Frontend - Mock Mode Indication (AC3)
6.1. When the history adapter is in mock mode, display a subtle indicator:
  - Banner or badge: "Donnees de demonstration - rapport reel disponible prochainement"
  - Style differently from real certified data (e.g., dashed border, slightly muted colors)
6.2. Ensure the mock indicator does not confuse buyers about real data once providers are integrated
6.3. Write unit test for mock mode indicator rendering

### Task 7: Integration Tests
7.1. Full flow: create listing -> trigger history report -> verify report cached in ApiCachedData -> verify logged in ApiCallLog
7.2. Test buyer access: publish listing -> access as authenticated buyer -> verify full report visible
7.3. Test anonymous access: verify report teaser shown with login prompt
7.4. Test provider swap readiness: change ConfigApiProvider for history -> verify factory resolves new adapter
7.5. Test cache behavior: fetch report -> fetch again -> verify second call uses cache

## Dev Notes

### Architecture & Patterns
- In V1, the history report uses MockHistoryAdapter exclusively. The architecture must be ready for a seamless swap to CarVertical, AutoDNA, or Autoviza via ConfigApiProvider without code changes.
- The report is fetched and cached when the listing is prepared for publication. It is not re-fetched on every buyer view; the cached version is served.
- The report is integrated inline in the listing detail page, not as a separate PDF download. This ensures a consistent UX and allows certified field badges on individual report fields.
- Report cost tracking via `api-logger` is essential because real history providers charge per report. This enables future cost analysis and billing reconciliation.
- Buyer access to the report is gated by authentication. Anonymous users see a teaser to encourage registration.

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
