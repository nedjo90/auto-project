# Story 1.2: User Registration with Configurable Fields

Status: done

## Story

As a visitor,
I want to create an account with registration fields whose required/optional status is configurable,
so that I can access the platform's authenticated features with my account active immediately.

## Acceptance Criteria (BDD)

### AC1: Configurable Registration Form
**Given** a visitor is on the registration page
**When** they fill in the registration form
**Then** the form displays fields whose required/optional status is driven by a `ConfigRegistrationField` CDS table
**And** required fields are visually marked and enforced (client-side Zod + server-side CDS validation)
**And** optional fields are clearly indicated

### AC2: Successful Registration Flow
**Given** a visitor submits a valid registration form
**When** the system processes the registration
**Then** a new user is created in Azure AD B2C via the sign-up user flow
**And** a corresponding user record is created in the PostgreSQL `User` table with default role `Buyer`
**And** the account is active immediately without moderator approval (FR22)
**And** the user is redirected to the platform as authenticated

### AC3: Validation Error Handling
**Given** a visitor submits a registration form with invalid data
**When** validation fails
**Then** specific, accessible error messages are displayed next to each invalid field (aria-describedby)
**And** focus is moved to the first invalid field

### AC4: Accessibility
**Given** the registration form is displayed
**When** a screen reader user navigates the form
**Then** all fields have associated labels, error messages are linked, and focus management is correct (NFR26)

## Tasks / Subtasks

### Task 1: Define CDS data models for registration configuration and User entity (AC1, AC2) [x]
1.1. [x] Create `db/schema/config.cds` (or extend existing config model) with `ConfigRegistrationField` entity:
    - `ID: UUID` (key)
    - `fieldName: String` (e.g., 'firstName', 'lastName', 'email', 'phone', 'siret')
    - `fieldType: String` (e.g., 'text', 'email', 'tel', 'select')
    - `isRequired: Boolean`
    - `isVisible: Boolean`
    - `displayOrder: Integer`
    - `validationPattern: String` (optional regex pattern)
    - `labelKey: String` (i18n key for field label)
    - `placeholderKey: String` (i18n key for placeholder)
1.2. [x] Create `db/schema/user.cds` with `User` entity:
    - `ID: UUID` (key)
    - `azureAdB2cId: String` (external identity link)
    - `email: String` (unique)
    - `firstName: String`
    - `lastName: String`
    - `phone: String` (optional)
    - `address: String` (optional)
    - `siret: String` (optional, for professionals)
    - `isAnonymized: Boolean` (default false)
    - `status: String` (enum: active, suspended, anonymized)
    - `createdAt: Timestamp`
    - `modifiedAt: Timestamp`
1.3. [x] Add seed data (CSV or initial load) for `ConfigRegistrationField` with standard registration fields.
1.4. [x] Add `@auto/shared` types: export `IUser`, `IConfigRegistrationField`, and registration-related types.

### Task 2: Create backend registration service (AC1, AC2) [x]
2.1. [x] Create `srv/registration-service.cds` exposing the registration action and config fields read endpoint:
    - `action register(input: RegistrationInput): RegistrationResult`
    - `entity ConfigRegistrationFields as projection on db.ConfigRegistrationField` (read-only for public)
2.2. [x] Create `srv/handlers/registration-handler.ts` implementing:
    - `getRegistrationFields()` - Returns active, visible fields ordered by `displayOrder`.
    - `register(req)` - Orchestrates the registration:
      a. Validate input against `ConfigRegistrationField` rules (server-side).
      b. Create user in Azure AD B2C via Graph API adapter (Adapter Pattern).
      c. Create user record in `User` table with status `active`.
      d. Assign default `Buyer` role in `UserRole` table.
      e. Return success with redirect info.
2.3. [x] Implement server-side validation logic that dynamically checks required fields based on `ConfigRegistrationField` config.
2.4. [x] Handle error cases: duplicate email, AD B2C API failure (rollback if partial), validation failures.
2.5. [x] Write unit tests for registration handler (>=90% coverage). Test both success and failure paths.

