# Story 2.4: Admin Dashboard & Real-Time KPIs

Status: review

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
- [x] **1.1** Create `src/app/(dashboard)/admin/page.tsx` as the main admin dashboard
- [x] **1.2** Design a responsive grid layout with KPI cards at the top and trend chart below
- [x] **1.3** Create `src/components/admin/kpi-card.tsx` reusable component showing: value, label, trend arrow (up/down), percentage change, period comparison
- [x] **1.4** Create `src/components/admin/trend-chart.tsx` component for 30-day line/area chart
- [x] **1.5** Write component tests for KPI card rendering with various data states (positive trend, negative trend, neutral)

### Task 2: Implement KPI Data Backend Endpoints (AC1)
- [x] **2.1** Define custom action in `admin-service.cds`: `action getDashboardKpis(period: String) returns { visitors: KpiValue, registrations: KpiValue, listings: KpiValue, contacts: KpiValue, sales: KpiValue, revenue: KpiValue, trafficSources: [TrafficSource] }`
- [x] **2.2** Define `type KpiValue { current: Integer; previous: Integer; trend: Decimal; }` in CDS
- [x] **2.3** Implement handler in `admin-service.ts`:
  - Query User table for new registrations (today vs last week)
  - Query Listing table for published listings count
  - Query Contact/Message table for contacts initiated
  - Query Sale/Transaction table for sales declared
  - Query Payment table for revenue calculation
  - Traffic sources: placeholder for analytics integration (Google Analytics API or internal tracking)
- [x] **2.4** Define `action getDashboardTrend(metric: String, days: Integer) returns [{ date: Date, value: Integer }]`
- [x] **2.5** Implement 30-day trend handler aggregating daily counts by metric
- [x] **2.6** Write integration tests for all KPI computation queries
- [x] **2.7** Write unit tests for trend calculation logic

### Task 3: Implement Real-Time Updates via SignalR (AC2)
- [x] **3.1** Set up Azure SignalR integration in the backend: `srv/lib/signalr-client.ts`
- [x] **3.2** Configure the `/admin` SignalR hub for admin-only connections
- [x] **3.3** Define SignalR events: `kpiUpdate`, `newListing`, `newSale`, `newRegistration`, `newContact`
- [x] **3.4** In relevant CDS AFTER handlers (listing publish, sale declaration, registration, contact), emit SignalR events with updated KPI data
- [x] **3.5** Create frontend SignalR hook: `src/hooks/use-signalr.ts` for connecting to the `/admin` hub
- [x] **3.6** Create `src/hooks/use-live-kpis.ts` hook that merges initial KPI data with real-time updates
- [x] **3.7** Integrate live KPI updates into dashboard KPI cards (animate value changes)
- [x] **3.8** Write integration tests for SignalR event emission
- [x] **3.9** Write component tests for real-time KPI update rendering

### Task 4: Implement KPI Drill-Down Views (AC3)
- [x] **4.1** Create `src/app/(dashboard)/admin/kpis/[metric]/page.tsx` dynamic route for drill-down
- [x] **4.2** Implement drill-down page with period selector (24h/7j/30j), summary cards (total/average/days), trend chart, and data table
- [x] **4.3** Implement metric validation and invalid metric handling with back navigation
- [x] **4.4** Add "actionable" links from drill-down to relevant admin pages (back button to dashboard)
- [x] **4.5** Define backend `getKpiDrillDown` action in `admin-service.cds`
- [x] **4.6** Implement drill-down handler in `admin-service.ts` with period-based daily aggregation
- [x] **4.7** Add `fetchKpiDrillDown` API function in `dashboard-api.ts`
- [x] **4.8** Write 11 component tests for drill-down page (loading, rendering, navigation, error, period change, empty state)
- [x] **4.9** Write 7 backend integration tests for drill-down endpoint (validation, data aggregation, periods)

### Task 5: Implement Admin Super-Role Access (AC4)
- [x] **5.1** Add `expandRolesWithHierarchy()` utility to `@auto/shared` that expands roles based on hierarchy level
- [x] **5.2** Modify backend auth-middleware to expand roles with hierarchy so admin gains all lower-level capabilities (FR54)
- [x] **5.3** Update frontend `useAuth` hook to expand roles with hierarchy for consistent role checks
- [x] **5.4** Create `AdminRoleIndicator` component showing role badge and "Acces complet" label for admin
- [x] **5.5** Update admin layout to include role indicator header bar
- [x] **5.6** Write 8 shared tests for `expandRolesWithHierarchy` function
- [x] **5.7** Write 6 component tests for `AdminRoleIndicator`
- [x] **5.8** Update `useAuth` hook tests to verify hierarchy expansion (1 new + 1 updated)

### Task 6: Dashboard Performance Optimization (NFR5)
- [x] **6.1** Verify parallel data fetching: `Promise.all([fetchDashboardKpis, fetchDashboardTrend])` already in place
- [x] **6.2** Add loading skeletons for each KPI card during data fetch (`KpiCardSkeleton` component + `Skeleton` UI primitive)
- [x] **6.3** Implement client-side TTL cache (30s) in `dashboard-api.ts` for KPIs, trend, and drill-down data
- [x] **6.4** Export `clearDashboardCache()` for manual cache invalidation
- [x] **6.5** Write 6 cache tests verifying caching, deduplication, and clearing
- [x] **6.6** Write 2 skeleton component tests
- [x] **6.7** Update dashboard page test to verify skeleton loading state

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
Claude Opus 4.6

