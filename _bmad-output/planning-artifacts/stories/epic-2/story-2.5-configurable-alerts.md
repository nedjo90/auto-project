# Story 2.5: Configurable Alerts & Thresholds

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR45
**NFRs:** NFR36 (admin notification on API failure)

## User Story

As an administrator,
I want to configure alerts on business thresholds (minimum margin, API availability, etc.),
So that I'm notified immediately when critical metrics deviate from expected values.

## Acceptance Criteria

**Given** an admin accesses the Alerts configuration page (FR45)
**When** they create or edit an alert
**Then** they can define: metric to monitor, threshold value, comparison operator (above/below), notification method (in-app, email), severity level
**And** alerts are stored in a `ConfigAlert` CDS entity (zero-hardcode)

**Given** an alert threshold is breached
**When** the system detects the breach (e.g., margin per listing drops below €8)
**Then** the admin is notified via the configured method
**And** the alert is displayed prominently on the admin dashboard
**And** the alert event is logged

**Given** an API provider becomes unavailable (NFR36)
**When** the `api-logger` middleware detects consecutive failures
**Then** an automatic alert is triggered to the admin with provider name, failure count, and last success timestamp
