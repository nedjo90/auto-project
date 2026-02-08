# Story 1.3: Explicit Consent & RGPD Compliance

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** FR29
**NFRs:** NFR15 (RGPD)

## User Story

As a new user,
I want to provide explicit, granular consent during registration for each type of data processing,
So that my personal data is handled only as I have agreed, in compliance with RGPD.

## Acceptance Criteria

**Given** a user is completing registration
**When** the consent step is presented
**Then** each consent type is displayed as an individual, unchecked checkbox (never pre-checked)
**And** consent types are driven by a `ConfigConsentType` CDS table (zero-hardcode)
**And** each consent includes a clear description of what data processing it authorizes

**Given** a user grants or revokes consent
**When** the system records the consent
**Then** the consent decision is stored with the user ID, consent type, decision (granted/revoked), and ISO 8601 timestamp
**And** the consent record is immutable (new record on change, not update)

**Given** consent types are updated by an admin
**When** a user logs in after the update
**Then** the user is prompted to review and accept the new consent terms before proceeding
