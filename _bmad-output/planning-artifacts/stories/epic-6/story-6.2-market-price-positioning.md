# Story 6.2: Market Price Positioning

**Epic:** 6 - Cockpit Vendeur & Intelligence Marché
**FRs:** FR34
**NFRs:** —

## User Story

As a seller,
I want to see how my listings are priced compared to the market,
So that I can adjust my pricing strategy to maximize sales.

## Acceptance Criteria

**Given** a seller views their listings (FR34)
**When** market data is available
**Then** each listing shows a visual indicator: "8% en dessous du marché" (green), "Prix aligné" (neutral), "12% au-dessus" (orange)
**And** the indicator uses design tokens (`--market-below/aligned/above`)

**Given** market data is not available (mock `IValuationAdapter` in V1)
**When** the comparison is displayed
**Then** mock market data is shown with a note about estimation methodology
**And** the architecture is ready for real provider integration
