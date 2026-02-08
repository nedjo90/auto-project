# Test Plan

> Actionable testing reference for the dev agent. Extracted and organized from `architecture.md`.
> **Rule: No code without tests. Tests are written WITH the code, not after.**

## Coverage Thresholds (CI gates — pipeline fails if not met)

| Test Type | Framework | Target | Scope |
|-----------|-----------|--------|-------|
| Unit Tests | Jest (backend/shared), Vitest (frontend) | **>= 90% line coverage** | Every function, every branch, every edge case |
| Integration Tests | Jest + `cds.test()` with SQLite | **>= 80% of service endpoints** | Every OData endpoint, custom action, webhook |
| Component Tests | Vitest + React Testing Library | **>= 85% of components** | Every interactive component, form, conditional rendering |
| API Contract Tests | Jest + Zod schema validation | **100% of public endpoints** | Every endpoint response validated against Zod schema |
| E2E Tests | Playwright | **4 critical journeys** | Buyer, Seller, Moderator, Admin |
| Accessibility Tests | axe-core + Playwright | **0 critical/serious violations** | Every public page, form, interactive component |
| Performance Tests | Lighthouse CI + custom benchmarks | **LCP <2.5s, API <2s** | SSR pages, API endpoints |
| Security Tests | OWASP ZAP (CI) | **0 critical/high findings** | Auth, payment, admin endpoints |

---

## Test File Organization

### auto-backend

```
test/
├── unit/
│   ├── lib/
│   │   ├── certification.test.ts
│   │   ├── visibility-score.test.ts
│   │   ├── crit-air.test.ts
│   │   ├── market-price.test.ts
│   │   └── config-cache.test.ts
│   ├── adapters/
│   │   ├── vehicle-lookup.test.ts
│   │   ├── emission.test.ts
│   │   ├── recall.test.ts
│   │   ├── history.test.ts
│   │   ├── valuation.test.ts
│   │   └── payment.test.ts
│   └── middleware/
│       ├── auth.test.ts
│       ├── audit-trail.test.ts
│       ├── api-logger.test.ts
│       └── rate-limiter.test.ts
├── integration/
│   ├── catalog-service.test.ts
│   ├── seller-service.test.ts
│   ├── admin-service.test.ts
│   ├── moderation-service.test.ts
│   ├── payment-service.test.ts
│   ├── chat-service.test.ts
│   └── rbac.test.ts
├── contract/
│   └── api-schemas.test.ts
└── fixtures/
    ├── vehicles.ts
    ├── listings.ts
    ├── users.ts
    └── config.ts
```

### auto-frontend

```
src/
├── __tests__/                      # E2E (Playwright)
│   ├── buyer-journey.spec.ts
│   ├── seller-journey.spec.ts
│   ├── moderator-journey.spec.ts
│   ├── admin-journey.spec.ts
│   └── accessibility.spec.ts
├── components/
│   ├── listing/
│   │   ├── listing-card.test.tsx
│   │   ├── listing-form.test.tsx
│   │   ├── certified-field.test.tsx
│   │   ├── visibility-score.test.tsx
│   │   ├── declaration-form.test.tsx
│   │   └── auto-fill-trigger.test.tsx
│   ├── search/
│   │   ├── search-filters.test.tsx
│   │   └── search-results.test.tsx
│   ├── chat/
│   │   └── chat-window.test.tsx
│   ├── moderation/
│   │   └── moderation-actions.test.tsx
│   └── layout/
│       ├── auth-guard.test.tsx
│       └── role-guard.test.tsx
└── hooks/
    ├── useVehicleLookup.test.ts
    ├── useAuth.test.ts
    └── useSignalR.test.ts
```

### auto-shared

```
test/
└── validators/
    ├── listing.schema.test.ts
    ├── user.schema.test.ts
    └── declaration.schema.test.ts
```

---

## Per-Story Test Requirements

The table below maps each story to the specific test types required.

### Phase 1: Foundation

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 1-1 | YES | YES | YES | — | — | — | Verify `cds watch` + `npm run dev` + `@auto/shared` import. Jest/Vitest config. CI pipeline runs. |

### Phase 2: Core Infrastructure

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 2-1 | YES | YES | — | YES | — | — | config-cache.test.ts, all 10 entities CRUD, cache invalidation, audit trail |
| 1-2 | YES | YES | YES | YES | — | YES | registration-handler.test.ts, registration-form.test.tsx, dynamic Zod schema, AD B2C adapter mock, axe-core on form |
| 1-3 | YES | YES | YES | — | — | YES | consent entity, immutable records, version tracking, re-consent flow UI |
| 1-4 | YES | YES | YES | — | — | — | MSAL flows, JWT middleware, session timeout, auth-guard.test.tsx |
| 1-5 | YES | YES | YES | — | — | — | rbac.test.ts (each role x each endpoint), role-guard.test.tsx |