### Task 3: Create Azure AD B2C adapter (AC2) [x]
3.1. [x] Create `srv/adapters/interfaces/identity-provider.interface.ts` defining the `IIdentityProviderAdapter` interface:
    - `createUser(userData): Promise<ExternalUserId>`
    - `disableUser(externalId): Promise<void>`
    - `updateUser(externalId, userData): Promise<void>`
3.2. [x] Create `srv/adapters/azure-ad-b2c-adapter.ts` implementing `IIdentityProviderAdapter`:
    - Use Microsoft Graph API SDK (`@microsoft/microsoft-graph-client`) to create users in AD B2C.
    - Read API credentials from environment variables / config (never hardcoded).
3.3. [x] Create `srv/adapters/factory/adapter-factory.ts` with factory method to resolve the identity provider adapter.
3.4. [x] Write unit tests with mocked Graph API responses.

### Task 4: Create frontend registration page and form (AC1, AC3, AC4) [x]
4.1. [x] Create `src/app/(auth)/register/page.tsx` as the registration page.
4.2. [x] Create `src/components/auth/registration-form.tsx`:
    - Fetch `ConfigRegistrationField` from backend API on mount.
    - Dynamically render form fields based on config (field type, required status, display order).
    - Use shadcn/ui form components (Input, Select, Button) with Radix UI primitives.
    - Required fields marked with asterisk (*) and `aria-required="true"`.
    - Optional fields labeled "(optionnel)".
4.3. [x] Implement client-side validation with Zod:
    - Dynamically build Zod schema from `ConfigRegistrationField` config.
    - Use `react-hook-form` with `@hookform/resolvers/zod` for form state management.
4.4. [x] Implement error display:
    - Error messages rendered below each field with `aria-describedby` linking.
    - On validation failure, focus moved to first invalid field via `ref.focus()`.
    - Error messages are specific and i18n-ready (e.g., "Ce champ est requis", "Format email invalide").
4.5. [x] Implement form submission:
    - Call backend registration endpoint.
    - On success: trigger MSAL.js sign-up flow or redirect to login.
    - On failure: display server-side errors mapped to form fields.
4.6. [x] Add loading state (spinner on submit button, disabled fields during submission).

### Task 5: Integrate MSAL.js for post-registration authentication (AC2) [x]
5.1. [x] Install `@azure/msal-browser` and `@azure/msal-react`.
5.2. [x] Create `src/lib/auth/msal-config.ts` with MSAL configuration:
    - Client ID, authority (AD B2C tenant), redirect URI from environment variables.
    - Sign-up/sign-in user flow reference.
5.3. [x] Create `src/lib/auth/msal-instance.ts` to initialize the `PublicClientApplication`.
5.4. [x] Create `src/components/auth/msal-provider.tsx` wrapper component for the app.
5.5. [x] After successful registration, initiate MSAL login redirect to authenticate the new user.
5.6. [x] Handle the auth callback in `src/app/(auth)/callback/page.tsx` - extract tokens, redirect to dashboard.

### Task 6: Accessibility testing (AC4) [x]
6.1. [x] Add automated accessibility tests for the registration form using `@testing-library/jest-dom` and `vitest-axe`.
6.2. [x] Verify: all inputs have `<label>` elements, errors linked via `aria-describedby`, focus management on error, keyboard navigation works, form is navigable with screen reader.
6.3. [ ] Write Playwright E2E test for the full registration flow (fill form -> submit -> verify redirect). *(Deferred: requires running backend + Playwright setup)*

### Task 7: Shared types and validators (AC1) [x]
7.1. [x] In `auto-shared`, create `src/types/user.ts` with `IUser`, `IRegistrationInput`, `IRegistrationResult` interfaces. *(Done in Task 1.4)*
7.2. [x] In `auto-shared`, create `src/types/config.ts` with `IConfigRegistrationField` interface. *(Done in Task 1.4)*
7.3. [x] In `auto-shared`, create `src/validators/registration.validator.ts` with Zod schema builder that takes field config and returns a dynamic Zod schema.
7.4. [x] Build updated `@auto/shared` package. *(Publish deferred until CI/CD pipeline configured)*

