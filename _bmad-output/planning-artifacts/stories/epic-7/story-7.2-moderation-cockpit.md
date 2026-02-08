# Story 7.2: Moderation Cockpit & Report Queue

**Epic:** 7 - Modération & Qualité du Contenu
**FRs:** FR38
**NFRs:** NFR5 (cockpit < 2s)

## User Story

As a moderator,
I want a dedicated cockpit showing all pending reports sorted by severity and type,
So that I can efficiently triage and address the most critical issues first.

## Acceptance Criteria

**Given** a moderator accesses their cockpit (`(dashboard)/moderation/`) (FR38)
**When** the dashboard loads
**Then** summary metrics are displayed: new reports count, in-progress count, weekly trend
**And** reports are listed in a queue sorted by severity (critical → high → medium → low) then by date
**And** each report card shows: type icon, target (listing/user), severity badge, reporter, date, status

**Given** a moderator clicks on a report
**When** the detail view opens
**Then** full context is displayed on a single screen: report details, target listing/user data, certified vs declared data comparison, reporter info, and available actions
**And** the moderator can make a decision in < 2 minutes (UX principle: "contexte complet sans navigation")
