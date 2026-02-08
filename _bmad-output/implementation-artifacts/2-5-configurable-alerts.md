# Story 2.5: Configurable Alerts & Thresholds

Status: ready-for-dev

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
- **1.1** Add `ConfigAlert` entity to `db/config-schema.cds`:
  - id: UUID
  - name: String (human-readable alert name)
  - metric: String (e.g., "margin_per_listing", "api_availability", "daily_registrations")
  - thresholdValue: Decimal
  - comparisonOperator: String (enum: "above", "below", "equals")
  - notificationMethod: String (enum: "in_app", "email", "both")
  - severityLevel: String (enum: "info", "warning", "critical")
  - enabled: Boolean
  - cooldownMinutes: Integer (prevent alert spam)
  - lastTriggeredAt: Timestamp
- **1.2** Add `managed` aspect for audit fields
- **1.3** Create `db/data/ConfigAlert.csv` with default alerts:
  - Margin below 8 EUR (critical)
  - API availability below 95% (warning)
  - Zero registrations in 24h (warning)
- **1.4** Expose `ConfigAlert` in `admin-service.cds` with full CRUD
- **1.5** Add to config cache (InMemoryConfigCache) for fast alert evaluation
- **1.6** Write unit tests for entity definition and seed data

### Task 2: Define AlertEvent CDS Entity for Alert History (AC2)
- **2.1** Add `AlertEvent` entity to `db/schema.cds`:
  - id: UUID
  - alertId: UUID (reference to ConfigAlert)
  - metric: String
  - currentValue: Decimal
  - thresholdValue: Decimal
  - severity: String
  - message: String
  - acknowledged: Boolean
  - acknowledgedBy: String
  - acknowledgedAt: Timestamp
  - createdAt: Timestamp
- **2.2** Expose `AlertEvent` in `admin-service.cds` (read + acknowledge action)
- **2.3** Write unit tests for entity definition

### Task 3: Implement Alerts Configuration Page (AC1)
- **3.1** Create `src/app/(dashboard)/admin/alerts/page.tsx`
- **3.2** Build a data table listing all `ConfigAlert` entries with: name, metric, threshold, operator, severity (colored badge), enabled toggle, last triggered date
- **3.3** Build a create/edit form dialog with fields: name, metric (dropdown of available metrics), threshold value, comparison operator, notification method, severity level, cooldown
- **3.4** Wire form to AdminService OData CREATE/PATCH on `ConfigAlert`
- **3.5** Add enable/disable toggle with inline update
- **3.6** Write component tests for table, form, and toggle functionality

### Task 4: Implement Alert Evaluation Engine (AC2)
- **4.1** Create `srv/lib/alert-evaluator.ts` service class
- **4.2** Implement metric evaluation functions for each supported metric:
  - `margin_per_listing`: compute from ConfigParameter (listing price) minus average API costs (from ApiCallLog)
  - `api_availability`: compute from ApiCallLog success rate for a given time window
  - `daily_registrations`: count from User table for today
  - `daily_listings`: count from Listing table for today
  - `daily_revenue`: sum from Payment table for today
- **4.3** Implement threshold comparison: evaluate currentValue against threshold using the operator
- **4.4** Implement cooldown logic: skip alert if last triggered is within cooldown window
- **4.5** Create `AlertEvent` record when threshold is breached
- **4.6** Schedule periodic evaluation (CDS cron job or setInterval on startup) -- e.g., every 5 minutes
- **4.7** Write unit tests for each metric evaluation function
- **4.8** Write unit tests for threshold comparison and cooldown logic
- **4.9** Write integration tests for end-to-end alert evaluation

### Task 5: Implement Alert Notification Delivery (AC2)
- **5.1** Create `srv/lib/alert-notifier.ts` service class
- **5.2** Implement in-app notification: push alert to SignalR `/admin` hub as a `newAlert` event
- **5.3** Implement email notification: send alert email via configured email service (Azure Communication Services or similar)
- **5.4** Route notifications based on `notificationMethod` field: "in_app", "email", or "both"
- **5.5** Write unit tests for notification routing logic
- **5.6** Write integration tests for SignalR alert delivery

### Task 6: Display Active Alerts on Admin Dashboard (AC2)
- **6.1** Create `src/components/admin/alert-banner.tsx` component for displaying active alerts
- **6.2** Display unacknowledged alerts prominently at the top of the admin dashboard
- **6.3** Color-code by severity: info (blue), warning (yellow), critical (red)
- **6.4** Add "Acknowledge" button to dismiss alert from dashboard view
- **6.5** Wire acknowledge action to AdminService (PATCH AlertEvent.acknowledged = true)
- **6.6** Real-time: listen for `newAlert` SignalR events and display immediately
- **6.7** Write component tests for alert banner rendering, severity styling, and acknowledge flow

### Task 7: Implement API Provider Failure Auto-Alert (AC3)
- **7.1** Extend `srv/middleware/api-logger.ts` to track consecutive failures per provider
- **7.2** Define failure threshold: e.g., 3 consecutive failures triggers alert
- **7.3** When threshold is reached, create an `AlertEvent` with: provider name, failure count, last success timestamp, severity "critical"
- **7.4** Trigger notification via `alert-notifier.ts`
- **7.5** Reset failure counter on next successful call
- **7.6** Write unit tests for consecutive failure tracking
- **7.7** Write integration tests for automatic alert triggering on API failure

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
- `db/config-schema.cds` - ConfigAlert entity definition
- `db/schema.cds` - AlertEvent entity definition
- `db/data/ConfigAlert.csv` - Default alert seed data
- `src/app/(dashboard)/admin/alerts/page.tsx` - Alerts configuration page
- `src/components/admin/alert-banner.tsx` - Active alerts banner for dashboard
- `srv/lib/alert-evaluator.ts` - Periodic alert evaluation engine
- `srv/lib/alert-notifier.ts` - Alert notification delivery (in-app, email)
- `srv/middleware/api-logger.ts` - Extended with consecutive failure tracking
- `srv/admin-service.cds` - ConfigAlert CRUD + AlertEvent read/acknowledge
- `srv/admin-service.ts` - Alert-related handlers

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
