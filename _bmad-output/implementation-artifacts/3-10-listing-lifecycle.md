# Story 3.10: Listing Lifecycle Management

Status: ready-for-dev

## Story

As a seller,
I want to mark a listing as sold or remove it from the marketplace,
so that I can manage the lifecycle of my listings and keep the marketplace accurate.

## Acceptance Criteria (BDD)

**Given** a seller views their published listings
**When** they click "Marquer comme vendu" (FR11)
**Then** the listing status changes to `Sold`
**And** the listing is removed from public search results but accessible via direct URL (with "Vendu" badge)
**And** open chat conversations for this listing are notified

**Given** a seller wants to remove a listing
**When** they click "Retirer"
**Then** the listing status changes to `Archived`
**And** the listing is no longer visible publicly
**And** the action is logged in the audit trail

**Given** a listing has been sold or archived
**When** the seller views their listing history
**Then** they can see all past listings with their final status, dates, and performance metrics

## Tasks / Subtasks

### Task 1: Backend - Listing Status Transitions (AC1, AC2)
1.1. Define listing status enum in CDS: `Draft`, `Published`, `Sold`, `Archived`
1.2. Implement status transition validation rules:
  - `Draft` -> `Published` (via payment, Story 3.9)
  - `Published` -> `Sold` (seller action)
  - `Published` -> `Archived` (seller action)
  - `Sold` -> `Archived` (optional cleanup)
  - Reject invalid transitions (e.g., Draft -> Sold, Archived -> Published)
1.3. Create CAP action `markAsSold(listingId)`:
  - Validate listing exists, belongs to current seller, status is `Published`
  - Update status to `Sold`
  - Set `soldAt` timestamp
  - Create audit trail entry: "Listing {id} marked as sold by seller {id}"
  - Return updated listing status
1.4. Create CAP action `archiveListing(listingId)`:
  - Validate listing exists, belongs to current seller, status is `Published` or `Sold`
  - Update status to `Archived`
  - Set `archivedAt` timestamp
  - Create audit trail entry: "Listing {id} archived by seller {id}"
  - Return updated listing status
1.5. Write unit tests for all valid transitions and rejection of invalid transitions

### Task 2: Backend - Search Visibility Rules (AC1, AC2)
2.1. Modify public listing query handlers to filter by status:
  - Search results / listing list: only `Published` listings
  - Direct URL access: `Published` and `Sold` listings (Sold with "Vendu" badge)
  - `Archived` listings: not accessible publicly at all
2.2. Implement search index update on status change:
  - When status changes to `Sold`, remove from active search but keep accessible by ID
  - When status changes to `Archived`, remove from all public access
2.3. Write unit tests for search visibility rules per status

### Task 3: Backend - Chat Notification on Status Change (AC1)
3.1. When a listing is marked as `Sold`, find all active chat conversations for this listing
3.2. Send system message to each conversation: "Cette annonce a ete marquee comme vendue par le vendeur"
3.3. Optionally close or flag the conversation as resolved (configurable behavior)
3.4. Write unit tests for chat notification triggering (mock chat service if not yet implemented)

### Task 4: Backend - Listing History with Performance Metrics (AC3)
4.1. Create CAP query handler for seller listing history:
  - `GET /odata/v4/seller/Listings?$filter=status ne 'Draft'&$orderby=modifiedAt desc`
  - Return all non-draft listings with: id, brand, model, status, publishedAt, soldAt, archivedAt, visibilityScore
4.2. Add performance metrics to listing response (computed or from analytics):
  - viewCount: number of times the listing was viewed
  - favoriteCount: number of times the listing was favorited
  - chatCount: number of chat conversations initiated
  - daysOnMarket: calculated from publishedAt to soldAt/archivedAt/now
4.3. Implement `ListingAnalytics` CDS entity or extend Listing with counters: viewCount, favoriteCount, chatCount
4.4. Write unit tests for history query and metrics calculation

### Task 5: Frontend - Listing Actions in Seller Dashboard (AC1, AC2)
5.1. In the seller's published listings view, add action buttons per listing:
  - "Marquer comme vendu" button with car-sold icon
  - "Retirer" button with archive icon
5.2. Implement "Marquer comme vendu" flow:
  - Confirmation dialog: "Confirmer que ce vehicule a ete vendu ?"
  - On confirm, call backend `markAsSold` action
  - Update listing card to show "Vendu" badge
  - Show success toast: "Annonce marquee comme vendue"
