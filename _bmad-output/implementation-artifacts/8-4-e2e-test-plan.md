# Story 8.4: E2E Test Plan — Complete User Journeys

Status: done

## Story

As a QA/developer,
I want a comprehensive test matrix of all possible user actions across all personas,
so that I can validate every front-end flow works correctly with the backend using seed data.

## Acceptance Criteria (BDD)

**AC-TEST-01: Full persona coverage**
**Given** the test plan is written
**Then** it covers all 5 personas: Anonymous Visitor, Buyer, Seller, Moderator, Admin

**AC-TEST-02: Complete action coverage per persona**
**Given** each persona section
**Then** every possible user action is listed with:
- Action description (e.g., "Ajouter une annonce aux favoris")
- Source route (e.g., `/listing/[slug]`)
- Destination route (e.g., `/favorites`)
- Prerequisites (e.g., "authenticated as buyer, listing exists")
- Expected result (e.g., "listing appears in favorites list, heart icon filled")
- Seed data required (e.g., "active listing from seed, buyer1 account")

**AC-TEST-03: Critical paths identified and prioritized**
**Given** the complete action matrix
**Then** the top 10-15 critical user journeys (happy paths) are marked P0:
- Visitor: Homepage -> Search -> View listing -> Register -> Login
- Buyer: Login -> Search -> Filter -> Favorite -> Chat seller -> Notifications
- Seller: Login -> Create draft -> Auto-fill vehicle -> Complete form -> Upload photos -> Declaration -> Pay -> Publish -> Track -> Chat buyer -> Manage lifecycle
- Moderator: Login -> View reports queue -> Review report -> Take action -> View seller history
- Admin: Login -> View KPIs -> Configure platform -> Manage alerts -> Manage users -> Legal docs -> SEO -> Audit trail

**AC-TEST-04: Error and edge cases documented**
**Given** each persona section
**Then** error scenarios are documented:
- 401 (unauthenticated access to protected routes)
- 403 (unauthorized role access)
- 404 (non-existent resources)
- Validation errors (invalid form submissions)
- Empty states (no results, no data)
- Suspended account behavior

**AC-TEST-05: Seed data cross-reference**
**Given** the complete test plan
**Then** every test case references the specific seed data it requires from Story 8-1
**And** the plan confirms 100% coverage: every seed data record is exercised by at least one test case

## Tasks / Subtasks

### T1: Document - Anonymous Visitor Journey (AC-TEST-01, AC-TEST-02)
- [x] T1.1: Map all visitor actions: homepage navigation, search (with filters, sorting, pagination), listing detail view, seller profile view, informational pages (about, how-it-works, trust), legal pages, register flow, login flow
- [x] T1.2: Map navigation paths: header links (desktop), tab bar (mobile), footer links, breadcrumbs
- [x] T1.3: Map error scenarios: accessing protected routes (redirect to login), non-existent listing (404), empty search results

### T2: Document - Buyer Journey (AC-TEST-01, AC-TEST-02)
- [x] T2.1: Map all buyer actions: login, search with all filter types (brand, model, year, price, mileage, location, fuel, certification level, market price comparison), sort options, infinite scroll/pagination
- [x] T2.2: Map listing interactions: view detail, view photos gallery, view certified vs declared data, view vehicle history report, view seller profile from listing
- [x] T2.3: Map favorites: add to favorites, remove from favorites, view favorites list, empty favorites state
- [x] T2.4: Map chat: initiate conversation from listing, send message, receive message, view conversation list, unread indicator
- [x] T2.5: Map notifications: receive notification, mark as read, notification bell indicator, notification preferences
- [x] T2.6: Map profile/settings: view profile, edit profile, consent management, security settings, data privacy (export, anonymization request), notification preferences
- [x] T2.7: Map error scenarios: favoriting same listing twice, chatting with suspended seller, accessing other user's data

### T3: Document - Seller Journey (AC-TEST-01, AC-TEST-02)
- [x] T3.1: Map listing creation flow: start new draft, enter plate/VIN, auto-fill moment (certified fields populate), complete declared fields, upload photos (add, reorder, delete, set primary), set price, preview visibility score, save draft
- [x] T3.2: Map publication flow: select drafts for publication, review batch, declaration of honor (read, sign), payment (Stripe mock), confirmation, listing goes live
- [x] T3.3: Map listing management: view active listings, view draft listings, view listing stats (views, favorites, contacts), renew listing, mark as sold, withdraw listing, edit published listing
- [x] T3.4: Map seller cockpit: dashboard KPIs (views, contacts, active count), market price positioning chart, market watch (competitors, alerts), empty state onboarding for new sellers
- [x] T3.5: Map chat: view conversations, reply to buyer, conversation linked to specific listing
- [x] T3.6: Map error scenarios: publish without required fields, payment failure, upload oversized photo, exceed max photos, edit deactivated listing

