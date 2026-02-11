# Story 2.5: Configurable Alerts & Thresholds

Status: done

## Story

As an administrator,
I want to configure alerts on business thresholds (minimum margin, API availability, etc.),
so that I'm notified immediately when critical metrics deviate from expected values.

## Acceptance Criteria (BDD)

**Given** an admin accesses the Alerts configuration page (FR45)
**When** they create or edit an alert
**Then** they can define: metric to monitor, threshold value, comparison operator (above/below), notification method (in-app, email), severity level
**And** alerts are stored in a `ConfigAlert` CDS entity (zero-hardcode)

**Given** an alert threshold is breached
**When** the system detects the breach (e.g., margin per listing drops below 8 EUR)
**Then** the admin is notified via the configured method
**And** the alert is displayed prominently on the admin dashboard
**And** the alert event is logged

**Given** an API provider becomes unavailable (NFR36)
**When** the `api-logger` middleware detects consecutive failures
**Then** an automatic alert is triggered to the admin with provider name, failure count, and last success timestamp

## Tasks / Subtasks

### Task 1: Define ConfigAlert CDS Entity (AC1)
- [x] **1.1** Add `ConfigAlert` entity to `db/config-schema.cds`
- [x] **1.2** Add `managed` aspect for audit fields
- [x] **1.3** Create `db/data/ConfigAlert.csv` with default alerts
- [x] **1.4** Expose `ConfigAlert` in `admin-service.cds` with full CRUD
- [x] **1.5** Add to config cache (InMemoryConfigCache) for fast alert evaluation
- [x] **1.6** Write unit tests for entity definition and seed data

### Task 2: Define AlertEvent CDS Entity for Alert History (AC2)
- [x] **2.1** Add `AlertEvent` entity to `db/schema.cds`
- [x] **2.2** Expose `AlertEvent` in `admin-service.cds` (read + acknowledge action)
- [x] **2.3** Write unit tests for entity definition

### Task 3: Implement Alerts Configuration Page (AC1)
- [x] **3.1** Create `src/app/(dashboard)/admin/alerts/page.tsx`
- [x] **3.2** Build a data table listing all `ConfigAlert` entries
- [x] **3.3** Build a create/edit form dialog with all fields
- [x] **3.4** Wire form to AdminService OData CREATE/PATCH on `ConfigAlert`
- [x] **3.5** Add enable/disable toggle with inline update
- [x] **3.6** Write component tests for table, form, and toggle functionality

### Task 4: Implement Alert Evaluation Engine (AC2)
- [x] **4.1** Create `srv/lib/alert-evaluator.ts` service class
- [x] **4.2** Implement metric evaluation functions for each supported metric
- [x] **4.3** Implement threshold comparison
- [x] **4.4** Implement cooldown logic
- [x] **4.5** Create `AlertEvent` record when threshold is breached
- [x] **4.6** Schedule periodic evaluation on startup
- [x] **4.7** Write unit tests for each metric evaluation function
- [x] **4.8** Write unit tests for threshold comparison and cooldown logic
- [x] **4.9** Write integration tests for end-to-end alert evaluation

### Task 5: Implement Alert Notification Delivery (AC2)
- [x] **5.1** Create `srv/lib/alert-notifier.ts` service class
- [x] **5.2** Implement in-app notification via SignalR `newAlert` event
- [x] **5.3** Implement email notification placeholder
- [x] **5.4** Route notifications based on `notificationMethod` field
- [x] **5.5** Write unit tests for notification routing logic
- [x] **5.6** Write integration tests for SignalR alert delivery

### Task 6: Display Active Alerts on Admin Dashboard (AC2)
- [x] **6.1** Create `src/components/admin/alert-banner.tsx` component
- [x] **6.2** Display unacknowledged alerts prominently on dashboard
- [x] **6.3** Color-code by severity: info (blue), warning (yellow), critical (red)
- [x] **6.4** Add "Acknowledge" button to dismiss alert
- [x] **6.5** Wire acknowledge action to AdminService
- [x] **6.6** Real-time: listen for `newAlert` SignalR events
- [x] **6.7** Write component tests for alert banner

