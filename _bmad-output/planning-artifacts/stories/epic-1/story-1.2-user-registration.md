# Story 1.2: User Registration with Configurable Fields

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** FR21, FR22
**NFRs:** NFR26 (accessible forms), NFR15 (RGPD)

## User Story

As a visitor,
I want to create an account with registration fields whose required/optional status is configurable,
So that I can access the platform's authenticated features with my account active immediately.

## Acceptance Criteria

**Given** a visitor is on the registration page
**When** they fill in the registration form
**Then** the form displays fields whose required/optional status is driven by a `ConfigRegistrationField` CDS table
**And** required fields are visually marked and enforced (client-side Zod + server-side CDS validation)
**And** optional fields are clearly indicated

**Given** a visitor submits a valid registration form
**When** the system processes the registration
**Then** a new user is created in Azure AD B2C via the sign-up user flow
**And** a corresponding user record is created in the PostgreSQL `User` table with default role `Buyer`
**And** the account is active immediately without moderator approval (FR22)
**And** the user is redirected to the platform as authenticated

**Given** a visitor submits a registration form with invalid data
**When** validation fails
**Then** specific, accessible error messages are displayed next to each invalid field (aria-describedby)
**And** focus is moved to the first invalid field

**Given** the registration form is displayed
**When** a screen reader user navigates the form
**Then** all fields have associated labels, error messages are linked, and focus management is correct (NFR26)
