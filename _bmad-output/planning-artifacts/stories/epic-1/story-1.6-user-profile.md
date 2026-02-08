# Story 1.6: User Profile & Seller Rating Contribution

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** FR26
**NFRs:** —

## User Story

As a user,
I want to manage my profile information, and as a seller, I want my profile completion rate to contribute to my seller rating,
So that buyers can assess my trustworthiness based on how thoroughly I've filled out my profile.

## Acceptance Criteria

**Given** an authenticated user navigates to their profile page
**When** the profile form loads
**Then** the user can view and edit their personal information (name, email, phone, address, SIRET for pros)
**And** changes are saved to the `User` CDS entity and synced with Azure AD B2C custom attributes if applicable

**Given** a user with role Seller views their profile
**When** they see their profile completion indicator
**Then** a percentage of filled fields is displayed
**And** the completion rate contributes to their public seller rating (FR26)
**And** tips are shown: "Ajoutez votre numéro SIRET pour renforcer votre crédibilité" (positive framing, never punitive)

**Given** a buyer views a seller's public profile on a listing
**When** the profile card renders
**Then** it shows the seller's rating, profile completion level, number of listings, and account seniority
