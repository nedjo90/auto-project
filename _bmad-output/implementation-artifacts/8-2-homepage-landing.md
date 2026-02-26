# Story 8.2: Homepage & Landing Page

Status: done

## Story

As a visitor arriving on the homepage,
I want to see an attractive storefront with a search bar, featured listings, and trust indicators,
so that I understand the platform's value and can start searching for a vehicle immediately.

## Acceptance Criteria (BDD)

**AC-HOME-01: Hero section with search**
**Given** a visitor arrives on `/`
**When** the page loads
**Then**:
- A hero section displays with Lora display typography (display-xl on desktop, display-lg on mobile)
- A subtitle explains the value proposition ("Annonces verifiees. Donnees certifiees. Transparence totale.")
- A quick search bar is visible (marque, modele, ville, budget fields)
- A primary CTA "Rechercher un vehicule" submits the search and navigates to `/search`
- A secondary CTA "Vendre mon vehicule" navigates to `/register` (not authenticated) or `/seller/publish` (authenticated)

**AC-HOME-02: Trust strip**
**Given** the hero section is visible
**When** the visitor scrolls slightly
**Then** a trust strip displays 3-4 indicators:
- "Donnees certifiees" (shield icon)
- "Historique verifie" (document icon)
- "Paiement securise" (lock icon)
- Optionally: "X annonces actives" (dynamic count from API or static placeholder)

**AC-HOME-03: Featured listings**
**Given** active listings exist in the database (seed data from 8-1)
**When** the page loads
**Then**:
- A "Annonces recentes" section displays 6-8 listing cards (reuse existing ListingCard component)
- Cards are clickable and navigate to `/listing/[slug]`
- A "Voir toutes les annonces" button navigates to `/search`
- If no listings exist, a graceful empty state is shown ("Aucune annonce pour le moment")

**AC-HOME-04: How it works section**
**Given** the page is loaded
**When** the visitor scrolls
**Then** a "Comment ca marche" section displays 3 steps:
1. "Recherchez" — browse verified listings with icon
2. "Comparez" — certified data + history report with icon
3. "Contactez" — direct messaging with seller with icon

**AC-HOME-05: Seller CTA section**
**Given** the page is loaded
**When** the visitor scrolls
**Then** a "Vendez votre vehicule" section displays:
- An engaging title
- 3 seller benefits (auto-fill in 3s, real-time visibility score, qualified audience)
- CTA "Publier une annonce" navigating to `/register` or `/seller/publish`

**AC-HOME-06: Responsive design**
**Given** the homepage on mobile (< 640px)
**When** the page loads
**Then**:
- Hero: display-lg title, search inputs stacked vertically
- Featured listings: horizontal scroll or single-column grid
- Sections stacked vertically with responsive spacing
- Compliant with `responsive-design-standards.md`

**AC-HOME-07: SEO metadata**
**Given** the homepage is rendered
**When** search engines crawl the page
**Then**:
- Page has proper title, description meta tags
- Open Graph tags for social sharing
- Schema.org WebSite structured data with SearchAction

## Tasks / Subtasks

### T1: Frontend - Hero Section (AC-HOME-01)
- [x] T1.1: Create `src/components/home/hero-section.tsx` with Lora display title, subtitle, responsive layout
- [x] T1.2: Implement quick search form (marque select, modele select, ville input, budget range) that navigates to `/search?brand=X&model=Y&city=Z&maxPrice=N`
- [x] T1.3: Implement dual CTAs with auth-aware logic (useAuth hook for seller CTA destination)
- [x] T1.4: Write unit tests for HeroSection (rendering, search form submission, CTA auth logic)

### T2: Frontend - Trust Strip (AC-HOME-02)
- [x] T2.1: Create `src/components/home/trust-strip.tsx` with 3-4 trust indicators using lucide-react icons
- [x] T2.2: Optional: fetch active listing count from API or display static value
- [x] T2.3: Write unit tests for TrustStrip

### T3: Frontend - Featured Listings (AC-HOME-03)
- [x] T3.1: Create `src/components/home/featured-listings.tsx` that fetches recent active listings via existing search API (`?sort=createdAt_desc&limit=8&status=active`)
- [x] T3.2: Reuse existing `ListingCard` component for display
- [x] T3.3: Implement empty state fallback if no listings exist
- [x] T3.4: Add "Voir toutes les annonces" link to `/search`
- [x] T3.5: Write unit tests with mocked API response (with data, empty)

### T4: Frontend - How It Works Section (AC-HOME-04)
- [x] T4.1: Create `src/components/home/how-it-works-section.tsx` with 3-step card layout
- [x] T4.2: Use consistent icons from lucide-react
- [x] T4.3: Write unit tests for HowItWorksSection

### T5: Frontend - Seller CTA Section (AC-HOME-05)
- [x] T5.1: Create `src/components/home/seller-cta-section.tsx` with benefits list and auth-aware CTA
- [x] T5.2: Write unit tests for SellerCtaSection

### T6: Frontend - Page Assembly & SEO (AC-HOME-06, AC-HOME-07)
- [x] T6.1: Rewrite `src/app/(public)/page.tsx` to assemble all sections (Hero, TrustStrip, FeaturedListings, HowItWorks, SellerCTA)
- [x] T6.2: Add Next.js metadata export (title, description, openGraph)
- [x] T6.3: Add Schema.org WebSite JSON-LD with SearchAction
- [x] T6.4: Responsive: verify all breakpoints (sm, md, lg, xl) per responsive-design-standards.md
- [x] T6.5: Write integration test for full homepage rendering with mock data

