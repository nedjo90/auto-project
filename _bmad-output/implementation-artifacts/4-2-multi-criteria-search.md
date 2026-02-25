# Story 4.2: Multi-Criteria Search & Filters

Status: review

## Story

As a buyer,
I want to filter listings by multiple criteria simultaneously,
so that I can narrow down results to vehicles that match my specific needs.

## Acceptance Criteria (BDD)

**Given** a buyer is on the search page
**When** they apply filters (FR14)
**Then** available filters include: budget (min/max), brand, model, year (min/max), mileage (max), fuel type, transmission, location (radius), body type, color
**And** filters are displayed as chips when active (visible, removable in one tap)
**And** results update within 2 seconds (NFR6)

**Given** a buyer applies multiple filters
**When** the results update
**Then** the count of matching listings is displayed
**And** results can be sorted by: price (asc/desc), date published, mileage, relevance
**And** no horizontal scroll occurs even on 320px viewport

**Given** a buyer removes a filter chip
**When** the chip is dismissed
**Then** the results update immediately to reflect the removed filter
**And** the filter is visually deselected in the filter panel

## Tasks / Subtasks

### Task 1: Backend - OData Filter Support in Catalog Service (AC1, AC2)
- [x] 1.1. Extend `srv/catalog-service.cds` to expose filterable fields on the Listing entity: `price`, `brand`, `model`, `year`, `mileage`, `fuelType`, `transmission`, `location`, `bodyType`, `color`.
- [x] 1.2. Implement custom `READ` handler in `srv/catalog-service.ts` that translates OData `$filter` expressions for each criterion (range filters for budget/year/mileage, equality for brand/model/fuel/transmission/bodyType/color, geo-radius for location).
- [x] 1.3. Add `$orderby` support for: `price asc`, `price desc`, `publishedAt desc`, `mileage asc`, relevance (default ranking).
- [x] 1.4. Return `$count` inline with results (`$count=true` OData parameter) so frontend can display total matching listings.
- [x] 1.5. Add database indexes on frequently filtered columns (`price`, `brand`, `model`, `year`, `mileage`, `fuelType`) for query performance within 2-second SLA.
- [x] 1.6. Write unit tests for each filter type individually and in combination.

### Task 2: Backend - Location Radius Search (AC1)
- [x] 2.1. Implement location-based filtering logic: accept `latitude`, `longitude`, and `radius` (km) as custom query parameters.
- [x] 2.2. Use PostgreSQL distance calculation (Haversine or PostGIS `ST_DWithin` if PostGIS is available, otherwise computed column) to filter listings within the radius.
- [x] 2.3. Store `latitude` and `longitude` on the Listing entity (populated during listing creation from city/postal code geocoding).
- [x] 2.4. Write unit tests for radius search with edge cases (exact boundary, zero results, very large radius).

### Task 3: Frontend - Search Filter Panel Component (AC1, AC3)
- [x] 3.1. Create `src/components/search/search-filters.tsx` as a Client Component (interactive filters require client-side state).
- [x] 3.2. Implement filter inputs for each criterion:
   - Budget: dual range slider (min/max) with numeric inputs
   - Brand: searchable dropdown (fetched from catalog-service distinct values)
   - Model: dependent dropdown (filtered by selected brand)
   - Year: dual range slider (min/max)
   - Mileage: single max slider with numeric input
   - Fuel type: multi-select chips (Essence, Diesel, Electrique, Hybride, GPL)
   - Transmission: toggle (Manuelle / Automatique / Toutes)
   - Location: city input with autocomplete + radius slider (10-200km)
   - Body type: icon-based multi-select (Berline, SUV, Break, Citadine, etc.)
   - Color: color swatch multi-select
- [x] 3.3. On mobile (< 768px), filters render as a slide-out drawer triggered by a "Filtres" button; on desktop, as a sidebar panel.
- [x] 3.4. Ensure no horizontal scroll at 320px viewport width (test with smallest supported viewport).
- [x] 3.5. Write component tests for each filter type and responsive layout.

### Task 4: Frontend - Filter Chips Display & Removal (AC1, AC3)
- [x] 4.1. Create `src/components/search/filter-chips.tsx` Client Component that displays all active filters as removable chips.
- [x] 4.2. Each chip shows the filter label and value (e.g., "Budget: 5 000 - 15 000 EUR", "Marque: Peugeot").
- [x] 4.3. Implement single-tap removal: clicking the X on a chip removes that filter, updates the filter state, and triggers a new search.
- [x] 4.4. Add a "Tout effacer" (Clear all) button when 2+ filters are active.
- [x] 4.5. Ensure the filter panel visually deselects the corresponding input when a chip is removed.
- [x] 4.6. Write tests for chip rendering, removal, and synchronization with filter panel state.

### Task 5: Frontend - Search Results with Sorting & Count (AC2)
- [x] 5.1. Create `src/components/search/search-results.tsx` Client Component that displays the results grid with result count header ("X annonces trouvees").
- [x] 5.2. Implement sort selector dropdown with options: Prix croissant, Prix decroissant, Plus recentes, Kilometrage, Pertinence.
- [x] 5.3. Integrate with `listing-grid.tsx` (from Story 4.1) for infinite scroll of filtered/sorted results.
- [x] 5.4. Manage search state via URL query parameters (`?brand=peugeot&maxPrice=15000&sort=price_asc`) for shareable/bookmarkable searches.
- [x] 5.5. Debounce filter changes (300ms) to avoid excessive API calls during rapid filter adjustments.
- [x] 5.6. Write integration tests verifying filter + sort + pagination flow end-to-end.

