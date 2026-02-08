# Story 1.4: User Authentication (Login, Logout, Session, 2FA)

Status: ready-for-dev

## Story

As a registered user,
I want to log in securely via Azure AD B2C, manage my session, and enable 2FA if I have a professional account,
so that my account is protected and I can access role-specific features.

## Acceptance Criteria (BDD)

### AC1: Login Flow via Azure AD B2C
**Given** a registered user navigates to the login page
**When** they click "Se connecter"
**Then** they are redirected to Azure AD B2C Authorization Code Flow with PKCE
**And** upon successful authentication, an access token (JWT) and refresh token are obtained via MSAL.js
**And** the user is redirected back to the platform as authenticated

### AC2: Silent Token Renewal
**Given** an authenticated user's access token expires
**When** a new API request is made
**Then** MSAL.js silently acquires a new token using the refresh token
**And** if the refresh token is also expired, the user is redirected to login

### AC3: Logout Flow
**Given** an authenticated user clicks "Se deconnecter"
**When** the logout is processed
**Then** the MSAL session is cleared, tokens are removed, and the user is redirected to the public homepage

### AC4: 2FA for Professional Accounts
**Given** a user with a professional account (role Seller)
**When** they access their security settings
**Then** they can enable/disable 2FA via Azure AD B2C MFA policy (NFR10)

### AC5: Configurable Session Timeout
**Given** a user's session has been inactive for a configurable duration (from `ConfigParameter`)
**When** the inactivity timeout is reached
**Then** the session expires and the user must re-authenticate (NFR13)

### AC6: Backend JWT Validation
**Given** the backend receives a request with a JWT token
**When** the auth middleware processes it
**Then** the JWT is validated against the Azure AD B2C JWKS endpoint
**And** the user context (`req.user`) is injected with user ID, email, and roles from the `UserRole` table

## Tasks / Subtasks

### Task 1: Configure MSAL.js authentication in frontend (AC1, AC2, AC3) [x]
1.1. [x] Finalize `src/lib/auth/msal-config.ts` (started in Story 1.2):
    - Configure `PublicClientApplication` with:
      - `clientId` from environment variable `NEXT_PUBLIC_AZURE_AD_B2C_CLIENT_ID`
      - `authority` pointing to AD B2C sign-in/sign-up user flow
      - `knownAuthorities` for the AD B2C tenant
      - `redirectUri` from environment variable `NEXT_PUBLIC_REDIRECT_URI`
      - `postLogoutRedirectUri` set to public homepage
    - Configure cache: `cacheLocation: "sessionStorage"`, `storeAuthStateInCookie: false`
    - Configure token request scopes (API scope from AD B2C app registration)
1.2. [x] Create `src/lib/auth/auth-utils.ts` with helper functions:
    - `loginRedirect()` - Initiates MSAL login redirect with PKCE.
    - `logoutRedirect()` - Clears MSAL session, calls `instance.logoutRedirect()`.
    - `acquireTokenSilent()` - Attempts silent token acquisition; falls back to redirect on failure.
    - `getAccessToken()` - Returns current valid access token or triggers silent renewal.
    - `isAuthenticated()` - Checks if a valid account exists in MSAL cache.
1.3. [x] Create `src/lib/auth/api-client.ts` (authenticated HTTP client):
    - Wrapper around `fetch` that automatically attaches Bearer token from `getAccessToken()`.
    - Intercepts 401 responses and triggers re-authentication.
    - Handles token refresh transparently on each request.

### Task 2: Create login and logout UI (AC1, AC3) [x]
2.1. [x] Create `src/app/(auth)/login/page.tsx`:
    - Display login page with "Se connecter" button.
    - On button click, call `loginRedirect()`.
    - Show loading state during redirect.
    - Handle error cases (user cancelled, network error).
