# Story 4.5: SEO Pages & Structured Data

Status: ready-for-dev

## Story

As the platform,
I want every public listing page, search page, and landing page to be optimized for search engines,
so that buyers discover auto through organic search on Google.

## Acceptance Criteria (BDD)

**Given** a listing detail page is rendered (SSR) (FR18)
**When** a search engine crawls the page
**Then** the page has: semantic URL (`/listing/peugeot-3008-2022-marseille-{id}`), meta title and description from `ConfigSeoTemplate`, Open Graph tags for social sharing
**And** Schema.org structured data (Vehicle, Product, Offer) is embedded as JSON-LD (FR19)

**Given** search pages are rendered
**When** crawled by search engines
**Then** each search combination generates an indexable page with unique meta tags
**And** canonical URLs prevent duplicate content

**Given** the system needs SEO infrastructure
**When** the build process runs
**Then** a sitemap XML is auto-generated listing all public pages
**And** `robots.txt` is configurable via admin
**And** static landing pages (how it works, about, trust) are server-rendered

## Tasks / Subtasks

### Task 1: Backend - SEO Configuration Entities (AC1)
1.1. Define `ConfigSeoTemplate` CDS entity in `db/schema.cds` with fields:
   - `ID` (UUID)
   - `pageType` (enum: 'listing_detail', 'search_results', 'landing_page')
   - `titleTemplate` (String, e.g., "{brand} {model} {year} - {price} | auto")
   - `descriptionTemplate` (String, e.g., "{brand} {model} {year}, {mileage} km, {fuelType} - Certifie {certLevel} sur auto")
   - `ogTitleTemplate` (String)
   - `ogDescriptionTemplate` (String)
   - `isActive` (Boolean)
1.2. Seed default SEO templates for listing detail pages and search results pages in `db/data/` CSV files.
1.3. Expose `ConfigSeoTemplate` as read-only in `srv/catalog-service.cds` and as read-write in admin service.
1.4. Write unit tests for template retrieval.

### Task 2: Backend - SEO Utility Library (AC1, AC2)
2.1. Create `srv/lib/seo.ts` with the following functions:
   - `generateSlug(listing)`: generates semantic URL slug from listing data, e.g., `peugeot-3008-2022-marseille-{id}` (lowercase, diacritics removed, spaces to hyphens).
   - `renderTemplate(template, listing)`: replaces placeholders `{brand}`, `{model}`, `{year}`, `{price}`, `{mileage}`, `{fuelType}`, `{certLevel}`, `{city}` with actual listing values.
   - `generateCanonicalUrl(searchParams)`: generates a canonical URL for search pages by normalizing and sorting query parameters to prevent duplicate content.
   - `generateStructuredData(listing)`: returns Schema.org JSON-LD object combining Vehicle, Product, and Offer schemas.
2.2. Implement `generateStructuredData` according to Schema.org specs:
   - `Vehicle` type: `brand`, `model`, `vehicleModelDate`, `mileageFromOdometer`, `fuelType`, `vehicleTransmission`, `color`, `vehicleIdentificationNumber` (if available)
   - `Product` type wrapper: `name`, `description`, `image`, `brand`
   - `Offer` type: `price`, `priceCurrency` (EUR), `availability` (InStock/SoldOut), `seller`
2.3. Expose a function import `getListingSeoData(listingId)` in the catalog-service that returns the complete SEO data (slug, meta tags, structured data) for a listing.
2.4. Write thorough unit tests for slug generation (special characters, diacritics, long names), template rendering, canonical URL generation, and structured data output validation.

### Task 3: Frontend - Semantic URLs & Routing (AC1)
3.1. Update `src/app/(public)/listing/[slug]/page.tsx` to parse the listing ID from the slug (last segment after final hyphen: `peugeot-3008-2022-marseille-abc123` -> ID = `abc123`).
3.2. Implement slug validation: fetch the listing by ID, regenerate the expected slug, and if the URL slug does not match (e.g., listing was renamed), issue a 301 redirect to the canonical slug URL.
3.3. Update all internal links to listings (in listing cards, search results, favorites) to use the semantic slug URL instead of bare IDs.
3.4. Write tests for slug parsing, redirect behavior on stale slugs, and 404 on invalid IDs.

### Task 4: Frontend - Meta Tags & Open Graph (AC1, AC2)
4.1. Implement Next.js `generateMetadata()` function in `src/app/(public)/listing/[slug]/page.tsx`:
   - Fetch SEO data from catalog-service `getListingSeoData()` endpoint
   - Set `title`, `description` from rendered `ConfigSeoTemplate`
   - Set Open Graph tags: `og:title`, `og:description`, `og:image` (hero photo CDN URL), `og:url` (canonical), `og:type` (product)
   - Set Twitter card tags: `twitter:card` (summary_large_image), `twitter:title`, `twitter:description`, `twitter:image`