### Phase 3A: Listing Creation Pipeline

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 3-1 | YES | YES | — | YES | — | — | All 8 adapter interfaces, mock implementations, AdapterFactory resolution, api-logger, fallback |
| 3-2 | YES | YES | YES | — | — | — | autoFillByPlate action, parallel adapter calls, auto-fill-trigger.test.tsx |
| 3-3 | YES | YES | YES | — | — | YES | listing-form.test.tsx, certified-field.test.tsx, Zod validation, WCAG audit |
| 3-4 | YES | YES | YES | — | — | — | Blob upload, client-side compression, drag-and-drop reorder |
| 3-5 | YES | YES | YES | — | — | — | visibility-score.test.ts, configurable weights, gauge component, SignalR live-score |
| 3-6 | YES | YES | YES | — | — | — | Draft CRUD, auto-save, completion percentage, draft restoration |
| 3-7 | YES | YES | YES | — | — | — | declaration-form.test.tsx, immutable declaration, IP capture, admin audit view |
| 3-8 | YES | YES | YES | — | — | — | history.test.ts, MockHistoryAdapter, buyer-gated access |
| 3-9 | YES | YES | YES | YES | — | — | payment.test.ts, Stripe checkout, webhook signature validation, atomic batch (NFR37), rollback |
| 3-10 | YES | YES | YES | — | — | — | State machine (Draft→Published→Sold→Archived), search visibility rules |
| 3-11 | YES | YES | — | — | — | — | Retry, circuit breaker, cache fallback, ApiProviderHealth monitoring |

### Phase 3B: Admin & Configuration UI

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 2-2 | — | YES | YES | — | — | — | Config UI tabs, impact preview, feature toggles |
| 2-3 | YES | YES | YES | — | — | — | Provider switching, cost tracking, AdapterFactory integration |
| 2-4 | YES | YES | YES | — | — | — | KPI aggregation, SignalR /admin hub, drill-down, <2s load (NFR5) |
| 2-5 | YES | YES | YES | — | — | — | Alert evaluation engine, notification delivery, auto-alert on API failure |
| 2-6 | YES | YES | YES | — | — | — | SEO template CRUD, SERP preview, generateMetadata integration |
| 2-7 | YES | YES | YES | — | — | — | Legal version management, re-acceptance middleware, rich text editor |
| 2-8 | YES | YES | YES | — | — | — | audit-trail.test.ts, api-logger.test.ts, viewer UI, CSV export, retention |

### Phase 3C: User Profile

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 1-6 | YES | YES | YES | — | — | — | Profile CRUD, completion %, seller rating, AD B2C sync |
| 1-7 | YES | YES | YES | — | — | — | Data export (JSON), anonymization logic, double confirm, Blob Storage |

### Phase 4: Marketplace & Discovery

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 4-1 | YES | YES | YES | — | — | YES | listing-card.test.tsx, infinite scroll, SSR, Lighthouse CI targets |
| 4-2 | YES | YES | YES | — | — | — | search-filters.test.tsx, OData $filter, URL state sync, debounce |
| 4-3 | YES | YES | YES | — | — | — | Certification/market price filters, valuation adapter, graceful degradation |
| 4-4 | YES | YES | YES | — | — | — | Favorite entity, change detection, optimistic UI, notification on price change |
| 4-5 | YES | — | YES | — | — | — | SEO metadata, JSON-LD, sitemap, robots.txt, canonical URLs |

### Phase 5: Real-Time Communication

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 5-1 | YES | YES | YES | — | — | — | chat-service.test.ts, chat-window.test.tsx, SignalR hub, optimistic UI |
| 5-2 | YES | YES | YES | — | — | — | Notification entity, push subscription, service worker, permission UI |

### Phase 6: Seller Cockpit

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 6-1 | YES | YES | YES | — | — | — | KPI aggregation, trend calc, kpi-card, listings table, <2s load |
| 6-2 | YES | YES | YES | — | — | — | valuation.test.ts, market position calc, price indicator component |
| 6-3 | YES | YES | YES | — | — | — | MarketWatch entity, price history, sparkline charts |
| 6-4 | — | — | YES | — | — | — | Empty state detection, onboarding components, transition to full dashboard |

### Phase 7: Moderation

| Story | Unit | Integration | Component | Contract | E2E | A11y | Notes |
|-------|------|-------------|-----------|----------|-----|------|-------|
| 7-1 | YES | YES | YES | — | — | — | Report entity, ConfigReportReason, report form, anonymous reporter option |
| 7-2 | YES | YES | YES | — | — | — | Queue sort/filter, report detail, moderation-actions.test.tsx, <2s load |
| 7-3 | YES | YES | YES | — | — | — | Deactivate/warn/reactivate actions, seller notification, audit trail |
| 7-4 | YES | YES | YES | — | — | — | Seller history aggregation, recurrence detection, history timeline |

### E2E Journeys (after Phase 6 complete)

