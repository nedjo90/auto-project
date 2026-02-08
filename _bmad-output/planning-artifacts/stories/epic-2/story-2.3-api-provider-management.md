# Story 2.3: API Provider Management & Cost Tracking

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR44, FR46
**NFRs:** NFR28 (Adapter Pattern), NFR29 (API logging)

## User Story

As an administrator,
I want to manage API providers (activate, deactivate, monitor costs) and track the margin per listing,
So that I can optimize costs and switch providers without developer intervention.

## Acceptance Criteria

**Given** an admin accesses the API Providers page
**When** the page loads
**Then** all `ConfigApiProvider` entries are listed with: provider name, adapter interface, status (active/standby/disabled), cost per call, availability rate, last call timestamp

**Given** an admin activates a standby provider and deactivates the current one (FR46)
**When** the switch is confirmed
**Then** the `AdapterFactory` resolves the new active provider for subsequent API calls
**And** no code change or deployment is required
**And** the switch is logged in the audit trail

**Given** API calls are being made
**When** the admin views the cost tracking dashboard (FR44)
**Then** they see: total API cost per day/week/month, cost breakdown by provider, average cost per listing, margin per listing (€15 revenue — cumulative API costs)
**And** data is sourced from the `ApiCallLog` table

**Given** the admin wants to compare providers
**When** they view provider analytics
**Then** they see cost per call, response time average, success rate, and downtime history for each provider
