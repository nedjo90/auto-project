# Story 1.5: Role-Based Access Control (RBAC)

Status: review

## Story

As an administrator,
I want the system to assign roles to users and control access to features based on their role,
so that each user accesses only the functionalities appropriate to their role.

## Acceptance Criteria (BDD)

### AC1: Default Role Assignment and Admin Role Management
**Given** the system defines 5 roles: Visitor (anonymous), Buyer, Seller, Moderator, Administrator
**When** a user is created
**Then** a default role (Buyer) is assigned in the `UserRole` CDS table
**And** an administrator can change user roles via the admin interface

### AC2: Role-Based Route Protection (Unauthorized Access)
**Given** a user with role Buyer attempts to access the seller cockpit (`(dashboard)/seller/`)
**When** the `RoleGuard` component checks the role
**Then** the user is redirected to an unauthorized page with a clear message

### AC3: Role-Based Route Protection (Authorized Access)
**Given** a user with role Seller accesses the seller cockpit
**When** the `RoleGuard` component checks the role
**Then** access is granted and the cockpit renders

### AC4: Configurable Auth-Required Features (Registration Wall)
**Given** configurable auth-required features exist in `ConfigFeature` table
**When** an anonymous visitor accesses a feature flagged as requiring authentication (FR25)
**Then** the registration wall is displayed with calibrated teasing (skeleton visible, details blurred)
**And** the features requiring auth are driven by config, not hardcoded

### AC5: Backend RBAC Middleware
**Given** the backend receives a request to a protected endpoint
**When** the RBAC middleware checks permissions
**Then** access is granted only if the user's role has the required permission
**And** a 403 Forbidden (RFC 7807) is returned for unauthorized access
**And** the attempt is logged in the audit trail

## Tasks / Subtasks

### Task 1: Define CDS data models for RBAC (AC1) [x]
1.1. [x] Create `db/schema/rbac.cds` with `Role` entity:
    - `ID: UUID` (key)
    - `code: String` (unique: 'visitor', 'buyer', 'seller', 'moderator', 'administrator')
    - `name: String` (display name, i18n key)
    - `description: String` (i18n key)
    - `level: Integer` (hierarchy level: visitor=0, buyer=1, seller=2, moderator=3, administrator=4)
1.2. [x] Create `UserRole` entity in `db/schema/rbac.cds`:
    - `ID: UUID` (key)
    - `user: Association to User`
    - `role: Association to Role`
    - `assignedAt: Timestamp`
    - `assignedBy: Association to User` (null for system-assigned defaults)
1.3. [x] Create `Permission` entity:
    - `ID: UUID` (key)
    - `code: String` (unique, e.g., 'listing.create', 'listing.moderate', 'user.manage', 'admin.access')
    - `description: String`
1.4. [x] Create `RolePermission` entity (many-to-many):
    - `ID: UUID` (key)
    - `role: Association to Role`
    - `permission: Association to Permission`
1.5. [x] Update `ConfigFeature` entity (or create if not exists):
    - `ID: UUID` (key)
    - `code: String` (unique feature identifier)
    - `name: String` (i18n key)
    - `requiresAuth: Boolean` (determines if registration wall is shown)
    - `requiredRole: Association to Role` (minimum role required, optional)
    - `isActive: Boolean`
1.6. [x] Add seed data:
    - 5 roles (Visitor, Buyer, Seller, Moderator, Administrator).
    - Initial permissions set (e.g., listing.view, listing.create, listing.edit, listing.moderate, user.manage, admin.access).
    - Role-permission mappings (Buyer: listing.view; Seller: listing.view + listing.create + listing.edit; Moderator: + listing.moderate; Admin: all).
    - ConfigFeature entries for auth-required features.

### Task 2: Create backend RBAC service and middleware (AC1, AC5) [x]
2.1. [x] Create `srv/rbac-service.cds` exposing:
    - `entity UserRoles as projection on db.UserRole` (admin-only write, user self-read)
    - `action assignRole(userId: UUID, roleCode: String): RoleAssignmentResult`
    - `action removeRole(userId: UUID, roleCode: String): RoleAssignmentResult`
    - `function getUserPermissions(userId: UUID): Permission[]`
