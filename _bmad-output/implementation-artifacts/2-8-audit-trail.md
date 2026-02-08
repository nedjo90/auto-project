# Story 2.8: Audit Trail System

Status: ready-for-dev

## Story

As an administrator,
I want every sensitive operation on the platform systematically logged with actor, action, target, and timestamp,
so that I have complete traceability for compliance, debugging, and security investigations.

## Acceptance Criteria (BDD)

**Given** any sensitive operation occurs (payment, account modification, moderation action, admin config change, listing publication, role change)
**When** the `audit-trail` middleware processes the request
**Then** an `AuditTrailEntry` CDS record is created with: action (e.g., `listing.published`), actorId, actorRole, targetType, targetId, timestamp (ISO 8601), details (JSON with contextual data) (FR53)

**Given** an admin accesses the Audit Trail viewer
**When** they search the audit log
**Then** they can filter by: date range, actor, action type, target type, target ID
**And** results are displayed in a sortable, paginated data table
**And** each entry shows the full detail on click

**Given** every API call to external providers is made
**When** the `api-logger` middleware processes the call
**Then** an `ApiCallLog` record is created with: adapter name, provider, endpoint, HTTP status, response time (ms), cost, listing ID, timestamp

## Tasks / Subtasks

### Task 1: Define AuditTrailEntry CDS Entity (AC1)
- **1.1** Add `AuditTrailEntry` entity to `db/schema.cds`:
  - id: UUID
  - action: String (e.g., "listing.published", "config.updated", "user.role_changed", "payment.processed", "moderation.action_taken")
  - actorId: UUID (who performed the action)
  - actorRole: String (e.g., "admin", "seller", "buyer", "system")
  - targetType: String (e.g., "Listing", "User", "ConfigParameter", "Payment")
  - targetId: String (ID of the affected entity)
  - timestamp: Timestamp (ISO 8601)
  - details: LargeString (JSON string with contextual data: old values, new values, metadata)
  - ipAddress: String
  - userAgent: String
  - requestId: String (for correlating related operations)
  - severity: String (enum: "info", "warning", "critical")
- **1.2** Add database indexes on: timestamp, actorId, action, targetType, targetId for efficient querying
- **1.3** Expose in `admin-service.cds` as read-only (admins cannot modify audit entries)
- **1.4** Write unit tests for entity definition

### Task 2: Define ApiCallLog CDS Entity (AC3)
- **2.1** Add `ApiCallLog` entity to `db/schema.cds` (if not already created in Story 2.3):
  - id: UUID
  - adapterName: String (e.g., "SivAdapter", "HistoVecAdapter")
  - provider: String (e.g., "siv_api_gouv", "histovec_beta")
  - endpoint: String (API endpoint URL)
  - httpMethod: String
  - httpStatus: Integer
  - responseTimeMs: Integer
  - cost: Decimal
  - listingId: UUID (nullable, associated listing if applicable)
  - requestId: String
  - errorMessage: String (nullable, on failure)
  - timestamp: Timestamp
- **2.2** Add database indexes on: timestamp, provider, listingId
- **2.3** Expose in `admin-service.cds` as read-only
- **2.4** Write unit tests for entity definition

### Task 3: Implement Audit Trail Middleware (AC1)
- **3.1** Create `srv/middleware/audit-trail.ts`
- **3.2** Define an `AuditableAction` type/enum listing all sensitive operations:
  - `listing.created`, `listing.published`, `listing.updated`, `listing.deleted`, `listing.moderated`
  - `user.registered`, `user.updated`, `user.role_changed`, `user.deactivated`
  - `config.created`, `config.updated`, `config.deleted`
  - `payment.initiated`, `payment.processed`, `payment.refunded`
  - `moderation.action_taken`, `moderation.appeal_reviewed`
  - `legal.version_published`, `legal.acceptance_recorded`
  - `api_provider.status_changed`
- **3.3** Implement `auditLog(action, actorId, actorRole, targetType, targetId, details, severity?)` function
- **3.4** Function creates `AuditTrailEntry` record via CDS service layer
- **3.5** Extract ipAddress, userAgent, requestId from the current request context
- **3.6** Serialize details object to JSON string
- **3.7** Make the function async/non-blocking: audit logging must not slow down the primary operation
- **3.8** Write unit tests for auditLog function with various action types
- **3.9** Write unit tests for details serialization and request context extraction

### Task 4: Integrate Audit Trail into CDS Service Handlers (AC1)
- **4.1** Integrate into `admin-service.ts` AFTER handlers for all config entity mutations (CREATE/UPDATE/DELETE)
- **4.2** For UPDATE operations, capture and include old values in the details JSON
- **4.3** Integrate into listing-related service handlers (publish, update, delete, moderate)
- **4.4** Integrate into user-related service handlers (register, update profile, role change, deactivate)
- **4.5** Integrate into payment-related service handlers (initiate, process, refund)
- **4.6** Integrate into moderation-related service handlers (action taken, appeal reviewed)
- **4.7** Integrate into legal text service handlers (version publish, acceptance record)
- **4.8** Write integration tests for each integration point verifying audit entries are created

