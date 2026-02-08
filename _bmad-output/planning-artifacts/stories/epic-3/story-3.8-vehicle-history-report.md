# Story 3.8: Vehicle History Report

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR10
**NFRs:** NFR28 (adapter pattern), NFR30 (mock mode)

## User Story

As a seller,
I want the platform to include a vehicle history report in my published listing,
So that buyers get comprehensive vehicle transparency included in the listing price.

## Acceptance Criteria

**Given** a listing is being prepared for publication
**When** the system assembles the listing data (FR10)
**Then** the vehicle history report is fetched via `IHistoryAdapter` (mock in V1)
**And** the report data is cached in `ApiCachedData` with the listing
**And** the report cost is logged via `api-logger`

**Given** a published listing exists
**When** a registered buyer views the listing detail
**Then** the vehicle history report is displayed as an integrated section (not a separate download)
**And** report fields are marked 🟢 Certified with their source

**Given** the `IHistoryAdapter` is in mock mode (V1)
**When** the report is generated
**Then** realistic mock data is displayed with clear indication of data availability
**And** the architecture is ready for real provider swap (CarVertical/AutoDNA/Autoviza) via config
