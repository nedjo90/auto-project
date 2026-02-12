# Story 2.7: Legal Texts Versioning & Re-acceptance

Status: done

## Story

As an administrator,
I want to manage legal texts (CGU, CGV, privacy policy, legal notices) with versioning and automatic re-acceptance,
so that users always accept the current version and the platform stays legally compliant.

## Acceptance Criteria (BDD)

**Given** an admin accesses the Legal Texts page (FR52)
**When** they view the legal documents
**Then** each document shows: current version number, last update date, content (rich text), acceptance count

**Given** an admin updates a legal document
**When** they save a new version
**Then** the version number is incremented
**And** the previous version is archived (not deleted)
**And** a flag `requiresReacceptance` is set to true

**Given** a user logs in after a legal text has been updated with `requiresReacceptance = true`
**When** the re-acceptance check runs
**Then** the user is presented with the updated document and must accept before proceeding
**And** the acceptance is recorded with user ID, document ID, version, and timestamp

**Given** legal texts are in development phase
**When** the system is in pre-launch state
**Then** mock/placeholder legal texts are displayed (to be replaced by lawyer-validated texts before launch)

## Tasks / Subtasks

### Task 1: Define LegalDocument and LegalDocumentVersion CDS Entities (AC1, AC2)
- **1.1** Add `LegalDocument` entity to `db/schema.cds`:
  - id: UUID
  - key: String (enum-like: "cgu", "cgv", "privacy_policy", "legal_notices")
  - title: String
  - currentVersion: Integer
  - requiresReacceptance: Boolean
  - active: Boolean
- **1.2** Add `LegalDocumentVersion` entity to `db/schema.cds`:
  - id: UUID
  - documentId: UUID (association to LegalDocument)
  - version: Integer
  - content: LargeString (rich text / HTML)
  - summary: String (summary of changes for re-acceptance prompt)
  - publishedAt: Timestamp
  - publishedBy: String
  - archived: Boolean
- **1.3** Add `managed` aspect to both entities
- **1.4** Expose both entities in `admin-service.cds` with full CRUD
- **1.5** Write unit tests for entity definitions

### Task 2: Define LegalAcceptance CDS Entity (AC3)
- **2.1** Add `LegalAcceptance` entity to `db/schema.cds`:
  - id: UUID
  - userId: UUID (association to User)
  - documentId: UUID (association to LegalDocument)
  - documentKey: String
  - version: Integer
  - acceptedAt: Timestamp
  - ipAddress: String
  - userAgent: String
- **2.2** Add index on (userId, documentId) for fast lookup
- **2.3** Expose read-only in `admin-service.cds` (admins can view acceptance records but not modify)
- **2.4** Write unit tests for entity definition

### Task 3: Create Seed Data for Legal Documents (AC4)
- **3.1** Create `db/data/LegalDocument.csv` with 4 documents: CGU, CGV, Privacy Policy, Legal Notices
- **3.2** Create `db/data/LegalDocumentVersion.csv` with version 1 placeholder content for each:
  - CGU: "[PLACEHOLDER] Conditions Generales d'Utilisation - A remplacer par un texte valide juridiquement avant le lancement"
  - CGV: "[PLACEHOLDER] Conditions Generales de Vente - A remplacer par un texte valide juridiquement avant le lancement"
  - Privacy Policy: "[PLACEHOLDER] Politique de Confidentialite - A remplacer par un texte valide juridiquement avant le lancement"
  - Legal Notices: "[PLACEHOLDER] Mentions Legales - A remplacer par un texte valide juridiquement avant le lancement"
- **3.3** Write integration tests verifying seed data loads correctly

### Task 4: Implement Legal Texts Admin Page (AC1)
- **4.1** Create `src/app/(dashboard)/admin/legal/page.tsx`
- **4.2** Build a card-based layout listing all `LegalDocument` entries
- **4.3** Each card displays: document title, current version number, last update date, acceptance count (computed from LegalAcceptance), requiresReacceptance badge
- **4.4** Compute acceptance count via backend aggregation endpoint
- **4.5** Write component tests for card rendering and data display

