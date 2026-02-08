# Story 4.2: Multi-Criteria Search & Filters

**Epic:** 4 - Marketplace, Recherche & Découverte
**FRs:** FR14
**NFRs:** NFR6 (search results < 2s)

## User Story

As a buyer,
I want to filter listings by multiple criteria simultaneously,
So that I can narrow down results to vehicles that match my specific needs.

## Acceptance Criteria

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