| Journey | File | Scope | Stories Covered |
|---------|------|-------|-----------------|
| Buyer | buyer-journey.spec.ts | Search → filter → view listing → register → access full data → contact seller via chat | 4-1, 4-2, 4-3, 1-2, 5-1 |
| Seller | seller-journey.spec.ts | Register → enter plate → auto-fill → add photos → save draft → batch publish → pay → verify published | 1-2, 3-2, 3-3, 3-4, 3-6, 3-9, 3-10 |
| Moderator | moderator-journey.spec.ts | Login → view reports → open report detail → deactivate listing → send warning | 1-4, 7-1, 7-2, 7-3 |
| Admin | admin-journey.spec.ts | Login → view KPIs → change API provider → modify pricing → verify audit trail | 1-4, 2-2, 2-3, 2-4, 2-8 |

---

## Test Rules (mandatory)

### Unit Tests
- Test every public function and method
- Test happy path + error paths + edge cases + boundary values
- Mock external dependencies (adapters, DB, SignalR)
- Test config-driven behavior with different ConfigParameter values
- Test certification logic: certified vs declared field handling
- Test visibility score with various field combinations
- Adapter tests: verify each adapter conforms to its interface contract
- NEVER test implementation details — test behavior and outcomes

### Integration Tests
- Test every CAP service handler with `cds.test()` and in-memory SQLite
- Test OData queries: `$filter`, `$expand`, `$orderby`, `$top`, `$skip`
- Test custom actions: `autoFillByPlate`, `publishListings`, `reportAbuse`, etc.
- Test middleware chain: auth -> rate-limiter -> audit-trail -> handler -> response
- Test payment webhook with valid/invalid Stripe signatures
- Test atomicity: payment failure -> no listing published (NFR37)
- Test degraded mode: adapter unavailable -> manual fallback (FR58-60)
- Test config cache invalidation: admin changes -> cache refreshed
- Test RBAC: each role accesses only its permitted endpoints

### Component Tests (Frontend)
- Test every interactive component with React Testing Library
- Test user events: click, type, submit, select, drag
- Test loading states, error states, empty states
- Test certified-field.tsx: displays correct certified/declared badge + accessible text
- Test listing-form.tsx: auto-fill populates fields, validation errors display
- Test declaration-form.tsx: all checkboxes required, timestamp generated
- Test auth-guard.tsx and role-guard.tsx: redirect unauthenticated/unauthorized users
- Test responsive behavior: mobile vs desktop rendering
- NEVER test internal state — test what the user sees and interacts with

### API Contract Tests
- Every endpoint response validated against shared Zod schemas
- Test RFC 7807 error responses for all error cases
- Test OData response format ($metadata compliance)
- Test pagination: $top, $skip, $count
- Test that no internal details leak (stack traces, DB errors, internal IDs)

### E2E Tests (Playwright)
- Cross-browser: Chromium, Firefox, WebKit
- Mobile viewport (375px) for all critical journeys

### Accessibility Tests
- axe-core scan on every public page and every form
- All inputs have `<label>` elements
- Errors linked via `aria-describedby`
- Focus management on error
- Keyboard navigation works
- Screen reader navigable

---

## Test Data Strategy

| Context | Approach |
|---------|----------|
| Backend unit/integration | Fixtures in `test/fixtures/` — deterministic, reproducible |
| Frontend component | Mock data co-located with test files |
| E2E | Seed data loaded before each test suite via API calls |
| Config-driven tests | Test with multiple ConfigParameter values to ensure zero-hardcode works |
| Adapter mock tests | Each adapter has a mock implementation — tests verify both mock and real conform to interface contract |

---

## CI Pipeline Integration

### auto-backend (azure-pipelines.yml)
1. lint (ESLint + Prettier check)
2. type-check (`tsc --noEmit`)
3. unit-tests (Jest — lib/, adapters/, middleware/)
4. integration-tests (Jest + `cds.test()` with SQLite)
5. contract-tests (Zod schema validation on all endpoints)
6. build (`cds build`)
7. coverage-report (FAIL if below: >= 90% unit, >= 80% integration)

### auto-frontend (azure-pipelines.yml)
1. lint (ESLint + Prettier check)
2. type-check (`tsc --noEmit`)
3. unit-tests (Vitest — hooks, utilities)
4. component-tests (Vitest + React Testing Library)
5. build (`next build`)
6. e2e-tests (Playwright — Chromium + Firefox + WebKit)
7. accessibility-tests (axe-core via Playwright)
8. coverage-report (FAIL if below: >= 85% component)

### auto-shared (azure-pipelines.yml)
1. lint + type-check
2. unit-tests (Zod schema tests)
3. build
4. publish to Azure Artifacts (@auto/shared)

**Gate: PR cannot merge if ANY step fails. Coverage below thresholds = pipeline failure.**

---

## Validation Checklist (per story)

Before marking a story as `done`, the dev agent must verify:

- [ ] All unit tests pass
- [ ] All integration tests pass (where applicable)
- [ ] All component tests pass (where applicable)
- [ ] Contract tests pass for any new/modified endpoints
- [ ] Accessibility tests pass for any new UI (where applicable)
- [ ] No existing tests broken (full test suite passes)
- [ ] Coverage thresholds met (>= 90% unit, >= 80% integration, >= 85% component)
- [ ] `npm run lint` passes with 0 errors
- [ ] `tsc --noEmit` passes with 0 errors
- [ ] Build succeeds (`cds build` / `next build`)
