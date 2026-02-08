# Story 3.11: API Resilience & Degraded Mode

Status: ready-for-dev

## Story

As a seller,
I want the platform to handle API outages gracefully by offering manual data entry and automatic re-synchronization,
so that I'm never blocked from creating a listing, even when data sources are temporarily unavailable.

## Acceptance Criteria (BDD)

**Given** an API provider is unavailable during auto-fill
**When** the adapter call fails or times out (FR58)
**Then** the affected fields show: "[Source] -- donnees indisponibles temporairement. Saisie manuelle disponible."
**And** the seller can manually enter the data (fields switch to Declared, yellow indicator)
**And** the source status indicator shows the failure ("ADEME failed")
**And** the remaining APIs continue to be called (partial success is accepted) (FR60)

**Given** a listing has manually entered fields due to API outage
**When** the API source becomes available again (FR59)
**Then** the system offers the seller to re-sync: "Les donnees [Source] sont a nouveau disponibles. Mettre a jour ?"
**And** upon confirmation, the fields are updated to Certified (green indicator) with the new API data
**And** the visibility score is recalculated

**Given** cached API data exists for a vehicle (from a previous lookup)
**When** the same vehicle is looked up and the API is down
**Then** the cached data is served with a note: "Donnees certifiees du [date] -- source temporairement indisponible" (NFR33, NFR35)
**And** cached data is served for up to 48h (configurable TTL)

**Given** an API provider experiences repeated failures
**When** the failure threshold is exceeded
**Then** an admin alert is triggered (NFR36)
**And** the failure pattern is logged in `ApiCallLog`

## Tasks / Subtasks

### Task 1: Backend - Adapter Error Handling and Partial Success (AC1)
1.1. Extend all adapter interfaces with standardized error types:
  - `AdapterTimeoutError` (configurable timeout per adapter from ConfigParameter)
  - `AdapterConnectionError` (network-level failure)
  - `AdapterResponseError` (API returned error status)
  - `AdapterRateLimitError` (429 or equivalent)
1.2. Implement retry logic in adapter base class:
  - Configurable retry count per adapter (from ConfigParameter, e.g., `ADAPTER_RETRY_COUNT = 2`)
  - Exponential backoff between retries
  - Circuit breaker pattern: after N consecutive failures, skip adapter calls for a cooldown period
1.3. Modify the auto-fill flow (Story 3.2 `autoFillByPlate` action) to handle partial results:
  - Use `Promise.allSettled()` (already in place from 3.2)
  - For each rejected promise, include the adapter name and error type in the response
  - Mark affected fields as unavailable with the specific source name
  - Continue processing successful adapter results normally
1.4. Write unit tests for each error type, retry behavior, and circuit breaker activation

### Task 2: Backend - Cache-Based Fallback (AC3)
2.1. Extend the auto-fill flow cache lookup logic:
  - Before calling an adapter, check `ApiCachedData` for the vehicle identifier
  - If cache exists and adapter call fails, serve cached data with `isCachedFallback = true` flag
  - Include `cachedAt` timestamp in the response for UI display
2.2. Implement configurable cache TTL from `ConfigParameter`:
  - `API_CACHE_TTL_HOURS = 48` (NFR33: 48-hour tolerance)
  - Cache is valid for TTL period; after expiry, cached data is marked stale but still servable as last-resort fallback
2.3. Implement cache status in response:
  - `fresh`: data from live API call
  - `cached`: data from cache, API was down, within TTL
  - `stale`: data from cache, beyond TTL, served as last resort
2.4. Write unit tests for cache fallback with TTL expiry scenarios

### Task 3: Backend - API Health Monitoring and Admin Alerts (AC4)
3.1. Extend `ApiCallLog` entity (from Story 3.1) with health monitoring fields:
  - `isFailure` (Boolean)
  - `errorType` (String: timeout, connection, response, rateLimit)
  - `consecutiveFailures` (computed or tracked in a separate health entity)
3.2. Create `ApiProviderHealth` CDS entity:
  - adapterName, providerName, consecutiveFailures, lastSuccessAt, lastFailureAt, isCircuitOpen, circuitOpenedAt
3.3. Implement failure tracking logic:
  - On adapter call failure, increment consecutiveFailures in `ApiProviderHealth`
  - On adapter call success, reset consecutiveFailures to 0
3.4. Implement admin alert trigger:
  - Configure threshold in `ConfigParameter` (e.g., `API_FAILURE_ALERT_THRESHOLD = 5`)
  - When consecutiveFailures exceeds threshold, create an admin alert/notification
  - Alert includes: adapter name, provider, failure count, last error type, time range
  - Send alert via configured channel (email/webhook/notification system)
3.5. Create admin dashboard query for API health: `GET /odata/v4/admin/ApiProviderHealth`
3.6. Write unit tests for failure tracking, threshold detection, and alert triggering

