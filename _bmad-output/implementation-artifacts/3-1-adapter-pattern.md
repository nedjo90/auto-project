# Story 3.1: Adapter Pattern & API Integration Framework

Status: ready-for-dev

## Story

As a seller,
I want the platform to connect to official data sources through interchangeable adapters,
so that my vehicle data is fetched from the best available provider, and the system never depends on a single source.

## Acceptance Criteria (BDD)

**Given** the backend is initialized
**When** the adapter layer is set up
**Then** 8 TypeScript adapter interfaces exist: `IVehicleLookupAdapter`, `IEmissionAdapter`, `IRecallAdapter`, `ICritAirCalculator`, `IVINTechnicalAdapter`, `IHistoryAdapter`, `IValuationAdapter`, `IPaymentAdapter`
**And** each interface defines a clear contract with input/output types in `@auto/shared`

**Given** adapter interfaces are defined
**When** the implementation layer is set up
**Then** mock implementations exist for all 8 adapters with realistic test data
**And** free API implementations exist for: ADEME (`IEmissionAdapter`), RappelConso (`IRecallAdapter`), local Crit'Air calculation (`ICritAirCalculator`), NHTSA vPIC (`IVINTechnicalAdapter`)

**Given** the `AdapterFactory` is initialized
**When** a service requests an adapter (e.g., `factory.getVehicleLookup()`)
**Then** the factory resolves the active implementation from `ConfigApiProvider` table
**And** if the active provider is unavailable, the factory returns the mock adapter as fallback

**Given** any adapter makes an external API call
**When** the call completes (success or failure)
**Then** the `api-logger` middleware logs: adapter name, provider, endpoint, status, response time, cost, listing ID, timestamp

## Tasks / Subtasks

### Task 1: Define Adapter Interfaces and Shared Types (AC1)
1.1. Create `@auto/shared` types directory with adapter input/output DTOs:
  - `VehicleLookupRequest` / `VehicleLookupResponse` (plate or VIN input, full vehicle data output)
  - `EmissionRequest` / `EmissionResponse` (CO2, energy class, Euro norm)
  - `RecallRequest` / `RecallResponse` (recall campaigns list)
  - `CritAirRequest` / `CritAirResponse` (Crit'Air vignette level)
  - `VINTechnicalRequest` / `VINTechnicalResponse` (decoded VIN technical specs)
  - `HistoryRequest` / `HistoryResponse` (vehicle history report data)
  - `ValuationRequest` / `ValuationResponse` (estimated market value)
  - `PaymentRequest` / `PaymentResponse` (checkout session, webhook events)
1.2. Create 8 TypeScript interfaces in `srv/adapters/interfaces/`:
  - `IVehicleLookupAdapter.ts`
  - `IEmissionAdapter.ts`
  - `IRecallAdapter.ts`
  - `ICritAirCalculator.ts`
  - `IVINTechnicalAdapter.ts`
  - `IHistoryAdapter.ts`
  - `IValuationAdapter.ts`
  - `IPaymentAdapter.ts`
1.3. Each interface must define async methods with typed inputs/outputs, error handling contract, and provider metadata (name, version)

### Task 2: Implement Mock Adapters (AC2)
2.1. Create `srv/adapters/mock/` directory
2.2. Implement `MockVehicleLookupAdapter` with realistic French vehicle test data (multiple makes/models, varying years)
2.3. Implement `MockEmissionAdapter` with CO2 values, energy classes, Euro norms for test vehicles
2.4. Implement `MockRecallAdapter` with sample recall campaigns (some vehicles with recalls, some without)
2.5. Implement `MockCritAirCalculator` with correct Crit'Air level calculations matching French regulations
2.6. Implement `MockVINTechnicalAdapter` with decoded VIN data for test vehicles
2.7. Implement `MockHistoryAdapter` with sample history report (accident history, ownership count, mileage records)
2.8. Implement `MockValuationAdapter` with estimated market values based on vehicle attributes
2.9. Implement `MockPaymentAdapter` simulating Stripe checkout sessions, webhook events, success/failure scenarios
2.10. All mocks must implement the same interface contracts and return data with realistic delays (configurable)

### Task 3: Implement Free API Adapters (AC2)
3.1. Implement `AdemeEmissionAdapter` calling the ADEME API for real CO2/emission data
3.2. Implement `RappelConsoRecallAdapter` calling RappelConso for French vehicle recall data
3.3. Implement `LocalCritAirCalculator` with local computation logic based on fuel type, Euro norm, and registration date (no external API needed)
3.4. Implement `NhtsaVINAdapter` calling NHTSA vPIC API for VIN decoding
3.5. Each implementation must include proper HTTP client configuration (timeouts, retries, error mapping)

### Task 4: Implement AdapterFactory with ConfigApiProvider Resolution (AC3)
4.1. Create CDS entity `ConfigApiProvider` with fields: adapterType, providerName, isActive, priority, config (JSON), createdAt, updatedAt
4.2. Seed initial `ConfigApiProvider` data: one row per adapter type with active provider set (mock for paid, real for free)
4.3. Implement `AdapterFactory` class in `srv/adapters/AdapterFactory.ts`:
  - Method per adapter type: `getVehicleLookup()`, `getEmission()`, `getRecall()`, `getCritAir()`, `getVINTechnical()`, `getHistory()`, `getValuation()`, `getPayment()`
  - Each method reads `ConfigApiProvider` to determine active implementation
  - Singleton pattern for factory, lazy instantiation of adapters
4.4. Implement fallback logic: if the resolved adapter fails health check or is not found, return the mock adapter
4.5. Write unit tests for factory resolution, fallback scenarios, and configuration changes

### Task 5: Implement API Logger Middleware (AC4)
5.1. Create `srv/middleware/api-logger.ts` with `ApiCallLog` CDS entity: adapterName, providerName, endpoint, httpStatus, responseTimeMs, costEur, listingId, timestamp, errorMessage
5.2. Implement logging middleware that wraps every adapter call, capturing start/end time, status, and error details
5.3. Ensure the logger is non-blocking (fire-and-forget DB insert) so it does not slow adapter calls
5.4. Write unit tests verifying log entries are created for success and failure scenarios

### Task 6: Integration Tests
6.1. Write integration tests verifying AdapterFactory resolves correct implementations based on ConfigApiProvider
6.2. Test switching providers at runtime by updating ConfigApiProvider
6.3. Test fallback to mock when active provider is unavailable
6.4. Verify api-logger captures complete call metadata for each adapter type
6.5. Test all free API adapters against live endpoints (mark as integration/slow tests)

## Dev Notes

### Architecture & Patterns
- This story establishes the foundational Adapter Pattern used by all subsequent Epic 3 stories. No adapter should be called directly; always go through `AdapterFactory`.
- The factory reads `ConfigApiProvider` at runtime, enabling provider swaps without code changes or redeployment.
- Mock adapters are not just for testing; they serve as the degraded-mode fallback and as placeholders for paid APIs not yet integrated (IVehicleLookupAdapter via SIV, IHistoryAdapter, IValuationAdapter).
- Each adapter interface must be self-contained: input types, output types, error types, and provider metadata.

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