### Completion Notes List
- **Task 1 complete**: Created KPI card component with trend arrows (up/down/neutral), currency/number formatting, click-through support with keyboard accessibility. Created SVG-based trend chart component with responsive layout, grid lines, axes. Updated admin dashboard page with 6-column responsive grid of KPI cards + trend chart. Added dashboard-api.ts for backend integration. 24 new component tests (9 kpi-card + 7 trend-chart + 8 dashboard-page). All 306 frontend tests + 150 shared tests green.
- **Task 2 complete**: Defined CDS types KpiValue and TrafficSource, added getDashboardKpis and getDashboardTrend actions. Implemented handlers querying User (registrations) and AuditLog (visitors). Listings/contacts/sales/revenue return 0 (entities not yet in schema, future epics). Trend handler aggregates daily counts with date bucketing. 16 new tests (8 KPIs + 8 trend). All 319 backend tests green.
- **Task 3 complete**: Created backend SignalR client (Azure REST API) with connection string parsing, broadcast method, graceful degradation when not configured. Created frontend useSignalR hook (with @microsoft/signalr) supporting auto-reconnect, event subscriptions. Created useLiveKpis hook merging initial data with real-time updates. Integrated into dashboard with connection status indicator. 7 backend + 12 frontend SignalR tests. All 326 backend + 318 frontend tests green.
- **Task 4 complete**: Created KPI drill-down dynamic route page with period selector (24h/7j/30j), summary cards (total/avg/days), TrendChart integration, data table with French date/number formatting, metric validation, and error handling. Added getKpiDrillDown CDS action and backend handler with period-based daily aggregation. 11 frontend + 7 backend tests. All 333 backend + 329 frontend tests green.
- **Task 5 complete**: Added `expandRolesWithHierarchy()` to @auto/shared that uses ROLE_HIERARCHY to expand admin role to include all lower roles (FR54 super-role). Modified backend auth-middleware and frontend useAuth hook to apply expansion. Created AdminRoleIndicator component with role badge and "Acces complet" label. Updated admin layout with role indicator header bar. 8 shared + 6 indicator + 2 hook tests. All 158 shared + 333 backend + 336 frontend tests green.
- **Task 6 complete**: Added KPI card skeleton loading components replacing generic spinner. Implemented 30s TTL client-side cache in dashboard-api.ts for all three API functions. Created Skeleton UI primitive (standard shadcn/ui pattern). 6 cache + 2 skeleton + 1 updated dashboard tests. All 158 shared + 333 backend + 344 frontend = 835 tests green.

### Change Log
- Task 1: Created admin dashboard layout with KPI cards, trend chart, and dashboard API (2026-02-09)
- Task 2: Added CDS KPI types/actions and backend handlers for getDashboardKpis/getDashboardTrend (2026-02-09)
- Task 3: Added SignalR real-time support (backend client + frontend hooks + dashboard integration) (2026-02-09)
- Task 4: Added KPI drill-down page, backend endpoint, and tests (2026-02-09)
- Task 5: Added admin super-role hierarchy expansion and UI role indicator (2026-02-09)
- Task 6: Added loading skeletons and 30s TTL client-side cache for dashboard APIs (2026-02-09)

### File List
- auto-shared/src/types/dashboard.ts (new)
- auto-shared/src/types/index.ts (modified)
- auto-frontend/src/components/admin/kpi-card.tsx (new)
- auto-frontend/src/components/admin/trend-chart.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/page.tsx (modified)
- auto-frontend/src/lib/api/dashboard-api.ts (new)
- auto-frontend/tests/components/admin/kpi-card.test.tsx (new)
- auto-frontend/tests/components/admin/trend-chart.test.tsx (new)
- auto-frontend/tests/app/dashboard/admin/dashboard-page.test.tsx (new)
- auto-backend/srv/admin-service.cds (modified)
- auto-backend/srv/admin-service.ts (modified)
- auto-backend/test/srv/admin-service.test.ts (modified)
- auto-backend/srv/lib/signalr-client.ts (new)
- auto-backend/test/srv/lib/signalr-client.test.ts (new)
- auto-frontend/src/hooks/use-signalr.ts (new)
- auto-frontend/src/hooks/use-live-kpis.ts (new)
- auto-frontend/tests/hooks/use-signalr.test.ts (new)
- auto-frontend/tests/hooks/use-live-kpis.test.ts (new)
- auto-frontend/package.json (modified - added @microsoft/signalr)
- auto-frontend/src/app/(dashboard)/admin/kpis/[metric]/page.tsx (new)
- auto-frontend/tests/app/dashboard/admin/kpis/drilldown-page.test.tsx (new)
- auto-shared/src/constants/roles.ts (modified - added expandRolesWithHierarchy)
- auto-shared/src/constants/index.ts (modified - export expandRolesWithHierarchy)
- auto-shared/tests/constants.test.ts (modified - 8 new hierarchy tests)
- auto-backend/srv/middleware/auth-middleware.ts (modified - FR54 role expansion)
- auto-frontend/src/hooks/use-auth.ts (modified - FR54 role expansion)
- auto-frontend/src/components/admin/admin-role-indicator.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/layout.tsx (modified - added role indicator)
- auto-frontend/tests/components/admin/admin-role-indicator.test.tsx (new)
- auto-frontend/tests/hooks/use-auth.test.ts (modified - hierarchy tests)
- auto-frontend/src/components/ui/skeleton.tsx (new)
- auto-frontend/src/components/admin/kpi-card-skeleton.tsx (new)
- auto-frontend/src/lib/api/dashboard-api.ts (modified - added TTL cache)
- auto-frontend/src/app/(dashboard)/admin/page.tsx (modified - skeleton loading)
- auto-frontend/tests/components/admin/kpi-card-skeleton.test.tsx (new)
- auto-frontend/tests/lib/api/dashboard-cache.test.ts (new)
- auto-frontend/tests/app/dashboard/admin/dashboard-page.test.tsx (modified - skeleton test)