### Review Follow-ups (AI)
- [x] [AI-Review][HIGH] Initialize identity provider in `RegistrationService.init()` — added `getIdentityProvider()` call in init
- [x] [AI-Review][HIGH] Add server-side password validation — added required + min 8 chars check before field validation
- [x] [AI-Review][HIGH] Add `@assert.unique: {email}` on `User` entity — added CDS annotation
- [x] [AI-Review][HIGH] Sanitize `validationPattern` regex — added try/catch for invalid patterns + max input length guard (1000 chars)
- [x] [AI-Review][HIGH] Clean up stale consent fields — removed from CDS RegistrationInput, IRegistrationInput, ConsentStatus interface
- [x] [AI-Review][MEDIUM] Add `@assert.unique: {fieldName}` on `ConfigRegistrationField` — added CDS annotation
- [x] [AI-Review][MEDIUM] Guard MSAL initialization before `loginRedirect` — exported `msalInitPromise`, awaited before redirect
- [ ] [AI-Review][MEDIUM] Document `UserRole` entity in story task definitions — deferred (documentation only)
- [ ] [AI-Review][LOW] Seed data i18n keys unresolvable — deferred (requires i18n story)
- [ ] [AI-Review][LOW] Hard-coded redirect URL `/auth/callback` — deferred (config table story)

## Dev Notes

### Architecture & Patterns
- The registration form is **config-driven**: the `ConfigRegistrationField` table determines which fields appear, their order, and whether they are required. This follows the zero-hardcode principle.
- The Adapter Pattern is used for Azure AD B2C integration. The `IIdentityProviderAdapter` interface abstracts the identity provider, allowing mock implementations for testing.
- Validation is **dual-layer**: client-side Zod validation (built dynamically from config) and server-side CDS/custom validation. The shared Zod schema builder in `@auto/shared` ensures consistency.
- The registration flow creates users in both AD B2C (identity) and PostgreSQL (application data). The backend must handle partial failures (e.g., AD B2C succeeds but DB insert fails) with proper rollback.

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
  db/schema/config.cds           # ConfigRegistrationField entity
  db/schema/user.cds             # User entity
  db/data/                       # Seed CSV data for config
  srv/registration-service.cds   # Registration service definition
  srv/handlers/registration-handler.ts
  srv/adapters/interfaces/identity-provider.interface.ts
  srv/adapters/azure-ad-b2c-adapter.ts
  srv/adapters/factory/adapter-factory.ts
  test/srv/handlers/registration-handler.test.ts

auto-frontend/
  src/app/(auth)/register/page.tsx
  src/app/(auth)/callback/page.tsx
  src/components/auth/registration-form.tsx
  src/components/auth/msal-provider.tsx
  src/lib/auth/msal-config.ts
  src/lib/auth/msal-instance.ts

auto-shared/
  src/types/user.ts
  src/types/config.ts
  src/validators/registration.validator.ts