### Task 4: Backend - Re-Sync Service (AC2)
4.1. Create CAP action `checkResyncAvailability(listingId)`:
  - For a listing with manually-declared fields (due to API outage), check if the relevant API adapters are now available
  - Perform lightweight health check on each adapter that previously failed
  - Return list of adapters that are now available with the fields they can certify
4.2. Create CAP action `resyncListing(listingId, adapterNames[])`:
  - Call specified adapters via AdapterFactory
  - For each successful adapter response:
    - Update fields from Declared to Certified
    - Create new CertifiedField records
    - Cache new API data
  - Recalculate visibility score after resync
  - Create audit trail entry: "Listing {id} re-synced with [adapters]"
  - Return updated listing with new certification status
4.3. Implement background resync check: periodic job that checks API health and notifies sellers with affected listings
  - Configurable check interval from ConfigParameter
  - Notification: "Les donnees [Source] sont a nouveau disponibles pour [N] de vos annonces"
4.4. Write unit tests for resync availability check, field update, and score recalculation

### Task 5: Frontend - Degraded Mode UI (AC1)
5.1. Extend the auto-fill UI (Story 3.2) to handle adapter failures:
  - Source status indicator shows failure state: "ADEME" with X/failed icon
  - Affected fields display: "[Source] -- donnees indisponibles temporairement. Saisie manuelle disponible."
  - Fields switch to editable input mode with Declared (yellow) badge pre-applied
  - Other fields from successful adapters display normally with Certified badges
5.2. Style degraded fields distinctly: light orange background, manual entry prompt text
5.3. Ensure the overall auto-fill flow is not blocked by individual adapter failures
5.4. Write unit tests for degraded mode rendering with various failure combinations

### Task 6: Frontend - Cached Data Indicator (AC3)
6.1. When cached data is served instead of live API data, display:
  - "Donnees certifiees du [formatted date] -- source temporairement indisponible"
  - Badge shows "Certifie (cache)" instead of just "Certifie"
  - Subtle visual distinction from live-certified data (e.g., dashed border on badge)
6.2. For stale cache (beyond TTL), add additional warning: "Donnees de plus de 48h -- verification recommandee"
6.3. Write unit tests for cached data indicators with fresh, cached, and stale states

### Task 7: Frontend - Re-Sync Notification and Flow (AC2)
7.1. Create `src/components/listing/resync-banner.tsx`:
  - Banner displayed at top of listing form when re-sync is available
  - Text: "Les donnees [Source] sont a nouveau disponibles. Mettre a jour ?"
  - "Mettre a jour" button triggers resync
  - "Ignorer" button dismisses the banner for this session
7.2. On resync trigger:
  - Show loading state per adapter being re-synced
  - On success, update affected fields from Declared to Certified with animation
  - Visibility score gauge animates to new value
  - Show success toast: "[N] champs certifies mis a jour"
7.3. Implement polling or push mechanism to detect when re-sync becomes available:
  - Option A: Check on listing form load (call `checkResyncAvailability`)
  - Option B: Listen for server-sent notification (if background job notifies)
7.4. Write unit tests for banner display, resync flow, and field status transitions

### Task 8: Integration Tests
8.1. Degraded mode flow: simulate adapter failure -> verify manual entry available -> complete listing with declared fields -> verify listing saveable
8.2. Cache fallback: populate cache -> simulate adapter failure -> verify cached data served with correct indicators
8.3. Re-sync flow: create listing with declared fields -> restore adapter -> trigger resync -> verify fields updated to certified
8.4. Admin alert: simulate 5+ consecutive failures -> verify alert created and logged
8.5. Partial success: simulate one adapter failing, others succeeding -> verify mixed certified/degraded state
8.6. TTL expiry: set short TTL -> verify cache expires and stale indicator appears
8.7. Circuit breaker: trigger many failures -> verify adapter calls skipped during cooldown -> verify recovery after cooldown

## Dev Notes

### Architecture & Patterns
- API resilience is a cross-cutting concern that touches the Adapter Pattern (Story 3.1), Auto-Fill (Story 3.2), and Certification (Story 3.3). This story adds error handling, fallback, and recovery layers.
- The circuit breaker pattern prevents cascading failures: after N consecutive failures for an adapter, stop calling it for a cooldown period. This protects both the platform and the external API.
- Re-sync is a proactive feature that recovers certification for fields that were manually entered during an outage. It increases data quality over time.
- The 48-hour cache tolerance (NFR33) means cached data is considered acceptable for up to 48 hours. Beyond that, it is served as "stale" with a warning but is still better than no data.
- Admin alerts on repeated failures enable operational awareness. The alert threshold and channel are configurable.
- The partial success model (FR60) is fundamental: a listing creation should never be completely blocked by a single API failure. Each adapter result is independent.

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
