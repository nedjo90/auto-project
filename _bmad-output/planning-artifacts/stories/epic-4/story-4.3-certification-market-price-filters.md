# Story 4.3: Certification & Market Price Filters

**Epic:** 4 - Marketplace, Recherche & Découverte
**FRs:** FR15, FR16
**NFRs:** —

## User Story

As a buyer,
I want to filter by certification level, valid CT, and market price positioning,
So that I can find the most trustworthy and best-value vehicles.

## Acceptance Criteria

**Given** a buyer views the filter options
**When** they access advanced filters (FR15)
**Then** they can filter by: certification level ("Très documenté", "Bien documenté", "Partiellement documenté"), CT valid (yes/no), price vs market (below, aligned, above)

**Given** a buyer filters by "below market price"
**When** results are displayed
**Then** each listing card shows a visual indicator: green arrow "8% en dessous du marché" or neutral "Prix aligné" (FR16)
**And** the market comparison uses colors from design tokens (`--market-below`, `--market-aligned`, `--market-above`)

**Given** market price data is not available (mock in V1)
**When** the comparison is displayed
**Then** the indicator shows "Estimation non disponible" rather than hiding the feature
**And** the architecture is ready for real valuation provider swap via `IValuationAdapter`