### Task 5: Implement API Logger Middleware (AC3)
- **5.1** Create `srv/middleware/api-logger.ts` (if not already created in Story 2.3)
- **5.2** Implement `logApiCall(adapterName, provider, endpoint, httpMethod, httpStatus, responseTimeMs, cost, listingId?, errorMessage?)` function
- **5.3** Function creates `ApiCallLog` record via CDS service layer
- **5.4** Integrate into the adapter base class: wrap every external API call with before/after logging
- **5.5** Capture timing: record start time before call, compute responseTimeMs after call
- **5.6** On error: log with httpStatus and errorMessage
- **5.7** Make logging async/non-blocking
- **5.8** Write unit tests for logApiCall function
- **5.9** Write integration tests for adapter integration

### Task 6: Implement Audit Trail Viewer Page (AC2)
- **6.1** Create `src/app/(dashboard)/admin/audit-trail/page.tsx`
- **6.2** Build a data table component with columns: timestamp, action, actor (name + role), target type, target ID, severity (colored badge), details (expandable)
- **6.3** Implement filter controls:
  - Date range picker (from/to)
  - Actor filter (search by name or ID)
  - Action type dropdown (multi-select from AuditableAction enum)
  - Target type dropdown (multi-select)
  - Target ID text input
  - Severity filter
- **6.4** Implement server-side pagination with configurable page size (25, 50, 100)
- **6.5** Implement column sorting (timestamp default desc, all columns sortable)
- **6.6** Implement detail view: click on a row to expand/show full details JSON in a formatted view
- **6.7** Wire all data fetching to AdminService OData endpoint with $filter, $orderby, $top, $skip
- **6.8** Write component tests for table rendering, filtering, sorting, pagination, and detail view

### Task 7: Implement API Call Log Viewer Page (AC3)
- **7.1** Create `src/app/(dashboard)/admin/audit-trail/api-calls/page.tsx` (or tab within audit trail)
- **7.2** Build a data table with columns: timestamp, adapter, provider, endpoint, HTTP status (colored badge), response time, cost, listing ID, error
- **7.3** Implement filter controls: date range, provider, adapter, HTTP status range, listing ID
- **7.4** Implement server-side pagination and sorting
- **7.5** Wire to AdminService OData endpoint for ApiCallLog
- **7.6** Write component tests for API call log viewer

### Task 8: Implement Audit Trail Data Retention Policy
- **8.1** Define retention policy in `ConfigParameter`: `audit_trail_retention_days` (default: 365)
- **8.2** Implement a scheduled cleanup job (`srv/jobs/audit-cleanup.ts`) that deletes entries older than retention period
- **8.3** Add `api_call_log_retention_days` parameter (default: 90)
- **8.4** Cleanup job runs daily (CDS cron or scheduled task)
- **8.5** Log cleanup actions to the audit trail itself (meta-audit)
- **8.6** Write unit tests for retention calculation logic
- **8.7** Write integration tests for cleanup job execution

### Task 9: Export and Compliance Features
- **9.1** Add CSV export button to audit trail viewer
- **9.2** Implement backend export endpoint: `action exportAuditTrail(filters: {...}) returns Binary`
- **9.3** Implement handler that streams filtered audit entries as CSV
- **9.4** Add export to API call log viewer
- **9.5** Write integration tests for export endpoints

## Dev Notes

### Architecture & Patterns
- The audit trail is implemented as a **middleware pattern**: `auditLog()` is a standalone function that can be called from any CDS service handler. It is not a CDS middleware in the traditional sense but a utility function called in AFTER handlers.
- **Non-blocking logging:** Audit trail writes must not slow down the primary operation. Use `await` but handle errors gracefully (log to console on failure, do not throw).
- **Two separate log types:** `AuditTrailEntry` is for business/security operations (who did what), `ApiCallLog` is for external API call tracking (cost, performance). They serve different purposes and have different retention policies.
- **Immutability:** Audit trail entries are **read-only** once created. The admin-service exposes them as read-only. No UPDATE or DELETE operations are allowed on audit entries.
- **Data retention:** Audit data grows continuously. The retention policy with scheduled cleanup prevents unbounded growth. Retention periods are configurable via `ConfigParameter` (zero-hardcode).
- The detail field stores a JSON string. This provides flexible schema for contextual data without requiring schema changes for new action types.
- The `requestId` field enables correlation of related audit entries within a single request (e.g., a listing publish that triggers both an audit entry and multiple API call logs).

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
- `db/schema.cds` - AuditTrailEntry and ApiCallLog entity definitions
- `srv/middleware/audit-trail.ts` - Audit trail logging utility function
- `srv/middleware/api-logger.ts` - API call logging middleware
- `srv/admin-service.cds` - Read-only exposure of AuditTrailEntry and ApiCallLog, export action
- `srv/admin-service.ts` - Audit trail query and export handlers
- `srv/jobs/audit-cleanup.ts` - Scheduled retention cleanup job
- `src/app/(dashboard)/admin/audit-trail/page.tsx` - Audit trail viewer page
- `src/app/(dashboard)/admin/audit-trail/api-calls/page.tsx` - API call log viewer page

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
