# Story 6.4: Empty State & Seller Onboarding

Status: ready-for-dev

## Story

As a new seller,
I want clear guidance when my cockpit is empty,
so that I know exactly what to do first and feel welcomed rather than lost.

## Acceptance Criteria (BDD)

**Given** a seller with zero listings accesses their cockpit (FR36)
**When** the dashboard loads
**Then** an engaging empty state is displayed (not a blank page)
**And** two clear CTAs are shown: "Publiez votre premier vehicule" and "Explorez le marche"
**And** the message tone is inviting and encouraging (UX principle: empty state = invitation)

**Given** a seller publishes their first listing
**When** they return to the cockpit
**Then** the empty state is replaced by the full dashboard with KPIs

## Tasks / Subtasks

### Task 1: Empty State Detection Logic (AC1, AC2)
1.1. Add listing count check to seller dashboard page (`src/app/(dashboard)/seller/page.tsx`): query seller's active listing count from SellerService
1.2. Implement conditional rendering: if listing count === 0, render empty state; otherwise, render full dashboard (from Story 6.1)
1.3. Ensure the check is fast and does not add latency to the dashboard load (use same data fetch as KPI query)
1.4. Write unit test for conditional rendering logic

### Task 2: Empty State Component (AC1)
2.1. Create `src/components/dashboard/empty-state-cockpit.tsx` — the main empty state component with:
  - Engaging illustration or icon (car/vehicle themed, using project design system)
  - Welcome headline: inviting, warm tone (e.g., "Bienvenue dans votre espace vendeur !")
  - Subtext explaining the cockpit value proposition (e.g., "Suivez vos performances, positionnez-vous sur le marche et gerez vos conversations, tout au meme endroit.")
  - Two prominent CTA buttons
2.2. Implement responsive layout: centered content, appropriate spacing, works on mobile and desktop
2.3. Use existing design system components (buttons, typography, spacing tokens) for consistency
2.4. Write component test for empty-state-cockpit rendering

### Task 3: CTA Buttons and Navigation (AC1)
3.1. Create primary CTA button: "Publiez votre premier vehicule" — navigates to listing creation page (e.g., `/seller/listings/new` or equivalent route from Epic 3)
3.2. Create secondary CTA button: "Explorez le marche" — navigates to public marketplace browse page (e.g., `/marketplace` or `/search`)
3.3. Style primary CTA with strong visual emphasis (filled/primary variant), secondary CTA with lighter style (outlined/secondary variant)
3.4. Add tracking/analytics event on CTA click for measuring onboarding funnel conversion (optional but recommended)
3.5. Write component tests for CTA button navigation

### Task 4: Empty State for Sub-Pages (AC1)
4.1. Create `src/components/dashboard/empty-state-chat.tsx` — empty state for seller chat page when no conversations exist: illustration, message "Pas encore de conversations", CTA "Vos acheteurs vous contacteront ici"
4.2. Create `src/components/dashboard/empty-state-market-watch.tsx` — empty state for market watch page when no tracked listings: illustration, message "Suivez la concurrence", CTA "Explorez le marche" linking to marketplace browse
4.3. Integrate empty states into respective pages: `seller/chat/page.tsx` and `seller/market/page.tsx`
4.4. Write component tests for sub-page empty states

### Task 5: Transition from Empty to Full Dashboard (AC2)
5.1. Ensure that after first listing publication, the seller dashboard page re-fetches data and renders the full KPI dashboard
5.2. Implement smooth transition: if seller navigates back to cockpit after publishing, the new listing appears in the dashboard
5.3. Handle edge case: if listing is in draft/pending state, show appropriate intermediate state (e.g., "Votre annonce est en cours de validation")
5.4. Write integration test for the empty-to-full transition flow

### Task 6: Onboarding Tips (Optional Enhancement) (AC1)
6.1. Create `src/components/dashboard/onboarding-tips.tsx` — optional tips section below empty state or as a dismissible banner after first listing: tips for improving listing quality, setting competitive prices, etc.
6.2. Implement dismissible behavior: once dismissed, do not show again (store preference in localStorage or user preferences)
6.3. Write component test for onboarding-tips

## Dev Notes

### Architecture & Patterns
- **Conditional rendering pattern:** The seller dashboard page checks listing count and conditionally renders either the empty state or the full dashboard; this avoids separate routes and keeps the URL consistent
- **Empty state as invitation:** Following UX best practices, empty states are not blank pages but engaging touchpoints that guide the user to their first action
- **Progressive disclosure:** The dashboard progressively reveals more features as the seller adds listings (empty -> single listing -> full dashboard with trends)
- **Design system consistency:** Empty state components use the same design tokens, typography, and button components as the rest of the app

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend, PostgreSQL, Azure SignalR Service
- **Real-time:** Azure SignalR Service with 4 separate hubs:
  - /chat — buyer<->seller messages linked to vehicle
  - /notifications — push events (new contact, new view, report handled, etc.)
  - /live-score — visibility score updates during listing creation
  - /admin — real-time KPIs
- **SignalR events:** domain:action naming (e.g., "chat:message-sent", "notification:new-contact")
- **Chat:** chat-service.cds + .ts, signalr/chat-hub.ts, ChatMessage entity in CDS
- **Notifications:** Push notifications via PWA service worker (serwist), notification-hub.ts
- **Seller cockpit:** src/app/(dashboard)/seller/* (SPA behind auth)
- **KPIs:** seller-service.cds + .ts, dashboard components (kpi-card.tsx, chart-wrapper.tsx, stat-trend.tsx)
- **Market price:** lib/market-price.ts, IValuationAdapter (mock V1)
- **Favorites/Watch:** Stored in PostgreSQL, accessible from seller cockpit
- **Empty states:** Engaging design when cockpit is empty, guide to first action
- **Testing:** Component tests for all dashboard components, SignalR integration tests

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- SignalR events: domain:action kebab-case
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded values
- Direct DB queries
- French in code
- Skipping tests

### Project Structure Notes
Backend: srv/chat-service.*, srv/signalr/ (chat-hub.ts, notification-hub.ts), srv/seller-service.*
Frontend: src/app/(dashboard)/seller/*, src/components/chat/*, src/components/dashboard/*, src/hooks/useChat.ts, src/hooks/useSignalR.ts, src/hooks/useNotifications.ts, src/stores/chat-store.ts, src/stores/notification-store.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-6/story-6.4-empty-state-onboarding.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
