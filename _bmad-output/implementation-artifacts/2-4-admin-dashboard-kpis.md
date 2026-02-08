# Story 2.4: Admin Dashboard & Real-Time KPIs

Status: ready-for-dev

## Story

As an administrator,
I want a dashboard displaying global business KPIs in real time,
so that I can monitor the platform's health and make data-driven decisions.

## Acceptance Criteria (BDD)

**Given** an admin accesses the admin dashboard (FR43)
**When** the page loads
**Then** the following KPIs are displayed: visitors (today vs last week), new registrations, listings published, contacts initiated, sales declared, revenue today, traffic sources breakdown
**And** each KPI shows the value + trend indicator (up/down + % variation vs previous period)
**And** a 30-day trend chart is displayed

**Given** the dashboard is open
**When** new data arrives (new listing published, new sale, etc.)
**Then** the KPIs update in real time via the SignalR `/admin` hub (NFR5)

**Given** an admin clicks on a KPI
**When** the drill-down opens
**Then** detailed data is shown (e.g., clicking "Revenue" shows revenue per day, per listing, per payment)
**And** each metric leads to an actionable view (UX principle: "Chaque chiffre mene a une action")

**Given** the admin has the dashboard role
**When** they access the admin section
**Then** they have access to all platform capabilities (seller, buyer, moderator functions) (FR54)

## Tasks / Subtasks

### Task 1: Create Admin Dashboard Page Layout (AC1)
- **1.1** Create `src/app/(dashboard)/admin/page.tsx` as the main admin dashboard
- **1.2** Design a responsive grid layout with KPI cards at the top and trend chart below
- **1.3** Create `src/components/admin/kpi-card.tsx` reusable component showing: value, label, trend arrow (up/down), percentage change, period comparison
- **1.4** Create `src/components/admin/trend-chart.tsx` component for 30-day line/area chart
- **1.5** Write component tests for KPI card rendering with various data states (positive trend, negative trend, neutral)

### Task 2: Implement KPI Data Backend Endpoints (AC1)
- **2.1** Define custom action in `admin-service.cds`: `action getDashboardKpis(period: String) returns { visitors: KpiValue, registrations: KpiValue, listings: KpiValue, contacts: KpiValue, sales: KpiValue, revenue: KpiValue, trafficSources: [TrafficSource] }`
- **2.2** Define `type KpiValue { current: Integer; previous: Integer; trend: Decimal; }` in CDS
- **2.3** Implement handler in `admin-service.ts`:
  - Query User table for new registrations (today vs last week)
  - Query Listing table for published listings count
  - Query Contact/Message table for contacts initiated
  - Query Sale/Transaction table for sales declared
  - Query Payment table for revenue calculation
  - Traffic sources: placeholder for analytics integration (Google Analytics API or internal tracking)
- **2.4** Define `action getDashboardTrend(metric: String, days: Integer) returns [{ date: Date, value: Integer }]`
- **2.5** Implement 30-day trend handler aggregating daily counts by metric
- **2.6** Write integration tests for all KPI computation queries
- **2.7** Write unit tests for trend calculation logic

### Task 3: Implement Real-Time Updates via SignalR (AC2)
- **3.1** Set up Azure SignalR integration in the backend: `srv/lib/signalr-client.ts`
- **3.2** Configure the `/admin` SignalR hub for admin-only connections
- **3.3** Define SignalR events: `kpiUpdate`, `newListing`, `newSale`, `newRegistration`, `newContact`
- **3.4** In relevant CDS AFTER handlers (listing publish, sale declaration, registration, contact), emit SignalR events with updated KPI data
- **3.5** Create frontend SignalR hook: `src/hooks/use-signalr.ts` for connecting to the `/admin` hub
- **3.6** Create `src/hooks/use-live-kpis.ts` hook that merges initial KPI data with real-time updates
- **3.7** Integrate live KPI updates into dashboard KPI cards (animate value changes)
- **3.8** Write integration tests for SignalR event emission
- **3.9** Write component tests for real-time KPI update rendering

