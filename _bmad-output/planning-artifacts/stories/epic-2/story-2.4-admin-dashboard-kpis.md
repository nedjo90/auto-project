# Story 2.4: Admin Dashboard & Real-Time KPIs

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR43, FR54
**NFRs:** NFR5 (cockpit < 2s)

## User Story

As an administrator,
I want a dashboard displaying global business KPIs in real time,
So that I can monitor the platform's health and make data-driven decisions.

## Acceptance Criteria

**Given** an admin accesses the admin dashboard (FR43)
**When** the page loads
**Then** the following KPIs are displayed: visitors (today vs last week), new registrations, listings published, contacts initiated, sales declared, revenue today, traffic sources breakdown
**And** each KPI shows the value + trend indicator (↑↓ + % variation vs previous period)
**And** a 30-day trend chart is displayed

**Given** the dashboard is open
**When** new data arrives (new listing published, new sale, etc.)
**Then** the KPIs update in real time via the SignalR `/admin` hub (NFR5)

**Given** an admin clicks on a KPI
**When** the drill-down opens
**Then** detailed data is shown (e.g., clicking "Revenue" shows revenue per day, per listing, per payment)
**And** each metric leads to an actionable view (UX principle: "Chaque chiffre mène à une action")

**Given** the admin has the dashboard role
**When** they access the admin section
**Then** they have access to all platform capabilities (seller, buyer, moderator functions) (FR54)
