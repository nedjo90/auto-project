# Story 6.2: Market Price Positioning

Status: ready-for-dev

## Story

As a seller,
I want to see how my listings are priced compared to the market,
so that I can adjust my pricing strategy to maximize sales.

## Acceptance Criteria (BDD)

**Given** a seller views their listings (FR34)
**When** market data is available
**Then** each listing shows a visual indicator: "8% en dessous du marche" (green), "Prix aligne" (neutral), "12% au-dessus" (orange)
**And** the indicator uses design tokens (`--market-below/aligned/above`)

**Given** market data is not available (mock `IValuationAdapter` in V1)
**When** the comparison is displayed
**Then** mock market data is shown with a note about estimation methodology
**And** the architecture is ready for real provider integration

## Tasks / Subtasks

### Task 1: Valuation Adapter Interface & Mock Implementation (AC1, AC2)
1.1. Define `IValuationAdapter` interface in `src/lib/market-price.ts` with method `getMarketPrice(make, model, year, mileage, fuelType, certificationLevel): Promise<MarketPriceResult>` where MarketPriceResult contains: estimatedPrice, confidence, source, timestamp
1.2. Implement `MockValuationAdapter` class implementing IValuationAdapter that returns realistic mock market prices based on vehicle attributes (use deterministic formula: base price adjusted by year depreciation, mileage factor, fuel type multiplier)
1.3. Create adapter factory function `createValuationAdapter()` that returns MockValuationAdapter in V1 with configuration for future provider swap
1.4. Add configuration flag (environment variable `VALUATION_PROVIDER`) to switch adapters in the future
1.5. Write unit tests for MockValuationAdapter with various vehicle inputs

### Task 2: Market Price Service Backend (AC1, AC2)
2.1. Add `marketPosition` computed field to listing performance in `srv/seller-service.cds`: positionLabel (String), positionPercentage (Decimal), positionCategory (enum: below, aligned, above)
2.2. Implement market price comparison logic in `srv/seller-service.ts`: for each listing, call IValuationAdapter.getMarketPrice(), compute percentage difference between listing price and market estimate
2.3. Define position thresholds: below = listing price < market price - 5%, aligned = within +/- 5%, above = listing price > market price + 5%
2.4. Implement caching for market price results: cache per (make, model, year, mileage range, fuelType) with TTL of 24 hours to minimize adapter calls
2.5. Add "estimation" flag to response when using MockValuationAdapter, so frontend can display methodology note
2.6. Write integration tests for market price comparison logic

### Task 3: Design Tokens for Market Position (AC1)
3.1. Define CSS custom properties (design tokens) for market position colors:
  - `--market-below`: green shade for below-market pricing
  - `--market-aligned`: neutral/gray shade for aligned pricing
  - `--market-above`: orange shade for above-market pricing
3.2. Define corresponding text labels mapping: below -> "X% en dessous du marche", aligned -> "Prix aligne", above -> "X% au-dessus"
3.3. Ensure design tokens work in both light and dark mode
3.4. Write visual regression tests or snapshot tests for color tokens

### Task 4: Market Position Indicator Component (AC1)
4.1. Create `src/components/dashboard/market-position-indicator.tsx` — visual badge/pill component displaying: position category icon (arrow down green, dash neutral, arrow up orange), percentage text, label text
4.2. Accept props: positionCategory, positionPercentage, isEstimation (boolean)
4.3. Apply design tokens for color styling based on positionCategory
4.4. When `isEstimation` is true, add a small info icon with tooltip explaining estimation methodology
4.5. Write component tests for all three position states and estimation flag

### Task 5: Integration into Listings Table (AC1, AC2)
5.1. Add market position column to `listings-table.tsx` (from Story 6.1) using MarketPositionIndicator component
5.2. Fetch market position data as part of `getListingPerformance` response from seller-service
5.3. Make market position column sortable (sort by positionPercentage)
5.4. Handle loading state: show skeleton in market position cell while valuation data loads (may be async)
5.5. Write integration tests for table with market position data

### Task 6: Market Position Detail View (AC1, AC2)
6.1. Create `src/components/dashboard/market-position-detail.tsx` — expanded view when seller clicks on market position indicator, showing: listing price, estimated market price, percentage difference, methodology note (for V1 mock), suggestion text based on position
6.2. Implement suggestion logic: if above -> "Consider lowering price for faster sale", if below -> "Your price is competitive", if aligned -> "Price is in line with market"
6.3. When using mock adapter, display clear note: "Estimation basee sur des donnees internes. Integration avec un fournisseur de donnees marche prevue."
6.4. Write component tests for market position detail view

## Dev Notes

### Architecture & Patterns
- **Adapter pattern:** IValuationAdapter provides a clean abstraction for market price data; V1 uses a mock implementation, future versions swap in a real provider (e.g., Argus, AutoScout24 API) without changing consuming code
- **Factory pattern:** createValuationAdapter() reads config to instantiate the correct adapter
- **Caching strategy:** Market prices are cached server-side with 24h TTL to avoid repeated adapter calls for similar vehicles
- **Position thresholds:** +/- 5% defines the "aligned" band; this threshold should be configurable via environment variable
- **Design tokens:** Color-coding uses CSS custom properties for consistent theming and easy dark mode support

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
- [Source: _bmad-output/planning-artifacts/stories/epic-6/story-6.2-market-price-positioning.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
