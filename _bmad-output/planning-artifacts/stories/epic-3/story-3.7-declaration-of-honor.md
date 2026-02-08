# Story 3.7: Declaration of Honor & Archival

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR8, FR12
**NFRs:** NFR14 (audit trail)

## User Story

As a seller,
I want to complete a digital declaration of honor before publishing each listing,
So that I formally attest to the accuracy of my declared data, and this attestation is archived as proof.

## Acceptance Criteria

**Given** a seller has completed their listing and wants to publish
**When** they reach the declaration step (FR8)
**Then** structured checkboxes are displayed (each representing a specific attestation point)
**And** all checkboxes must be checked to proceed
**And** the declaration text is configurable admin (zero-hardcode)

**Given** a seller completes the declaration
**When** they sign digitally
**Then** a `Declaration` CDS record is created with: seller ID, listing ID, timestamp (ISO 8601), declaration version, IP address, all checkbox states (FR12)
**And** the declaration is immutable and archived permanently
**And** an audit trail entry is created

**Given** someone needs to verify a declaration
**When** they access the listing or moderation view
**Then** the declaration is accessible with its full timestamp and attestation details
