# Story 6.1: Seller Dashboard & Listing KPIs

**Epic:** 6 - Cockpit Vendeur & Intelligence Marché
**FRs:** FR33
**NFRs:** NFR5 (cockpit < 2s)

## User Story

As a seller,
I want to see the performance metrics of my listings (views, contacts, days online),
So that I can make data-driven decisions about pricing and listing quality.

## Acceptance Criteria

**Given** a seller accesses their cockpit (`(dashboard)/seller/`) (FR33)
**When** the dashboard loads (< 2 seconds, NFR5)
**Then** aggregate KPIs are displayed: total active listings, total views (with trend), total contacts received (with trend), average days online
**And** each KPI shows value + trend indicator (↑↓ + % variation vs previous period)

**Given** a seller views individual listing performance
**When** they see the listings table
**Then** each listing shows: photo thumbnail, title, price, views count, contacts count, days online, visibility score, market position
**And** the table is sortable by any column

**Given** a seller clicks on a KPI or listing metric
**When** the drill-down opens
**Then** a detailed view shows the metric over time (chart) with actionable insights
