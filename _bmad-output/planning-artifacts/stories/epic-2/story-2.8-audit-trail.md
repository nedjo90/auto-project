# Story 2.8: Audit Trail System

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR53
**NFRs:** NFR14 (audit trail), NFR16 (access logging), NFR29 (API logging)

## User Story

As an administrator,
I want every sensitive operation on the platform systematically logged with actor, action, target, and timestamp,
So that I have complete traceability for compliance, debugging, and security investigations.

## Acceptance Criteria

**Given** any sensitive operation occurs (payment, account modification, moderation action, admin config change, listing publication, role change)
**When** the `audit-trail` middleware processes the request
**Then** an `AuditTrailEntry` CDS record is created with: action (e.g., `listing.published`), actorId, actorRole, targetType, targetId, timestamp (ISO 8601), details (JSON with contextual data) (FR53)

**Given** an admin accesses the Audit Trail viewer
**When** they search the audit log
**Then** they can filter by: date range, actor, action type, target type, target ID
**And** results are displayed in a sortable, paginated data table
**And** each entry shows the full detail on click

**Given** every API call to external providers is made
**When** the `api-logger` middleware processes the call
**Then** an `ApiCallLog` record is created with: adapter name, provider, endpoint, HTTP status, response time (ms), cost, listing ID, timestamp
