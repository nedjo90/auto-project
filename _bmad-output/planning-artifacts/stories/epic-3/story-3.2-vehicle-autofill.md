# Story 3.2: Vehicle Auto-Fill via License Plate or VIN

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR1, FR2
**NFRs:** NFR2 (auto-fill < 3s)

## User Story

As a seller,
I want to enter my vehicle's license plate or VIN and have the data fields automatically populated from official sources,
So that I save time and my listing has certified data that builds buyer trust.

## Acceptance Criteria

**Given** a seller navigates to the "Create Listing" page
**When** the page loads
**Then** a single hero input field is displayed with label "Identifiez votre véhicule", placeholder `AA-123-BB ou numéro VIN`, and sub-text explaining the auto-fill

**Given** a seller types 3+ characters in the input
**When** the system detects the format
**Then** a license plate format (XX-NNN-XX) triggers the label to update to "Plaque détectée ✓" with auto-formatting of dashes
**And** a VIN format (17 alphanumeric, no I/O/Q) triggers the label to update to "VIN détecté ✓" with grouping for readability

**Given** a seller confirms their plate/VIN and clicks "Rechercher"
**When** the auto-fill process starts
**Then** the button shows a spinner + "Recherche en cours..." + API source status indicators ("SIV ⏳ ADEME ⏳ ANTS ⏳")
**And** API calls are made in parallel via the adapter layer
**And** fields populate progressively in cascade (100ms micro-stagger per field within each API response block)
**And** each auto-filled field receives a 🟢 Certified badge with source name and timestamp (FR1, FR2)
**And** source status indicators update as each API responds ("SIV ✓ | ADEME ✓ | ANTS ⏳")

**Given** the auto-fill completes
**When** all API responses are received
**Then** all returned data is cached in the `ApiCachedData` table with TTL configurable
**And** a `CertifiedField` record is created for each certified field (source, value, timestamp)
**And** the target aspiration time is ~3 seconds (NFR2)

**Given** a user with `prefers-reduced-motion` enabled
**When** the auto-fill cascade runs
**Then** all fields appear instantaneously without stagger animation
