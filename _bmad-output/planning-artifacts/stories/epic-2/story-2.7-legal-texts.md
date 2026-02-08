# Story 2.7: Legal Texts Versioning & Re-acceptance

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR52
**NFRs:** NFR15 (RGPD)

## User Story

As an administrator,
I want to manage legal texts (CGU, CGV, privacy policy, legal notices) with versioning and automatic re-acceptance,
So that users always accept the current version and the platform stays legally compliant.

## Acceptance Criteria

**Given** an admin accesses the Legal Texts page (FR52)
**When** they view the legal documents
**Then** each document shows: current version number, last update date, content (rich text), acceptance count

**Given** an admin updates a legal document
**When** they save a new version
**Then** the version number is incremented
**And** the previous version is archived (not deleted)
**And** a flag `requiresReacceptance` is set to true

**Given** a user logs in after a legal text has been updated with `requiresReacceptance = true`
**When** the re-acceptance check runs
**Then** the user is presented with the updated document and must accept before proceeding
**And** the acceptance is recorded with user ID, document ID, version, and timestamp

**Given** legal texts are in development phase
**When** the system is in pre-launch state
**Then** mock/placeholder legal texts are displayed (to be replaced by lawyer-validated texts before launch)
