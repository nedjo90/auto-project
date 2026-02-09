# Story 1.7: Account Anonymization & Personal Data Export

Status: done

## Story

As a user,
I want to request anonymization of my account or export of all my personal data,
so that my RGPD rights (right to erasure, right to portability) are respected.

## Acceptance Criteria (BDD)

### AC1: Personal Data Export
**Given** an authenticated user navigates to their account settings
**When** they request personal data export (FR28)
**Then** the system generates a JSON file containing all their personal data (profile, listings, messages, consent records, declarations)
**And** the file is available for download within a configurable timeframe
**And** the export request is logged in the audit trail

### AC2: Account Anonymization
**Given** an authenticated user requests account anonymization (FR27)
**When** they confirm the irreversible action (double confirmation dialog)
**Then** personal data is anonymized (replaced with hashed/generic values), NOT deleted
**And** listings and declarations are preserved with anonymized seller references (data integrity maintained)
**And** the Azure AD B2C account is disabled
**And** the anonymization is logged in the audit trail

### AC3: Anonymized User Display
**Given** a user has been anonymized
**When** anyone views their former listings
**Then** the seller is displayed as "Utilisateur anonymise" with no personal information

## Tasks / Subtasks

### Task 1: Define CDS models for data export and anonymization tracking (AC1, AC2)
1.1. Create `db/schema/rgpd.cds` with `DataExportRequest` entity:
    - `ID: UUID` (key)
    - `user: Association to User`
    - `status: String` (enum: 'pending', 'processing', 'ready', 'downloaded', 'expired')
    - `requestedAt: Timestamp`
    - `completedAt: Timestamp` (nullable)
    - `downloadUrl: String` (nullable, temporary signed URL)
    - `expiresAt: Timestamp` (nullable, when download link expires)
    - `fileSizeBytes: Integer` (nullable)
1.2. Create `AnonymizationRequest` entity in `db/schema/rgpd.cds`:
    - `ID: UUID` (key)
    - `user: Association to User`
    - `status: String` (enum: 'requested', 'confirmed', 'processing', 'completed', 'failed')
    - `requestedAt: Timestamp`
    - `confirmedAt: Timestamp` (nullable, when double-confirmation completed)
    - `completedAt: Timestamp` (nullable)
    - `anonymizedFields: String` (JSON string listing anonymized field names)
1.3. Add `ConfigParameter` seed data:
    - Key: `rgpd.export.download.expiry.hours`, Value: `48` (download link valid for 48 hours).
    - Key: `rgpd.export.processing.timeout.minutes`, Value: `30`.
    - Key: `rgpd.anonymization.cooldown.hours`, Value: `72` (waiting period before anonymization is executed).

### Task 2: Create backend RGPD service for data export (AC1)
2.1. Create `srv/rgpd-service.cds` exposing:
    - `action requestDataExport(): DataExportRequestResult`
    - `function getExportStatus(requestId: UUID): DataExportRequest`
    - `action downloadExport(requestId: UUID): ExportDownloadResult`
    - `action requestAnonymization(): AnonymizationRequestResult`
    - `action confirmAnonymization(requestId: UUID, confirmationCode: String): AnonymizationResult`
2.2. Create `srv/handlers/rgpd-handler.ts` implementing data export:
    - `requestDataExport(req)`:
      a. Create `DataExportRequest` record with status `pending`.
      b. Log request in audit trail.
      c. Trigger async export generation (queue or background job).
      d. Return request ID and estimated completion time.
    - `generateDataExport(requestId)` (internal, async):
      a. Collect all personal data for the user:
         - User profile (from `User` entity).
         - Consent records (from `UserConsent` entity, full history).
         - Listings (if any, from future entities - handle gracefully if not yet implemented).
         - Messages (if any, from future entities - handle gracefully).
         - Declarations (if any, from future entities - handle gracefully).
         - Audit trail entries for this user.
      b. Format as structured JSON with sections.
      c. Upload JSON file to Azure Blob Storage (temporary container).
      d. Generate signed download URL with configurable expiry.
      e. Update `DataExportRequest` with status `ready`, `downloadUrl`, `expiresAt`.
    - `downloadExport(req)`:
      a. Validate request belongs to authenticated user.
      b. Check not expired.
      c. Return download URL (or stream file).
      d. Update status to `downloaded`.
