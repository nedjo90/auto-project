# Story 3.5: Real-Time Visibility Score

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR9
**NFRs:** NFR3 (score update < 500ms)

## User Story

As a seller,
I want to see a visibility score that updates in real time as I fill in my listing,
So that I'm motivated to provide more data and understand how it affects my listing's visibility.

## Acceptance Criteria

**Given** a seller is creating or editing a listing
**When** they modify any field (add data, upload photo, complete a section)
**Then** the visibility score recalculates and the UI updates within 500ms (NFR3) (FR9)
**And** the score is displayed as an animated gauge (spring 500ms animation)
**And** a qualitative label is shown based on configurable thresholds: "Très documenté" / "Bien documenté" / "Partiellement documenté"

**Given** a vehicle is more than 15 years old
**When** the score is calculated
**Then** the score is normalized by vehicle category/age with a contextual message: "Bon score pour un véhicule de [year]"
**And** the normalization thresholds are configurable admin via `ConfigBoostFactor`

**Given** the score is displayed
**When** the seller views improvement tips
**Then** positive suggestions are shown: "Ajoutez le CT pour gagner en visibilité" (never punitive)
**And** each suggestion indicates the approximate score boost

**Given** a user has `prefers-reduced-motion`
**When** the score updates
**Then** the gauge updates without animation
