# Story 7.2: Moderation Cockpit & Report Queue

Status: ready-for-dev

## Story

As a moderator,
I want a dedicated cockpit showing all pending reports sorted by severity and type,
so that I can efficiently triage and address the most critical issues first.

## Acceptance Criteria (BDD)

**Given** a moderator accesses their cockpit (`(dashboard)/moderation/`) (FR38)
**When** the dashboard loads
**Then** summary metrics are displayed: new reports count, in-progress count, weekly trend
**And** reports are listed in a queue sorted by severity (critical > high > medium > low) then by date
**And** each report card shows: type icon, target (listing/user), severity badge, reporter, date, status

**Given** a moderator clicks on a report
**When** the detail view opens
**Then** full context is displayed on a single screen: report details, target listing/user data, certified vs declared data comparison, reporter info, and available actions
**And** the moderator can make a decision in < 2 minutes (UX principle: "contexte complet sans navigation")

## Tasks / Subtasks

### T1: Backend - Moderation Queue API Endpoints (AC1)
- [ ] T1.1: Define `Reports` entity exposure in `srv/moderation-service.cds` with read access restricted to moderator role
- [ ] T1.2: Implement `getReportQueue` query handler in `srv/moderation-service.ts` with: default sort by severity (Critical=1, High=2, Medium=3, Low=4) then by createdAt ascending, pagination support ($top, $skip), filtering by status (Pending, InProgress, Treated, Dismissed), filtering by targetType (Listing/User/Chat), filtering by severity
- [ ] T1.3: Implement `getReportMetrics` function/action returning: newReportsCount (Pending status), inProgressCount, treatedThisWeek, dismissedThisWeek, weeklyTrend (percentage change vs previous week)
- [ ] T1.4: Ensure all queries use efficient DB indexes on (status, severity, createdAt)
- [ ] T1.5: Write unit tests for sorting logic, filtering, and metrics calculation
- [ ] T1.6: Write integration tests for queue API with various filter combinations

### T2: Backend - Report Detail API (AC2)
- [ ] T2.1: Implement report detail endpoint with deep expand: Report with reason (from ConfigReportReason), reporter user info, target entity (listing with seller info or user profile), related reports on same target
- [ ] T2.2: For listing targets: include listing details, seller info, certification data (certified vs declared comparison), listing photos
- [ ] T2.3: For user targets: include user profile, account age, listing count, average rating
- [ ] T2.4: Implement `assignReport` action to set report status to `InProgress` and assign moderator ID when a moderator opens a report detail
- [ ] T2.5: Write unit tests for detail data assembly and assignReport action
- [ ] T2.6: Write integration tests for report detail with listing and user targets

### T3: Frontend - Moderation Dashboard Page (AC1)
- [ ] T3.1: Create `src/app/(dashboard)/moderation/page.tsx` with moderator role guard (redirect unauthorized users)
- [ ] T3.2: Create `src/components/moderation/metrics-summary.tsx` displaying: new reports count (with badge), in-progress count, weekly trend (up/down arrow with percentage)
- [ ] T3.3: Create `src/components/moderation/report-card.tsx` displaying: type icon (listing/user/chat), target name/title, severity badge (color-coded: critical=red, high=orange, medium=yellow, low=gray), reporter name, date (relative format: "il y a 2h"), status pill
- [ ] T3.4: Create `src/components/moderation/report-queue.tsx` implementing: virtualized list for performance, sort controls (severity+date default, date only, status), filter dropdowns (status, targetType, severity), pagination or infinite scroll
- [ ] T3.5: Implement loading skeleton states for metrics and queue
- [ ] T3.6: Ensure cockpit loads in < 2s (NFR5): use server components for initial data, optimize query payload
- [ ] T3.7: Write component tests for metrics-summary, report-card, report-queue

### T4: Frontend - Report Detail Page (AC2)
- [ ] T4.1: Create `src/app/(dashboard)/moderation/reports/[id]/page.tsx` with single-screen layout showing all context
- [ ] T4.2: Create `src/components/moderation/report-detail.tsx` with sections: report info (reason, severity, description, reporter, date), target preview (listing card or user profile card), certified vs declared data comparison (side-by-side if listing), related reports on same target (count and mini-list)
- [ ] T4.3: Include action buttons area (placeholder for Story 7.3: deactivate listing, send warning, deactivate account, dismiss, reactivate)
- [ ] T4.4: Include "Voir l'historique vendeur" link (navigates to seller history, Story 7.4)
- [ ] T4.5: Auto-assign report to moderator (status -> InProgress) when detail page is opened
- [ ] T4.6: Implement breadcrumb navigation: Moderation > Reports > Report #ID
- [ ] T4.7: Write component tests for report-detail with mock data for listing and user target types

### T5: Frontend - API Integration & State Management (AC1, AC2)
- [ ] T5.1: Create API client functions: `fetchReportQueue(filters, sort, pagination)`, `fetchReportMetrics()`, `fetchReportDetail(id)`, `assignReport(id)`
- [ ] T5.2: Implement client-side caching strategy: metrics refresh every 30s, queue refreshes on filter change and every 60s
- [ ] T5.3: Handle real-time updates: when a report is treated by another moderator, reflect in queue (polling-based initially)
- [ ] T5.4: Write integration tests for API client functions

## Dev Notes

### Architecture & Patterns
- The moderation cockpit is a protected SPA section under `(dashboard)/moderation/`. It requires the moderator RBAC role.
- The dashboard follows a list-detail pattern: the main page shows the queue with metrics, clicking a report navigates to the detail page.
- The "contexte complet sans navigation" UX principle means the detail page must show ALL information needed for a decision on a single screen without requiring the moderator to open additional tabs or pages.
- The certified vs declared data comparison is a key differentiator: moderators can see if a listing's declared data matches the SIV certification data, helping identify fraudulent listings.
- Report assignment (InProgress status) prevents two moderators from working on the same report simultaneously.
- NFR5 requires cockpit load time < 2s. Use server components for initial data fetch and optimize the query to avoid N+1 patterns.

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
- [Source: _bmad-output/planning-artifacts/stories/epic-7/story-7.2-moderation-cockpit.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
