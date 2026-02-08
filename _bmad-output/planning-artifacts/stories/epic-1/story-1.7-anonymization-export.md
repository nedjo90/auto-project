# Story 1.7: Account Anonymization & Personal Data Export

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** FR27, FR28
**NFRs:** NFR15 (RGPD)

## User Story

As a user,
I want to request anonymization of my account or export of all my personal data,
So that my RGPD rights (right to erasure, right to portability) are respected.

## Acceptance Criteria

**Given** an authenticated user navigates to their account settings
**When** they request personal data export (FR28)
**Then** the system generates a JSON file containing all their personal data (profile, listings, messages, consent records, declarations)
**And** the file is available for download within a configurable timeframe
**And** the export request is logged in the audit trail

**Given** an authenticated user requests account anonymization (FR27)
**When** they confirm the irreversible action (double confirmation dialog)
**Then** personal data is anonymized (replaced with hashed/generic values), NOT deleted
**And** listings and declarations are preserved with anonymized seller references (data integrity maintained)
**And** the Azure AD B2C account is disabled
**And** the anonymization is logged in the audit trail

**Given** a user has been anonymized
**When** anyone views their former listings
**Then** the seller is displayed as "Utilisateur anonymisé" with no personal information
