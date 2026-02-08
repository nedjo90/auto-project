# Story 6.1: Seller Dashboard & Listing KPIs

Status: ready-for-dev

## Story

As a seller,
I want to see the performance metrics of my listings (views, contacts, days online),
so that I can make data-driven decisions about pricing and listing quality.

## Acceptance Criteria (BDD)

**Given** a seller accesses their cockpit (`(dashboard)/seller/`) (FR33)
**When** the dashboard loads (< 2 seconds, NFR5)
**Then** aggregate KPIs are displayed: total active listings, total views (with trend), total contacts received (with trend), average days online
**And** each KPI shows value + trend indicator (up/down + % variation vs previous period)

**Given** a seller views individual listing performance
**When** they see the listings table
**Then** each listing shows: photo thumbnail, title, price, views count, contacts count, days online, visibility score, market position
**And** the table is sortable by any column

**Given** a seller clicks on a KPI or listing metric
**When** the drill-down opens
**Then** a detailed view shows the metric over time (chart) with actionable insights

## Tasks / Subtasks

### Task 1: Seller Service CDS Definitions (AC1, AC2)
1.1. Define `SellerDashboard` view/projection in `srv/seller-service.cds` aggregating: totalActiveListings, totalViews, totalContacts, averageDaysOnline
1.2. Define `ListingPerformance` view in `srv/seller-service.cds` joining listing data with metrics: listingID, photoUrl, title, price, viewsCount, contactsCount, daysOnline, visibilityScore, marketPosition
1.3. Define `MetricHistory` entity for time-series KPI data: ID, listingID (optional, null for aggregate), metricType (enum: views, contacts, daysOnline), value, period (date), createdAt
1.4. Define CDS service actions for dashboard data retrieval with seller authorization
1.5. Write unit tests for CDS model definitions

### Task 2: Seller Service Backend Logic (AC1, AC2, AC3)
2.1. Implement `srv/seller-service.ts` with handler `getAggregateKPIs(sellerID)` returning dashboard KPIs with trend calculation (current period vs previous period percentage change)
2.2. Implement handler `getListingPerformance(sellerID)` returning all listings with performance metrics, supporting sort parameters
2.3. Implement handler `getMetricDrilldown(sellerID, metricType, listingID?)` returning time-series data for chart rendering
2.4. Implement trend calculation logic: compare current 30-day period with previous 30-day period, return percentage change and direction
2.5. Implement view/contact counting: query ChatMessage and listing view events grouped by listing
2.6. Ensure all queries are optimized for < 2s response (NFR5): add appropriate indexes, use CDS projections
2.7. Write integration tests for all service handlers

### Task 3: KPI Card Components (AC1)
3.1. Create `src/components/dashboard/kpi-card.tsx` — reusable card displaying: metric label, current value (formatted), trend arrow (up/down), trend percentage, trend color (green for positive, red for negative)
3.2. Create `src/components/dashboard/stat-trend.tsx` — reusable trend indicator component: arrow icon, percentage text, color coding based on direction
3.3. Create `src/components/dashboard/kpi-grid.tsx` — grid layout for 4 KPI cards (total listings, total views, total contacts, avg days online)
3.4. Implement loading skeleton states for KPI cards during data fetch
3.5. Write component tests for kpi-card, stat-trend, and kpi-grid

### Task 4: Listings Performance Table (AC2)
4.1. Create `src/components/dashboard/listings-table.tsx` — sortable data table with columns: thumbnail, title, price, views, contacts, days online, visibility score, market position
4.2. Implement column sorting: client-side sort with sort indicator icons in column headers
4.3. Implement row click behavior: navigate to listing detail or open drill-down
4.4. Create `src/components/dashboard/listing-row.tsx` — table row component with photo thumbnail, formatted values, color-coded market position indicator
4.5. Implement responsive behavior: stack columns or switch to card layout on mobile
4.6. Add loading skeleton for table during data fetch
4.7. Write component tests for listings-table and listing-row

