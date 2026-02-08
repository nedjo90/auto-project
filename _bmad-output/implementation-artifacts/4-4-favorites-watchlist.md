# Story 4.4: Favorites & Watchlist

Status: ready-for-dev

## Story

As a registered buyer,
I want to save listings to my favorites and track changes to their information,
so that I can compare options over time and be notified of price drops or new information.

## Acceptance Criteria (BDD)

**Given** a registered buyer views a listing card or detail page
**When** they click the favorite icon (FR17)
**Then** the listing is added to their favorites with a visual confirmation
**And** a `Favorite` CDS record is created linking user and listing

**Given** a buyer accesses their favorites
**When** the favorites page loads
**Then** all favorited listings are displayed with current data
**And** changes since favoriting are highlighted (price change, new photos, certification update)

**Given** a favorited listing's price changes
**When** the change is detected
**Then** the buyer receives a notification: "Le prix du [brand] [model] a baisse de EUR[old] a EUR[new]"

**Given** a favorited listing is marked as sold
**When** the status changes
**Then** the buyer is notified and the listing is visually marked in favorites

## Tasks / Subtasks

### Task 1: Backend - Favorite Entity & Service (AC1)
1.1. Define `Favorite` CDS entity in `db/schema.cds` with fields: `ID` (UUID), `user_ID` (association to User), `listing_ID` (association to Listing), `createdAt` (Timestamp), `snapshotPrice` (Decimal - price at time of favoriting), `snapshotCertificationLevel` (String), `snapshotPhotoCount` (Integer).
1.2. Add unique constraint on `(user_ID, listing_ID)` to prevent duplicate favorites.
1.3. Expose `Favorite` entity in a new `srv/favorite-service.cds` (or extend user-facing service) with CRUD operations, restricted to authenticated users (`@requires: 'authenticated-user'`).
1.4. Implement `CREATE` handler in `srv/favorite-service.ts` that:
   - Validates the listing exists and is published
   - Captures a snapshot of current listing state (price, certification level, photo count) at the time of favoriting
   - Returns the created Favorite record
1.5. Implement `DELETE` handler for unfavoriting (by Favorite ID or by listing_ID for the current user).
1.6. Implement `READ` handler that returns favorites for the current user, enriched with current listing data and change indicators.
1.7. Write unit tests for favorite creation, deletion, duplicate prevention, and read with enrichment.

### Task 2: Backend - Change Detection & Highlighting (AC2)
2.1. Implement change detection logic in `srv/favorite-service.ts` `READ` handler:
   - Compare current listing `price` vs `snapshotPrice` --> flag `priceChanged` with `oldPrice` and `newPrice`
   - Compare current `certificationLevel` vs `snapshotCertificationLevel` --> flag `certificationChanged`
   - Compare current photo count vs `snapshotPhotoCount` --> flag `photosAdded` with count
2.2. Return enriched Favorite objects with change flags: `{ ...favorite, changes: { priceChanged, priceDiff, certificationChanged, photosAdded } }`.
2.3. Optionally update snapshots when the user acknowledges changes (e.g., "mark as seen" action resets snapshot to current values).
2.4. Write unit tests for each change detection scenario (price up, price down, certification upgrade, new photos, no changes).

### Task 3: Backend - Notification on Price Change & Sold Status (AC3, AC4)
3.1. Create `srv/lib/favorite-notifications.ts` module for notification logic.
3.2. Implement an `after UPDATE` handler on the Listing entity (in catalog-service or a separate event handler) that:
   - When `price` changes: queries all Favorites for this listing and creates a notification for each favoriting user with message "Le prix du [brand] [model] a baisse de EUR[old] a EUR[new]" (or "augmente" for price increase).
   - When `status` changes to 'sold': queries all Favorites for this listing and creates a notification for each favoriting user.
3.3. Define `Notification` CDS entity in `db/schema.cds`: `ID`, `user_ID`, `type` (enum: 'price_change', 'sold', 'certification_update', 'photos_added'), `message` (String), `listing_ID`, `isRead` (Boolean, default false), `createdAt`.
3.4. Expose notifications via the user service with read/mark-as-read operations.
3.5. Write unit tests for notification creation on price change (decrease and increase) and sold status change.

### Task 4: Frontend - Favorite Toggle on Listing Card & Detail Page (AC1)
4.1. Create `src/components/listing/favorite-button.tsx` Client Component:
   - Heart icon that toggles filled/unfilled state
   - Calls favorite-service CREATE/DELETE on click
   - Shows brief visual confirmation (toast or animation) on toggle
   - Requires authentication: if user is not logged in, clicking redirects to login with return URL