2.3. Write unit tests for data export: request creation, data collection, JSON format, audit logging.

### Task 3: Create backend anonymization logic (AC2, AC3)
3.1. Implement `requestAnonymization(req)` in `srv/handlers/rgpd-handler.ts`:
    a. Create `AnonymizationRequest` record with status `requested`.
    b. Generate a confirmation code (6-digit, sent via email or displayed).
    c. Log request in audit trail.
    d. Return request ID and instructions for confirmation.
3.2. Implement `confirmAnonymization(req)`:
    a. Validate confirmation code.
    b. Update request status to `confirmed`, set `confirmedAt`.
    c. Optionally enforce a cooldown period (configurable) before execution.
    d. Trigger anonymization execution.
3.3. Implement `executeAnonymization(requestId)` (internal):
    a. Replace personal data in `User` entity with anonymized values:
       - `firstName` -> `"Anonyme"`
       - `lastName` -> `"Utilisateur"`
       - `email` -> `"anonymized-{hash}@anonymized.auto"`
       - `phone` -> `null`
       - `address*` fields -> `null`
       - `siret` -> `null`
       - `companyName` -> `null`
       - `avatarUrl` -> `null`
       - `bio` -> `null`
       - `displayName` -> `"Utilisateur anonymise"`
    b. Set `User.isAnonymized = true`, `User.status = 'anonymized'`.
    c. Preserve all listings and declarations but ensure seller references show anonymized name.
    d. Preserve consent records (required for RGPD audit trail even after anonymization).
    e. Disable Azure AD B2C account via identity provider adapter (`disableUser()`).
    f. Update `AnonymizationRequest` status to `completed`.
    g. Log completion in audit trail with list of anonymized fields.
3.4. Implement safeguards:
    - Cannot anonymize admin accounts without super-admin approval.
    - Cannot anonymize if there are active, pending transactions (future check, add placeholder).
    - Anonymization is irreversible - clearly communicate this.
3.5. Write unit tests: anonymization execution, field replacement, AD B2C disable, audit logging, safeguards.

### Task 4: Create frontend account settings RGPD section (AC1, AC2)
4.1. Create `src/app/(dashboard)/settings/page.tsx` (or extend if exists):
    - Account settings page with sections: Profile, Security, Consent (Story 1.3), Data & Privacy.
4.2. Create `src/app/(dashboard)/settings/data-privacy/page.tsx`:
    - Two main sections: "Export de mes donnees" and "Anonymisation de mon compte".
4.3. Create `src/components/settings/data-export-section.tsx`:
    - "Exporter mes donnees" button.
    - On click: call `requestDataExport()` API.
    - Show status indicator (pending, processing, ready).
    - Poll for status updates or use a refresh button.
    - When ready: show download button with expiry notice.
    - Previous export requests listed (with statuses).
4.4. Create `src/components/settings/anonymization-section.tsx`:
    - Clear warning text explaining anonymization is irreversible.
    - List of data that will be anonymized vs. preserved.
    - "Anonymiser mon compte" button (styled as destructive/danger).
4.5. Create `src/components/settings/anonymization-confirmation-dialog.tsx`:
    - **Double confirmation** dialog:
      - Step 1: "Etes-vous sur ? Cette action est irreversible." with explanation. Must type "ANONYMISER" to proceed.
      - Step 2: "Derniere confirmation. Toutes vos donnees personnelles seront anonymisees." Final confirm button.
    - On confirm: call `requestAnonymization()` then `confirmAnonymization()` APIs.
    - On success: logout user and redirect to homepage with confirmation message.
4.6. Handle edge cases in UI:
    - Show loading states during processing.
    - Handle errors (network failure, server error) with retry options.
    - Disable anonymization button if cooldown period is active.

### Task 5: Update public-facing components for anonymized users (AC3)
5.1. Update `src/components/profile/public-seller-card.tsx` (from Story 1.6):
    - Check `isAnonymized` flag.
    - If anonymized: display "Utilisateur anonymise" as name, no avatar, no personal details.
    - Listing counts and dates may still be shown (non-personal data).
5.2. Update `src/app/(public)/sellers/[id]/page.tsx` (from Story 1.6):
    - If seller is anonymized: show minimal page with "Ce vendeur a anonymise son compte."
    - Listings still accessible but with anonymized seller reference.