4.2. Implement `generateMetadata()` in `src/app/(public)/search/page.tsx`:
   - Generate unique meta title/description based on active search filters (e.g., "Peugeot 3008 d'occasion a Marseille | auto")
   - Set canonical URL using `generateCanonicalUrl()` to normalize filter parameter order
4.3. Add `<link rel="canonical">` to both listing detail and search pages.
4.4. Write tests verifying meta tag output for listing pages and filtered search pages.

### Task 5: Frontend - Schema.org Structured Data as JSON-LD (AC1)
5.1. Create `src/components/seo/json-ld.tsx` Server Component that renders a `<script type="application/ld+json">` tag with the structured data.
5.2. Integrate `json-ld.tsx` into the listing detail page, passing the structured data object from the backend.
5.3. Validate the JSON-LD output against Google's Rich Results Test format requirements:
   - Vehicle schema with required fields
   - Product schema with Offer
   - Correct `@context` and `@type` annotations
5.4. Write tests verifying JSON-LD output structure and content.

### Task 6: Sitemap XML Generation (AC3)
6.1. Create `src/app/sitemap.ts` (Next.js App Router sitemap route) that:
   - Fetches all published listing slugs from the catalog-service
   - Fetches all valid search filter combination landing pages (top brands, top cities)
   - Includes static pages: homepage, how-it-works, about, trust/security
   - Returns a `MetadataRoute.Sitemap` array with `url`, `lastModified`, `changeFrequency`, `priority`
6.2. Set priorities: homepage = 1.0, listing details = 0.8, search pages = 0.6, static pages = 0.5.
6.3. Set change frequencies: listing details = 'daily', search pages = 'daily', static pages = 'monthly'.
6.4. Ensure the sitemap handles large numbers of listings (pagination/streaming if > 50,000 URLs, as per sitemap protocol limit).
6.5. Write tests verifying sitemap output format and content.

### Task 7: Robots.txt Configuration (AC3)
7.1. Create `src/app/robots.ts` (Next.js App Router robots route) that generates `robots.txt`.
7.2. Default rules: allow all crawlers for public pages, disallow authenticated routes (`/favorites`, `/dashboard`, `/api/`).
7.3. Reference the sitemap URL in robots.txt.
7.4. Store configurable overrides in `ConfigSeoTemplate` or a dedicated `ConfigRobotsTxt` entity so admins can modify rules without code changes.
7.5. Write tests verifying robots.txt output.

### Task 8: Static Landing Pages (AC3)
8.1. Create SSR landing pages as Server Components:
   - `src/app/(public)/how-it-works/page.tsx` - How the platform works
   - `src/app/(public)/about/page.tsx` - About the platform
   - `src/app/(public)/trust/page.tsx` - Trust & security information
8.2. Implement `generateMetadata()` for each landing page with appropriate SEO meta tags.
8.3. Ensure all landing pages are included in the sitemap.
8.4. Write basic rendering tests for each landing page.

## Dev Notes

### Architecture & Patterns
- **SSR is mandatory for all public pages:** Every page in the `(public)` route group must be a Server Component (or use Server Components for the page-level component) to ensure search engines receive fully rendered HTML. No client-side-only rendering for public pages.
- **Semantic URL pattern:** `/listing/{brand}-{model}-{year}-{city}-{id}`. The ID is always the last segment, making parsing deterministic. French characters (accents) are stripped during slug generation. The slug is regenerated on each request to handle listing data changes (with 301 redirect if the URL is stale).
- **ConfigSeoTemplate as template engine:** Templates use `{placeholder}` syntax. The `renderTemplate()` function replaces placeholders with actual values. This allows admins to customize SEO text without code changes.
- **Canonical URLs for search pages:** Search filter parameters are sorted alphabetically in the canonical URL to prevent Google from indexing duplicate pages (e.g., `?brand=peugeot&maxPrice=15000` and `?maxPrice=15000&brand=peugeot` resolve to the same canonical).
- **JSON-LD for structured data:** Schema.org data is embedded as JSON-LD (not microdata or RDFa) because it is the format Google recommends and does not interfere with HTML structure.
- **Sitemap scalability:** If the listing count exceeds 50,000, the sitemap must be split into sitemap index + multiple sitemap files per the sitemap protocol specification.

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
Frontend: src/app/(public)/listing/[slug]/page.tsx, src/app/(public)/search/page.tsx, src/components/listing/listing-card.tsx, src/components/search/search-filters.tsx, src/components/seo/json-ld.tsx, src/app/sitemap.ts, src/app/robots.ts, src/app/(public)/how-it-works/page.tsx, src/app/(public)/about/page.tsx, src/app/(public)/trust/page.tsx
Backend: srv/catalog-service.cds + .ts, srv/lib/seo.ts, srv/lib/market-price.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-4/story-4.5-seo-pages-structured-data.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