### Task 5: Drill-Down Chart View (AC3)
5.1. Create `src/components/dashboard/chart-wrapper.tsx` — wrapper component for rendering metric charts using a charting library (e.g., recharts or chart.js)
5.2. Create `src/components/dashboard/metric-drilldown.tsx` — drill-down panel/modal showing: metric title, line/bar chart of metric over time, period selector (7d, 30d, 90d), actionable insights text
5.3. Implement chart data transformation: convert MetricHistory records to chart-compatible format
5.4. Add insight generation logic: based on trends, display contextual tips (e.g., "Views are increasing, consider raising price" or "Days online is high, review listing quality")
5.5. Write component tests for chart-wrapper and metric-drilldown

### Task 6: Seller Dashboard Page Assembly (AC1, AC2, AC3)
6.1. Create `src/app/(dashboard)/seller/page.tsx` as the main seller cockpit page
6.2. Fetch aggregate KPIs from SellerService on page load, render KPI grid
6.3. Fetch listing performance data, render listings table below KPI grid
6.4. Wire drill-down: on KPI card click or table metric click, open metric-drilldown component
6.5. Implement data refresh: periodic refresh or SignalR-based real-time KPI updates via `/admin` hub (optional)
6.6. Ensure page load performance < 2s (NFR5): use React Suspense boundaries, skeleton loaders, parallel data fetching
6.7. Write page-level integration tests

### Task 7: Performance Optimization (AC1 - NFR5)
7.1. Add database indexes on listing views and contacts tables for seller-based aggregation queries
7.2. Implement server-side caching for aggregate KPIs (short TTL, e.g., 60 seconds)
7.3. Profile dashboard API response time, ensure < 2s target
7.4. Implement incremental loading: KPI cards load first, then table, then charts on demand
7.5. Write performance benchmark tests

## Dev Notes

### Architecture & Patterns
- **Aggregate-then-serve:** KPIs are computed server-side via CDS projections and aggregation queries, not computed client-side from raw data
- **Trend calculation:** Compare current 30-day window vs previous 30-day window; percentage change = ((current - previous) / previous) * 100
- **Drill-down pattern:** KPI cards and table cells are clickable; drill-down opens a chart overlay fetching time-series data on demand
- **Skeleton loading:** All dashboard components render skeleton placeholders during data fetch to maintain perceived performance
- **Parallel fetch:** KPI aggregate and listing performance data are fetched in parallel using React Suspense boundaries

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend, PostgreSQL, Azure SignalR Service
- **Real-time:** Azure SignalR Service with 4 separate hubs:
  - /chat — buyer<->seller messages linked to vehicle
  - /notifications — push events (new contact, new view, report handled, etc.)
  - /live-score — visibility score updates during listing creation
  - /admin — real-time KPIs
- **SignalR events:** domain:action naming (e.g., "chat:message-sent", "notification:new-contact")
- **Chat:** chat-service.cds + .ts, signalr/chat-hub.ts, ChatMessage entity in CDS
- **Notifications:** Push notifications via PWA service worker (serwist), notification-hub.ts
- **Seller cockpit:** src/app/(dashboard)/seller/* (SPA behind auth)
- **KPIs:** seller-service.cds + .ts, dashboard components (kpi-card.tsx, chart-wrapper.tsx, stat-trend.tsx)
- **Market price:** lib/market-price.ts, IValuationAdapter (mock V1)
- **Favorites/Watch:** Stored in PostgreSQL, accessible from seller cockpit
- **Empty states:** Engaging design when cockpit is empty, guide to first action
- **Testing:** Component tests for all dashboard components, SignalR integration tests

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- SignalR events: domain:action kebab-case
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded values
- Direct DB queries
- French in code
- Skipping tests

### Project Structure Notes
Backend: srv/chat-service.*, srv/signalr/ (chat-hub.ts, notification-hub.ts), srv/seller-service.*
Frontend: src/app/(dashboard)/seller/*, src/components/chat/*, src/components/dashboard/*, src/hooks/useChat.ts, src/hooks/useSignalR.ts, src/hooks/useNotifications.ts, src/stores/chat-store.ts, src/stores/notification-store.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-6/story-6.1-seller-dashboard-kpis.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