2.2. [x] Create `srv/handlers/rbac-handler.ts` implementing:
    - `assignRole(req)` - Validates role exists, creates `UserRole` record. Only admins can call this. Logs to audit trail.
    - `removeRole(req)` - Removes role assignment. Prevents removing last role. Admin-only. Audit trail.
    - `getUserPermissions(req)` - Resolves all permissions for a user based on their roles.
2.3. [x] Create `srv/middleware/rbac-middleware.ts`:
    - Middleware function that checks if `req.user` has the required permission for the endpoint.
    - Usage: `@requires: 'listing.create'` CDS annotation or programmatic check.
    - On unauthorized: return RFC 7807 error response `{ type: "...", title: "Forbidden", status: 403, detail: "..." }`.
    - Log unauthorized attempt to audit trail with: user ID, attempted action, timestamp, IP.
2.4. [x] Create `srv/lib/audit-logger.ts`:
    - `AuditLog` CDS entity: `ID`, `userId`, `action`, `resource`, `details`, `ipAddress`, `timestamp`.
    - `logAudit(event)` function to insert audit records.
    - Used by RBAC middleware and other sensitive operations.
2.5. [x] Write unit tests: role assignment, permission check, 403 response, audit logging.

### Task 3: Create frontend RoleGuard component (AC2, AC3) [x]
3.1. [x] Create `src/components/auth/role-guard.tsx`:
    - Props: `requiredRole: string | string[]`, `children: ReactNode`, `fallback?: ReactNode`.
    - Check user's roles from Zustand auth store against `requiredRole`.
    - If authorized: render `children`.
    - If unauthorized but authenticated: redirect to `/unauthorized` page.
    - If unauthenticated: redirect to `/login` with return URL.
3.2. [x] Create `src/app/(dashboard)/unauthorized/page.tsx`:
    - Clear message: "Vous n'avez pas les droits necessaires pour acceder a cette page."
    - Link back to dashboard home.
    - Appropriate HTTP status (403 via Next.js metadata).
3.3. [x] Wrap protected route layouts with `RoleGuard`:
    - `src/app/(dashboard)/seller/layout.tsx` - wrapped with `<RoleGuard requiredRole="seller">`.
    - `src/app/(dashboard)/admin/layout.tsx` - wrapped with `<RoleGuard requiredRole="administrator">`.
    - `src/app/(dashboard)/moderator/layout.tsx` - wrapped with `<RoleGuard requiredRole="moderator">`.
3.4. [x] Create placeholder pages for each protected section:
    - `src/app/(dashboard)/seller/page.tsx` - Seller cockpit placeholder.
    - `src/app/(dashboard)/admin/page.tsx` - Admin dashboard placeholder.
    - `src/app/(dashboard)/moderator/page.tsx` - Moderator dashboard placeholder.

### Task 4: Implement registration wall for anonymous visitors (AC4) [x]
4.1. [x] Create `src/hooks/use-feature-config.ts`:
    - Fetch `ConfigFeature` entries from backend.
    - Cache in Zustand store or React Query cache.
    - Provide `isFeatureAuthRequired(featureCode): boolean`.
4.2. [x] Create `src/components/auth/registration-wall.tsx`:
    - Overlay component that shows a teaser of the content behind it.
    - Visual treatment: skeleton loader visible, details blurred (CSS `filter: blur()`).
    - CTA: "Connectez-vous ou creez un compte pour acceder a cette fonctionnalite".
    - Login and Register buttons.
4.3. [x] Create `src/components/auth/auth-required-wrapper.tsx`:
    - Props: `featureCode: string`, `children: ReactNode`.
    - If user is authenticated: render `children`.
    - If user is anonymous AND feature requires auth (from config): render `registration-wall`.
    - If feature does not require auth: render `children` regardless.
4.4. [x] Integrate `AuthRequiredWrapper` into relevant pages (future stories will use this pattern).

### Task 5: Admin role management interface (AC1) [x]
5.1. [x] Create `src/app/(dashboard)/admin/users/page.tsx`:
    - Table listing all users with their current roles.
    - Use shadcn/ui Table component with sortable columns.
    - Search/filter by name, email, role.
5.2. [x] Create `src/components/admin/role-assignment-dialog.tsx`:
    - Dialog to change a user's role.
    - Dropdown with available roles.
    - Confirmation step before applying.
    - Calls backend `assignRole` / `removeRole` API.
5.3. [x] Display audit log for role changes (read-only table of recent role modifications).

