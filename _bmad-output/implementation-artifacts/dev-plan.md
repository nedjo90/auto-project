# Development Execution Plan

> This document defines the implementation order, dependencies, and execution rules for the dev agent.
> Always check `sprint-status.yaml` for current story statuses before starting work.

## Execution Rules

1. **Never skip a story** — implement in the order defined below
2. **Check dependencies** — a story can only start when ALL its `depends_on` stories are `done`
3. **Update sprint-status.yaml** — set story to `in-progress` when starting, `done` when complete
4. **One story at a time** — complete and validate each story before moving to the next
5. **Run tests** — every story must pass its own tests AND not break previously passing tests
6. **Fill Dev Agent Record** — update the Dev Agent Record section at the bottom of each story file upon completion

## Phase 1: Foundation

> Goal: 3 repos initialized, shared package published, design system + layouts ready, CI/CD pipelines

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 1 | 1-1 | Project Bootstrap & Design System Foundation | — | all 3 repos |

**Exit criteria:** `cds watch` runs in backend, `npm run dev` runs in frontend, `@auto/shared` importable from both repos, CI pipelines pass.

---

## Phase 2: Core Infrastructure

> Goal: Config engine, auth stack, and RBAC fully operational

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 2 | 2-1 | Zero-Hardcode Configuration Engine | 1-1 | backend, shared |
| 3 | 1-2 | User Registration with Configurable Fields | 1-1, 2-1 | all 3 |
| 4 | 1-3 | Explicit Consent & RGPD Compliance | 1-2 | all 3 |
| 5 | 1-4 | User Authentication (Login, Logout, Session, 2FA) | 1-2 | all 3 |
| 6 | 1-5 | Role-Based Access Control (RBAC) | 1-4 | all 3 |

**Exit criteria:** Users can register, login, have roles assigned. Config tables seeded and cached. Admin role protected. Consent tracked.

---

## Phase 3A: Listing Creation Pipeline (Stream A)

> Goal: Full listing creation flow from auto-fill to publication with payment

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 7 | 3-1 | Adapter Pattern & API Integration Framework | 2-1 | backend, shared |
| 8 | 3-2 | Vehicle Auto-Fill via License Plate or VIN | 3-1 | all 3 |
| 9 | 3-3 | Listing Form & Declared Fields | 3-2 | all 3 |
| 10 | 3-4 | Photo Management | 3-3 | all 3 |
| 11 | 3-5 | Real-Time Visibility Score | 3-3, 3-4 | all 3 |
| 12 | 3-6 | Draft Management | 3-3 | all 3 |
| 13 | 3-7 | Declaration of Honor & Archival | 3-6 | all 3 |
| 14 | 3-8 | Vehicle History Report | 3-1 | all 3 |
| 15 | 3-9 | Batch Publication & Payment via Stripe | 3-7, 3-1 | all 3 |
| 16 | 3-10 | Listing Lifecycle Management | 3-9 | all 3 |
| 17 | 3-11 | API Resilience & Degraded Mode | 3-1 | backend |

**Exit criteria:** Seller can create a listing (auto-fill + manual), upload photos, see visibility score, save draft, sign declaration, pay via Stripe, publish. Listings have lifecycle states.

---

## Phase 3B: Admin & Configuration UI (Stream B)

> Goal: Admin can manage all config, view KPIs, manage API providers
> Can run IN PARALLEL with Phase 3A (after story 7 / 3-1 is done for story 2-3)

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 7b | 2-2 | Platform Configuration UI | 2-1 | frontend |
| 8b | 2-3 | API Provider Management & Cost Tracking | 2-1, 3-1 | all 3 |
| 9b | 2-4 | Admin Dashboard & Real-Time KPIs | 2-2 | all 3 |
| 10b | 2-5 | Configurable Alerts & Thresholds | 2-4 | all 3 |
| 11b | 2-6 | SEO Templates Management | 2-1 | all 3 |
| 12b | 2-7 | Legal Texts Versioning & Re-acceptance | 2-1, 1-3 | all 3 |
| 13b | 2-8 | Audit Trail System | 2-1 | all 3 |

**Exit criteria:** Admin can configure all platform parameters, manage API providers, view KPIs, set alerts, manage SEO templates and legal texts, view audit trail.

---

## Phase 3C: User Profile (Stream C)

> Goal: User profile management and RGPD compliance
> Can run IN PARALLEL with Phase 3A/3B

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 7c | 1-6 | User Profile & Seller Rating Contribution | 1-5 | all 3 |
| 8c | 1-7 | Account Anonymization & Personal Data Export | 1-6, 1-3 | all 3 |

