# Story 4.3: Certification & Market Price Filters

Status: review

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

### Task 1: Backend - Market Price Comparison Logic (AC2, AC3) ✅
- [x] 1.1. `IValuationAdapter` already exists from Story 3-1; reused via adapter factory
- [x] 1.2. `ValuationResponse` type already exists in `@auto/shared`; added `MarketComparison`, `MarketPricePosition` types
- [x] 1.3. `MockValuationAdapter` already exists from Story 3-1; reused
- [x] 1.4. Implemented `computeMarketComparison()` in `srv/lib/market-price.ts`
- [x] 1.5. Thresholds defined as `MARKET_PRICE_THRESHOLDS` in `@auto/shared/constants`
- [x] 1.6. Wired via existing adapter factory pattern (`getValuation()`)
- [x] 1.7. 32 unit tests (26 core + 6 cache) — all pass

### Task 2: Backend - Certification & CT Filter Support (AC1) ✅
- [x] 2.1. Added `certificationLevel` and `ctValid` fields to Listing CDS entity and projection
- [x] 2.2. Market position computed at query time via `computeMarketComparison()`
- [x] 2.3. Added certification/ctValid DB filters and marketPosition post-filter in catalog handler
- [x] 2.4. Post-filtering implemented for V1 (acceptable per dev notes)
- [x] 2.5. 6 new unit tests in catalog-handler — 50 total pass

### Task 3: Frontend - Advanced Filter Section (AC1) ✅
- [x] 3.1. Added expandable "Filtres avancés" section with ChevronDown/Up toggle
- [x] 3.2. Certification level multi-select chips with color-coded indicators
- [x] 3.3. CT valid toggle switch with accessible custom component
- [x] 3.4. Market position select dropdown
- [x] 3.5. Integrated into URL param state (cert, ctValid, market param keys)
- [x] 3.6. Filter chips for certification, CT valid, market position
- [x] 3.7. 8 new search-filters tests + 6 new filter-chips tests + 14 new search-params tests

### Task 4: Frontend - Market Price Indicator on Listing Cards (AC2, AC3) ✅
- [x] 4.1. Created `market-price-indicator.tsx` with TrendingDown/Minus/TrendingUp/Info icons
- [x] 4.2. Design tokens updated: `--market-aligned` (gray), `--market-above` (orange)
- [x] 4.3. Integrated into `listing-card.tsx` below price display
- [x] 4.4. Integrated into `listing-detail-client.tsx` in price section
- [x] 4.5. 7 component tests — all pass

### Task 5: Backend - Enrich Listing Responses with Market Price Data (AC2) ✅
- [x] 5.1. Enrichment added in `handleGetListings` and `handleGetListingDetail` handlers
- [x] 5.2. `marketComparison` defined in `IPublicListingCard` and `IPublicListingDetail` DTOs
- [x] 5.3. In-memory cache with 1-hour TTL implemented in `srv/lib/market-price.ts`
- [x] 5.4. Enrichment works for both list and detail queries
- [x] 5.5. 16 integration tests in `market-price-enrichment-integration.test.ts` — all pass

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
Claude Opus 4.6

### Completion Notes List
- Reused existing `IValuationAdapter` / `MockValuationAdapter` / adapter factory from Story 3-1 (no duplication)
- Added `MarketComparison`, `MarketPricePosition`, `CertificationLevel` types to `@auto/shared`
- Market price comparison computed at query time with in-memory cache (1-hour TTL)
- Market position filtering is post-filter (acceptable for V1 per dev notes)
- Design tokens updated: `--market-aligned` to neutral gray, `--market-above` to orange
- All 2991 tests green across 3 repos (433 shared + 1229 backend + 1329 frontend)

### Change Log
| Repo | File | Change |
|------|------|--------|
| auto-shared | src/types/listing.ts | Added `MarketPricePosition`, `MarketComparison`, `CertificationLevel` types; extended `IPublicListingCard`, `IPublicListingDetail`, `ISearchFilters` |
| auto-shared | src/types/index.ts | Added exports for new types |
| auto-shared | src/constants/listing.ts | Added `MARKET_PRICE_THRESHOLDS`, `CERTIFICATION_LEVELS`, `CERTIFICATION_LEVEL_THRESHOLDS` |
| auto-shared | src/constants/index.ts | Added exports for new constants |
| auto-backend | srv/lib/market-price.ts | **NEW** — `computeMarketComparison()`, `classifyPosition()`, `formatDisplayText()`, in-memory cache with TTL |
| auto-backend | db/schema/listing.cds | Added `certificationLevel`, `ctValid` fields to Listing entity |
| auto-backend | srv/catalog-service.cds | Added new fields to Listings projection and `getListings` action params |
| auto-backend | srv/handlers/catalog-handler.ts | Added certification/CT/market filters, market comparison enrichment |
| auto-backend | test/srv/lib/market-price.test.ts | **NEW** — 32 unit tests (classification, formatting, computation, caching) |
| auto-backend | test/srv/handlers/catalog-handler.test.ts | Updated fixtures + 6 new filter tests |
| auto-backend | test/srv/handlers/market-price-enrichment-integration.test.ts | **NEW** — 16 integration tests |
| auto-frontend | src/lib/search-params.ts | Added cert/ctValid/market param keys, parsing, serialization |
| auto-frontend | src/lib/api/catalog-api.ts | Added new filter params to `buildListingsBody()` |
| auto-frontend | src/components/search/search-filters.tsx | Added AdvancedFilters expandable section with cert/CT/market controls |
| auto-frontend | src/components/search/filter-chips.tsx | Added chips for certification, CT valid, market position |
| auto-frontend | src/components/listing/market-price-indicator.tsx | **NEW** — Market price indicator component with design tokens |
| auto-frontend | src/components/listing/listing-card.tsx | Integrated `MarketPriceIndicator` |
| auto-frontend | src/app/(public)/listings/[id]/listing-detail-client.tsx | Integrated `MarketPriceIndicator` |
| auto-frontend | src/app/globals.css | Updated `--market-aligned`, `--market-above` design tokens |
| auto-frontend | tests/lib/search-params.test.ts | 14 new tests for advanced filter parsing/serialization/counting |
| auto-frontend | tests/components/search/search-filters.test.tsx | 8 new tests for advanced filter controls |
| auto-frontend | tests/components/search/filter-chips.test.tsx | 6 new tests for advanced filter chips |
| auto-frontend | tests/components/listing/market-price-indicator.test.tsx | **NEW** — 7 component tests |

### File List
**auto-shared:**
- src/types/listing.ts
- src/types/index.ts
- src/constants/listing.ts
- src/constants/index.ts

**auto-backend:**
- srv/lib/market-price.ts (NEW)
- db/schema/listing.cds
- srv/catalog-service.cds
- srv/handlers/catalog-handler.ts
- test/srv/lib/market-price.test.ts (NEW)
- test/srv/handlers/catalog-handler.test.ts
- test/srv/handlers/market-price-enrichment-integration.test.ts (NEW)

**auto-frontend:**
- src/lib/search-params.ts
- src/lib/api/catalog-api.ts
- src/components/search/search-filters.tsx
- src/components/search/filter-chips.tsx
- src/components/listing/market-price-indicator.tsx (NEW)
- src/components/listing/listing-card.tsx
- src/app/(public)/listings/[id]/listing-detail-client.tsx
- src/app/globals.css
- tests/lib/search-params.test.ts
- tests/components/search/search-filters.test.tsx
- tests/components/search/filter-chips.test.tsx
- tests/components/listing/market-price-indicator.test.tsx (NEW)