### Task 6: Shared types (all ACs) [x]
6.1. [x] In `auto-shared`, create `src/types/rbac.ts`:
    - `IRole`, `IUserRole`, `IPermission`, `IRolePermission`, `IConfigFeature`.
    - `RoleCode` enum: `'visitor' | 'buyer' | 'seller' | 'moderator' | 'administrator'`.
6.2. [x] In `auto-shared`, create `src/constants/roles.ts`:
    - Role code constants and hierarchy levels.
    - Permission code constants.
6.3. [x] Publish updated `@auto/shared` package.

### Task 7: Testing (all ACs) [x]
7.1. [x] Backend unit tests: role assignment, permission resolution, RBAC middleware (grant/deny), audit logging.
7.2. [x] Frontend component tests: `RoleGuard` (authorized/unauthorized/unauthenticated), `RegistrationWall` rendering, `AuthRequiredWrapper` config-driven behavior.
7.3. E2E Playwright tests (deferred — Playwright not yet configured in sprint 1):
    - Buyer accessing seller cockpit -> redirect to unauthorized.
    - Seller accessing seller cockpit -> renders.
    - Anonymous accessing auth-required feature -> registration wall.
    - Admin assigning role to user -> role updated.

## Dev Notes

### Architecture & Patterns
- RBAC is **hybrid**: Azure AD B2C manages identity tokens, but the PostgreSQL `UserRole` + `Permission` tables are the source of truth for authorization. The JWT middleware (Story 1.4) enriches the user context with roles from the database.
- The **permission model** is role-based with explicit permission codes. Each role maps to a set of permissions. Endpoint protection checks permissions, not roles directly, allowing flexible reconfiguration.
- The **registration wall** (FR25) is config-driven via `ConfigFeature`. Features can be toggled between public and auth-required without code changes.
- The **audit trail** logs all sensitive RBAC operations (role changes, unauthorized access attempts) for compliance.
- Frontend uses both a `RoleGuard` component (for route-level protection) and an `AuthRequiredWrapper` (for feature-level protection within pages).

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 App Router frontend, PostgreSQL, Azure ecosystem
- **Multi-repo:** auto-backend, auto-frontend, auto-shared (npm package @auto/shared via Azure Artifacts)
- **Auth:** Azure AD B2C (Authorization Code Flow + PKCE), MSAL.js frontend, custom JWT middleware backend
- **RBAC:** Hybrid - AD B2C for identity + user_roles table in PostgreSQL for permissions
- **API:** Hybrid OData v4 (auto-generated by CDS) + REST custom endpoints
- **Real-time:** Azure SignalR Service (4 hubs: /chat, /notifications, /live-score, /admin)
- **UI:** shadcn/ui + Tailwind CSS + Radix UI, Zustand for SPA state
- **Config:** Zero-hardcode - 10+ config tables in DB, InMemoryConfigCache
- **Adapter Pattern:** 8 interfaces for external APIs, Factory resolves from ConfigApiProvider
- **Testing:** Jest/Vitest, React Testing Library, Playwright E2E, >=90% unit coverage

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- API REST custom: kebab-case
- All technical naming in English, French only in i18n DB texts

### Anti-Patterns (FORBIDDEN)
- Hardcoded values (use config tables)
- Direct DB queries (use CDS service layer)
- Direct external API calls (use Adapter Pattern)
- French in code/files/variables
- Exposing internal errors to clients
- Skipping audit trail for sensitive ops
- Skipping tests