2.2. [x] Update `src/app/(auth)/callback/page.tsx` (started in Story 1.2):
    - Handle MSAL redirect response via `instance.handleRedirectPromise()`.
    - Extract account info and tokens.
    - Store authenticated state in Zustand auth store.
    - Redirect to dashboard or intended page (stored in `state` parameter).
2.3. [x] Create `src/components/layout/user-menu.tsx`:
    - Show user avatar/initials, name, and role when authenticated.
    - Dropdown with: "Mon profil", "Parametres", "Se deconnecter".
    - "Se deconnecter" calls `logoutRedirect()`.
2.4. [x] Update header component to show login/register buttons when unauthenticated, user menu when authenticated.

### Task 3: Create Zustand auth store (AC1, AC2, AC5) [x]
3.1. [x] Create `src/stores/auth-store.ts`:
    - State: `user` (user info), `isAuthenticated`, `roles`, `isLoading`, `lastActivity` timestamp.
    - Actions: `setUser()`, `clearUser()`, `updateLastActivity()`, `checkSessionTimeout()`.
    - On initialization, check MSAL cache for existing session.
3.2. [x] Create `src/hooks/use-auth.ts`:
    - Custom hook wrapping the Zustand auth store.
    - Provides: `user`, `isAuthenticated`, `roles`, `login()`, `logout()`, `hasRole(role)`.
3.3. [x] Create `src/hooks/use-inactivity-timeout.ts` (AC5):
    - Track user activity (mouse move, key press, click, scroll).
    - Fetch timeout duration from `ConfigParameter` API (key: `session.inactivity.timeout.minutes`).
    - On timeout, show warning dialog (5 min before), then force logout.
    - Reset timer on any user activity.

### Task 4: Implement backend JWT middleware (AC6) [x]
4.1. [x] Create `srv/middleware/auth-middleware.ts`:
    - Express middleware that intercepts all incoming requests.
    - Extract Bearer token from `Authorization` header.
    - Validate JWT signature against Azure AD B2C JWKS endpoint (cache the JWKS keys with TTL).
    - Validate standard claims: `iss` (issuer), `aud` (audience), `exp` (expiration), `nbf` (not before).
    - On valid token: extract `sub` (subject/user ID), `email`, and AD B2C custom claims.
    - Query `UserRole` table to get user roles.
    - Inject user context into `req.user` with `{ id, azureAdB2cId, email, roles }`.
    - On invalid/missing token for protected routes: return 401 Unauthorized (RFC 7807 format).
4.2. [x] Install `jose` library for JWT verification (modern, ESM-compatible, includes JWKS).
4.3. [x] JWKS key fetching handled by jose's `createRemoteJWKSet` (no separate jwks-rsa needed).
4.4. [x] Create `srv/lib/jwt-validator.ts` with reusable JWT validation logic:
    - `validateToken(token): Promise<DecodedToken>` - validates and decodes.
    - `getSigningKey(kid): Promise<string>` - fetches signing key from JWKS.
4.5. [x] Register middleware in CAP server bootstrap (`srv/server.ts`).
4.6. [x] Write unit tests for auth middleware: valid token, expired token, invalid signature, missing token.

### Task 5: Implement 2FA toggle for sellers (AC4) [x]
5.1. [x] Create `src/app/(dashboard)/settings/security/page.tsx`:
    - Display 2FA status (enabled/disabled).
    - Toggle button to enable/disable 2FA.
    - When enabling: redirect to AD B2C MFA setup flow (custom policy or user flow).
    - When disabling: require current password confirmation, then call AD B2C to disable MFA.
5.2. [x] Create backend endpoint `srv/handlers/security-handler.ts`:
    - `action toggle2FA(enable: Boolean): SecurityResult`
    - Calls Azure AD B2C Graph API to update MFA policy for the user.
    - Restricted to Seller role (RBAC check).
5.3. [x] Only show 2FA section for users with Seller role (conditional rendering based on `hasRole('Seller')`).