### Task 5: Implement Legal Document Editor (AC2)
- **5.1** Create `src/app/(dashboard)/admin/legal/[id]/edit/page.tsx`
- **5.2** Build a rich text editor component (use a library like TipTap, Lexical, or similar)
- **5.3** Load current version content into the editor
- **5.4** Add a "changes summary" text input for the re-acceptance prompt
- **5.5** Add a "Requires Re-acceptance" checkbox (default: true for new versions)
- **5.6** On save:
  - Create new `LegalDocumentVersion` with incremented version number
  - Update `LegalDocument.currentVersion` to the new version number
  - Set `LegalDocument.requiresReacceptance` based on checkbox
  - Archive previous version (set archived = true)
- **5.7** Implement version history sidebar showing all past versions with date and publisher
- **5.8** Allow viewing (read-only) of archived versions
- **5.9** Wire all operations to AdminService OData endpoints
- **5.10** Write component tests for editor, version history, and save flow

### Task 6: Implement Backend Version Management Logic (AC2)
- **6.1** Add custom action in `admin-service.cds`: `action publishLegalVersion(documentId: UUID, content: LargeString, summary: String, requiresReacceptance: Boolean) returns LegalDocumentVersion`
- **6.2** Implement handler in `admin-service.ts`:
  - Validate document exists
  - Increment version number
  - Create new LegalDocumentVersion record
  - Archive previous version
  - Update LegalDocument currentVersion and requiresReacceptance
  - Log to audit trail
- **6.3** Add `function getLegalAcceptanceCount(documentId: UUID) returns Integer` for acceptance stats
- **6.4** Write integration tests for version publish workflow
- **6.5** Write integration tests for acceptance count query

### Task 7: Implement Re-acceptance Check Middleware (AC3)
- **7.1** Create `srv/middleware/legal-check.ts` middleware
- **7.2** On authenticated requests, check if any `LegalDocument` with `requiresReacceptance = true` has a version newer than the user's last acceptance
- **7.3** Query `LegalAcceptance` for the user: for each document, compare accepted version vs current version
- **7.4** If re-acceptance is needed, return a specific response (e.g., HTTP 403 with `requiresLegalAcceptance: true` and list of documents needing acceptance)
- **7.5** Optimize: cache user acceptance status in session/token to avoid DB queries on every request
- **7.6** Write unit tests for acceptance check logic
- **7.7** Write integration tests for middleware behavior with various acceptance states

### Task 8: Implement Frontend Re-acceptance Flow (AC3)
- **8.1** Create `src/components/legal/legal-acceptance-modal.tsx` modal component
- **8.2** Display the updated legal document content with change summary
- **8.3** Require explicit acceptance (checkbox + "I accept" button)
- **8.4** On acceptance, call backend endpoint to create `LegalAcceptance` record
- **8.5** Create `src/lib/api/legal-api.ts` with functions: `checkLegalAcceptance()`, `acceptLegalDocument(documentId, version)`
- **8.6** Integrate acceptance check into the authenticated app layout: if legal acceptance is needed, show modal before allowing navigation
- **8.7** Create `srv/public-service.cds` (or extend existing) with `action acceptLegalDocument(documentId: UUID, version: Integer)` for authenticated users
- **8.8** Implement handler: create LegalAcceptance record with userId, documentId, version, timestamp, IP, user agent
- **8.9** Write component tests for modal rendering and acceptance flow
- **8.10** Write integration tests for end-to-end re-acceptance workflow

### Task 9: Implement Public Legal Pages (AC4)
- **9.1** Create `src/app/(public)/legal/[key]/page.tsx` for public-facing legal text display
- **9.2** Fetch current active version content from a public API endpoint
- **9.3** Render rich text content
- **9.4** Add footer links to CGU, CGV, Privacy Policy, Legal Notices
- **9.5** Write component tests for public legal page rendering

## Dev Notes