4.2. Integrate `favorite-button.tsx` into `listing-card.tsx` (top-right corner of card).
4.3. Integrate `favorite-button.tsx` into the listing detail page.
4.4. Fetch initial favorite state: on page load, check if the current user has favorited each visible listing (batch query to favorite-service).
4.5. Implement optimistic UI update: toggle visual state immediately, revert on API error.
4.6. Write component tests for toggle behavior, auth redirect, and optimistic update with rollback.

### Task 5: Frontend - Favorites Page (AC2)
5.1. Create `src/app/(authenticated)/favorites/page.tsx` as a Server Component that fetches the user's favorites with enriched change data.
5.2. Display favorited listings using the standard `listing-card.tsx` component with additional change indicators:
   - Price change: badge showing "Prix: EUR[old] -> EUR[new]" with green (decrease) or red (increase) color
   - New photos: badge showing "+X photos"
   - Certification update: badge showing "Certification mise a jour"
5.3. Create `src/components/favorites/change-indicator.tsx` component for rendering change badges on cards.
5.4. Add an "Unfavorite" action (swipe on mobile, hover menu on desktop) for each card.
5.5. Add a "Mark all as seen" button that resets snapshots to current values (clears change indicators).
5.6. Handle empty state: display a message with a CTA to browse the marketplace when no favorites exist.
5.7. Write component tests for change indicator rendering and empty state.

### Task 6: Frontend - Notification Display (AC3, AC4)
6.1. Create `src/components/notifications/notification-bell.tsx` Client Component: bell icon in the header with unread count badge.
6.2. Create `src/components/notifications/notification-dropdown.tsx` Client Component: dropdown list of recent notifications with message, timestamp, and link to the listing.
6.3. Mark notifications as read when the dropdown is opened or individual notifications are clicked.
6.4. For sold listings in favorites, apply a visual treatment: grayscale/opacity overlay on the card with a "Vendu" label.
6.5. Write component tests for notification bell badge count, dropdown rendering, and read-marking behavior.

## Dev Notes

### Architecture & Patterns
- **Snapshot-based change detection:** When a user favorites a listing, the current price, certification level, and photo count are captured as a snapshot. On subsequent reads, the current values are compared to the snapshot to detect changes. This avoids complex event sourcing while still providing change visibility.
- **Notification creation pattern:** Notifications are created reactively via `after UPDATE` handlers on the Listing entity. When a listing's price or status changes, all users who favorited that listing receive a notification. This is a fan-out write pattern.
- **Authentication required:** All favorite and notification operations require authentication. The frontend must handle the unauthenticated case gracefully (redirect to login with return URL).
- **Optimistic UI:** The favorite toggle uses optimistic updates for instant visual feedback, with rollback on server error.
- **Favorites page is authenticated:** Unlike public search/listing pages, the favorites page lives under `(authenticated)` route group and does not need SSR for SEO.

### Key Technical Context
- **Stack:** SAP CAP backend, Next.js 16 frontend (SSR for public pages), PostgreSQL
- **Public pages:** src/app/(public)/ route group -- SSR for SEO (Server Components default)
- **Listing cards:** Configurable display via config tables (FR48 admin can configure what's shown on cards)
- **Search/filters:** OData $filter, $search on catalog-service, multi-criteria (budget, make, model, location, mileage, fuel type)
- **Certification filters:** Filter by certification level, valid CT, market price positioning
- **Market price:** lib/market-price.ts comparison logic, IValuationAdapter (mock V1)
- **SEO:** SSR pages, Schema.org structured data (Vehicle, Product, Offer), sitemap XML, semantic URLs (/listing/peugeot-3008-2022-marseille-{id})
- **Favorites:** Requires auth, stored in PostgreSQL
- **Cards:** listing-card.tsx component, configurable fields from config tables
- **Images:** Azure CDN + Next.js Image (lazy loading, responsive)
- **Infinite scroll:** For search results
- **Filters as chips:** Active filters visible, removable in one tap
- **Testing:** SSR pages need Lighthouse CI LCP <2.5s

### Naming Conventions
- Frontend: kebab-case files, PascalCase components
- SEO URLs: may contain French for SEO (/listing/peugeot-3008-2022-marseille-{id}) but route folders in English
- All technical naming in English

### Anti-Patterns (FORBIDDEN)
- Hardcoded card display fields (use config tables)
- SPA rendering for public pages (must be SSR)
- French in code/files

### Project Structure Notes
Frontend: src/app/(public)/listing/[slug]/page.tsx, src/app/(public)/search/page.tsx, src/components/listing/listing-card.tsx, src/components/search/search-filters.tsx, src/app/(authenticated)/favorites/page.tsx
Backend: srv/catalog-service.cds + .ts, srv/favorite-service.cds + .ts, srv/lib/favorite-notifications.ts, srv/lib/market-price.ts

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/stories/epic-4/story-4.4-favorites-watchlist.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
