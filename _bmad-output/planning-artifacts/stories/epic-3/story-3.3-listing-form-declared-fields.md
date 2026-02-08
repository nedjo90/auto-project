# Story 3.3: Listing Form & Declared Fields

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR3
**NFRs:** NFR3 (score update < 500ms), NFR25 (badge accessibility), NFR26 (form accessibility)

## User Story

As a seller,
I want to complete, modify, or correct the remaining fields of my listing (price, description, condition, options),
So that my listing is comprehensive with both certified and declared data clearly distinguished.

## Acceptance Criteria

**Given** auto-fill has populated the certified fields
**When** the seller views the listing form
**Then** remaining empty fields are highlighted as "À compléter" and marked as 🟡 Declared when filled (FR3)
**And** the form is a single scrollable page with sections and anchors (not multi-page)
**And** all fields have accessible labels and error messages (NFR26)

**Given** a seller fills in a declared field (e.g., price, mileage adjustment, description)
**When** they enter a value
**Then** the field is marked 🟡 Declared with text "Déclaré vendeur"
**And** the visibility score updates in real time (< 500ms, NFR3)

**Given** a seller wants to override a certified field
**When** they modify a certified value
**Then** the field status changes from 🟢 Certified to 🟡 Declared with a warning: "La valeur certifiée sera remplacée par votre saisie"
**And** the original certified value is preserved in `CertifiedField` history

**Given** the listing form is rendered
**When** checked for accessibility
**Then** the form passes WCAG 2.1 AA: labels associated, errors linked via `aria-describedby`, focus management correct, badges have text equivalents (NFR25)
