# Story 7.1: Abuse Reporting System

Status: ready-for-dev

## Story

As a user,
I want to report a listing or abusive behavior with specific categorization,
so that the platform maintains quality and trust through community-driven moderation.

## Acceptance Criteria (BDD)

**Given** a user views a listing or interacts with another user
**When** they click "Signaler" (FR37)
**Then** a reporting dialog opens with: report type categories (from `ConfigReportReason` table), severity indicator, free-text description field
**And** report categories are configurable admin (zero-hardcode)

**Given** a user submits a report
**When** the report is processed
**Then** a `Report` CDS record is created with: reporter ID, target type (listing/user/chat), target ID, reason category, severity, description, timestamp, status (`Pending`)
**And** the reporter receives confirmation: "Votre signalement a été enregistré"
**And** the report appears in the moderation queue

## Tasks / Subtasks

### T1: Backend - ConfigReportReason Entity & Seed Data (AC1)
- [ ] T1.1: Define `ConfigReportReason` entity in `db/schema.cds` with fields: ID, code, label (localized), description, targetTypes (listing/user/chat), defaultSeverity, isActive, sortOrder
- [ ] T1.2: Create seed data CSV for initial report reason categories (e.g., fraudulent listing, misleading description, inappropriate content, harassment, spam, other)
- [ ] T1.3: Expose `ConfigReportReason` as a read-only entity in `srv/moderation-service.cds` (no moderator role required for reading categories)
- [ ] T1.4: Write unit tests for ConfigReportReason entity exposure and filtering by targetType and isActive

### T2: Backend - Report Entity & Creation Endpoint (AC1, AC2)
- [ ] T2.1: Define `Report` entity in `db/schema.cds` with fields: ID, reporter (association to User), targetType (enum: Listing/User/Chat), targetID (UUID), reason (association to ConfigReportReason), severity (enum: Low/Medium/High/Critical), description (String(2000)), status (enum: Pending/InProgress/Treated/Dismissed), createdAt, updatedAt
- [ ] T2.2: Implement `submitReport` action in `srv/moderation-service.cds` accepting: targetType, targetID, reasonID, severity, description
- [ ] T2.3: Implement `submitReport` handler in `srv/moderation-service.ts`: validate inputs (target exists, reason exists and is active, description length), create Report record with status `Pending`, return confirmation
- [ ] T2.4: Add authorization: any authenticated user can submit reports; prevent self-reporting (user cannot report their own listing)
- [ ] T2.5: Add rate limiting: max 10 reports per user per day to prevent abuse
- [ ] T2.6: Write unit tests for report creation, validation, duplicate prevention, rate limiting
- [ ] T2.7: Write integration tests for the full submitReport flow

### T3: Frontend - Report Button & Dialog Component (AC1)
- [ ] T3.1: Create `src/components/moderation/report-dialog.tsx` - a modal dialog component with: reason category dropdown (fetched from ConfigReportReason API), severity indicator (auto-set from category defaultSeverity, overridable), free-text description textarea (max 2000 chars), submit and cancel buttons
- [ ] T3.2: Create `src/components/moderation/report-button.tsx` - a "Signaler" button component that accepts targetType and targetID props and opens the report dialog
- [ ] T3.3: Integrate report button into listing detail page and user profile contexts
- [ ] T3.4: Implement form validation: reason required, description minimum 20 characters
- [ ] T3.5: On successful submission, show toast confirmation: "Votre signalement a été enregistré"
- [ ] T3.6: Handle error states (network failure, rate limit exceeded, already reported)
- [ ] T3.7: Write component tests for report-dialog and report-button

### T4: Frontend - API Integration (AC2)
- [ ] T4.1: Create API client functions for: `fetchReportReasons(targetType)`, `submitReport(data)`
- [ ] T4.2: Implement optimistic UI: disable submit button on click, show loading state, handle success/error
- [ ] T4.3: Write integration tests for API calls

## Dev Notes

### Architecture & Patterns
- The reporting system is the entry point for the moderation pipeline. Reports flow from user submission to the moderation queue (Story 7.2) where moderators take action (Story 7.3).
- ConfigReportReason follows the config-table pattern used across the project: admin-configurable lookup tables that eliminate hardcoded values.
- The Report entity is central to the moderation domain and will be referenced by ModerationAction (Story 7.3) and seller history views (Story 7.4).
- The `submitReport` action should be a CDS bound/unbound action (not a standard CRUD POST) to encapsulate validation logic.

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend, PostgreSQL, Azure
- **Moderation service:** moderation-service.cds + moderation-service.ts
- **Report entity:** In CDS schema with type and severity classification (ConfigReportReason table for categories)
- **Moderation cockpit:** src/app/(dashboard)/moderation/* (SPA behind auth, moderator role required)
- **Actions:** Deactivate listing, deactivate account, send warning, reactivate
- **Seller history:** View all past reports, seller rating, account age
- **RBAC:** Moderator role required for all moderation endpoints
- **Audit trail:** All moderation actions logged via audit-trail middleware
- **Notifications:** Notify seller of moderation actions via notification-hub
- **ConfigModerationRule:** Configurable moderation rules from DB
- **Testing:** >=90% unit, >=80% integration, component tests for all moderation UI

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded report categories (use ConfigReportReason table)
- Hardcoded moderation rules (use ConfigModerationRule table)
- Skipping audit trail on moderation actions
- French in code

### Project Structure Notes
Backend: srv/moderation-service.cds + .ts, db/schema.cds (Report, ModerationAction entities)
Frontend: src/app/(dashboard)/moderation/page.tsx (reports queue), src/app/(dashboard)/moderation/reports/[id]/page.tsx (report detail), src/app/(dashboard)/moderation/sellers/[id]/page.tsx (seller history), src/components/moderation/ (report-card, report-detail, seller-history, moderation-actions)

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-7/story-7.1-abuse-reporting.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