### Task 4: Implement KPI Drill-Down Views (AC3)
- **4.1** Create `src/app/(dashboard)/admin/kpis/[metric]/page.tsx` dynamic route for drill-down
- **4.2** Implement Revenue drill-down: revenue per day chart, revenue per listing table, revenue per payment method breakdown
- **4.3** Implement Registrations drill-down: daily registration chart, user list with registration date
- **4.4** Implement Listings drill-down: daily listing chart, listings by status, listings by vehicle type
- **4.5** Implement Sales drill-down: daily sales chart, sales by vehicle type, average sale price
- **4.6** Implement Contacts drill-down: daily contacts chart, contacts by type, conversion rate
- **4.7** Add "actionable" links from drill-down to relevant admin pages (e.g., from a listing in drill-down to moderation)
- **4.8** Define backend drill-down endpoints in `admin-service.cds` for each metric
- **4.9** Implement drill-down handlers in `admin-service.ts`
- **4.10** Write component tests for each drill-down view
- **4.11** Write integration tests for drill-down data endpoints

### Task 5: Implement Admin Super-Role Access (AC4)
- **5.1** Define admin role in CDS authorization model with access to all platform capabilities
- **5.2** Implement admin role check middleware: admin users can impersonate seller, buyer, moderator functions
- **5.3** Add role indicator in the admin UI header showing current role context
- **5.4** Write integration tests verifying admin role has access to all service endpoints

### Task 6: Dashboard Performance Optimization (NFR5)
- **6.1** Ensure dashboard loads within 2 seconds (NFR5 requirement)
- **6.2** Implement data pre-fetching: load KPIs in parallel, not sequentially
- **6.3** Add loading skeletons for each KPI card during data fetch
- **6.4** Cache KPI data with short TTL (30s) to avoid excessive DB queries
- **6.5** Write performance tests verifying load time under threshold

## Dev Notes

### Architecture & Patterns
- The admin dashboard is the **primary landing page** for administrators. Performance is critical -- NFR5 mandates < 2s load time for the cockpit.
- **Real-time architecture:** Azure SignalR `/admin` hub pushes KPI updates to connected admin clients. The backend emits events from CDS AFTER handlers when relevant entities change.
- **Drill-down pattern:** Each KPI card is clickable and navigates to a dedicated drill-down page. The UX principle "Chaque chiffre mene a une action" means every number must lead to an actionable view.
- KPI computation involves querying multiple tables. Consider creating a dedicated `KpiService` or helper module to isolate query logic from the admin-service handler.
- Traffic sources integration depends on external analytics. For MVP, use internal page view tracking or placeholder data. Google Analytics API integration can be a follow-up.
- The admin "super role" (FR54) grants access to all platform operations. This is implemented at the CDS authorization level, not as separate UI components.

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 App Router frontend, PostgreSQL, Azure
- **Multi-repo:** auto-backend, auto-frontend, auto-shared (@auto/shared via Azure Artifacts)
- **Config:** Zero-hardcode - 10+ config tables in DB (ConfigParameter, ConfigText, ConfigFeature, ConfigBoostFactor, ConfigVehicleType, ConfigListingDuration, ConfigReportReason, ConfigChatAction, ConfigModerationRule, ConfigApiProvider), InMemoryConfigCache (Redis-ready interface)
- **Admin service:** admin-service.cds + admin-service.ts
- **Adapter Pattern:** 8 interfaces, Factory resolves active impl from ConfigApiProvider table
- **API logging:** Every external API call logged (provider, cost, status, time) via api-logger middleware
- **Audit trail:** Systematic logging via audit-trail middleware on all sensitive operations
- **Error handling:** RFC 7807 (Problem Details) for custom endpoints
- **Frontend admin:** src/app/(dashboard)/admin/* pages (SPA behind auth)
- **Real-time:** Azure SignalR /admin hub for live KPIs
- **Testing:** >=90% unit, >=80% integration, >=85% component, 100% contract

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- API REST custom: kebab-case
- All technical naming in English, French only in i18n DB texts

### Anti-Patterns (FORBIDDEN)
- Hardcoded values (use config tables)
- Direct DB queries (use CDS service layer)
- French in code/files/variables
- Skipping audit trail for sensitive ops
- Skipping tests

### Project Structure Notes
- `src/app/(dashboard)/admin/page.tsx` - Main admin dashboard page
- `src/app/(dashboard)/admin/kpis/[metric]/page.tsx` - KPI drill-down dynamic route
- `src/components/admin/kpi-card.tsx` - Reusable KPI card component
- `src/components/admin/trend-chart.tsx` - 30-day trend chart component
- `src/hooks/use-signalr.ts` - SignalR connection hook
- `src/hooks/use-live-kpis.ts` - Live KPI data hook
- `srv/lib/signalr-client.ts` - Azure SignalR backend client
- `srv/admin-service.cds` - getDashboardKpis, getDashboardTrend, drill-down actions
- `srv/admin-service.ts` - KPI computation handlers

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