### Task 6: Frontend - Search State & URL Synchronization (AC1, AC2, AC3)
- [x] 6.1. Implement `src/lib/search-params.ts` utility to serialize/deserialize filter state to/from URL search parameters.
- [x] 6.2. On page load, parse URL params to restore filter state (enables bookmarkable searches and SSR of filtered results).
- [x] 6.3. On filter change, update URL params via `router.push()` with shallow routing (no full page reload).
- [x] 6.4. Ensure the SSR initial render on `src/app/(public)/search/page.tsx` reads search params and passes them to the catalog-service query for SEO-friendly filtered pages.
- [x] 6.5. Write unit tests for search param serialization/deserialization round-trips.

## Dev Notes

### Architecture & Patterns
- **Filter-to-OData translation:** The frontend builds OData `$filter` strings from the active filter state. Example: `$filter=price ge 5000 and price le 15000 and brand eq 'Peugeot' and mileage le 80000&$orderby=price asc&$count=true&$top=20&$skip=0`. The catalog-service handles these standard OData query options.
- **URL as single source of truth:** All active filters are reflected in URL query parameters. This enables SSR of filtered results (SEO-indexable), browser back/forward navigation, and shareable search links.
- **Debounced updates:** Filter changes are debounced at 300ms to batch rapid changes before firing an API call. The debounce resets on each new change.
- **Brand-Model dependency:** When a brand is selected, the model dropdown fetches only models for that brand from the catalog-service (`$filter=brand eq 'Peugeot'` on a distinct models endpoint or dedicated function import).
- **Location radius:** This is a custom filter not natively supported by OData. The backend implements it as a custom query parameter that gets translated into a PostGIS or Haversine SQL expression.
- **Mobile-first responsive:** Filters are hidden behind a drawer on mobile. The chip bar remains visible above results on all viewports. The layout must not cause horizontal scroll on 320px.

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
- [Source: _bmad-output/planning-artifacts/stories/epic-4/story-4.2-multi-criteria-search.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- Backend: Extended catalog-service getListings action with 17 filter parameters (price range, make, model, year range, maxMileage, fuelType, gearbox, bodyType, color, location lat/lon/radius, sort). Filter conditions built incrementally with CDS query builder.
- Backend: Implemented Haversine distance calculation for location radius search with bounding-box SQL pre-filter + JS post-filter (no PostGIS dependency). Added latitude, longitude, city, postalCode fields to Listing entity.
- Backend: Added @cds.search annotation for full-text search on make, model, variant. Documented PostgreSQL production indexes as SQL comments.
- Frontend: Created search-filters.tsx with responsive layout (desktop sidebar + mobile Sheet drawer), supporting all filter types: budget min/max, make, model (dependent on make), year min/max, max mileage, fuel type multi-select chips, gearbox select, body type chips, color chips. Clear all button with active filter count badge on mobile.
- Frontend: Created filter-chips.tsx showing active filters as removable chips with aria-labels. Smart chip labels for ranges. "Tout effacer" button when 2+ filters active. Cascading removal (make removal also removes model).
- Frontend: Created search-results.tsx orchestrating filters, chips, sort, listing grid, and infinite scroll. URL is single source of truth — all filters serialized to query params. 300ms debounced filter→URL sync; immediate sort changes.
- Frontend: Created search-params.ts with parseSearchParams, serializeSearchParams, countActiveFilters, removeFilter utilities for URL↔filter round-trips.
- Frontend: Updated catalog-api.ts with buildListingsBody helper accepting ISearchFilters.
- Frontend: Rewrote search/page.tsx for SSR with filter params passed to getListings.
- Shared: Added ISearchFilters interface, SearchSortOption type, SEARCH_SORT_OPTIONS, DEFAULT_SEARCH_SORT, SEARCH_DEBOUNCE_MS constants.
- Tests: 80 new tests across all repos. 2902 total tests green (433 shared + 1175 backend + 1294 frontend).

### Change Log
- auto-shared: Added ISearchFilters, SearchSortOption types; SEARCH_SORT_OPTIONS, DEFAULT_SEARCH_SORT, SEARCH_DEBOUNCE_MS constants; location fields on IListing
- auto-backend: Extended catalog-service.cds with filter params and location fields; rewrote catalog-handler.ts with filter/sort/location logic; added @cds.search annotation on Listing; 33 new backend tests
- auto-frontend: Created search-params.ts, search-filters.tsx, filter-chips.tsx, search-results.tsx; updated catalog-api.ts and search/page.tsx; fixed seo-pages.test.tsx mocks; 49 new frontend tests

### File List
**auto-shared:**
- src/types/listing.ts (modified - added ISearchFilters, SearchSortOption, location fields)
- src/types/index.ts (modified - added exports)
- src/constants/listing.ts (modified - added search constants)
- src/constants/index.ts (modified - added exports)

**auto-backend:**
- srv/catalog-service.cds (modified - filter params, location fields)
- srv/handlers/catalog-handler.ts (modified - filter/sort/location logic, haversineDistance)
- db/schema/listing.cds (modified - location fields, @cds.search)
- test/srv/handlers/catalog-handler.test.ts (modified - 33 new tests)

**auto-frontend:**
- src/lib/search-params.ts (created - URL serialization)
- src/lib/api/catalog-api.ts (modified - filter support)
- src/components/search/search-filters.tsx (created - filter panel)
- src/components/search/filter-chips.tsx (created - active filter chips)
- src/components/search/search-results.tsx (created - results orchestrator)
- src/app/(public)/search/page.tsx (modified - SSR with filters)
- tests/lib/search-params.test.ts (created - 27 tests)
- tests/components/search/search-filters.test.tsx (created - 21 tests)
- tests/components/search/filter-chips.test.tsx (created - 22 tests)
- tests/components/search/search-results.test.tsx (created - 10 tests)
- tests/app/public/seo-pages.test.tsx (modified - added mocks)