5.3. Ensure all components that display user information handle the `isAnonymized` flag gracefully.

### Task 6: Azure Blob Storage adapter for export files (AC1)
6.1. Create `srv/adapters/interfaces/blob-storage.interface.ts`:
    - `uploadFile(container, path, content, options): Promise<string>` (returns URL)
    - `generateSignedUrl(container, path, expiryMinutes): Promise<string>`
    - `deleteFile(container, path): Promise<void>`
6.2. Create `srv/adapters/azure-blob-storage-adapter.ts`:
    - Implement using `@azure/storage-blob` SDK.
    - Container: `rgpd-exports` (temporary, lifecycle-managed).
    - Generate SAS (Shared Access Signature) URLs for download.
6.3. Register in adapter factory.
6.4. Write unit tests with mocked Blob Storage SDK.

### Task 7: Shared types (all ACs)
7.1. In `auto-shared`, create `src/types/rgpd.ts`:
    - `IDataExportRequest`, `IAnonymizationRequest`, `ExportStatus` enum, `AnonymizationStatus` enum.
    - `IDataExportContent` (structure of the exported JSON).
7.2. In `auto-shared`, create `src/constants/rgpd.ts`:
    - Anonymization field list, export section names.
7.3. Publish updated `@auto/shared` package.

### Task 8: Testing (all ACs)
8.1. Backend unit tests:
    - Data export: request creation, data collection from multiple entities, JSON structure, signed URL generation, audit logging.
    - Anonymization: field replacement, AD B2C account disable, safeguards (admin check, pending transactions), audit logging.
    - Blob storage adapter: upload, signed URL generation.
8.2. Frontend component tests:
    - Data export section: request flow, status polling, download button.
    - Anonymization section: double confirmation dialog, text input validation ("ANONYMISER"), loading states.
    - Public seller card: anonymized state rendering.
8.3. E2E Playwright tests:
    - Request data export -> wait for ready -> download.
    - Request anonymization -> double confirm -> verify account anonymized -> verify public profile shows "Utilisateur anonymise".

## Dev Notes

### Architecture & Patterns
- **Anonymization, not deletion**: RGPD right to erasure is implemented via anonymization. Personal data is replaced with generic values, but records (listings, declarations, consent history) are preserved for data integrity and audit purposes. This is the architecture-specified approach.
- **Immutable consent records**: Even after anonymization, consent records are preserved because RGPD requires proof of consent given. The anonymized user's consent history remains linked via the `UserConsent.user` association.
- **Async data export**: Export generation is asynchronous because it may involve collecting data from multiple entities and generating a large file. The user requests an export, receives a tracking ID, and polls or returns later to download.
- **Azure Blob Storage** is used for temporary export file storage with SAS URLs for secure, time-limited downloads.
- **Double confirmation** for anonymization is a UX safeguard for an irreversible action. The user must explicitly type a confirmation word and confirm twice.
- The **Adapter Pattern** is used for both Azure AD B2C (disable account) and Azure Blob Storage (file upload/download).

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
  db/schema/rgpd.cds                          # DataExportRequest, AnonymizationRequest entities
  db/data/ConfigParameter.csv                  # RGPD config parameters (extend)
  srv/rgpd-service.cds                         # RGPD service definition
  srv/handlers/rgpd-handler.ts                 # Export and anonymization logic
  srv/adapters/interfaces/blob-storage.interface.ts
  srv/adapters/azure-blob-storage-adapter.ts   # Azure Blob Storage adapter
  test/srv/handlers/rgpd-handler.test.ts
  test/srv/adapters/azure-blob-storage-adapter.test.ts

auto-frontend/
  src/app/(dashboard)/settings/page.tsx                    # Account settings hub
  src/app/(dashboard)/settings/data-privacy/page.tsx       # Data & Privacy section
  src/components/settings/data-export-section.tsx           # Data export UI
  src/components/settings/anonymization-section.tsx         # Anonymization UI
  src/components/settings/anonymization-confirmation-dialog.tsx  # Double-confirm dialog
  src/components/profile/public-seller-card.tsx             # Updated for anonymized state

auto-shared/
  src/types/rgpd.ts
  src/constants/rgpd.ts
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
