# Story 1.5: Role-Based Access Control (RBAC)

Status: ready-for-dev

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

### Task 1: Define CDS data models for RBAC (AC1)
1.1. Create `db/schema/rbac.cds` with `Role` entity:
    - `ID: UUID` (key)
    - `code: String` (unique: 'visitor', 'buyer', 'seller', 'moderator', 'administrator')
    - `name: String` (display name, i18n key)
    - `description: String` (i18n key)
    - `level: Integer` (hierarchy level: visitor=0, buyer=1, seller=2, moderator=3, administrator=4)
1.2. Create `UserRole` entity in `db/schema/rbac.cds`:
    - `ID: UUID` (key)
    - `user: Association to User`
    - `role: Association to Role`
    - `assignedAt: Timestamp`
    - `assignedBy: Association to User` (null for system-assigned defaults)
1.3. Create `Permission` entity:
    - `ID: UUID` (key)
    - `code: String` (unique, e.g., 'listing.create', 'listing.moderate', 'user.manage', 'admin.access')
    - `description: String`
1.4. Create `RolePermission` entity (many-to-many):
    - `ID: UUID` (key)
    - `role: Association to Role`
    - `permission: Association to Permission`
1.5. Update `ConfigFeature` entity (or create if not exists):
    - `ID: UUID` (key)
    - `code: String` (unique feature identifier)
    - `name: String` (i18n key)
    - `requiresAuth: Boolean` (determines if registration wall is shown)
    - `requiredRole: Association to Role` (minimum role required, optional)
    - `isActive: Boolean`
1.6. Add seed data:
    - 5 roles (Visitor, Buyer, Seller, Moderator, Administrator).
    - Initial permissions set (e.g., listing.view, listing.create, listing.edit, listing.moderate, user.manage, admin.access).
    - Role-permission mappings (Buyer: listing.view; Seller: listing.view + listing.create + listing.edit; Moderator: + listing.moderate; Admin: all).
    - ConfigFeature entries for auth-required features.

### Task 2: Create backend RBAC service and middleware (AC1, AC5)
2.1. Create `srv/rbac-service.cds` exposing:
    - `entity UserRoles as projection on db.UserRole` (admin-only write, user self-read)
    - `action assignRole(userId: UUID, roleCode: String): RoleAssignmentResult`
    - `action removeRole(userId: UUID, roleCode: String): RoleAssignmentResult`
    - `function getUserPermissions(userId: UUID): Permission[]`
2.2. Create `srv/handlers/rbac-handler.ts` implementing:
    - `assignRole(req)` - Validates role exists, creates `UserRole` record. Only admins can call this. Logs to audit trail.
    - `removeRole(req)` - Removes role assignment. Prevents removing last role. Admin-only. Audit trail.
    - `getUserPermissions(req)` - Resolves all permissions for a user based on their roles.
2.3. Create `srv/middleware/rbac-middleware.ts`:
    - Middleware function that checks if `req.user` has the required permission for the endpoint.
    - Usage: `@requires: 'listing.create'` CDS annotation or programmatic check.
    - On unauthorized: return RFC 7807 error response `{ type: "...", title: "Forbidden", status: 403, detail: "..." }`.
    - Log unauthorized attempt to audit trail with: user ID, attempted action, timestamp, IP.
2.4. Create `srv/lib/audit-logger.ts`:
    - `AuditLog` CDS entity: `ID`, `userId`, `action`, `resource`, `details`, `ipAddress`, `timestamp`.
    - `logAudit(event)` function to insert audit records.
    - Used by RBAC middleware and other sensitive operations.
2.5. Write unit tests: role assignment, permission check, 403 response, audit logging.

### Task 3: Create frontend RoleGuard component (AC2, AC3)
3.1. Create `src/components/auth/role-guard.tsx`:
    - Props: `requiredRole: string | string[]`, `children: ReactNode`, `fallback?: ReactNode`.
    - Check user's roles from Zustand auth store against `requiredRole`.
    - If authorized: render `children`.
    - If unauthorized but authenticated: redirect to `/unauthorized` page.
    - If unauthenticated: redirect to `/login` with return URL.
3.2. Create `src/app/(dashboard)/unauthorized/page.tsx`:
    - Clear message: "Vous n'avez pas les droits necessaires pour acceder a cette page."
    - Link back to dashboard home.
    - Appropriate HTTP status (403 via Next.js metadata).
3.3. Wrap protected route layouts with `RoleGuard`:
    - `src/app/(dashboard)/seller/layout.tsx` - wrapped with `<RoleGuard requiredRole="seller">`.
    - `src/app/(dashboard)/admin/layout.tsx` - wrapped with `<RoleGuard requiredRole="administrator">`.
    - `src/app/(dashboard)/moderator/layout.tsx` - wrapped with `<RoleGuard requiredRole="moderator">`.
3.4. Create placeholder pages for each protected section:
    - `src/app/(dashboard)/seller/page.tsx` - Seller cockpit placeholder.
    - `src/app/(dashboard)/admin/page.tsx` - Admin dashboard placeholder.
    - `src/app/(dashboard)/moderator/page.tsx` - Moderator dashboard placeholder.

### Task 4: Implement registration wall for anonymous visitors (AC4)
4.1. Create `src/hooks/use-feature-config.ts`:
    - Fetch `ConfigFeature` entries from backend.
    - Cache in Zustand store or React Query cache.
    - Provide `isFeatureAuthRequired(featureCode): boolean`.
4.2. Create `src/components/auth/registration-wall.tsx`:
    - Overlay component that shows a teaser of the content behind it.
    - Visual treatment: skeleton loader visible, details blurred (CSS `filter: blur()`).
    - CTA: "Connectez-vous ou creez un compte pour acceder a cette fonctionnalite".
    - Login and Register buttons.
4.3. Create `src/components/auth/auth-required-wrapper.tsx`:
    - Props: `featureCode: string`, `children: ReactNode`.
    - If user is authenticated: render `children`.
    - If user is anonymous AND feature requires auth (from config): render `registration-wall`.
    - If feature does not require auth: render `children` regardless.
4.4. Integrate `AuthRequiredWrapper` into relevant pages (future stories will use this pattern).

### Task 5: Admin role management interface (AC1)
5.1. Create `src/app/(dashboard)/admin/users/page.tsx`:
    - Table listing all users with their current roles.
    - Use shadcn/ui Table component with sortable columns.
    - Search/filter by name, email, role.
5.2. Create `src/components/admin/role-assignment-dialog.tsx`:
    - Dialog to change a user's role.
    - Dropdown with available roles.
    - Confirmation step before applying.
    - Calls backend `assignRole` / `removeRole` API.
5.3. Display audit log for role changes (read-only table of recent role modifications).

### Task 6: Shared types (all ACs)
6.1. In `auto-shared`, create `src/types/rbac.ts`:
    - `IRole`, `IUserRole`, `IPermission`, `IRolePermission`, `IConfigFeature`.
    - `RoleCode` enum: `'visitor' | 'buyer' | 'seller' | 'moderator' | 'administrator'`.
6.2. In `auto-shared`, create `src/constants/roles.ts`:
    - Role code constants and hierarchy levels.
    - Permission code constants.
6.3. Publish updated `@auto/shared` package.

### Task 7: Testing (all ACs)
7.1. Backend unit tests: role assignment, permission resolution, RBAC middleware (grant/deny), audit logging.
7.2. Frontend component tests: `RoleGuard` (authorized/unauthorized/unauthenticated), `RegistrationWall` rendering, `AuthRequiredWrapper` config-driven behavior.
7.3. E2E Playwright tests:
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
### Completion Notes List
### Change Log
### File List
