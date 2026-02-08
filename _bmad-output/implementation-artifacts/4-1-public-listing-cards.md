# Story 4.1: Public Listing Browsing & Configurable Cards

Status: ready-for-dev

## Story

As a buyer,
I want to browse published listings displayed as visually rich cards with key information at a glance,
so that I can quickly scan multiple vehicles and identify the ones worth investigating.

## Acceptance Criteria (BDD)

**Given** a visitor accesses the marketplace homepage or search page
**When** the page loads (SSR) (FR13)
**Then** published listings are displayed as cards with: hero photo, price, key specs (brand, model, year, mileage, fuel), certification level indicator, location
**And** the fields displayed on cards are configurable by admin via `ConfigListingCard` (FR20)
**And** cards use the listing-card component with configurable 4-7 fields without breaking layout (elastic design)

**Given** listing cards are rendered
**When** the page is measured for performance
**Then** LCP < 2.5s, INP < 200ms, CLS < 0.1, TTFB < 800ms (NFR1)
**And** images use lazy loading with skeleton placeholders during load
**And** the page uses infinite scroll for loading more results

**Given** a visitor clicks on a listing card
**When** the listing detail page loads (SSR)
**Then** the full listing is displayed with: photo gallery (60% desktop / full-width mobile), all fields with green/yellow badges, certification level label, price market comparison, seller profile, contact button
**And** the layout follows the UX spec: gallery + info split on desktop, stacked on mobile, sticky contact bar

## Tasks / Subtasks

### Task 1: Backend - ConfigListingCard Entity & Service (AC1)
1.1. Define `ConfigListingCard` CDS entity in `db/schema.cds` with fields: `fieldName` (String), `displayOrder` (Integer), `isVisible` (Boolean), `label_fr` (String), `label_en` (String), `fieldType` (enum: text, badge, price, location).
1.2. Expose `ConfigListingCard` as a read-only entity in `srv/catalog-service.cds` for public consumption and as read-write in an admin service.
1.3. Seed default card configuration data (hero photo, price, brand/model, year, mileage, fuel type, certification level, location) in `db/data/` CSV files.
1.4. Add service handler in `srv/catalog-service.ts` to return published listings with pagination support (`$top`, `$skip`) for infinite scroll.
1.5. Write unit tests for the catalog service listing query and config retrieval.

### Task 2: Frontend - Listing Card Component (AC1, AC2)
2.1. Create `src/components/listing/listing-card.tsx` as a Server Component that accepts a listing object and card config array.
2.2. Implement elastic layout that supports 4-7 configurable fields from `ConfigListingCard` without breaking layout (use CSS Grid or Flexbox with dynamic slots).
2.3. Render hero photo using Next.js `<Image>` component with `priority` for above-the-fold cards, `loading="lazy"` for below-fold cards.
2.4. Implement skeleton placeholder component `src/components/listing/listing-card-skeleton.tsx` for loading states.
2.5. Display certification level indicator (color-coded badge) and location on each card.
2.6. Write component unit tests verifying rendering with 4, 5, 6, and 7 fields.

### Task 3: Frontend - Search/Browse Page with Infinite Scroll (AC1, AC2)
3.1. Create `src/app/(public)/search/page.tsx` as a Server Component for initial SSR load of first page of listings.
3.2. Create `src/components/search/listing-grid.tsx` Client Component that handles infinite scroll using `IntersectionObserver`.
3.3. Implement pagination: initial SSR page renders first 20 results, client-side fetches next pages on scroll via `fetch()` to catalog-service OData endpoint.
3.4. Fetch `ConfigListingCard` data server-side and pass to listing card components.
3.5. Ensure no layout shift during infinite scroll loading (reserve space with skeleton cards).
3.6. Write integration tests for the search page SSR rendering and infinite scroll behavior.

### Task 4: Frontend - Listing Detail Page (AC3)
4.1. Create `src/app/(public)/listing/[slug]/page.tsx` as a Server Component that fetches full listing data by ID extracted from slug.
4.2. Implement photo gallery component `src/components/listing/photo-gallery.tsx`: 60% width on desktop, full-width on mobile, swipeable, thumbnail strip.
4.3. Display all listing fields with appropriate badges (green/yellow indicators for certification status).
4.4. Add certification level label section with visual styling per level.
4.5. Add price market comparison section (placeholder for Story 4.3 integration).
4.6. Implement seller profile card and contact button with sticky contact bar on mobile.
4.7. Implement responsive layout: gallery + info split on desktop (CSS Grid 60/40), stacked on mobile.
4.8. Write unit and integration tests for detail page rendering.

### Task 5: Performance Optimization (AC2)
5.1. Configure Next.js `<Image>` with Azure CDN domain in `next.config.ts` `images.remotePatterns`.
5.2. Set appropriate image sizes and `srcSet` for responsive images (card thumbnail: 400w, gallery: 800w/1200w).
5.3. Implement resource hints: `preconnect` to CDN domain, `prefetch` for likely next pages.
5.4. Add Lighthouse CI configuration targeting LCP < 2.5s, INP < 200ms, CLS < 0.1, TTFB < 800ms.
5.5. Run Lighthouse CI and iterate on performance bottlenecks until targets are met.

### Task 6: Image Handling & Optimization (AC2)
6.1. Implement image URL builder utility `src/lib/image-url.ts` that constructs Azure CDN URLs with appropriate transformations (resize, format).
6.2. Set `sizes` attribute on card images for correct responsive behavior.
6.3. Use WebP format via CDN transformation where supported.
6.4. Verify lazy loading behavior: only above-the-fold images load eagerly; below-fold images load on scroll.

## Dev Notes

### Architecture & Patterns
- **SSR-first approach:** All public pages are Server Components by default within the `(public)` route group. This is critical for SEO and Core Web Vitals compliance.
- **Configurable card fields:** The `ConfigListingCard` entity drives which fields appear on listing cards. The admin can configure 4-7 fields. The `listing-card.tsx` component must dynamically render fields based on this config, using an elastic CSS layout that does not break regardless of field count.
- **Infinite scroll pattern:** First page is SSR-rendered (hydrated). Subsequent pages are fetched client-side using a Client Component wrapper (`listing-grid.tsx`) that observes a sentinel element via `IntersectionObserver`. Skeleton placeholders prevent CLS during loading.
- **Image optimization:** Azure CDN serves images. Next.js `<Image>` handles responsive `srcSet`, lazy loading, and format negotiation. The CDN domain must be allowlisted in `next.config.ts`.
- **Listing detail split layout:** Desktop uses a 60/40 grid (gallery / info). Mobile stacks vertically with a sticky contact bar at the bottom.

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
- [Source: _bmad-output/planning-artifacts/stories/epic-4/story-4.1-public-listing-cards.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