### Project Structure Notes
```
auto-backend/
  db/schema/rbac.cds                  # Role, UserRole, Permission, RolePermission entities
  db/schema/config.cds                # ConfigFeature entity (extend)
  db/data/Role.csv                    # Seed roles
  db/data/Permission.csv              # Seed permissions
  db/data/RolePermission.csv          # Seed role-permission mappings
  db/data/ConfigFeature.csv           # Seed feature configs
  srv/rbac-service.cds                # RBAC service definition
  srv/handlers/rbac-handler.ts        # RBAC business logic
  srv/middleware/rbac-middleware.ts    # Permission checking middleware
  srv/lib/audit-logger.ts             # Audit trail utility
  test/srv/handlers/rbac-handler.test.ts
  test/srv/middleware/rbac-middleware.test.ts

auto-frontend/
  src/components/auth/role-guard.tsx               # Route-level role protection
  src/components/auth/registration-wall.tsx         # Auth teaser for anonymous
  src/components/auth/auth-required-wrapper.tsx     # Feature-level auth check
  src/components/admin/role-assignment-dialog.tsx    # Admin role management
  src/app/(dashboard)/unauthorized/page.tsx         # 403 page
  src/app/(dashboard)/seller/layout.tsx             # Seller cockpit (role-guarded)
  src/app/(dashboard)/admin/layout.tsx              # Admin section (role-guarded)
  src/app/(dashboard)/admin/users/page.tsx          # User management
  src/app/(dashboard)/moderator/layout.tsx          # Moderator section (role-guarded)
  src/hooks/use-feature-config.ts                   # Feature config hook

auto-shared/
  src/types/rbac.ts
  src/constants/roles.ts
```

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/epics.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- **Task 1 (CDS Data Models):** Created `db/schema/rbac.cds` with Role, UserRole, Permission, RolePermission entities. Added ConfigFeature to `db/schema/config.cds`. Moved UserRole from `user.cds` to `rbac.cds` with association-based role (was String(30)). Added seed data for 5 roles, 6 permissions, 14 role-permission mappings, 5 config features. 31 new tests + 127 total passing.
- **Task 2 (RBAC Service & Middleware):** Created `rbac-service.cds`, `rbac-handler.ts` (assignRole, removeRole, getUserPermissions), `rbac-middleware.ts` (requirePermission + hasPermission), `audit-logger.ts` + AuditLog CDS entity. Updated auth-middleware to resolve role codes through Role association. Updated registration-handler to use role_ID FK. 28 new tests + 155 total passing.
- **Task 3 (Frontend RoleGuard):** Created `role-guard.tsx`, `unauthorized/page.tsx`, 3 protected layouts (seller, admin, moderator), 3 placeholder pages. 8 new tests + 121 frontend total passing.
- **Task 4 (Registration Wall):** Created `feature-config-store.ts` (Zustand), `use-feature-config.ts` hook, `registration-wall.tsx` (blur overlay + CTA), `auth-required-wrapper.tsx` (config-driven auth check), local `IConfigFeature` type. 22 new tests + 143 frontend total passing.
- **Task 5 (Admin Role Management):** Created `admin/users/page.tsx` (searchable user table, role display, edit button), `role-assignment-dialog.tsx` (role select, confirm/cancel, API call). Used `refreshKey` pattern for re-fetching after role change. 11 new tests + 154 frontend total passing.
- **Task 6 (Shared Types):** Created `src/types/rbac.ts` (IRole, IUserRole, IPermission, IRolePermission, IConfigFeature, RoleCode). Updated Role type from old codes to new RBAC codes. Added ROLE_CODES, ROLE_HIERARCHY, PERMISSION_CODES constants. 10 new tests + 81 shared total passing.
- **Task 7 (Testing):** All unit tests green across 3 repos: 155 backend + 154 frontend + 81 shared = 390 total. E2E tests deferred (Playwright not yet configured). Fixed backend setup.test.ts for new role code.

### Change Log
- 2026-02-08: Task 1 — RBAC CDS data models, seed data, schema tests
- 2026-02-08: Task 2 — RBAC service, handler, middleware, audit logger, auth/registration fixes
- 2026-02-08: Task 3 — RoleGuard, unauthorized page, protected layouts, placeholder pages
- 2026-02-08: Task 4 — Feature config store/hook, registration wall, auth-required wrapper
- 2026-02-08: Task 5 — Admin user management page, role assignment dialog
- 2026-02-08: Task 6 — Shared RBAC types, updated Role type and constants
- 2026-02-08: Task 7 — All 390 unit tests green, backend role assertion fix
- 2026-02-08: Code Review Fixes — Adversarial review found 12 HIGH, 12 MEDIUM, 3 LOW issues. All HIGH/MEDIUM fixed:
  - Shared: `PermissionCode` literal union type, typed `IPermission.code`/`IConfigFeature.requiredRole_code`, `Role`→`RoleCode` alias, `ROLE_CODES`→`ROLES` alias, `Readonly<Record>` for `ROLE_HIERARCHY`
  - Backend: extracted `rbac-utils.ts` (DRY `resolveUserPermissions`/`extractIpAddress`), `removeRole` race condition fix (delete-then-verify), null `buyerRole` check, RFC 7807 Content-Type on all error responses, CDS entity exposure in `rbac-service.cds`
  - Frontend: RoleGuard spinner fallback (flash fix), `safeReturnUrl()` open redirect protection, AbortController for fetch cleanup, sortable admin table columns, `useFeatureConfig` error state, registration wall accessibility (`role="dialog"`, `aria-modal`, auto-focus), implemented Task 5.3 audit log display (`AuditLogTable`), deleted local `config-feature.ts` (uses `@auto/shared`)
  - Tests: 82 shared + 154 backend + 160 frontend = 396 total passing

