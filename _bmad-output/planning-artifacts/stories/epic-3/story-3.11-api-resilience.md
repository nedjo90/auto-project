# Story 3.11: API Resilience & Degraded Mode

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR58, FR59, FR60
**NFRs:** NFR33 (48h tolerance), NFR34 (degraded mode), NFR35 (cached data), NFR36 (admin alert)

## User Story

As a seller,
I want the platform to handle API outages gracefully by offering manual data entry and automatic re-synchronization,
So that I'm never blocked from creating a listing, even when data sources are temporarily unavailable.

## Acceptance Criteria

**Given** an API provider is unavailable during auto-fill
**When** the adapter call fails or times out (FR58)
**Then** the affected fields show: "[Source] — données indisponibles temporairement. Saisie manuelle disponible."
**And** the seller can manually enter the data (fields switch to 🟡 Declared)
**And** the source status indicator shows the failure ("ADEME ✗")
**And** the remaining APIs continue to be called (partial success is accepted) (FR60)

**Given** a listing has manually entered fields due to API outage
**When** the API source becomes available again (FR59)
**Then** the system offers the seller to re-sync: "Les données [Source] sont à nouveau disponibles. Mettre à jour ?"
**And** upon confirmation, the fields are updated to 🟢 Certified with the new API data
**And** the visibility score is recalculated

**Given** cached API data exists for a vehicle (from a previous lookup)
**When** the same vehicle is looked up and the API is down
**Then** the cached data is served with a note: "Données certifiées du [date] — source temporairement indisponible" (NFR33, NFR35)
**And** cached data is served for up to 48h (configurable TTL)

**Given** an API provider experiences repeated failures
**When** the failure threshold is exceeded
**Then** an admin alert is triggered (NFR36)
**And** the failure pattern is logged in `ApiCallLog`
