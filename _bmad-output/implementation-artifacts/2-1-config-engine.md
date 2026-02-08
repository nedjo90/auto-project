# Story 2.1: Zero-Hardcode Configuration Engine

Status: ready-for-dev

## Story

As an administrator,
I want all platform values, texts, rules, and settings stored in database configuration tables with an in-memory cache,
so that I can modify any business parameter without developer intervention.

## Acceptance Criteria (BDD)

**Given** the backend is initialized
**When** the CDS models are deployed
**Then** the following config CDS entities exist: `ConfigParameter`, `ConfigText`, `ConfigFeature`, `ConfigBoostFactor`, `ConfigVehicleType`, `ConfigListingDuration`, `ConfigReportReason`, `ConfigChatAction`, `ConfigModerationRule`, `ConfigApiProvider`
**And** each entity has seed data loaded from CSV files
**And** all entities have full OData CRUD via the `AdminService`

**Given** config data exists in the database
**When** the backend starts or a config value is mutated by the admin
**Then** an `InMemoryConfigCache` singleton loads/refreshes all config values
**And** the cache implements the `IConfigCache` interface (ready for Redis swap)
**And** all services read config values from the cache, never directly from the database

**Given** an admin modifies a config value via the admin API
**When** the change is saved
**Then** the cache is invalidated and refreshed
**And** the change is recorded in the audit trail with the old value, new value, actor, and timestamp
**And** the change takes effect immediately across the platform

## Tasks / Subtasks

### Task 1: Define CDS Config Schema (AC1)
- **1.1** Create `db/config-schema.cds` with all 10 config entities:
  - `ConfigParameter` (key: String, value: String, type: String, category: String, description: String)
  - `ConfigText` (key: String, language: String, value: LargeString, category: String)
  - `ConfigFeature` (key: String, enabled: Boolean, description: String)
  - `ConfigBoostFactor` (key: String, factor: Decimal, description: String)
  - `ConfigVehicleType` (key: String, label: String, active: Boolean)
  - `ConfigListingDuration` (key: String, days: Integer, label: String, active: Boolean)
  - `ConfigReportReason` (key: String, label: String, severity: String, active: Boolean)
  - `ConfigChatAction` (key: String, label: String, active: Boolean)
  - `ConfigModerationRule` (key: String, condition: String, action: String, active: Boolean)
  - `ConfigApiProvider` (key: String, adapterInterface: String, status: String, costPerCall: Decimal, baseUrl: String, active: Boolean)
- **1.2** Add common audit fields to all entities (createdAt, createdBy, modifiedAt, modifiedBy) using `managed` aspect
- **1.3** Add appropriate CDS annotations for validation constraints
- **1.4** Write unit tests verifying all 10 entities compile and deploy correctly

### Task 2: Create CSV Seed Data (AC1)
- **2.1** Create `db/data/ConfigParameter.csv` with initial platform parameters (listing price = 15, etc.)
- **2.2** Create `db/data/ConfigText.csv` with initial UI texts (FR language)
- **2.3** Create `db/data/ConfigFeature.csv` with initial feature toggles
- **2.4** Create `db/data/ConfigBoostFactor.csv` with initial boost factors
- **2.5** Create `db/data/ConfigVehicleType.csv` with French vehicle types
- **2.6** Create `db/data/ConfigListingDuration.csv` with listing duration options
- **2.7** Create `db/data/ConfigReportReason.csv` with report reasons
- **2.8** Create `db/data/ConfigChatAction.csv` with chat action types
- **2.9** Create `db/data/ConfigModerationRule.csv` with moderation rules
- **2.10** Create `db/data/ConfigApiProvider.csv` with API providers (SIV, HistoVec, Argus, etc.)
- **2.11** Write integration tests verifying seed data loads on deploy

### Task 3: Expose Config Entities via AdminService (AC1)
- **3.1** Define `srv/admin-service.cds` exposing all 10 config entities with full CRUD
- **3.2** Add `@requires: 'admin'` authorization annotation to the AdminService
- **3.3** Implement `srv/admin-service.ts` handler skeleton with BEFORE/AFTER hooks for mutations
- **3.4** Write integration tests for OData CRUD operations on each config entity

### Task 4: Implement IConfigCache Interface and InMemoryConfigCache (AC2)
- **4.1** Define `srv/lib/config-cache.ts` with `IConfigCache` interface:
  - `get<T>(table: string, key: string): T | undefined`
  - `getAll<T>(table: string): T[]`
  - `invalidate(table?: string): void`
  - `refresh(): Promise<void>`
  - `isReady(): boolean`
- **4.2** Implement `InMemoryConfigCache` class as singleton implementing `IConfigCache`
- **4.3** Load all config tables into Map-based memory structure on `refresh()`
- **4.4** Add Redis-ready interface documentation (comments describing Redis swap strategy)
- **4.5** Write unit tests for cache get, getAll, invalidate, refresh, isReady
- **4.6** Write unit tests verifying the cache is a singleton

### Task 5: Wire Cache Initialization on Backend Startup (AC2)
- **5.1** Add cache initialization in the CDS bootstrap (`server.ts` or CDS `init` event)
- **5.2** Ensure all services resolve config values from `InMemoryConfigCache`, never direct DB
- **5.3** Write integration test: start server, verify cache is populated with seed data

### Task 6: Implement Cache Invalidation on Admin Mutation (AC3)
- **6.1** In `admin-service.ts` AFTER handlers for CREATE/UPDATE/DELETE, call `configCache.invalidate(entityName)`
- **6.2** Re-load the affected config table from DB into cache after invalidation
- **6.3** Write integration test: update ConfigParameter via admin API, verify cache returns new value

### Task 7: Integrate Audit Trail Logging on Config Changes (AC3)
- **7.1** In `admin-service.ts` BEFORE handlers, capture old values for UPDATE/DELETE operations
- **7.2** In AFTER handlers, log to audit trail: action, actorId, old value, new value, timestamp
- **7.3** Write integration test: modify config, verify AuditTrailEntry is created with correct fields

### Task 8: Add @auto/shared Types for Config Entities
- **8.1** Define TypeScript interfaces in `@auto/shared` for all 10 config entity types
- **8.2** Export config cache interface types for potential frontend consumption
- **8.3** Write type compilation tests

## Dev Notes

### Architecture & Patterns
- The config engine is the **foundation** for all of Epic 2. All other stories (2.2-2.8) depend on this being completed first.
- `IConfigCache` is designed as an interface to allow Redis swap in production without changing consumers. The `InMemoryConfigCache` is the MVP implementation.
- Cache invalidation strategy: on any admin mutation (CREATE/UPDATE/DELETE) on a config entity, invalidate the specific table cache and re-fetch from DB. This is a simple but effective approach for single-instance deployments.
- All 10 config tables follow a consistent pattern: key-based lookup, category grouping, managed aspect for audit fields.
- The AdminService must be the **only** entry point for config mutations -- no direct DB writes allowed.

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
- `db/config-schema.cds` - All 10 config CDS entity definitions
- `db/data/*.csv` - Seed data for each config entity
- `srv/admin-service.cds` - AdminService CDS definition exposing config entities
- `srv/admin-service.ts` - AdminService handler with BEFORE/AFTER hooks
- `srv/lib/config-cache.ts` - IConfigCache interface + InMemoryConfigCache implementation
- `srv/server.ts` - Bootstrap file for cache initialization
- `packages/shared/src/types/config.ts` - Shared TypeScript types for config entities

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
