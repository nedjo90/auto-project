# Story 7.4: Seller History & Moderation Context

**Epic:** 7 - Modération & Qualité du Contenu
**FRs:** FR42
**NFRs:** —

## User Story

As a moderator,
I want to view a seller's complete history (previous reports, warnings, rating, seniority, listing patterns),
So that I can make informed moderation decisions with full context.

## Acceptance Criteria

**Given** a moderator is reviewing a report about a seller
**When** they click "Voir l'historique vendeur" (FR42)
**Then** the seller history view shows: account creation date, total listings published, active listings count, all previous reports (with outcomes), warnings received, account suspensions, seller rating, average certification level

**Given** a moderator views a seller with repeated violations
**When** the history shows a pattern
**Then** the pattern is visually highlighted (e.g., "3ème signalement en 30 jours")
**And** the moderator can take escalated action (account deactivation)
