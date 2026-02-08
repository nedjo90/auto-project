# Story 2.1: Zero-Hardcode Configuration Engine

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR47 (foundation)
**NFRs:** NFR19 (extensible without code)

## User Story

As an administrator,
I want all platform values, texts, rules, and settings stored in database configuration tables with an in-memory cache,
So that I can modify any business parameter without developer intervention.

## Acceptance Criteria

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