### File List
- auto-backend/db/schema/rbac.cds (new)
- auto-backend/db/schema/config.cds (modified — added ConfigFeature, Role import)
- auto-backend/db/schema/user.cds (modified — removed UserRole)
- auto-backend/db/schema.cds (modified — added rbac import)
- auto-backend/db/data/auto-Role.csv (new)
- auto-backend/db/data/auto-Permission.csv (new)
- auto-backend/db/data/auto-RolePermission.csv (new)
- auto-backend/db/data/auto-ConfigFeature.csv (new)
- auto-backend/test/db/rbac-schema.test.ts (new)
- auto-backend/db/schema/audit.cds (new)
- auto-backend/srv/rbac-service.cds (new)
- auto-backend/srv/handlers/rbac-handler.ts (new)
- auto-backend/srv/middleware/rbac-middleware.ts (new)
- auto-backend/srv/lib/audit-logger.ts (new)
- auto-backend/srv/middleware/auth-middleware.ts (modified — role resolution via Role association)
- auto-backend/srv/handlers/registration-handler.ts (modified — role_ID FK + Role lookup)
- auto-backend/test/srv/handlers/rbac-handler.test.ts (new)
- auto-backend/test/srv/middleware/rbac-middleware.test.ts (new)
- auto-backend/test/srv/lib/audit-logger.test.ts (new)
- auto-backend/test/srv/handlers/registration-handler.test.ts (modified — updated mock for Role lookup)
- auto-frontend/src/components/auth/role-guard.tsx (new)
- auto-frontend/src/app/(dashboard)/unauthorized/page.tsx (new)
- auto-frontend/src/app/(dashboard)/seller/layout.tsx (new)
- auto-frontend/src/app/(dashboard)/seller/page.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/layout.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/page.tsx (new)
- auto-frontend/src/app/(dashboard)/moderator/layout.tsx (new)
- auto-frontend/src/app/(dashboard)/moderator/page.tsx (new)
- auto-frontend/tests/components/auth/role-guard.test.tsx (new)
- auto-frontend/tests/app/dashboard/unauthorized-page.test.tsx (new)
- auto-frontend/src/types/config-feature.ts (deleted — uses @auto/shared)
- auto-frontend/src/stores/feature-config-store.ts (new)
- auto-frontend/src/hooks/use-feature-config.ts (new)
- auto-frontend/src/components/auth/registration-wall.tsx (new)
- auto-frontend/src/components/auth/auth-required-wrapper.tsx (new)
- auto-frontend/tests/stores/feature-config-store.test.ts (new)
- auto-frontend/tests/hooks/use-feature-config.test.ts (new)
- auto-frontend/tests/components/auth/registration-wall.test.tsx (new)
- auto-frontend/tests/components/auth/auth-required-wrapper.test.tsx (new)
- auto-frontend/src/app/(dashboard)/admin/users/page.tsx (new)
- auto-frontend/src/components/admin/role-assignment-dialog.tsx (new)
- auto-frontend/tests/app/dashboard/admin-users-page.test.tsx (new)
- auto-frontend/tests/components/admin/role-assignment-dialog.test.tsx (new)
- auto-shared/src/types/rbac.ts (new)
- auto-shared/src/types/user.ts (modified — Role type updated)
- auto-shared/src/types/index.ts (modified — RBAC type exports)
- auto-shared/src/constants/roles.ts (modified — new RBAC constants)
- auto-shared/src/constants/index.ts (modified — new RBAC constant exports)
- auto-shared/tests/rbac-types.test.ts (new)
- auto-shared/tests/constants.test.ts (modified — updated role assertions)
- auto-backend/srv/lib/rbac-utils.ts (new — shared resolveUserPermissions/extractIpAddress)
- auto-backend/test/setup.test.ts (modified — updated role assertion)
- auto-frontend/src/components/admin/audit-log-table.tsx (new — audit log display)
- auto-frontend/tests/components/admin/audit-log-table.test.tsx (new)