### Task 6: Session timeout configuration (AC5)
6.1. Add `ConfigParameter` seed data:
    - Key: `session.inactivity.timeout.minutes`, Value: `30` (default 30 minutes).
    - Key: `session.timeout.warning.minutes`, Value: `5` (show warning 5 minutes before).
6.2. Create backend endpoint to expose session config parameters (public, cacheable):
    - `GET /api/config/session-parameters` returning timeout values.
6.3. Create `src/components/auth/session-timeout-warning.tsx`:
    - Dialog warning the user their session will expire in N minutes.
    - "Rester connecte" button to reset the timer.
    - Auto-logout when timer reaches zero.

### Task 7: Shared types (all ACs)
7.1. In `auto-shared`, create/update `src/types/auth.ts`:
    - `IDecodedToken`, `IUserContext`, `IAuthState`, `ISessionConfig`.
7.2. Publish updated `@auto/shared` package.

### Task 8: Testing (all ACs)
8.1. Unit tests for `auth-middleware.ts`: valid token, expired, invalid signature, missing, role injection.
8.2. Unit tests for `jwt-validator.ts`: token validation, JWKS key fetching.
8.3. Component tests for login page, callback page, user menu, session timeout warning.
8.4. Integration test: full login flow with mocked MSAL.
8.5. E2E Playwright test: login redirect, callback handling, protected page access, logout.

## Dev Notes

### Architecture & Patterns
- Authentication is **fully delegated to Azure AD B2C**: the platform never handles passwords directly. MSAL.js manages the OAuth 2.0 Authorization Code Flow with PKCE on the frontend.
- The backend is **stateless**: it validates JWTs on every request. No server-side sessions are stored. The JWKS endpoint is cached for performance.
- The **hybrid RBAC** model means AD B2C handles identity (who you are) while the PostgreSQL `UserRole` table handles authorization (what you can do). The JWT middleware enriches `req.user` with roles from the database.
- Session timeout is **configurable** via `ConfigParameter` table, following the zero-hardcode principle.
- 2FA is implemented through AD B2C MFA policies, not custom code. The platform only toggles the MFA requirement for the user's account.

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
  srv/middleware/auth-middleware.ts       # JWT validation middleware
  srv/lib/jwt-validator.ts               # JWT validation utility
  srv/handlers/security-handler.ts       # 2FA toggle
  srv/server.ts                          # CAP server bootstrap (middleware registration)
  db/data/ConfigParameter.csv            # Session timeout config seed data
  test/srv/middleware/auth-middleware.test.ts
  test/srv/lib/jwt-validator.test.ts

auto-frontend/
  src/app/(auth)/login/page.tsx          # Login page
  src/app/(auth)/callback/page.tsx       # Auth callback handler
  src/app/(dashboard)/settings/security/page.tsx  # 2FA settings
  src/components/layout/user-menu.tsx    # Authenticated user menu
  src/components/auth/session-timeout-warning.tsx
  src/lib/auth/msal-config.ts            # MSAL configuration
  src/lib/auth/auth-utils.ts             # Auth helper functions
  src/lib/auth/api-client.ts             # Authenticated HTTP client
  src/stores/auth-store.ts               # Zustand auth state
  src/hooks/use-auth.ts                  # Auth hook
  src/hooks/use-inactivity-timeout.ts    # Session timeout hook

auto-shared/
  src/types/auth.ts
