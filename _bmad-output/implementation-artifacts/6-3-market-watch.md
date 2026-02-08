# Story 6.3: Market Watch & Competitor Tracking

Status: ready-for-dev

## Story

As a seller,
I want to follow competitor vehicles on the marketplace and track their price and status changes,
so that I can stay competitive and adjust my strategy based on market movements.

## Acceptance Criteria (BDD)

**Given** a seller browses the public marketplace
**When** they click "Suivre" on a competitor's listing (FR35)
**Then** the listing is added to their market watch list
**And** a `MarketWatch` record is created linking the seller and the tracked listing

**Given** a seller accesses their market watch (`(dashboard)/seller/market/`)
**When** the page loads
**Then** tracked listings are displayed with: current price, price history (changes highlighted), status (active/sold), days online, certification level

**Given** a tracked listing changes (price, status, new photos)
**When** the change is detected
**Then** the seller receives a notification about the change

## Tasks / Subtasks

### Task 1: CDS Entity Modeling for Market Watch (AC1, AC2)
1.1. Define `MarketWatch` entity in `srv/seller-service.cds` with fields: ID, sellerID (Association to User), listingID (Association to Listing), addedAt (Timestamp), notes (String, optional seller notes)
1.2. Define `ListingPriceHistory` entity (if not existing) with fields: ID, listingID (Association to Listing), price (Decimal), changedAt (Timestamp), previousPrice (Decimal)
1.3. Add unique constraint on (sellerID, listingID) for MarketWatch to prevent duplicate tracking
1.4. Expose MarketWatch and ListingPriceHistory through SellerService with appropriate read/write projections
1.5. Write unit tests for CDS model validation

### Task 2: Market Watch Service Backend Logic (AC1, AC2, AC3)
2.1. Implement action `addToMarketWatch(listingID)` in `srv/seller-service.ts`: validate listing exists and is not seller's own listing, create MarketWatch record
2.2. Implement action `removeFromMarketWatch(listingID)` to untrack a listing
2.3. Implement query handler `getMarketWatchList(sellerID)` returning tracked listings with: current listing details (price, status, photos, certification), price history, days online, change indicators (price changed since last viewed)
2.4. Implement price history tracking: add an `afterUpdate` handler on Listing entity that creates a ListingPriceHistory record whenever price changes
2.5. Implement change detection: when a tracked listing is updated (price, status, photos), trigger a notification for all sellers watching that listing
2.6. Add authorization: only the seller who created the watch can read/delete it
2.7. Write integration tests for all service actions and change detection

### Task 3: "Suivre" Button on Public Listings (AC1)
3.1. Create `src/components/marketplace/follow-button.tsx` — toggle button component: "Suivre" (default state) / "Suivi" (active state with checkmark)
3.2. Implement click handler: call `addToMarketWatch` or `removeFromMarketWatch` based on current state
3.3. Show button only to authenticated sellers viewing listings that are not their own
3.4. Implement optimistic toggle: update UI immediately, revert on error
3.5. Add the follow button to listing card component and listing detail page
3.6. Write component tests for follow-button in both states

### Task 4: Market Watch Page (AC2)
4.1. Create `src/app/(dashboard)/seller/market/page.tsx` — market watch page in seller cockpit
4.2. Fetch tracked listings from SellerService getMarketWatchList
4.3. Create `src/components/dashboard/market-watch-list.tsx` — list/grid of tracked listings
4.4. Create `src/components/dashboard/market-watch-card.tsx` — card for each tracked listing showing: photo thumbnail, title, current price, price change indicator (new price vs previous, highlighted in green/red), status badge (active/sold), days online, certification badge
4.5. Create `src/components/dashboard/price-history-chart.tsx` — mini sparkline chart showing price history over time for a tracked listing
4.6. Implement "changes since last visit" highlighting: bold/badge on listings that changed since seller last viewed the market watch page
4.7. Add empty state for market watch page when no listings are tracked (link to browse marketplace)
4.8. Write component tests for all market watch components

### Task 5: Price History Display (AC2)
5.1. Create `src/components/dashboard/price-change-badge.tsx` — badge showing price change: arrow up/down, old price strikethrough, new price, percentage change
5.2. Implement price history timeline: expandable section on market-watch-card showing all historical price changes with dates
5.3. Color coding: price decrease = green (good for buyer/competitor lowering), price increase = red
5.4. Write component tests for price-change-badge

### Task 6: Change Notification Integration (AC3)
6.1. Add change detection handler in listing service: on listing update (price, status, photos), query MarketWatch for all sellers tracking this listing
6.2. For each tracking seller, call NotificationService.createNotification with type "favorite-update" (reusing notification infrastructure from Story 5.2), including details: "Le prix de [listing title] a change: [old] -> [new]"
6.3. Implement notification batching: if multiple tracked listings change in a short window, batch into a single notification
6.4. Write integration tests for change detection -> notification flow

### Task 7: Market Watch Store and Hooks (AC1, AC2)
7.1. Create `src/stores/market-watch-store.ts` — Zustand store for market watch state: tracked listings, loading state, last viewed timestamp
7.2. Create `src/hooks/useMarketWatch.ts` — hook for managing market watch operations: add/remove tracking, fetch list, check if a listing is tracked
7.3. Integrate with notification store: when a tracked listing change notification is received, update market watch store to reflect changes
7.4. Write unit tests for store and hook

## Dev Notes

### Architecture & Patterns
- **Event-driven change detection:** Listing updates trigger change detection via CDS `afterUpdate` handlers; if the listing is tracked by any seller, notifications are dispatched
- **Price history as event log:** Every price change creates an immutable ListingPriceHistory record, enabling full price timeline visualization
- **Optimistic UI for follow:** The follow button updates immediately and reverts on server error, providing responsive UX
- **Notification reuse:** Market watch change notifications reuse the notification infrastructure from Story 5.2 (NotificationService + SignalR /notifications hub)
- **Last-visited tracking:** The market watch page tracks when the seller last visited to highlight changes since then

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
- [Source: _bmad-output/planning-artifacts/stories/epic-6/story-6.3-market-watch.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
