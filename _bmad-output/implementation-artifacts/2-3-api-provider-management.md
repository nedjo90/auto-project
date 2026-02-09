# Story 2.3: API Provider Management & Cost Tracking

Status: done

## Story

As an administrator,
I want to manage API providers (activate, deactivate, monitor costs) and track the margin per listing,
so that I can optimize costs and switch providers without developer intervention.

## Acceptance Criteria (BDD)

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
**Then** they see: total API cost per day/week/month, cost breakdown by provider, average cost per listing, margin per listing (15 EUR revenue minus cumulative API costs)
**And** data is sourced from the `ApiCallLog` table

**Given** the admin wants to compare providers
**When** they view provider analytics
**Then** they see cost per call, response time average, success rate, and downtime history for each provider

## Tasks / Subtasks

### Task 1: Implement API Providers List Page (AC1)
- [x] **1.1** Create `src/app/(dashboard)/admin/config/providers/page.tsx`
- [x] **1.2** Build a data table component listing all `ConfigApiProvider` entries
- [x] **1.3** Display columns: provider name, adapter interface, status (with colored badge: green=active, yellow=standby, gray=disabled), cost per call, availability rate, last call timestamp
- [x] **1.4** Fetch provider data from AdminService OData endpoint
- [x] **1.5** Compute availability rate from `ApiCallLog` data (success calls / total calls)
- [x] **1.6** Compute last call timestamp from most recent `ApiCallLog` entry per provider
- [x] **1.7** Write component tests for table rendering and data display

### Task 2: Implement Provider Status Switching (AC2)
- [x] **2.1** Add status change controls (dropdown or button group) to each provider row
- [x] **2.2** Implement business logic: only one provider per adapter interface can be active at a time
- [x] **2.3** Create a confirmation dialog: "Switching from [current] to [new] for [interface]. This will take effect immediately."
- [x] **2.4** Wire status change to AdminService OData PATCH on `ConfigApiProvider`
- [x] **2.5** Verify the `AdapterFactory` reads from config cache and resolves the newly active provider
- [x] **2.6** Write integration test: switch provider status, verify AdapterFactory resolves new provider
- [x] **2.7** Write component tests for status switch UI and confirmation flow

### Task 3: Implement AdapterFactory Config Cache Integration (AC2)
- [x] **3.1** Ensure `srv/adapters/factory/adapter-factory.ts` reads active provider from `InMemoryConfigCache` (not DB)
- [x] **3.2** `AdapterFactory.getAdapter(interfaceName: string)` resolves the provider with status=active for the given interface
- [x] **3.3** Add fallback logic: if no active provider, throw a descriptive error
- [x] **3.4** Write unit tests for factory resolution from cache, including fallback scenarios

### Task 4: Implement Cost Tracking Dashboard (AC3)
- [x] **4.1** Create `src/app/(dashboard)/admin/config/costs/page.tsx` (tab within config hub)
- [x] **4.2** Build summary cards: total API cost today/this week/this month
- [x] **4.3** Build cost breakdown table by provider
- [x] **4.4** Compute and display average cost per call: total API costs / total calls
- [x] **4.5** Compute and display margin per listing: listing price (15 EUR) minus average API costs
- [x] **4.6** Create backend aggregation endpoint: `action getApiCostSummary(period: String) returns { ... }` in `admin-service.cds`
- [x] **4.7** Implement aggregation handler in `admin-service.ts` querying `ApiCallLog` with GROUP BY provider, date ranges
- [x] **4.8** Write integration tests for the cost summary endpoint
- [x] **4.9** Write component tests for cost dashboard rendering

### Task 5: Implement Provider Analytics Comparison (AC4)
- [x] **5.1** Create `src/app/(dashboard)/admin/config/analytics/page.tsx` (tab within config hub)
- [x] **5.2** Build comparison table/cards per provider showing: cost per call, average response time, success rate (%), last call timestamp
- [x] **5.3** Create backend analytics endpoint: `action getProviderAnalytics(providerKey: String) returns { ... }` in `admin-service.cds`
- [x] **5.4** Implement handler in `admin-service.ts` computing metrics from `ApiCallLog`:
  - Average cost per call (AVG of cost field)
  - Average response time (AVG of responseTime field)
  - Success rate (count of status 2xx / total count)
  - Last call timestamp (MAX of timestamp)
- [x] **5.5** Write integration tests for the analytics endpoint
- [x] **5.6** Write component tests for analytics comparison view

### Task 6: Implement ApiCallLog CDS Entity and API Logger Middleware (AC3, AC4)
- [x] **6.1** Define `ApiCallLog` CDS entity in `db/schema/audit.cds`: adapter, provider, endpoint, httpStatus, responseTimeMs, cost, listingId, timestamp, requestId
- [x] **6.2** Implement `srv/lib/api-logger.ts` middleware that creates `ApiCallLog` entries after each external API call
- [x] **6.3** Integrate api-logger into the adapter factory so every adapter call is automatically logged via `wrapWithLogging`
- [x] **6.4** Write unit tests for api-logger middleware
- [x] **6.5** Write integration tests verifying log entries are created for API calls (adapter-factory.test.ts)