### Task 7: Implement API Provider Failure Auto-Alert (AC3)
- [x] **7.1** Extend `srv/lib/api-logger.ts` to track consecutive failures per provider
- [x] **7.2** Define failure threshold: 3 consecutive failures triggers alert
- [x] **7.3** When threshold is reached, create `AlertEvent` with provider details
- [x] **7.4** Trigger notification via `alert-notifier.ts`
- [x] **7.5** Reset failure counter on next successful call
- [x] **7.6** Write unit tests for consecutive failure tracking
- [x] **7.7** Write integration tests for automatic alert triggering

## Dev Notes

### Architecture & Patterns
- The alert system has three layers: **Configuration** (ConfigAlert entity), **Evaluation** (alert-evaluator.ts periodic checks), and **Notification** (alert-notifier.ts delivery).
- Alert evaluation runs on a **periodic schedule** (e.g., every 5 minutes) for threshold-based alerts. API failure alerts are **event-driven** (triggered immediately by the api-logger middleware).
- The **cooldown mechanism** prevents alert spam: once an alert fires, it will not fire again until the cooldown period expires.
- Alert events are persisted for audit/history purposes. The `AlertEvent` entity provides a complete record of when alerts were triggered, the values at the time, and who acknowledged them.
- The API provider failure detection is separate from the periodic evaluation -- it must be real-time within the api-logger middleware to ensure immediate notification (NFR36).
- `ConfigAlert` follows the zero-hardcode pattern: new metrics can be added to the evaluator without changing the CDS model.

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 App Router frontend, PostgreSQL, Azure
- **Multi-repo:** auto-backend, auto-frontend, auto-shared (@auto/shared via Azure Artifacts)
- **Config:** Zero-hardcode - 13 config tables in DB (added ConfigAlert), InMemoryConfigCache (Redis-ready interface)
- **Admin service:** admin-service.cds + admin-service.ts
- **Adapter Pattern:** 8 interfaces, Factory resolves active impl from ConfigApiProvider table
- **API logging:** Every external API call logged (provider, cost, status, time) via api-logger middleware
- **Audit trail:** Systematic logging via audit-trail middleware on all sensitive operations
- **Error handling:** RFC 7807 (Problem Details) for custom endpoints
- **Frontend admin:** src/app/(dashboard)/admin/* pages (SPA behind auth)
- **Real-time:** Azure SignalR /admin hub for live KPIs + alert events
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
- `db/schema/config.cds` - ConfigAlert entity definition
- `db/schema/audit.cds` - AlertEvent entity definition
- `db/data/auto-ConfigAlert.csv` - Default alert seed data
- `src/app/(dashboard)/admin/alerts/page.tsx` - Alerts configuration page
- `src/components/admin/alert-banner.tsx` - Active alerts banner for dashboard
- `srv/lib/alert-evaluator.ts` - Periodic alert evaluation engine
- `srv/lib/alert-notifier.ts` - Alert notification delivery (in-app, email)
- `srv/lib/api-logger.ts` - Extended with consecutive failure tracking
- `srv/admin-service.cds` - ConfigAlert CRUD + AlertEvent read/acknowledge
- `srv/admin-service.ts` - Alert-related handlers

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- **Task 1 complete**: Added ConfigAlert entity to config.cds with managed aspect, @assert.unique name constraint. Created seed CSV with 3 alerts (margin critical, API availability warning, zero registrations warning). Exposed in admin-service. Added to config cache (13 tables). Added all shared types (IConfigAlert, IAlertEvent, enums) and constants. Created Zod v4 configAlertInputSchema validator. 31 new shared tests (8 type + 23 validator). Updated config-cache test counts. All 189 shared + 333 backend tests green.
- **Task 2 complete**: Added AlertEvent entity to audit.cds. Exposed AlertEvents (readonly) and added acknowledgeAlert/getActiveAlerts actions to admin-service.cds. Implemented handlers with validation, acknowledgement flow, and audit logging. Added ConfigAlert to ENTITY_TABLE_MAP. 8 new backend tests. All 341 backend tests green.
- **Task 3 complete**: Added ConfigAlerts to VALID_ENTITIES in config-api.ts. Created alerts-api.ts with fetchActiveAlerts/acknowledgeAlert. Added Alertes sidebar link. Created alert-form-dialog.tsx (create/edit dialog with all form fields). Created admin/alerts/page.tsx (data table, create/edit/toggle). 23 new frontend tests (14 page + 9 dialog). All 368 frontend tests green.
- **Task 4 complete**: Created alert-evaluator.ts with evaluateMetric() for 5 metrics, isThresholdBreached() comparison, isCooldownActive() cooldown, createAlertEvent() DB insertion, runEvaluationCycle() orchestrator, startPeriodicEvaluation()/stopPeriodicEvaluation() scheduling. 21 new backend tests. All 362 backend tests green.
- **Task 5 complete**: Created alert-notifier.ts with sendAlertNotification() routing, sendInAppNotification() via SignalR, sendEmailNotification() placeholder. Added "newAlert" to SignalREvent type. Wired notifier into evaluator cycle and periodic evaluation into server.ts startup. 6 new backend tests. All 374 backend tests green.
- **Task 6 complete**: Created alert-banner.tsx component (fetches active alerts, severity styling red/yellow/blue, acknowledge flow, SignalR real-time newAlert events). Integrated into admin dashboard page.tsx. 8 new frontend tests. All 376 frontend tests green.
- **Task 7 complete**: Extended api-logger.ts with failureCounters Map, trackProviderFailure() function (increment on failure, reset on success), FAILURE_THRESHOLD=3 auto-alert trigger via createAlertEvent + sendAlertNotification. Added getFailureState/resetFailureCounters exports. 8 new api-logger tests with mocks for alert-evaluator/alert-notifier. All 189 shared + 382 backend + 376 frontend = 947 tests green.

### Change Log
- Task 1: Added ConfigAlert entity, shared types/constants/validators, config cache integration (2026-02-11)
- Task 2: Added AlertEvent entity, acknowledgeAlert/getActiveAlerts service actions and handlers (2026-02-11)
- Task 3: Created alerts configuration page with data table, form dialog, sidebar link (2026-02-11)
- Task 4: Created alert evaluation engine with metric evaluation, threshold comparison, cooldown, periodic scheduling (2026-02-11)
- Task 5: Created alert notification delivery (SignalR in-app + email placeholder), wired into evaluation cycle and server startup (2026-02-11)
- Task 6: Created alert banner component on admin dashboard with real-time updates and acknowledge flow (2026-02-11)
- Task 7: Added API provider consecutive failure tracking and auto-alert in api-logger (2026-02-11)

### Senior Developer Review

**Review Date:** 2026-02-11
**Findings:** 14 total (2 critical, 4 high, 6 medium, 2 low)
**Fixed:** 11 | **Deferred:** 3 (low-priority)

#### Fixed Findings

| # | Severity | Description | Fix |
|---|----------|-------------|-----|
| F1 | Critical | `isThresholdBreached` `equals` used strict equality (`===`) — fails for floating-point (0.1+0.2≠0.3) | Changed to epsilon-based comparison (`Math.abs(a-b) < 1e-6`) |
| F2 | High | `getActiveAlerts` unbounded SELECT could return thousands of rows | Added `.orderBy("createdAt desc").limit(50)` |
| F3 | High | No Zod validation on ConfigAlert CRUD — invalid data could bypass frontend | Added `configAlertInputSchema` validation in BEFORE handler |
| F4 | High | `failureCounters` Map unbounded — could grow indefinitely with many providers | Added `MAX_TRACKED_PROVIDERS=1000` cap with FIFO eviction |
| F5 | High | `createAlertEvent` UPDATE on `lastTriggeredAt` fails for synthetic auto-alert IDs | Skip UPDATE when `alert.ID.startsWith("auto-")` |
| F6 | Medium | `evaluateMetric` loaded full tables into memory for counting | Changed to aggregate queries (`SELECT.one ... count(*) as cnt`) |
| F7 | Medium | Alert message duplicated between `createAlertEvent` and `runEvaluationCycle` | Changed `createAlertEvent` to return `{ id, message }`, DRY message construction |
| F8 | Medium | `AlertEvent.alertId` is loose String, not Association — unclear why | Added CDS comment explaining synthetic auto-alert IDs |
| F9 | Medium | `thresholdValue` from cache could be string, not number | Added `Number()` normalization in `runEvaluationCycle` |
| F11 | Medium | No cleanup of periodic evaluation interval on shutdown | Added `cds.on("shutdown")` handler calling `stopPeriodicEvaluation()` |
| F12 | Medium | Missing server-side validation (covered by F3) | Resolved via F3 Zod validation |

#### Deferred Findings (Low Priority)

| # | Severity | Description | Reason |
|---|----------|-------------|--------|
| F10 | Low | No delete UI for alerts — only create/edit/toggle | Non-critical; admin can disable alerts instead |
| F13 | Low | No polling fallback if SignalR connection drops | Out of scope; existing SignalR reconnect handles it |
| F14 | Low | ConfigAlert `@assert.unique` on name — could cause label collision UX issues | Edge case; Zod + DB constraint provide sufficient protection |

**Post-fix test results:** 189 shared + 383 backend + 376 frontend = **948 tests green**

### File List
- auto-shared/src/types/config.ts (modified - added alert types)
- auto-shared/src/types/index.ts (modified - added alert exports)
- auto-shared/src/constants/alerts.ts (new)
- auto-shared/src/constants/index.ts (modified - added alert exports)
- auto-shared/src/validators/alert.validator.ts (new)
- auto-shared/src/validators/index.ts (modified - added alert exports)
- auto-shared/tests/alert-types.test.ts (new)
- auto-shared/tests/alert-validator.test.ts (new)
- auto-backend/db/schema/config.cds (modified - added ConfigAlert)
- auto-backend/db/schema/audit.cds (modified - added AlertEvent)
- auto-backend/db/data/auto-ConfigAlert.csv (new)
- auto-backend/srv/admin-service.cds (modified - added ConfigAlerts, AlertEvents, actions)
- auto-backend/srv/admin-service.ts (modified - added alert handlers, ENTITY_TABLE_MAP)
- auto-backend/srv/server.ts (modified - wired startPeriodicEvaluation)
- auto-backend/srv/lib/config-cache.ts (modified - added ConfigAlert to cache)
- auto-backend/srv/lib/signalr-client.ts (modified - added newAlert event type)
- auto-backend/srv/lib/alert-evaluator.ts (new)
- auto-backend/srv/lib/alert-notifier.ts (new)
- auto-backend/srv/lib/api-logger.ts (modified - added failure tracking)
- auto-backend/test/srv/admin-service.test.ts (modified - added alert tests)
- auto-backend/test/srv/lib/config-cache.test.ts (modified - updated table counts)
- auto-backend/test/srv/lib/alert-evaluator.test.ts (new)
- auto-backend/test/srv/lib/alert-notifier.test.ts (new)
- auto-backend/test/srv/lib/api-logger.test.ts (modified - added failure tracking tests)
- auto-frontend/src/lib/api/config-api.ts (modified - added ConfigAlerts)
- auto-frontend/src/lib/api/alerts-api.ts (new)
- auto-frontend/src/components/layout/sidebar.tsx (modified - added Alertes link)
- auto-frontend/src/components/admin/alert-form-dialog.tsx (new)
- auto-frontend/src/components/admin/alert-banner.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/alerts/page.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/page.tsx (modified - added AlertBanner)
- auto-frontend/tests/app/dashboard/admin/alerts/alerts-page.test.tsx (new)
- auto-frontend/tests/components/admin/alert-form-dialog.test.tsx (new)
- auto-frontend/tests/components/admin/alert-banner.test.tsx (new)