5.3. Implement "Retirer" flow:
  - Confirmation dialog: "Retirer cette annonce ? Elle ne sera plus visible publiquement."
  - On confirm, call backend `archiveListing` action
  - Remove listing card from active listings view (move to history)
  - Show success toast: "Annonce retiree"
5.4. Write unit tests for action flows, dialogs, and UI state updates

### Task 6: Frontend - Sold Listing Public View (AC1)
6.1. When a buyer accesses a sold listing via direct URL:
  - Display listing content normally
  - Overlay "Vendu" badge prominently (top-right corner or banner)
  - Disable contact/chat buttons
  - Optionally show "Voir des vehicules similaires" CTA
6.2. Ensure search results do NOT include sold listings
6.3. Write unit tests for sold listing display and disabled actions

### Task 7: Frontend - Listing History Page (AC3)
7.1. Create or extend seller dashboard with listing history view:
  - Tab or section showing all past listings (Published, Sold, Archived)
  - Each listing card shows: vehicle info, status badge (Published green, Sold blue, Archived grey), dates (published, sold, archived), performance metrics (views, favorites, chats, days on market)
7.2. Implement filters: by status, by date range
7.3. Implement sorting: by date, by views, by days on market
7.4. Write unit tests for history page rendering, filtering, and sorting

### Task 8: Integration Tests
8.1. Full lifecycle: create draft -> publish (via payment) -> mark as sold -> verify search visibility -> verify direct URL access
8.2. Test archive flow: publish -> archive -> verify not accessible publicly
8.3. Test chat notification: publish -> create chat -> mark as sold -> verify system message in chat
8.4. Test invalid transitions: attempt Draft -> Sold -> verify rejection
8.5. Test listing history: publish multiple listings with different outcomes -> verify history page shows all with correct metrics

## Dev Notes

### Architecture & Patterns
- Listing status follows a strict state machine: Draft -> Published -> Sold/Archived. Invalid transitions are rejected at the service level.
- When a listing is marked as sold, it remains accessible by direct URL so that shared links still work. This is important for SEO and user experience.
- Chat notification on status change is a cross-cutting concern. If the chat system (Epic 5) is not yet implemented, use an event/hook pattern so the notification logic can be plugged in later.
- Performance metrics (viewCount, favoriteCount, etc.) may be incremented in real-time or calculated periodically. For V1, simple counters on the Listing entity are sufficient. Consider moving to a dedicated analytics service later.
- The audit trail for lifecycle changes is critical for platform integrity and dispute resolution.

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 frontend, PostgreSQL, Azure
- **Adapter Pattern:** 8 interfaces (IVehicleLookupAdapter, IEmissionAdapter, IRecallAdapter, ICritAirCalculator, IVINTechnicalAdapter, IHistoryAdapter, IValuationAdapter, IPaymentAdapter). Factory resolves from ConfigApiProvider.
- **Auto-fill flow:** Seller enters plate -> POST /odata/v4/seller/autoFillByPlate -> AdapterFactory resolves adapters -> parallel API calls -> certification.ts marks fields -> visibility-score.ts calculates -> cached in api_cached_data
- **Certification:** Each field tracked to source (API + timestamp). CertifiedField entity in CDS.
- **Visibility Score:** Real-time calculation via lib/visibility-score.ts, SignalR /live-score hub for live updates
- **Photo management:** Azure Blob Storage upload, Azure CDN serving, Next.js Image optimization
- **Payment:** Stripe checkout, atomic publish (NFR37), IPaymentAdapter interface
- **Batch publish:** Select drafts -> calculate total -> Stripe Checkout Session -> webhook confirms -> atomic status update
- **API resilience:** PostgreSQL api_cached_data table with TTL, mode degrade (manual input fallback), auto re-sync
- **Declaration:** Digital declaration of honor, timestamped, archived as proof
- **Testing:** >=90% unit, >=80% integration coverage

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Direct external API calls (MUST use Adapter Pattern)
- Hardcoded values (use config tables)
- Skipping audit trail/API logging

### Project Structure Notes
Backend: srv/adapters/ (interfaces + implementations), srv/lib/certification.ts, srv/lib/visibility-score.ts, srv/middleware/api-logger.ts
Frontend: src/components/listing/ (auto-fill-trigger, certified-field, visibility-score, listing-form, declaration-form), src/hooks/useVehicleLookup.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
