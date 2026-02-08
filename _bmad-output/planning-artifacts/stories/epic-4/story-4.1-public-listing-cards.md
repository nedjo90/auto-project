# Story 4.1: Public Listing Browsing & Configurable Cards

**Epic:** 4 - Marketplace, Recherche & Découverte
**FRs:** FR13, FR20
**NFRs:** NFR1 (Core Web Vitals), NFR7 (image optimization)

## User Story

As a buyer,
I want to browse published listings displayed as visually rich cards with key information at a glance,
So that I can quickly scan multiple vehicles and identify the ones worth investigating.

## Acceptance Criteria

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
**Then** the full listing is displayed with: photo gallery (60% desktop / full-width mobile), all fields with 🟢/🟡 badges, certification level label, price market comparison, seller profile, contact button
**And** the layout follows the UX spec: gallery + info split on desktop, stacked on mobile, sticky contact bar
