# Story 4.3: Certification & Market Price Filters

Status: ready-for-dev

## Story

As a buyer,
I want to filter by certification level, valid CT, and market price positioning,
so that I can find the most trustworthy and best-value vehicles.

## Acceptance Criteria (BDD)

**Given** a buyer views the filter options
**When** they access advanced filters (FR15)
**Then** they can filter by: certification level ("Tres documente", "Bien documente", "Partiellement documente"), CT valid (yes/no), price vs market (below, aligned, above)

**Given** a buyer filters by "below market price"
**When** results are displayed
**Then** each listing card shows a visual indicator: green arrow "8% en dessous du marche" or neutral "Prix aligne" (FR16)
**And** the market comparison uses colors from design tokens (`--market-below`, `--market-aligned`, `--market-above`)

**Given** market price data is not available (mock in V1)
**When** the comparison is displayed
**Then** the indicator shows "Estimation non disponible" rather than hiding the feature
**And** the architecture is ready for real valuation provider swap via `IValuationAdapter`

## Tasks / Subtasks

### Task 1: Backend - Market Price Comparison Logic (AC2, AC3)
1.1. Define the `IValuationAdapter` interface in `srv/lib/market-price.ts` with method signature: `getMarketPrice(brand: string, model: string, year: number, mileage: number, fuelType: string): Promise<MarketPriceResult | null>`.
1.2. Define `MarketPriceResult` type: `{ estimatedPrice: number, confidence: 'high' | 'medium' | 'low', source: string }`.
1.3. Implement `MockValuationAdapter` class that implements `IValuationAdapter` and returns deterministic mock prices based on vehicle attributes (e.g., base price by brand/model lookup table with depreciation by age and mileage).
1.4. Implement `MarketPriceService` in `srv/lib/market-price.ts` that:
   - Accepts a listing and calls the active `IValuationAdapter`
   - Computes the percentage difference: `((listingPrice - marketPrice) / marketPrice) * 100`
   - Returns a `MarketComparison` object: `{ position: 'below' | 'aligned' | 'above', percentageDiff: number, displayText: string }`
   - When adapter returns null, returns `{ position: 'unavailable', percentageDiff: null, displayText: 'Estimation non disponible' }`
1.5. Define thresholds: below = diff <= -5%, aligned = -5% < diff < 5%, above = diff >= 5%.
1.6. Wire adapter via dependency injection (factory pattern) so swapping to real provider requires only a new adapter implementation.
1.7. Write unit tests for MarketPriceService covering all positions (below, aligned, above, unavailable) and edge cases.

### Task 2: Backend - Certification & CT Filter Support (AC1)
2.1. Add `certificationLevel` (enum: 'tres_documente', 'bien_documente', 'partiellement_documente') and `ctValid` (Boolean) as filterable fields on the Listing entity in `srv/catalog-service.cds`.
2.2. Add `marketPricePosition` as a computed/virtual field on the Listing entity (not persisted, calculated at query time via MarketPriceService).
2.3. Implement custom `READ` handler logic in `srv/catalog-service.ts` to:
   - Support `$filter` on `certificationLevel` and `ctValid` (standard OData filters)
   - Support custom filter parameter `marketPosition=below|aligned|above` that post-filters results after market price computation
2.4. For market position filtering, compute market price for each listing in the result set and filter accordingly (acceptable for V1 with mock data; optimize with caching/materialized column for V2).
2.5. Write unit tests for certification level filtering, CT filtering, and market position filtering.

### Task 3: Frontend - Advanced Filter Section (AC1)
3.1. Extend `src/components/search/search-filters.tsx` to add an "Advanced Filters" expandable section below the basic filters.
3.2. Implement certification level filter as multi-select chips: "Tres documente", "Bien documente", "Partiellement documente" with color-coded visual indicators matching certification badge colors.
3.3. Implement CT valid filter as a toggle switch: "CT valide uniquement" (on/off).
3.4. Implement market price position filter as radio buttons or segmented control: "En dessous du marche", "Prix aligne", "Au-dessus du marche", "Tous".
3.5. Integrate these filters into the existing filter state management and URL parameter synchronization (from Story 4.2).
3.6. Add corresponding filter chips for active advanced filters in `filter-chips.tsx`.
3.7. Write component tests for each advanced filter control.