### Architecture & Patterns
- Legal texts use a **versioned document** pattern: `LegalDocument` is the master record, `LegalDocumentVersion` holds each version's content. Previous versions are archived, never deleted (legal compliance requirement).
- The **re-acceptance mechanism** is critical for RGPD (GDPR) compliance: when legal texts change materially, users must re-accept before continuing to use the platform.
- Re-acceptance check runs as **middleware** on authenticated requests. To avoid performance impact, cache the user's acceptance status in the session or JWT token claims.
- The `publishLegalVersion` custom action encapsulates the complex version increment + archive + flag update logic in a single atomic operation.
- Placeholder texts are used during development. The system is designed so that lawyer-validated texts can be entered via the admin UI before launch without any code changes.
- Legal acceptance records (LegalAcceptance) include IP address and user agent for legal evidence purposes.

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
- `db/schema.cds` - LegalDocument, LegalDocumentVersion, LegalAcceptance entities
- `db/data/LegalDocument.csv` - Legal document seed data
- `db/data/LegalDocumentVersion.csv` - Placeholder version seed data
- `src/app/(dashboard)/admin/legal/page.tsx` - Legal texts admin list page
- `src/app/(dashboard)/admin/legal/[id]/edit/page.tsx` - Legal document editor page
- `src/app/(public)/legal/[key]/page.tsx` - Public legal text display page
- `src/components/legal/legal-acceptance-modal.tsx` - Re-acceptance modal
- `src/lib/api/legal-api.ts` - Legal API client functions
- `srv/middleware/legal-check.ts` - Re-acceptance check middleware
- `srv/admin-service.cds` - publishLegalVersion action, LegalDocument/Version CRUD
- `srv/admin-service.ts` - Legal text management handlers

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Completion Notes List
- Used textarea editor instead of rich text (TipTap/Lexical) since content is placeholder text during development phase
- Re-acceptance check implemented as a LegalService function (`checkLegalAcceptance`) rather than middleware to follow existing consent-check pattern
- Created separate `legal-service.cds` for public/authenticated legal endpoints (instead of extending existing services)
- Adversarial code review found and fixed: race condition (unique constraint), N+1 query (batch optimization), OData injection, infinite render loop, stale state, IP truncation
- 1166 tests total: 248 shared + 458 backend + 460 frontend

### Change Log
- auto-shared: feat(config) + fix via review
- auto-backend: feat(config) + fix(config) via review
- auto-frontend: feat(config) + fix(config) via review
- auto-project: docs update sprint-status + story file

### File List

#### auto-shared
- `src/types/legal.ts` - ILegalDocument, ILegalDocumentVersion, ILegalAcceptance, LegalDocumentKey
- `src/constants/legal.ts` - LEGAL_DOCUMENT_KEYS, LEGAL_DOCUMENT_LABELS
- `src/validators/legal.validator.ts` - publishLegalVersionInputSchema, acceptLegalDocumentInputSchema
- `src/types/index.ts` - barrel export update
- `src/constants/index.ts` - barrel export update
- `src/validators/index.ts` - barrel export update
- `tests/legal-constants.test.ts` - 5 tests
- `tests/legal-validator.test.ts` - 13 tests

#### auto-backend
- `db/schema/legal.cds` - LegalDocument, LegalDocumentVersion (w/ unique constraint), LegalAcceptance
- `db/schema.cds` - import legal schema
- `db/data/auto-LegalDocument.csv` - 4 document seed records
- `db/data/auto-LegalDocumentVersion.csv` - 4 placeholder version records
- `srv/admin-service.cds` - LegalDocuments, LegalDocumentVersions projections + publishLegalVersion action + getLegalAcceptanceCount function
- `srv/admin-service.ts` - publishLegalVersion + getLegalAcceptanceCount handlers
- `srv/legal-service.cds` - public legal service with getCurrentVersion, acceptLegalDocument, checkLegalAcceptance
- `srv/legal-service.ts` - delegates to handler
- `srv/handlers/legal-handler.ts` - getCurrentVersion, acceptLegalDocument (w/ duplicate check + IP extraction), checkLegalAcceptance (batched queries)
- `test/db/legal-schema.test.ts` - schema + seed data tests
- `test/srv/handlers/legal-handler.test.ts` - handler tests
- `test/srv/admin-service.test.ts` - updated with legal entity mocks + publish/count tests

#### auto-frontend
- `src/lib/api/legal-api.ts` - publishLegalVersion, getLegalAcceptanceCount, getCurrentLegalVersion, checkLegalAcceptance, acceptLegalDocument
- `src/lib/api/config-api.ts` - added LegalDocuments/Versions/Acceptances to VALID_ENTITIES
- `src/app/(dashboard)/admin/legal/page.tsx` - admin legal texts list page
- `src/app/(dashboard)/admin/legal/[id]/edit/page.tsx` - legal document editor with version history
- `src/app/(public)/legal/[key]/page.tsx` - public legal page (SSR w/ metadata)
- `src/components/legal/legal-acceptance-modal.tsx` - step-through re-acceptance modal (w/ useEffect + AbortController)
- `tests/app/dashboard/admin/legal/legal-page.test.tsx` - 8 tests
- `tests/components/legal/legal-acceptance-modal.test.tsx` - 7 tests
- `tests/lib/api/legal-api.test.ts` - 9 tests