**Exit criteria:** Users can view/edit profile, see completion %, seller rating displayed. Users can export data and anonymize account.

---

## Phase 4: Marketplace & Discovery

> Goal: Public browsing, search, filters, favorites, SEO

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 18 | 4-1 | Public Listing Browsing & Configurable Cards | 3-10 | all 3 |
| 19 | 4-2 | Multi-Criteria Search & Filters | 4-1 | all 3 |
| 20 | 4-3 | Certification & Market Price Filters | 4-2, 3-1 | all 3 |
| 21 | 4-4 | Favorites & Watchlist | 4-1, 1-4 | all 3 |
| 22 | 4-5 | SEO Pages & Structured Data | 4-1, 2-6 | frontend |

**Exit criteria:** Public users can browse, search, filter listings. Authenticated users can favorite. SEO pages and structured data in place.

---

## Phase 5: Real-Time Communication

> Goal: Buyer-seller chat and notification system

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 23 | 5-1 | Real-Time Chat Linked to Vehicle | 1-4, 3-10 | all 3 |
| 24 | 5-2 | Event Notifications & Push | 5-1 | all 3 |

**Exit criteria:** Buyers can chat with sellers about a listing. Push notifications delivered for key events.

---

## Phase 6: Seller Cockpit & Market Intelligence

> Goal: Seller dashboard with KPIs, market positioning, competitor tracking

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 25 | 6-1 | Seller Dashboard & Listing KPIs | 3-10 | all 3 |
| 26 | 6-2 | Market Price Positioning | 6-1, 3-1 | all 3 |
| 27 | 6-3 | Market Watch & Competitor Tracking | 6-1, 4-1 | all 3 |
| 28 | 6-4 | Empty State & Seller Onboarding | 6-1 | frontend |

**Exit criteria:** Sellers have a full dashboard with KPIs, market price positioning, competitor tracking. Empty states guide new sellers.

---

## Phase 7: Moderation & Content Quality

> Goal: Abuse reporting, moderation cockpit, moderator actions, seller history

| Order | Story | Title | Depends On | Repo(s) |
|-------|-------|-------|------------|---------|
| 29 | 7-1 | Abuse Reporting System | 1-4, 3-10 | all 3 |
| 30 | 7-2 | Moderation Cockpit & Report Queue | 7-1, 1-5 | all 3 |
| 31 | 7-3 | Moderation Actions & Notifications | 7-2, 5-2 | all 3 |
| 32 | 7-4 | Seller History & Recurrence Detection | 7-2 | all 3 |

**Exit criteria:** Users can report abuse. Moderators have a cockpit to triage, act on reports, and view seller history.

---

## Parallelization Guide

```
Timeline:
=========

Phase 1:  [1-1] ─────────────────────────────────────────────────────────────
Phase 2:        [2-1] → [1-2] → [1-3] → [1-4] → [1-5] ─────────────────────
                  │                                  │
Phase 3A:         └──→ [3-1] → [3-2] → [3-3] → [3-4] → [3-5]
                         │       [3-6] → [3-7] → [3-9] → [3-10] → [3-11]
                         │       [3-8] ──────────────┘
                         │
Phase 3B:         └──→ [2-2] → [2-4] → [2-5]
                    └──→ [2-3] (after 3-1)
                    └──→ [2-6]
                    └──→ [2-7] (after 1-3)
                    └──→ [2-8]
                                    │
Phase 3C:                [1-6] → [1-7] ─────────────────────────────────────

Phase 4:                              [4-1] → [4-2] → [4-3]
                                        │       [4-4]
                                        └──→ [4-5]

Phase 5:                                    [5-1] → [5-2]
Phase 6:                              [6-1] → [6-2] → [6-3] → [6-4]
Phase 7:                                    [7-1] → [7-2] → [7-3] → [7-4]
```

## Single-Agent Sequential Path (recommended)

If using a single dev agent, follow this linear order:

```
1-1 → 2-1 → 1-2 → 1-3 → 1-4 → 1-5 →
3-1 → 3-2 → 3-3 → 3-4 → 3-5 → 3-6 → 3-7 → 3-8 → 3-9 → 3-10 → 3-11 →
1-6 → 1-7 →
2-2 → 2-3 → 2-4 → 2-5 → 2-6 → 2-7 → 2-8 →
4-1 → 4-2 → 4-3 → 4-4 → 4-5 →
5-1 → 5-2 →
6-1 → 6-2 → 6-3 → 6-4 →
7-1 → 7-2 → 7-3 → 7-4
```

## Story File Location

All story files are at: `_bmad-output/implementation-artifacts/{story-key}.md`
Sprint status tracking: `_bmad-output/implementation-artifacts/sprint-status.yaml`
