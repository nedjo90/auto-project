# Story 7.3: Moderation Actions (Deactivate, Warn, Reactivate)

**Epic:** 7 - Modération & Qualité du Contenu
**FRs:** FR39, FR40, FR41
**NFRs:** NFR14 (audit trail)

## User Story

As a moderator,
I want to take actions on reported content (deactivate listings, deactivate accounts, send warnings, reactivate),
So that I can protect the platform's reputation while being fair to users.

## Acceptance Criteria

**Given** a moderator reviews a report
**When** they choose to deactivate a listing (FR39)
**Then** the listing status changes to `Suspended`
**And** the listing is hidden from public search
**And** the seller receives a templated notification: "Votre annonce a été mise en pause pour vérification" (smoothed communication)
**And** the action is logged in the audit trail

**Given** a moderator decides to send a warning (FR41)
**When** they select the warning action
**Then** a templated warning message is sent to the user via the platform
**And** the warning is recorded on the user's moderation history
**And** the report status is updated to `Treated`

**Given** a moderator decides to deactivate a user account (FR40)
**When** they confirm the action (double confirmation)
**Then** the user account is suspended (cannot login, listings hidden)
**And** the user receives a notification with the reason
**And** the action is logged in the audit trail

**Given** a moderator wants to reactivate a listing or account
**When** the seller has corrected the issue
**Then** the moderator can reactivate via a single action
**And** the listing/account becomes visible again
**And** the reactivation is logged
