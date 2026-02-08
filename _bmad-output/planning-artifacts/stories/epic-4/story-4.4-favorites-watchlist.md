# Story 4.4: Favorites & Watchlist

**Epic:** 4 - Marketplace, Recherche & Découverte
**FRs:** FR17
**NFRs:** —

## User Story

As a registered buyer,
I want to save listings to my favorites and track changes to their information,
So that I can compare options over time and be notified of price drops or new information.

## Acceptance Criteria

**Given** a registered buyer views a listing card or detail page
**When** they click the favorite icon (FR17)
**Then** the listing is added to their favorites with a visual confirmation
**And** a `Favorite` CDS record is created linking user and listing

**Given** a buyer accesses their favorites
**When** the favorites page loads
**Then** all favorited listings are displayed with current data
**And** changes since favoriting are highlighted (price change, new photos, certification update)

**Given** a favorited listing's price changes
**When** the change is detected
**Then** the buyer receives a notification: "Le prix du [brand] [model] a baissé de €[old] à €[new]"

**Given** a favorited listing is marked as sold
**When** the status changes
**Then** the buyer is notified and the listing is visually marked in favorites
