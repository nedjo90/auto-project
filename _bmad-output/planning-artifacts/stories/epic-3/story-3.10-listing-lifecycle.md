# Story 3.10: Listing Lifecycle Management

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR11
**NFRs:** NFR14 (audit trail)

## User Story

As a seller,
I want to mark a listing as sold or remove it from the marketplace,
So that I can manage the lifecycle of my listings and keep the marketplace accurate.

## Acceptance Criteria

**Given** a seller views their published listings
**When** they click "Marquer comme vendu" (FR11)
**Then** the listing status changes to `Sold`
**And** the listing is removed from public search results but accessible via direct URL (with "Vendu" badge)
**And** open chat conversations for this listing are notified

**Given** a seller wants to remove a listing
**When** they click "Retirer"
**Then** the listing status changes to `Archived`
**And** the listing is no longer visible publicly
**And** the action is logged in the audit trail

**Given** a listing has been sold or archived
**When** the seller views their listing history
**Then** they can see all past listings with their final status, dates, and performance metrics