### T4: Document - Moderator Journey (AC-TEST-01, AC-TEST-02)
- [x] T4.1: Map report management: view report queue (with filters: status, type, severity), view report detail, view reported listing, view reported seller
- [x] T4.2: Map moderation actions: send warning to seller, deactivate listing, deactivate seller account, reactivate listing, reactivate account, add moderator note
- [x] T4.3: Map seller history: navigate from report to seller history, view timeline, view pattern alerts, take escalated action from history page
- [x] T4.4: Map error scenarios: action on already-resolved report, action on non-existent seller, concurrent moderation (two moderators on same report)

### T5: Document - Admin Journey (AC-TEST-01, AC-TEST-02)
- [x] T5.1: Map KPI dashboard: view all metrics, filter by date range, view individual metric detail pages
- [x] T5.2: Map platform configuration: each config section (features, pricing, costs, registration, card display, providers, texts, analytics), edit values, save, verify changes take effect
- [x] T5.3: Map alert management: view alerts, configure thresholds, enable/disable alerts, test alert triggers
- [x] T5.4: Map user management: list users, search users, view user detail, change user role, suspend user
- [x] T5.5: Map legal documents: list documents, edit document, create new version, publish version, verify re-acceptance trigger
- [x] T5.6: Map SEO management: view templates, edit templates, preview generated SEO
- [x] T5.7: Map audit trail: view audit log, filter by entity/action/user/date, view API call audit, export
- [x] T5.8: Map error scenarios: save invalid config, delete active legal document

### T6: Synthesis - Matrix & Prioritization (AC-TEST-03, AC-TEST-04, AC-TEST-05)
- [x] T6.1: Compile all actions into a single matrix table (persona, action, route, prerequisites, expected result, seed data, priority)
- [x] T6.2: Mark top 10-15 critical journeys as P0 (must work for launch)
- [x] T6.3: Mark secondary journeys as P1 (important but not blocking)
- [x] T6.4: Mark edge cases and error scenarios as P2
- [x] T6.5: Cross-reference every test with seed data from Story 8-1 — flag any gaps
- [x] T6.6: Add summary stats: total actions, P0/P1/P2 breakdown, coverage percentage

## Output

The deliverable is a document: `_bmad-output/implementation-artifacts/e2e-test-plan-user-journeys.md`

Structure:
1. **Overview** — purpose, personas, priority definitions
2. **Seed Data Reference** — summary of available seed data from 8-1
3. **Visitor Journey** — complete action table
4. **Buyer Journey** — complete action table
5. **Seller Journey** — complete action table
6. **Moderator Journey** — complete action table
7. **Admin Journey** — complete action table
8. **Critical Path Matrix** — P0 journeys in sequence
9. **Error Scenarios Matrix** — all error/edge cases
10. **Coverage Summary** — stats, gaps, recommendations

## Dev Notes

### Architecture & Patterns
- This story produces a **document**, not code. No tests to run, no components to build.
- The document serves as: (1) manual QA checklist for dev environment, (2) specification for future automated E2E tests (Playwright/Cypress), (3) acceptance criteria for the platform "readiness" assessment.
- Every action must be verifiable using seed data from Story 8-1.

### Key Technical Context
- **All 53 routes** in the frontend must be covered by at least one test case
- **All API endpoints** exercised by frontend actions should be documented
- **Role matrix:** buyer, seller, moderator, admin — each has different accessible routes
- **Dev-mode auth:** Users can switch roles via dev-mode auto-login

### Anti-Patterns (FORBIDDEN)
- Do NOT write automated test code in this story — this is a planning document
- Do NOT assume features that don't exist — only test what's built
- Do NOT skip error scenarios — they are as important as happy paths

### Dependencies
- **Story 8-1 (seed data):** Required for verifying that every test case has the necessary data to execute. The test plan should be written in parallel but validated against actual seed data.

### References
- All story files (1-1 through 7-4): acceptance criteria define the expected behaviors
- Route map: 53 routes across public, auth, and dashboard groups
- RBAC: Story 1-5 defines roles and permissions
- Responsive standards: `_bmad-output/responsive-design-standards.md`
