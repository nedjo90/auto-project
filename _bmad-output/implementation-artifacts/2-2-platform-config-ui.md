# Story 2.2: Platform Configuration UI (Prices, Texts, Rules, Features)

Status: ready-for-dev

## Story

As an administrator,
I want to configure prices, display texts, business rules, feature toggles, registration fields, and auth-required features through a dedicated admin interface,
so that I can adapt the platform to business needs without touching code.

## Acceptance Criteria (BDD)

**Given** an admin accesses the configuration section
**When** they navigate to Pricing configuration
**Then** they can modify the listing price (currently 15 EUR) via `ConfigParameter`
**And** a preview shows the estimated impact ("Cette modification affectera les X prochaines annonces")

**Given** an admin accesses Texts configuration
**When** they edit a `ConfigText` entry
**Then** they can modify UI texts by key and language (i18n support)
**And** changes are reflected immediately on the platform

**Given** an admin accesses Feature Toggles
**When** they toggle a `ConfigFeature` entry (FR49)
**Then** they can enable/disable features (e.g., "require auth for contact", "show price comparison")
**And** the frontend respects the feature flag via config cache

**Given** an admin accesses Registration Fields configuration (FR50)
**When** they modify a field's required/optional status
**Then** the registration form dynamically adjusts

**Given** an admin accesses Card Display configuration (FR48)
**When** they configure which fields appear on listing cards
**Then** the public listing cards reflect the configuration

**Given** an admin modifies any configuration
**When** the change is saved
**Then** a confirmation dialog shows: what changed, estimated impact, before/after preview (UX principle: "Preview before commit")

## Tasks / Subtasks

### Task 1: Create Admin Configuration Layout and Navigation (AC1-AC5)
- **1.1** Create `src/app/(dashboard)/admin/config/layout.tsx` with tabbed navigation for config sections: Pricing, Texts, Features, Registration Fields, Card Display
- **1.2** Create `src/app/(dashboard)/admin/config/page.tsx` as the config landing/overview page
- **1.3** Add config section to the admin sidebar navigation
- **1.4** Write component tests for layout and navigation rendering

### Task 2: Implement Pricing Configuration Page (AC1)
- **2.1** Create `src/app/(dashboard)/admin/config/pricing/page.tsx`
- **2.2** Build a form component to edit `ConfigParameter` entries filtered by category "pricing"
- **2.3** Implement impact preview: fetch active listing count from backend, display estimated impact message ("Cette modification affectera les X prochaines annonces")
- **2.4** Add input validation (numeric, positive, reasonable range)
- **2.5** Wire form submission to AdminService OData PATCH endpoint
- **2.6** Write component tests for form rendering, validation, and preview logic

### Task 3: Implement Texts Configuration Page (AC2)
- **3.1** Create `src/app/(dashboard)/admin/config/texts/page.tsx`
- **3.2** Build a searchable/filterable data table listing all `ConfigText` entries
- **3.3** Add language filter dropdown (FR, EN, etc.)
- **3.4** Implement inline editing or modal editor for text values (support multi-line/rich text)
- **3.5** Wire save to AdminService OData PATCH endpoint
- **3.6** Verify changes are reflected immediately via config cache invalidation
- **3.7** Write component tests for table, search, edit, and save flow

### Task 4: Implement Feature Toggles Page (AC3)
- **4.1** Create `src/app/(dashboard)/admin/config/features/page.tsx`
- **4.2** Build a list component displaying all `ConfigFeature` entries with toggle switches
- **4.3** Each toggle shows feature key, description, and current status
- **4.4** Wire toggle to AdminService OData PATCH endpoint
- **4.5** Implement frontend feature flag hook: `useFeatureFlag(key: string): boolean` that reads from config cache API
- **4.6** Write component tests for toggle rendering and state management

### Task 5: Implement Registration Fields Configuration Page (AC4)
- **5.1** Create `src/app/(dashboard)/admin/config/registration/page.tsx`
- **5.2** Build a field list component showing registration field definitions from `ConfigParameter` (category: "registration")
- **5.3** Add required/optional toggle for each field
- **5.4** Wire changes to AdminService OData PATCH endpoint
- **5.5** Verify the frontend registration form dynamically adjusts based on config
- **5.6** Write component tests for field configuration and dynamic form behavior

### Task 6: Implement Card Display Configuration Page (AC5)
- **6.1** Create `src/app/(dashboard)/admin/config/card-display/page.tsx`
- **6.2** Build a field selector component showing available listing card fields from config
- **6.3** Allow toggling visibility of each field on the listing card
- **6.4** Add drag-and-drop reordering for field display order
- **6.5** Wire changes to AdminService OData PATCH endpoint
- **6.6** Write component tests for field selection and reordering

### Task 7: Implement Confirmation Dialog with Preview (AC6)
- **7.1** Create a reusable `ConfigChangeConfirmDialog` component
- **7.2** Dialog shows: field name, old value, new value, estimated impact
- **7.3** "Before/After" visual preview for applicable changes (texts, card display)
- **7.4** Confirm/Cancel buttons; only submit to backend on Confirm
- **7.5** Wire dialog into all config save flows (Tasks 2-6)
- **7.6** Write component tests for dialog rendering, before/after preview, and confirm/cancel flows

### Task 8: Backend Support -- Impact Estimation Endpoint
- **8.1** Add a custom action in `admin-service.cds`: `action estimateConfigImpact(parameterKey: String) returns { affectedCount: Integer, message: String }`
- **8.2** Implement handler in `admin-service.ts` that queries affected entities based on parameter type
- **8.3** Write unit and integration tests for the estimation endpoint

### Task 9: Frontend Config Cache API Integration
- **9.1** Create `src/lib/api/config-api.ts` with functions to fetch config values from backend
- **9.2** Implement client-side config cache with SWR/React Query for config data
- **9.3** Add cache invalidation trigger after admin mutations
- **9.4** Write unit tests for API functions and cache behavior

## Dev Notes

### Architecture & Patterns
- This story depends on **Story 2.1** (config engine) being complete -- all config entities and the cache must exist.
- The admin config UI follows a **tabbed layout** pattern: one tab per config category, consistent form patterns across all tabs.
- The "Preview before commit" UX principle is critical: every save must show a confirmation dialog with before/after comparison.
- Feature toggles must propagate to the frontend immediately. Use a `useFeatureFlag` hook that reads from the backend config cache API endpoint.
- The impact estimation endpoint is a custom CDS action (not OData standard) and follows RFC 7807 error handling.
- All config pages share the same CRUD patterns -- consider creating reusable admin form components (table, form, toggle) to avoid duplication.

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
- `src/app/(dashboard)/admin/config/layout.tsx` - Config section tabbed layout
- `src/app/(dashboard)/admin/config/page.tsx` - Config overview page
- `src/app/(dashboard)/admin/config/pricing/page.tsx` - Pricing config
- `src/app/(dashboard)/admin/config/texts/page.tsx` - Texts config
- `src/app/(dashboard)/admin/config/features/page.tsx` - Feature toggles
- `src/app/(dashboard)/admin/config/registration/page.tsx` - Registration fields config
- `src/app/(dashboard)/admin/config/card-display/page.tsx` - Card display config
- `src/components/admin/config-change-confirm-dialog.tsx` - Reusable confirmation dialog
- `src/lib/api/config-api.ts` - Config API client functions
- `src/hooks/use-feature-flag.ts` - Feature flag hook
- `srv/admin-service.cds` - estimateConfigImpact action definition
- `srv/admin-service.ts` - estimateConfigImpact handler

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
