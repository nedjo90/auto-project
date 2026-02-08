# Story 4.5: SEO Pages & Structured Data

**Epic:** 4 - Marketplace, Recherche & Découverte
**FRs:** FR18, FR19
**NFRs:** NFR1 (Core Web Vitals)

## User Story

As the platform,
I want every public listing page, search page, and landing page to be optimized for search engines,
So that buyers discover auto through organic search on Google.

## Acceptance Criteria

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