```

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/epics.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- **Task 1**: Finalized msal-config.ts (added storeAuthStateInCookie: false, apiScopes from env var). Created auth-utils.ts (loginRedirect, logoutRedirect, acquireTokenSilent, getAccessToken, isAuthenticated). Created api-client.ts (authenticated fetch wrapper with 401 interception). 19 unit tests added, 82 total passing.
- **Task 2**: Implemented login page with "Se connecter" button + loading state + error handling. Updated callback page with state-based redirect and error display. Created UserMenu component (avatar initials, dropdown with profile/settings/logout). Updated Header (conditional auth/unauth UI) and TopBar (integrated UserMenu). Fixed pre-existing layout test regression. 9 new tests, 91 total passing.
- **Task 3**: Created Zustand auth-store (user, isAuthenticated, roles, lastActivity, session timeout check). Created use-auth hook (wraps store + login/logout/hasRole). Created use-inactivity-timeout hook (activity listeners, periodic timeout check, force logout). 16 new tests, 107 total passing.
- **Task 4**: Installed jose library. Created jwt-validator.ts (validates JWT against Azure AD B2C JWKS, handles expired/invalid/malformed tokens). Created auth-middleware.ts (Express middleware, Bearer token extraction, RFC 7807 errors, user context injection with CDS role lookup). Created server.ts bootstrap (registers middleware on /api/ routes). Updated jest.config.js for ESM jose transform. 10 new backend tests, 90 total passing.
- **Task 5**: Created security-service.cds (toggle2FA action, authenticated-user required). Created security-handler.ts (RBAC seller check, Graph API MFA toggle, error handling). Created security settings page (conditional 2FA section for sellers, enable/disable toggle). 6 new tests (3 backend + 3 frontend), 203 total across repos.

### Change Log
- 2026-02-08: Task 1 complete — MSAL config, auth utilities, authenticated HTTP client

### File List
- auto-frontend/src/lib/auth/msal-config.ts (modified)
- auto-frontend/src/lib/auth/auth-utils.ts (new)
- auto-frontend/src/lib/auth/api-client.ts (new)
- auto-frontend/tests/lib/auth/msal-config.test.ts (new)
- auto-frontend/tests/lib/auth/auth-utils.test.ts (new)
- auto-frontend/tests/lib/auth/api-client.test.ts (new)
- auto-frontend/src/app/(auth)/login/page.tsx (modified)
- auto-frontend/src/app/(auth)/callback/page.tsx (modified)
- auto-frontend/src/components/layout/user-menu.tsx (new)
- auto-frontend/src/components/layout/header.tsx (modified)
- auto-frontend/src/components/layout/top-bar.tsx (modified)
- auto-frontend/src/components/ui/dropdown-menu.tsx (new - shadcn)
- auto-frontend/src/components/ui/avatar.tsx (new - shadcn)
- auto-frontend/tests/app/auth/login-page.test.tsx (new)
- auto-frontend/tests/components/layout/user-menu.test.tsx (new)
- auto-frontend/tests/components/layout/header.test.tsx (new)
- auto-frontend/tests/layouts.test.tsx (modified - fixed regression)
- auto-frontend/src/stores/auth-store.ts (new)
- auto-frontend/src/hooks/use-auth.ts (new)
- auto-frontend/src/hooks/use-inactivity-timeout.ts (new)
- auto-frontend/tests/stores/auth-store.test.ts (new)
- auto-frontend/tests/hooks/use-auth.test.ts (new)
- auto-frontend/tests/hooks/use-inactivity-timeout.test.ts (new)
- auto-backend/srv/lib/jwt-validator.ts (new)
- auto-backend/srv/middleware/auth-middleware.ts (new)
- auto-backend/srv/server.ts (new)
- auto-backend/jest.config.js (modified)
- auto-backend/package.json (modified - added jose dependency)
- auto-backend/test/srv/lib/jwt-validator.test.ts (new)
- auto-backend/test/srv/middleware/auth-middleware.test.ts (new)
- auto-backend/srv/security-service.cds (new)
- auto-backend/srv/security-service.ts (new)
- auto-backend/srv/handlers/security-handler.ts (new)
- auto-backend/test/srv/handlers/security-handler.test.ts (new)
- auto-frontend/src/app/(dashboard)/settings/security/page.tsx (new)
- auto-frontend/tests/app/dashboard/security-page.test.tsx (new)
