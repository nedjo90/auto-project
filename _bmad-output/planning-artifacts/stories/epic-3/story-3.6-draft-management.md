# Story 3.6: Draft Management

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR5, FR6
**NFRs:** —

## User Story

As a seller,
I want to save my listing as a draft and manage multiple drafts simultaneously,
So that I can prepare several listings at my own pace before publishing them.

## Acceptance Criteria

**Given** a seller is creating a listing
**When** they click "Sauvegarder le brouillon" (FR5)
**Then** the listing is saved with status `Draft` in the `Listing` CDS entity
**And** all data (certified fields, declared fields, photos, score) is preserved
**And** a confirmation toast is displayed

**Given** a seller has multiple drafts (FR6)
**When** they access their drafts page (`(dashboard)/seller/drafts/`)
**Then** all drafts are listed with: vehicle info (brand, model), creation date, completion %, visibility score, photo count
**And** they can edit, duplicate, or delete any draft

**Given** a seller opens a saved draft
**When** the listing form loads
**Then** all previously saved data is restored including certified fields, declared fields, photos, and score
**And** the seller can continue editing where they left off