### Task 4: Frontend - Market Price Indicator on Listing Cards (AC2, AC3)
4.1. Create `src/components/listing/market-price-indicator.tsx` component that displays the market comparison:
   - Below market: green down-arrow icon + text "X% en dessous du marche" using `--market-below` design token color
   - Aligned: neutral icon + "Prix aligne" using `--market-aligned` design token color
   - Above market: orange up-arrow icon + "X% au-dessus du marche" using `--market-above` design token color
   - Unavailable: gray info icon + "Estimation non disponible"
4.2. Define CSS custom properties (design tokens) in the global stylesheet or design token file:
   - `--market-below: #16a34a` (green)
   - `--market-aligned: #6b7280` (neutral gray)
   - `--market-above: #ea580c` (orange)
4.3. Integrate the market price indicator into `listing-card.tsx` (conditionally rendered based on ConfigListingCard config).
4.4. Integrate the market price indicator into the listing detail page `src/app/(public)/listing/[slug]/page.tsx` in the price section.
4.5. Write component tests for all four states (below, aligned, above, unavailable).

### Task 5: Backend - Enrich Listing Responses with Market Price Data (AC2)
5.1. Add an `after READ` handler on the Listing entity in `srv/catalog-service.ts` that enriches each listing with `marketComparison` data by calling `MarketPriceService`.
5.2. Define the `marketComparison` as a virtual/transient field on the Listing entity projection in `catalog-service.cds` (not persisted in DB).
5.3. Implement caching of market price computations (in-memory cache with TTL of 1 hour) to avoid redundant calculations for the same listing within a session.
5.4. Ensure the enrichment works for both list (search results) and single (detail page) queries.
5.5. Write integration tests verifying enriched listing responses.

## Dev Notes

### Architecture & Patterns
- **Adapter pattern for valuation:** `IValuationAdapter` is the abstraction. `MockValuationAdapter` is the V1 implementation. When a real provider (e.g., Argus, La Centrale) is integrated, a new adapter class is created and swapped in via the factory. No other code changes needed.
- **Market price computation:** This is computed at query time for V1 (acceptable with mock adapter). For V2 with real API calls, consider materializing the market price position as a stored column updated periodically (cron job) to avoid API call overhead on every search.
- **Post-filtering for market position:** Since market position is computed (not stored), filtering by it requires fetching results and then post-filtering. For V1 with small datasets this is acceptable. For V2, store the position and filter at the DB level.
- **Design tokens for colors:** Market price colors are defined as CSS custom properties, not hardcoded hex values. This ensures theme consistency and makes future design changes centralized.
- **Graceful degradation:** When market price is unavailable, the UI still shows the indicator slot with "Estimation non disponible". The feature is never hidden; it gracefully degrades.

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend (SSR for public pages), PostgreSQL
- **Public pages:** src/app/(public)/ route group -- SSR for SEO (Server Components default)
- **Listing cards:** Configurable display via config tables (FR48 admin can configure what's shown on cards)
- **Search/filters:** OData $filter, $search on catalog-service, multi-criteria (budget, make, model, location, mileage, fuel type)
- **Certification filters:** Filter by certification level, valid CT, market price positioning
- **Market price:** lib/market-price.ts comparison logic, IValuationAdapter (mock V1)
- **SEO:** SSR pages, Schema.org structured data (Vehicle, Product, Offer), sitemap XML, semantic URLs (/listing/peugeot-3008-2022-marseille-{id})
- **Favorites:** Requires auth, stored in PostgreSQL
- **Cards:** listing-card.tsx component, configurable fields from config tables
- **Images:** Azure CDN + Next.js Image (lazy loading, responsive)
- **Infinite scroll:** For search results
- **Filters as chips:** Active filters visible, removable in one tap
- **Testing:** SSR pages need Lighthouse CI LCP <2.5s

### Naming Conventions
- Frontend: kebab-case files, PascalCase components
- SEO URLs: may contain French for SEO (/listing/peugeot-3008-2022-marseille-{id}) but route folders in English
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded card display fields (use config tables)
- SPA rendering for public pages (must be SSR)
- French in code/files

### Project Structure Notes
Frontend: src/app/(public)/listing/[slug]/page.tsx, src/app/(public)/search/page.tsx, src/components/listing/listing-card.tsx, src/components/search/search-filters.tsx
Backend: srv/catalog-service.cds + .ts, srv/lib/seo.ts, srv/lib/market-price.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-4/story-4.3-certification-market-price-filters.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