### Task 7: Audit Trail Integration for Provider Switches (AC2)
- [x] **7.1** Ensure ConfigApiProvider status changes trigger audit trail entries via admin-service AFTER handlers (from Story 2.1)
- [x] **7.2** Audit entry includes: old status, new status, provider name, actor, timestamp
- [x] **7.3** Write integration test: switch provider, verify audit trail entry

## Dev Notes

### Architecture & Patterns
- **Adapter Pattern** is central to this story. The `AdapterFactory` must resolve the active implementation from the `ConfigApiProvider` table via the config cache. This enables zero-downtime provider switching.
- Provider switching follows a **mutual exclusion** rule: only one provider per adapter interface can have status "active" at a time. The UI and backend must enforce this constraint.
- The `ApiCallLog` entity is the data source for all cost tracking and analytics. The `api-logger` middleware must be integrated at the adapter base class level to capture every external call.
- Cost aggregation queries can be expensive on large datasets. Consider pagination and date-range filtering for the analytics endpoints. Future optimization: materialized views or pre-computed daily summaries.
- Margin calculation: revenue per listing (from ConfigParameter "listingPrice") minus cumulative API costs for that listing (from ApiCallLog grouped by listingId).

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
- `src/app/(dashboard)/admin/config/providers/page.tsx` - Provider list page
- `src/app/(dashboard)/admin/config/costs/page.tsx` - Cost tracking dashboard
- `src/app/(dashboard)/admin/config/analytics/page.tsx` - Provider analytics comparison
- `srv/adapters/factory/adapter-factory.ts` - AdapterFactory resolving active provider from config cache
- `srv/lib/api-logger.ts` - API call logging middleware
- `db/schema/audit.cds` - ApiCallLog entity definition
- `srv/admin-service.cds` - getApiCostSummary and getProviderAnalytics actions
- `srv/admin-service.ts` - Handler implementations for cost/analytics endpoints

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- **Task 1**: Enhanced existing providers page (`config/providers/page.tsx`) with availability rate (success rate from analytics) and last call timestamp columns. Added `lastCallTimestamp` field to backend `getProviderAnalytics` action return type and handler implementation. Updated 14 frontend component tests (all passing).
- **Tasks 2-4**: Already fully implemented in Stories 2-1 (config-engine) and 2-2 (platform-config-ui). Provider switching with mutual exclusion, confirmation dialog, AdapterFactory config cache integration, cost tracking dashboard with period selector, summary cards, margin calculation, and cost breakdown table — all verified with passing tests.
- **Task 5**: Created new analytics comparison page at `config/analytics/page.tsx`. Displays summary cards (active providers, total calls, total cost, average availability) and comparison table with cost/call, avg response time, success rate, last call timestamp per provider. Added "Analytique API" tab to config layout. 15 component tests written and passing.
- **Task 6**: ApiCallLog CDS entity and api-logger utility already existed. Integrated `withApiLogging` wrapper into adapter factory via `wrapWithLogging` function — every adapter method call is now automatically logged to ApiCallLog with interface, provider, cost, status, response time. 3 new integration tests in adapter-factory.test.ts verify logging on success, failure, and across all methods.
- **Task 7**: Audit trail for provider switches already implemented in `switchProvider` action handler, logging `PROVIDER_SWITCHED` events with old/new provider details. Verified with existing integration tests.
- **Shared package**: Added `IApiCallLog` type to `@auto/shared` types for cross-repo type safety.

### Change Log
- 2026-02-09: Story 2.3 implementation complete — all 7 tasks, 734 tests passing (150 shared + 303 backend + 281 frontend)
- 2026-02-09: Code review completed — 7 findings (2 HIGH, 3 MEDIUM, 2 LOW). Fixed F1 (parallel analytics loading), F2 (90-day lookback), F3 (endpoint name fix), F6 (deprecated provider test). F4/F5/F7 accepted as deviations. Final: 735 tests (150 shared + 303 backend + 282 frontend)

### File List

**auto-backend (modified)**
- `srv/admin-service.cds` — Added `lastCallTimestamp` field to `getProviderAnalytics` return type
- `srv/admin-service.ts` — Added `lastCallTimestamp` computation from ApiCallLog timestamps
- `srv/adapters/factory/adapter-factory.ts` — Added `wrapWithLogging` function, integrated api-logger into `resolveAdapter`
- `test/srv/admin-service.test.ts` — Updated `getProviderAnalytics` tests for `lastCallTimestamp`
- `test/srv/adapters/adapter-factory.test.ts` — Added api-logger mock and 3 logging integration tests

**auto-frontend (modified)**
- `src/app/(dashboard)/admin/config/providers/page.tsx` — Replaced URL/calls columns with availability rate + last call timestamp
- `src/app/(dashboard)/admin/config/layout.tsx` — Added "Analytique API" tab
- `src/lib/api/config-api.ts` — Added `lastCallTimestamp` field to `ProviderAnalytics` type
- `tests/app/dashboard/admin/config/providers-page.test.tsx` — Updated mock data and tests for new columns

**auto-frontend (new)**
- `src/app/(dashboard)/admin/config/analytics/page.tsx` — Provider analytics comparison page
- `tests/app/dashboard/admin/config/analytics-page.test.tsx` — 15 component tests

**auto-shared (modified)**
- `src/types/config.ts` — Added `IApiCallLog` interface
- `src/types/index.ts` — Exported `IApiCallLog`