```

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/epics.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- **Task 1:** CDS models created. `ConfigRegistrationField` (cuid) in `db/schema/config.cds`, `User` (cuid, managed) with `UserStatus` enum in `db/schema/user.cds`. Seed CSV with 5 standard fields (email, firstName, lastName required; phone, siret optional). Updated `@auto/shared` with `IUser`, `IConfigRegistrationField`, `IRegistrationInput`, `IRegistrationResult`. 22 backend tests pass. 44 shared tests pass.
- **Task 2:** Registration service created. CDS service at `/api/registration` with `ConfigRegistrationFields` read-only entity and `register` action. Handler implements: dynamic validation against config fields, duplicate email check, AD B2C adapter integration (via DI), user + UserRole creation with rollback on failure. Added `UserRole` entity to schema. 25 handler tests (14 validation + 11 handler). 47 total backend tests pass.
- **Task 3:** Azure AD B2C adapter created. `IIdentityProviderAdapter` interface with createUser/disableUser/updateUser. `AzureAdB2cAdapter` using @microsoft/microsoft-graph-client + @azure/identity. Factory with get/set/reset singleton pattern. 10 adapter tests. 57 total backend tests pass.
- **Task 4:** Frontend registration form created. Dynamic config-driven form with react-hook-form + zodResolver. Fields fetched from API, Zod schema built at runtime. Full a11y support: aria-required, aria-invalid, aria-describedby, role="alert". Loading/submitting states. Server error display. 13 form tests. 35 total frontend tests pass.
- **Task 5:** MSAL.js integration complete. @azure/msal-browser + @azure/msal-react installed. MSAL config from env vars, PublicClientApplication singleton, MsalProvider wrapper, auth callback page. Registration form calls loginRedirect on success. 35 frontend tests pass.
- **Task 6:** Accessibility tests complete. 8 vitest-axe + a11y tests: axe violations (form loaded + error state), label associations, aria-describedby error linking, aria-invalid on errors, focusable fields, aria-required on required fields, role="alert" for errors. Playwright E2E deferred (requires running backend). 43 frontend tests pass.
- **Task 7:** Shared `buildRegistrationSchema()` function in `registration.validator.ts`. Takes `IConfigRegistrationField[]` → dynamic Zod schema. Frontend refactored to use shared builder instead of local copy. 13 new tests. 57 shared tests pass. All 157 tests across 3 repos green.

### Change Log
- 2026-02-08: Task 1 complete - CDS data models + shared types
- 2026-02-08: Task 2 complete - Backend registration service + handler + tests
- 2026-02-08: Task 3 complete - Azure AD B2C adapter + factory + interface + tests
- 2026-02-08: Task 4 complete - Frontend registration page + form + tests
- 2026-02-08: Task 5 complete - MSAL.js integration for post-registration auth
- 2026-02-08: Task 6 complete - Accessibility tests (vitest-axe + a11y assertions)
- 2026-02-08: Task 7 complete - Shared dynamic Zod schema builder + frontend refactor

### File List
- auto-backend/db/schema.cds (modified - references sub-schemas)
- auto-backend/db/schema/config.cds (new)
- auto-backend/db/schema/user.cds (new)
- auto-backend/db/data/auto-ConfigRegistrationField.csv (new)
- auto-backend/test/db/schema.test.ts (new)
- auto-backend/srv/registration-service.cds (new)
- auto-backend/srv/registration-service.ts (new - re-export for CAP auto-discovery)
- auto-backend/srv/handlers/registration-handler.ts (new)
- auto-backend/test/srv/handlers/registration-handler.test.ts (new)
- auto-backend/srv/adapters/interfaces/identity-provider.interface.ts (new)
- auto-backend/srv/adapters/azure-ad-b2c-adapter.ts (new)
- auto-backend/srv/adapters/factory/adapter-factory.ts (new)
- auto-backend/test/srv/adapters/azure-ad-b2c-adapter.test.ts (new)
- auto-shared/src/types/user.ts (modified - added IUser, IRegistrationInput, IRegistrationResult, UserStatus)
- auto-shared/src/types/config.ts (new)
- auto-shared/src/types/index.ts (modified - re-exports new types)
- auto-shared/src/validators/registration.validator.ts (new - buildRegistrationSchema)
- auto-shared/src/validators/index.ts (modified - re-exports buildRegistrationSchema)
- auto-shared/tests/registration-validator.test.ts (new - 13 tests)
- auto-frontend/src/app/(auth)/register/page.tsx (new)
- auto-frontend/src/app/(auth)/callback/page.tsx (new)
- auto-frontend/src/components/auth/registration-form.tsx (new)
- auto-frontend/src/components/auth/msal-provider.tsx (new)
- auto-frontend/src/components/ui/label.tsx (new - shadcn component)
- auto-frontend/src/lib/auth/msal-config.ts (new)
- auto-frontend/src/lib/auth/msal-instance.ts (new)
- auto-frontend/tests/components/auth/registration-form.test.tsx (new - 13 tests)
- auto-frontend/tests/components/auth/registration-form-a11y.test.tsx (new - 8 tests)
