# Story 3.1: Adapter Pattern & API Integration Framework

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** —
**NFRs:** NFR28 (adapter pattern), NFR29 (API logging), NFR30 (mock mode)

## User Story

As a seller,
I want the platform to connect to official data sources through interchangeable adapters,
So that my vehicle data is fetched from the best available provider, and the system never depends on a single source.

## Acceptance Criteria

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
