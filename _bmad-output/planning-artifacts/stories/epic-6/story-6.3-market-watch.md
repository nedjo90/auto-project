# Story 6.3: Market Watch & Competitor Tracking

**Epic:** 6 - Cockpit Vendeur & Intelligence Marché
**FRs:** FR35
**NFRs:** —

## User Story

As a seller,
I want to follow competitor vehicles on the marketplace and track their price and status changes,
So that I can stay competitive and adjust my strategy based on market movements.

## Acceptance Criteria

**Given** a seller browses the public marketplace
**When** they click "Suivre" on a competitor's listing (FR35)
**Then** the listing is added to their market watch list
**And** a `MarketWatch` record is created linking the seller and the tracked listing

**Given** a seller accesses their market watch (`(dashboard)/seller/market/`)
**When** the page loads
**Then** tracked listings are displayed with: current price, price history (changes highlighted), status (active/sold), days online, certification level

**Given** a tracked listing changes (price, status, new photos)
**When** the change is detected
**Then** the seller receives a notification about the change
