# Story 7.4: Seller History & Moderation Context

Status: ready-for-dev

## Story

As a moderator,
I want to view a seller's complete history (previous reports, warnings, rating, seniority, listing patterns),
so that I can make informed moderation decisions with full context.

## Acceptance Criteria (BDD)

**Given** a moderator is reviewing a report about a seller
**When** they click "Voir l'historique vendeur" (FR42)
**Then** the seller history view shows: account creation date, total listings published, active listings count, all previous reports (with outcomes), warnings received, account suspensions, seller rating, average certification level

**Given** a moderator views a seller with repeated violations
**When** the history shows a pattern
**Then** the pattern is visually highlighted (e.g., "3eme signalement en 30 jours")
**And** the moderator can take escalated action (account deactivation)

## Tasks / Subtasks

### T1: Backend - Seller History API Endpoint (AC1)
- [ ] T1.1: Implement `getSellerHistory` function/action in `srv/moderation-service.cds` accepting sellerID, returning a structured seller history object
- [ ] T1.2: Implement handler in `srv/moderation-service.ts` that aggregates: account creation date (from User entity), total listings published (count of all Listing records by seller), active listings count (count of Active status listings), all previous reports against this seller or their listings (with report details, reason, outcome/status), all warnings received (from ModerationAction where actionType = Warning), all account suspensions (from ModerationAction where actionType = DeactivateAccount), seller rating (average from reviews/ratings), average certification level (percentage of listings with SIV certification)
- [ ] T1.3: Authorization: moderator role required
- [ ] T1.4: Optimize queries: use aggregation queries to avoid loading all entities, add DB indexes on seller foreign keys in Report and ModerationAction tables
- [ ] T1.5: Write unit tests for seller history data assembly (seller with no history, seller with mixed history, seller with many reports)
- [ ] T1.6: Write integration tests for getSellerHistory endpoint

### T2: Backend - Violation Pattern Detection (AC2)
- [ ] T2.1: Implement pattern detection logic in `srv/moderation-service.ts`: count reports in last 30 days, count warnings in last 90 days, count account suspensions total, identify repeated report reasons (same ConfigReportReason category appearing 3+ times)
- [ ] T2.2: Return pattern data as part of the seller history response: `patterns` array with objects containing `type` (frequentReports/repeatedWarnings/repeatOffender/sameReasonPattern), `description` (human-readable), `count`, `period`, `severity` (info/warning/critical)
- [ ] T2.3: Pattern thresholds should be loaded from `ConfigModerationRule` table (not hardcoded): e.g., "frequentReports" threshold = 3 reports in 30 days, "repeatedWarnings" threshold = 2 warnings in 90 days
- [ ] T2.4: Write unit tests for pattern detection with various seller histories
- [ ] T2.5: Write integration tests for pattern detection with ConfigModerationRule configuration

### T3: Frontend - Seller History Page (AC1)
- [ ] T3.1: Create `src/app/(dashboard)/moderation/sellers/[id]/page.tsx` with moderator role guard
- [ ] T3.2: Create `src/components/moderation/seller-history.tsx` as the main layout component with sections: seller profile summary, statistics cards, moderation timeline, pattern alerts
- [ ] T3.3: Implement seller profile summary section: avatar/initials, name, account creation date (with "Membre depuis X mois/ans"), seller rating (star display), account status (Active/Suspended badge)
- [ ] T3.4: Implement statistics cards section: total listings published (number), active listings (number), reports received (number with trend), warnings received (number), suspensions (number), average certification level (percentage bar)
- [ ] T3.5: Implement moderation timeline section: chronological list of all moderation events (reports, warnings, suspensions, reactivations) with: event type icon, date, description, outcome, moderator who handled it. Use a vertical timeline UI pattern for clear chronological visualization.
- [ ] T3.6: Implement breadcrumb navigation: Moderation > Reports > Report #ID > Seller History
- [ ] T3.7: Write component tests for seller-history with mock data covering various seller profiles

### T4: Frontend - Pattern Alerts & Escalation (AC2)
- [ ] T4.1: Create `src/components/moderation/pattern-alert.tsx` component: displays pattern alerts prominently at the top of the seller history page, color-coded by severity (info=blue, warning=orange, critical=red), each alert shows: pattern icon, description text (e.g., "3eme signalement en 30 jours"), action suggestion
- [ ] T4.2: For critical patterns (e.g., repeat offender), show escalation prompt: "Ce vendeur presente un historique problematique. Envisagez la desactivation du compte." with a direct "Suspendre le compte" button
- [ ] T4.3: The escalation button triggers the `deactivateAccount` action from Story 7.3 (reuse the same action flow with double confirmation)
- [ ] T4.4: Write component tests for pattern-alert with different pattern types and severities

### T5: Frontend - API Integration (AC1, AC2)
- [ ] T5.1: Create API client function: `fetchSellerHistory(sellerID)` returning the full seller history with patterns
- [ ] T5.2: Implement loading skeleton for seller history page (profile, stats, timeline sections)
- [ ] T5.3: Handle edge cases: seller not found (404 page), seller with no history (empty state with message), API error (error boundary with retry)
- [ ] T5.4: Add link from report detail page (Story 7.2) to seller history page: "Voir l'historique vendeur" button
- [ ] T5.5: Write integration tests for fetchSellerHistory API call

## Dev Notes

### Architecture & Patterns
- The seller history page is the final piece of the moderation pipeline. It provides the full context a moderator needs to make escalated decisions (especially account deactivation).
- Pattern detection is a key feature that transforms raw data into actionable insights. The patterns are computed server-side to ensure consistency and to leverage ConfigModerationRule thresholds.
- The moderation timeline is a chronological view that combines reports, warnings, suspensions, and reactivations into a single narrative, making it easy for moderators to spot escalation patterns.
- ConfigModerationRule is used for pattern thresholds to ensure they can be tuned by admins without code changes. Example rules: `frequentReports.threshold=3`, `frequentReports.periodDays=30`, `repeatedWarnings.threshold=2`, `repeatedWarnings.periodDays=90`.
- The escalation action (account deactivation) reuses the same backend action from Story 7.3, ensuring consistent behavior and audit trail regardless of where the action is triggered from.

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
- [Source: _bmad-output/planning-artifacts/stories/epic-7/story-7.4-seller-history.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