## Dev Agent Record

### Implementation Summary
- Created 5 homepage section components under `src/components/home/`
- HeroSection (client): Lora serif title, quick search form (make/model/city/budget → URL params → /search), auth-aware seller CTA
- TrustStrip (server): 4 trust indicators with lucide-react icons, responsive 2-col mobile / 4-col desktop
- FeaturedListings (server): async component fetching 8 recent listings via existing `getListings()` + `getCardConfig()`, reuses `ListingCard`, empty state fallback, Suspense skeleton
- HowItWorksSection (server): 3-step card layout (Recherchez/Comparez/Contactez)
- SellerCtaSection (client): 3 benefits, auth-aware CTA to /register or /seller/publish
- Rewrote `page.tsx` as Server Component assembling all sections with Suspense for FeaturedListings
- Added Next.js metadata export (title, description, openGraph, twitter)
- Added Schema.org WebSite JSON-LD with SearchAction via existing JsonLd component

### Tests Created
- `tests/components/home/hero-section.test.tsx` — 9 tests (rendering, search params, CTA auth)
- `tests/components/home/trust-strip.test.tsx` — 4 tests (rendering, indicators, responsive grid)
- `tests/components/home/featured-listings.test.tsx` — 6 tests (with data, empty state, API error, skeleton)
- `tests/components/home/how-it-works-section.test.tsx` — 6 tests (title, steps, descriptions, step numbers)
- `tests/components/home/seller-cta-section.test.tsx` — 6 tests (rendering, benefits, auth-aware CTA)
- `tests/app/public/homepage.test.tsx` — 3 tests (all sections rendered, JSON-LD, section order)
- **Total: 34 new tests, all passing**

### Decisions
- Used text inputs for make/model instead of selects since search page also uses text inputs (no brand/model API)
- Used 4th trust indicator "Prix du marche" instead of dynamic listing count (simpler, no API call needed)
- FeaturedListings is an async Server Component with Suspense boundary for streaming

## File List

### New Files
- `auto-frontend/src/components/home/hero-section.tsx`
- `auto-frontend/src/components/home/trust-strip.tsx`
- `auto-frontend/src/components/home/featured-listings.tsx`
- `auto-frontend/src/components/home/how-it-works-section.tsx`
- `auto-frontend/src/components/home/seller-cta-section.tsx`
- `auto-frontend/tests/components/home/hero-section.test.tsx`
- `auto-frontend/tests/components/home/trust-strip.test.tsx`
- `auto-frontend/tests/components/home/featured-listings.test.tsx`
- `auto-frontend/tests/components/home/how-it-works-section.test.tsx`
- `auto-frontend/tests/components/home/seller-cta-section.test.tsx`
- `auto-frontend/tests/app/public/homepage.test.tsx`

### Modified Files
- `auto-frontend/src/app/(public)/page.tsx` — rewrote from stub to full homepage
- `_bmad-output/implementation-artifacts/8-2-homepage-landing.md` — story status updates
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — status update

## Dev Notes

### Architecture & Patterns
- Reuse existing components wherever possible: `ListingCard`, `Badge`, `Button`, `Input`, `Select`
- The quick search form is a simplified version of the search page filters — it builds URL params and navigates to `/search`
- `FeaturedListings` calls the existing search API endpoint — no new backend work required
- Sections are separate components under `src/components/home/` for testability and maintainability
- The page uses Server Components where possible, with Client Components only for interactive elements (search form, auth-aware CTAs)

### Key Technical Context
- **Stack:** Next.js 16, React 19, Tailwind CSS v4, shadcn/ui
- **Typography:** Lora (serif) for hero headings, Inter (body) — both already configured in root layout
- **Design system:** `_bmad-output/design-system.md` — follow existing color palette, spacing, shadow conventions
- **Search API:** Already exists from Story 4-2, supports query params for filtering/sorting
- **ListingCard:** Already exists from Story 4-1 in `src/components/listings/`
- **Auth hook:** `useAuth()` or equivalent from Story 1-4 for checking authentication state

### Naming Conventions
- Components: PascalCase in `src/components/home/` (e.g., `hero-section.tsx` exports `HeroSection`)
- Test files: co-located `__tests__/` or `.test.tsx` suffix per project convention

### Anti-Patterns (FORBIDDEN)
- Do NOT create a new search API endpoint — reuse existing
- Do NOT create a new ListingCard variant — reuse existing component
- Do NOT hardcode listing data — always fetch from API
- Do NOT use raw Dialog — use ResponsiveDialog per responsive standards
- Do NOT skip responsive design — AC-RESPONSIVE gate applies

### Dependencies
- **Story 8-1 (seed data):** Featured listings section requires listings in the database to display content. Without seed data, only the empty state will show.

### References
- UX specification: `_bmad-output/planning-artifacts/ux-design-specification.md`
- Design system: `_bmad-output/design-system.md`
- Responsive standards: `_bmad-output/responsive-design-standards.md`
- Existing ListingCard: `auto-frontend/src/components/listings/`
- Existing search API: Story 4-2 implementation
- SEO patterns: Story 4-5 (structured data)
