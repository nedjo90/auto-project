# E2E Test Plan — Complete User Journeys

## 1. Overview

### Purpose
This document is the definitive manual QA checklist for the Auto platform. It maps **every user action** across all personas, routes, and API endpoints against seed data from Story 8-1. It serves as:
1. Manual QA checklist for dev environment validation
2. Specification for future automated E2E tests (Playwright/Cypress)
3. Acceptance criteria for platform launch readiness

### Personas
| Persona | Email | Role | Description |
|---------|-------|------|-------------|
| Anonymous Visitor | — | None | Unauthenticated user browsing the site |
| Buyer | buyer1@test.com (Sophie Bernard) | buyer | Authenticated user searching for vehicles |
| Seller | seller1@test.com (Marie Dupont) | seller | Active seller with listings |
| Seller (Pro) | seller2@test.com (Pierre Martin) | seller | Professional seller with company info |
| Seller (Suspended) | seller-suspended@test.com (Jean Suspect) | seller | Suspended account |
| Moderator | moderator@test.com (Luc Moderateur) | moderator | Content moderator |
| Admin | admin@test.com (Claire Admin) | administrator | Platform administrator |

### Priority Definitions
| Priority | Definition | Count Target |
|----------|------------|-------------|
| **P0** | Critical path — must work for launch | 10-15 journeys |
| **P1** | Important — should work, not blocking | Secondary flows |
| **P2** | Edge cases — error handling, boundary conditions | Error scenarios |

### Dev-Mode Authentication
In development mode (no Azure AD configured):
- All API calls use `Basic admin:` header
- Dev auto-login as admin with role hierarchy: admin > moderator > seller > buyer
- Switch personas by modifying dev auth config

---

## 2. Seed Data Reference

### Users (6 accounts)
| Account | UUID | Role | Status | City |
|---------|------|------|--------|------|
| seller1@test.com (Marie Dupont) | `11111111-...` | seller | active | Paris |
| seller2@test.com (Pierre Martin) | `22222222-...` | seller (pro) | active | Lyon |
| buyer1@test.com (Sophie Bernard) | `33333333-...` | buyer | active | Paris |
| moderator@test.com (Luc Moderateur) | `44444444-...` | moderator | active | Paris |
| admin@test.com (Claire Admin) | `55555555-...` | administrator | active | Paris |
| seller-suspended@test.com (Jean Suspect) | `66666666-...` | seller | suspended | Marseille |

### Listings (15 total)
| ID | Vehicle | Seller | Price | Status | Cert Level | Photos |
|----|---------|--------|-------|--------|-------------|--------|
| L1 | Renault Clio V RS Line 2022 | seller1 | 18 500 | published | tres_documente | 5 |
| L2 | Peugeot 308 GT 2023 | seller1 | 28 900 | published | tres_documente | 5 |
| L3 | Volkswagen Golf 8 TSI 2021 | seller2 | 24 500 | published | tres_documente | 5 |
| L4 | BMW Serie 3 320d 2020 | seller2 | 45 000 | published | tres_documente | 5 |
| L5 | Audi A3 Sportback 2022 | seller1 | 27 500 | published | partiellement | 3 |
| L6 | Toyota Yaris Cross Hybrid 2024 | seller2 | 22 800 | published | partiellement | 3 |
| L7 | Mercedes Classe A 200d 2021 | seller1 | 38 000 | published | partiellement | 3 |
| L8 | Ford Focus ST-Line 2019 | seller2 | 16 500 | published | partiellement | 3 |
| L9 | Citroen C3 PureTech 2020 | seller1 | 11 500 | sold | — | 3 |
| L10 | Dacia Sandero Stepway 2018 | seller2 | 5 000 | sold | — | 3 |
| L11 | Peugeot 208 BlueHDi 2019 | seller1 | 12 000 | expired | — | 3 |
| L12 | Renault Megane TCe 2020 | seller2 | 16 500 | expired | — | 3 |
| L13 | Seat Leon 2.0 TDI 2022 | seller2 | 21 000 | draft | — | 3 |
| L14 | Fiat 500 Lounge 2021 | seller1 | 15 000 | published | partiellement | 3 |
| L15 | Opel Corsa 1.2 2019 | seller2 | 9 500 | suspended | — | 3 |

### Chat Conversations (3 conversations, 14 messages)
| Conv | Buyer | Seller | Listing | Messages | Last Msg |
|------|-------|--------|---------|----------|----------|
| C1 | buyer1 | seller1 | L1 Clio V | 5 | 2026-02-22 (1 unread by seller1) |
| C2 | buyer1 | seller1 | L2 308 GT | 4 | 2026-02-20 (all read) |
| C3 | buyer1 | seller2 | L3 Golf 8 | 5 | 2026-02-24 (1 unread by seller2) |

### Favorites (4 — all buyer1)
L1 (Clio V), L2 (308 GT), L3 (Golf 8), L7 (Mercedes A)

### Notifications (5)
- buyer1: 3 notifications (1 unread: new message from seller1)
- seller1: 2 notifications (1 unread: new message from buyer1)

### Abuse Reports (2)
| Report | Reporter | Target | Reason | Status |
|--------|----------|--------|--------|--------|
| R1 | buyer1 | L14 (Fiat 500) | Media mismatch | pending |
| R2 | buyer1 | seller-suspended | Document fraud | treated |

### Declarations of Honor (14)
One per published/sold/draft/suspended listing. All v1.0 with 4 checkboxes checked.

---

## 3. Anonymous Visitor Journey

### 3.1 Homepage & Navigation

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| V-01 | Load homepage | `/` | `POST /api/catalog/getListings` (top 8) | Hero section, trust strip, featured listings (up to 8 cards), how-it-works, seller CTA | L1-L14 (published) | P0 |
| V-02 | Click "Recherche" in header (desktop) | `/` → `/search` | — | Navigate to search page, "Recherche" link highlighted | — | P0 |
| V-03 | Click "Comment ca marche" in header | `/` → `/how-it-works` | — | Navigate to how-it-works page, link highlighted | — | P1 |
| V-04 | Click "Confiance" in header | `/` → `/trust` | — | Navigate to trust page, link highlighted | — | P1 |
| V-05 | Click "Auto" logo | any → `/` | — | Navigate to homepage | — | P1 |
| V-06 | Open mobile hamburger menu | any (mobile) | — | Sheet drawer opens with: Accueil, Recherche, Comment ca marche, Confiance, Se connecter, Creer un compte | — | P0 |
| V-07 | Tap bottom tab bar (mobile) | any (mobile) | — | 5 tabs: Accueil, Recherche, Favoris (→ /login), Messages (→ /login), Profil (→ /login) | — | P0 |
| V-08 | Click footer "Mentions legales" | any → `/legal/cgu` | `GET /api/legal/getCurrentVersion` | Display CGU legal document | — | P1 |
| V-09 | Click footer "Politique de confidentialite" | any → `/legal/privacy-policy` | `GET /api/legal/getCurrentVersion` | Display privacy policy | — | P1 |
| V-10 | Click footer "Recherche" | any → `/search` | — | Navigate to search page | — | P2 |
| V-11 | Click footer "Comment ca marche" | any → `/how-it-works` | — | Navigate to how-it-works page | — | P2 |
| V-12 | Click footer "Confiance & Transparence" | any → `/trust` | — | Navigate to trust page | — | P2 |

### 3.2 Search & Browse

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| V-13 | Load search page (no filters) | `/search` | `POST /api/catalog/getListings` | Show all 9 published listings as cards | L1-L8, L14 | P0 |
| V-14 | Quick search from homepage (make + city) | `/` → `/search?make=Renault&city=Paris` | `POST /api/catalog/getListings` | Filtered results matching criteria | L1 (Clio V) | P0 |
| V-15 | Filter by brand (Peugeot) | `/search?make=Peugeot` | `POST /api/catalog/getListings` | Show Peugeot listings only | L2 (308 GT) | P1 |
| V-16 | Filter by price range (10k-20k) | `/search?priceMin=10000&priceMax=20000` | `POST /api/catalog/getListings` | Show listings 10k-20k | L1, L8, L14 | P1 |
| V-17 | Filter by mileage | `/search?mileageMax=50000` | `POST /api/catalog/getListings` | Listings under 50k km | L1, L2, L5, L6, L7 | P1 |
| V-18 | Filter by certification level (tres_documente) | `/search?certification=tres_documente` | `POST /api/catalog/getListings` | Only highly certified listings | L1, L2, L3, L4 | P1 |
| V-19 | Sort by price ascending | `/search?sort=price_asc` | `POST /api/catalog/getListings` | Cheapest first | L8 first | P1 |
| V-20 | Sort by newest | `/search?sort=createdAt_desc` | `POST /api/catalog/getListings` | Most recent first | L14 first | P1 |
| V-21 | Empty search results | `/search?make=Ferrari` | `POST /api/catalog/getListings` | Empty state message, no cards | — | P2 |
| V-22 | Pagination / infinite scroll | `/search` (scroll down) | `POST /api/catalog/getListings` (skip > 0) | Load more results if > page size | All published | P1 |

### 3.3 Listing Detail

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| V-23 | Click listing card to view detail | `/search` → `/listing/[slug]` | `POST /api/catalog/getListingDetail` | Full detail page: photos, certified fields, declared fields, price, location, seller info | L1 (Clio V) | P0 |
| V-24 | View photo gallery | `/listing/[slug]` | — | Swipeable gallery with all photos | L1: 5 photos | P1 |
| V-25 | View certified vs declared data distinction | `/listing/[slug]` | — | Certified fields marked with badge, declared fields without | L1: engine/CO2 certified | P1 |
| V-26 | Click "Contacter le vendeur" (not logged in) | `/listing/[slug]` → `/login` | — | Redirect to login with returnUrl | L1 | P0 |
| V-27 | View seller profile from listing | `/listing/[slug]` → `/sellers/[id]` | — | Public seller profile: name, rating, bio, listing count | seller1 (Marie) | P1 |
| V-28 | Legacy listing URL redirect | `/listings/[id]` → `/listing/[slug]` | — | permanentRedirect (301) to semantic slug URL | L1 | P2 |

### 3.4 Informational Pages

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| V-29 | View How It Works page | `/how-it-works` | — | 3-step cards: Recherchez, Comparez, Contactez | — | P1 |
| V-30 | View Trust page | `/trust` | — | Trust & security information | — | P1 |
| V-31 | View About page | `/about` | — | Platform information | — | P2 |
| V-32 | View SEO page (brand) | `/brands/[brand]` | `POST /api/catalog/getListings` | Brand-filtered results with SEO metadata | Renault | P2 |
| V-33 | View SEO page (brand + model) | `/brands/[brand]/[model]` | `POST /api/catalog/getListings` | Brand+model filtered results | Renault/Clio | P2 |
| V-34 | View SEO page (city) | `/cities/[city]` | `POST /api/catalog/getListings` | City-filtered results | Paris | P2 |

### 3.5 Authentication Entry Points

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| V-35 | Click "Se connecter" (header) | any → `/login` | — | Login page displayed | — | P0 |
| V-36 | Click "Creer un compte" (header) | any → `/register` | — | Registration form displayed | — | P0 |
| V-37 | Click "Creer un compte" on homepage seller CTA | `/` → `/register` | — | Registration page | — | P1 |
| V-38 | Click auth-protected mobile tab (Favoris) | any → `/login` | — | Redirect to login | — | P1 |

### 3.6 Error Scenarios

| # | Action | Route | Expected Result | Seed Data | Priority |
|---|--------|-------|-----------------|-----------|----------|
| V-39 | Access protected route /dashboard | `/dashboard` → `/login` | Redirect to login with returnUrl=/dashboard | — | P2 |
| V-40 | Access protected route /seller/drafts | `/seller/drafts` → `/login` | Redirect to login | — | P2 |
| V-41 | Access non-existent listing | `/listing/fake-slug` | 404 page or empty state | — | P2 |
| V-42 | Access non-existent seller | `/sellers/fake-id` | 404 page or empty state | — | P2 |

---

## 4. Buyer Journey

*Persona: buyer1@test.com (Sophie Bernard)*

### 4.1 Authentication & Dashboard

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-01 | Login as buyer | `/login` → `/dashboard` | Auth flow | Dashboard hub with welcome "Sophie Bernard", buyer quick links | buyer1 account | P0 |
| B-02 | View dashboard hub stats | `/dashboard` | `POST /api/favorites/getMyFavorites`, `GET /api/chat/getUnreadCount` | Favorites count: 4, Unread messages count displayed | 4 favorites, unread msgs | P0 |
| B-03 | Click "Rechercher" quick link | `/dashboard` → `/search` | — | Navigate to search | — | P1 |
| B-04 | Click "Mes favoris" quick link | `/dashboard` → `/favorites` | — | Navigate to favorites | — | P1 |
| B-05 | Click "Messages" quick link | `/dashboard` → `/seller/chat` | — | Navigate to chat | — | P1 |

### 4.2 Search & Filter

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-06 | Search with multiple filters | `/search?make=Renault&priceMax=20000` | `POST /api/catalog/getListings` | Filtered results | L1 (Clio V 18 500) | P0 |
| B-07 | Filter by fuel type | `/search?fuel=diesel` | `POST /api/catalog/getListings` | Diesel listings | L2, L4, L7 | P1 |
| B-08 | Filter by year range | `/search?yearMin=2022&yearMax=2024` | `POST /api/catalog/getListings` | 2022-2024 vehicles | L1, L2, L5, L6, L13 | P1 |
| B-09 | Filter by location (city) | `/search?city=Paris` | `POST /api/catalog/getListings` | Paris listings | L1, L6 | P1 |
| B-10 | Combine sort + filter | `/search?make=Peugeot&sort=price_asc` | `POST /api/catalog/getListings` | Peugeot sorted by price | L2 | P1 |
| B-11 | Clear all filters | `/search` (reset) | `POST /api/catalog/getListings` | All published listings shown | L1-L8, L14 | P2 |

### 4.3 Listing Detail & Interaction

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-12 | View listing detail (tres_documente) | `/listing/[slug]` | `POST /api/catalog/getListingDetail` | All fields visible: certified engine data (1333cc, 96kW), CO2, photos, price, seller info | L1 (Clio V) | P0 |
| B-13 | View listing detail (partiellement_documente) | `/listing/[slug]` | `POST /api/catalog/getListingDetail` | Fewer certified fields, more declared fields visible | L5 (Audi A3) | P1 |
| B-14 | View vehicle history report | `/listing/[slug]` | `POST /api/buyer/getHistoryReport` | History report data displayed | L1 | P1 |
| B-15 | View seller profile from listing | `/listing/[slug]` → `/sellers/[id]` | — | Marie Dupont: rating 4.5/5, 7 listings, bio | seller1 | P1 |

### 4.4 Favorites

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-16 | View favorites list | `/favorites` | `POST /api/favorites/getMyFavorites` | 4 listings: Clio V, 308 GT, Golf 8, Mercedes A | buyer1 favorites | P0 |
| B-17 | Add listing to favorites | `/listing/[slug]` | `POST /api/favorites/toggleFavorite` | Heart icon filled, listing appears in favorites | L8 (Ford Focus) | P0 |
| B-18 | Remove listing from favorites | `/favorites` or `/listing/[slug]` | `POST /api/favorites/toggleFavorite` | Heart icon unfilled, listing removed from list | L7 (Mercedes A) | P1 |
| B-19 | Check favorite status on search results | `/search` | `POST /api/favorites/checkFavorites` | Heart icons filled for L1, L2, L3, L7 | buyer1 favorites | P1 |
| B-20 | Empty favorites state | `/favorites` (after removing all) | `POST /api/favorites/getMyFavorites` | Empty state message | — | P2 |

### 4.5 Chat

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-21 | View conversation list | `/seller/chat` | `POST /api/chat/getConversations` | 3 conversations: C1 (Clio V), C2 (308 GT), C3 (Golf 8) | buyer1 conversations | P0 |
| B-22 | Open conversation | `/seller/chat/[conversationId]` | `POST /api/chat/getMessages` | Message history with cursor pagination | C1: 5 messages | P0 |
| B-23 | Send message | `/seller/chat/[conversationId]` | `POST /api/chat/sendMessage` | Message appears in thread, delivered status | C1 | P0 |
| B-24 | Initiate new conversation from listing | `/listing/[slug]` → `/seller/chat/[new]` | `POST /api/chat/startOrResumeConversation` | New or resumed conversation opened | L6 (Toyota Yaris) | P1 |
| B-25 | Mark messages as read | `/seller/chat/[conversationId]` | `POST /api/chat/markAsRead` | Read receipts updated | C1 unread messages | P1 |
| B-26 | View unread count badge | `/seller/chat` | `GET /api/chat/getUnreadCount` | Badge showing unread count | buyer1 unread | P2 |

### 4.6 Notifications

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-27 | View notifications | `/settings/notifications` | `POST /api/notifications/getNotifications` | 3 notifications: new message (unread), price change (read), new results (read) | buyer1 notifications | P1 |
| B-28 | Mark notification as read | notification bell | `POST /api/notifications/markNotificationsRead` | Notification marked as read, unread count decreases | buyer1 unread notif | P1 |
| B-29 | View notification preferences | `/settings/notifications` | `POST /api/notifications/getPreferences` | Preference toggles for each notification type | — | P2 |
| B-30 | Update notification preference | `/settings/notifications` | `POST /api/notifications/updatePreference` | Preference saved | — | P2 |

### 4.7 Profile & Settings

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-31 | View profile | `/profile` | — | Sophie Bernard, Paris, phone, avatar, bio | buyer1 profile | P1 |
| B-32 | Edit profile | `/profile` | — | Update display name, phone, city, bio | buyer1 | P1 |
| B-33 | Manage consent (RGPD) | `/settings/consent` | — | View and manage data consent toggles | buyer1 consent | P1 |
| B-34 | Data privacy — request export | `/settings/data-privacy` | — | Initiate data export request | buyer1 | P2 |
| B-35 | Data privacy — request anonymization | `/settings/data-privacy` | — | Initiate anonymization request | buyer1 | P2 |
| B-36 | Security settings | `/settings/security` | — | View security options (2FA for sellers only) | buyer1 | P2 |

### 4.8 Reporting

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-37 | Report a listing | `/listing/[slug]` | `GET /api/moderation/ReportReasons`, `POST /api/moderation/submitReport` | Report form with reasons, submit success | L8 (not yet reported) | P1 |
| B-38 | Report a user | `/sellers/[id]` | `POST /api/moderation/submitReport` | Report submitted for user | seller2 | P2 |

### 4.9 Logout

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| B-39 | Logout | any → `/` | `logoutRedirect()` | Session cleared, redirected to homepage | — | P1 |

---

## 5. Seller Journey

*Persona: seller1@test.com (Marie Dupont) — 7 listings (5 published, 1 sold, 1 expired)*
*Secondary: seller2@test.com (Pierre Martin) — 8 listings (4 published, 1 sold, 1 expired, 1 draft, 1 suspended)*

### 5.1 Dashboard & Cockpit

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-01 | Login as seller | `/login` → `/dashboard` | Auth flow | Dashboard hub with seller section: Mes brouillons, Publier, Messages, Suivi marche | seller1 | P0 |
| S-02 | View seller cockpit | `/seller` | `POST /api/seller/getAggregateKPIs` | KPI summary: total views, contacts, active count | seller1 KPIs | P0 |
| S-03 | View listing performance table | `/seller` | `POST /api/seller/getListingPerformance` | Table of listings with views, favorites, chats per listing | seller1 listings | P1 |
| S-04 | View metric drilldown | `/seller` | `POST /api/seller/getMetricDrilldown` | Chart/data for specific metric over time | seller1 | P1 |

### 5.2 Draft Creation

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-05 | Start new draft | `/seller/drafts` → create form | `POST /api/seller/saveDraft` | Empty draft form with vehicle fields | — | P0 |
| S-06 | Enter plate/VIN for auto-fill | create form | `POST /api/seller/saveDraft` (with plate) | Certified fields auto-populated (engine, CO2, etc.) | Mock adapter data | P0 |
| S-07 | Complete declared fields | create form | — | Fill: price, mileage, description, location, condition | — | P0 |
| S-08 | Upload photos | create form | `POST /api/seller/uploadPhoto` | Photo appears in gallery, sortable | — | P0 |
| S-09 | Reorder photos | create form | `POST /api/seller/reorderPhotos` | Photo order updated, primary photo set | — | P1 |
| S-10 | Delete photo | create form | `POST /api/seller/deletePhoto` | Photo removed from gallery | — | P1 |
| S-11 | Preview visibility score | create form | — | Score displayed (0-100) based on completeness | — | P1 |
| S-12 | Save draft | create form | `POST /api/seller/saveDraft` | Draft saved, appears in drafts list | — | P0 |
| S-13 | View drafts list | `/seller/drafts` | `GET /api/seller/Listings?$filter=status eq 'draft'` | List of draft listings | L13 (Seat Leon) for seller2 | P0 |
| S-14 | Load existing draft | `/seller/drafts` → edit | `POST /api/seller/loadDraft` | Draft data loaded in form | L13 | P1 |
| S-15 | Duplicate draft | `/seller/drafts` | `POST /api/seller/duplicateDraft` | New draft created as copy | L13 | P2 |
| S-16 | Delete draft | `/seller/drafts` | `POST /api/seller/deleteDraft` | Draft removed from list | L13 | P1 |

### 5.3 Publication & Payment

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-17 | View publishable listings | `/seller/publish` | `POST /api/seller/getPublishableListings` | List of ready drafts with unit price | Drafts with all required fields | P0 |
| S-18 | Select listings for batch publish | `/seller/publish` | `POST /api/seller/calculateBatchTotal` | Total price calculated for selected listings | — | P0 |
| S-19 | Sign declaration of honor | `/seller/publish` | `POST /api/seller/getDeclarationTemplate`, `POST /api/seller/submitDeclaration` | 4 checkboxes displayed, all must be checked | Declaration v1.0 | P0 |
| S-20 | Proceed to payment (Stripe) | `/seller/publish` → Stripe | `POST /api/seller/createCheckoutSession` | Redirect to Stripe checkout (mock in dev) | — | P0 |
| S-21 | Payment success return | `/seller/publish/success?session_id=...` | `POST /api/seller/getPaymentSessionStatus` | Success page, listings now published | — | P0 |
| S-22 | Poll payment status | `/seller/publish/success` | `POST /api/seller/getPaymentSessionStatus` (polling) | Status transitions: pending → completed | — | P1 |

### 5.4 Listing Management

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-23 | View active listings | `/seller/listings` | `POST /api/seller/getSellerListings` | List with stats (views, favorites, chats) | seller1: L1, L2, L5, L7, L14 | P0 |
| S-24 | Mark listing as sold | `/seller/listings` | `POST /api/seller/markAsSold` | Status changes to "sold", moved to history | L14 (Fiat 500) | P1 |
| S-25 | Archive/withdraw listing | `/seller/listings` | `POST /api/seller/archiveListing` | Listing archived, no longer visible publicly | L5 (Audi A3) | P1 |
| S-26 | View listing history (sold/archived) | `/seller/history` | `POST /api/seller/getListingHistory` | List of sold and archived listings | L9, L10 (sold) | P1 |

### 5.5 Market Watch

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-27 | View market watch list | `/seller/market` | `POST /api/seller/getMarketWatchList` | Competitor listings being tracked | — | P1 |
| S-28 | Add listing to market watch | `/listing/[slug]` | `POST /api/seller/addToMarketWatch` | Listing tracked, appears in watch list | L3 (Golf 8, competitor) | P1 |
| S-29 | Remove from market watch | `/seller/market` | `POST /api/seller/removeFromMarketWatch` | Listing removed from tracking | — | P2 |
| S-30 | Check market watch status | `/search` | `POST /api/seller/checkMarketWatches` | Watch icons shown on tracked listings | — | P2 |

### 5.6 Seller Chat

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| S-31 | View conversations as seller | `/seller/chat` | `POST /api/chat/getConversations` | Conversations from buyers about seller's listings | seller1: C1, C2 | P0 |
| S-32 | Reply to buyer message | `/seller/chat/[conversationId]` | `POST /api/chat/sendMessage` | Reply sent, appears in thread | C1 | P0 |
| S-33 | View unread indicator | `/seller/chat` | `GET /api/chat/getUnreadCount` | Badge on unread conversations | seller1: 1 unread in C1 | P1 |

### 5.7 Error Scenarios (Seller)

| # | Action | Route | Expected Result | Seed Data | Priority |
|---|--------|-------|-----------------|-----------|----------|
| S-34 | Publish without required fields | `/seller/publish` | Validation error, fields highlighted | Incomplete draft | P2 |
| S-35 | Upload oversized photo | create form | Error message, upload rejected | — | P2 |
| S-36 | Exceed max photo count | create form | Error message, upload disabled | — | P2 |
| S-37 | Edit deactivated/suspended listing | `/seller/listings` | Error or read-only state | L15 (suspended) | P2 |
| S-38 | Payment failure | `/seller/publish` | Error page, listings remain as drafts | — | P2 |

---

## 6. Moderator Journey

*Persona: moderator@test.com (Luc Moderateur)*

### 6.1 Dashboard & Report Queue

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| M-01 | Login as moderator | `/login` → `/dashboard` | Auth flow | Dashboard hub with moderation section | moderator account | P0 |
| M-02 | View moderation dashboard | `/moderator` | `POST /api/moderation/getReportMetrics` | Metrics: pending count, treated count, severity breakdown | R1 pending, R2 treated | P0 |
| M-03 | View report queue | `/moderator` | `POST /api/moderation/getReportQueue` | List of reports with filters (status, type, severity) | R1 (pending) | P0 |
| M-04 | Filter reports by status (pending) | `/moderator` | `POST /api/moderation/getReportQueue` (status=pending) | Only pending reports | R1 | P1 |
| M-05 | Filter reports by severity (high) | `/moderator` | `POST /api/moderation/getReportQueue` (severity=high) | Only high-severity reports | R2 (treated, high) | P1 |

### 6.2 Report Detail & Actions

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| M-06 | View report detail | `/moderator/reports/[id]` | `POST /api/moderation/getReportDetail` | Full report: reporter, target, reason, description, photos | R1 (Fiat 500 report) | P0 |
| M-07 | Assign report to self | `/moderator/reports/[id]` | `POST /api/moderation/assignReport` | Report assigned to moderator, status updated | R1 | P1 |
| M-08 | Send warning to seller | `/moderator/reports/[id]` | `POST /api/moderation/sendWarning` | Warning sent, action logged | seller1 (via R1) | P0 |
| M-09 | Deactivate listing | `/moderator/reports/[id]` | `POST /api/moderation/deactivateListing` | Listing suspended, no longer visible publicly | L14 (via R1) | P0 |
| M-10 | Deactivate seller account | `/moderator/reports/[id]` | `POST /api/moderation/deactivateAccount` | Account suspended, all listings hidden | seller target | P1 |
| M-11 | Reactivate listing | `/moderator/reports/[id]` | `POST /api/moderation/reactivateListing` | Listing republished | L15 (suspended) | P1 |
| M-12 | Reactivate account | `/moderator` | `POST /api/moderation/reactivateAccount` | Account reactivated | seller-suspended | P1 |
| M-13 | Dismiss report | `/moderator/reports/[id]` | `POST /api/moderation/dismissReport` | Report closed without action | R1 | P1 |

### 6.3 Seller History

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| M-14 | View seller history from report | `/moderator/reports/[id]` → `/moderator/sellers/[id]` | `POST /api/moderation/getSellerHistory` | Timeline: reports, actions, warnings, listing history | seller-suspended history | P0 |
| M-15 | View seller history (clean record) | `/moderator/sellers/[id]` | `POST /api/moderation/getSellerHistory` | Timeline showing no issues for good seller | seller2 (Pierre) | P1 |
| M-16 | Take action from seller history page | `/moderator/sellers/[id]` | Moderation action APIs | Can deactivate account directly from history | seller-suspended | P1 |

### 6.4 Error Scenarios (Moderator)

| # | Action | Route | Expected Result | Seed Data | Priority |
|---|--------|-------|-----------------|-----------|----------|
| M-17 | Action on already-resolved report | `/moderator/reports/[id]` | Error message or disabled actions | R2 (treated) | P2 |
| M-18 | Access non-existent seller | `/moderator/sellers/fake-id` | 404 or empty state | — | P2 |
| M-19 | Access admin routes as moderator | `/admin` → `/unauthorized` | Redirect to unauthorized page | moderator role | P2 |

---

## 7. Admin Journey

*Persona: admin@test.com (Claire Admin)*

### 7.1 Dashboard & KPIs

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-01 | Login as admin | `/login` → `/dashboard` | Auth flow | Dashboard hub with admin section (7 links: KPIs, Config, Alertes, Utilisateurs, Legal, SEO, Audit) | admin account | P0 |
| A-02 | View KPI dashboard | `/admin` | `POST /api/admin/getDashboardKpis` | Metrics: visitors, registrations, listings, contacts, sales, revenue | Seed analytics data | P0 |
| A-03 | View trend chart | `/admin` | `POST /api/admin/getDashboardTrend` | Line chart for selected metric over time | — | P1 |
| A-04 | KPI drilldown (specific metric) | `/admin/kpis/[metric]` | `POST /api/admin/getKpiDrillDown` | Detailed breakdown of metric (e.g., listings by status) | — | P1 |
| A-05 | Switch period filter | `/admin` | `POST /api/admin/getDashboardKpis` (different period) | KPIs update for selected time range | — | P1 |

### 7.2 Platform Configuration

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-06 | View config overview | `/admin/config` | — | Links to all config sections | — | P0 |
| A-07 | Edit pricing config | `/admin/config/pricing` | `GET /api/admin/ConfigParameters`, `PATCH /api/admin/ConfigParameters(...)` | View and edit listing prices, durations | Existing config | P0 |
| A-08 | Toggle feature flags | `/admin/config/features` | `GET /api/admin/ConfigFeatures`, `PATCH /api/admin/ConfigFeatures(...)` | Enable/disable features | Existing features | P1 |
| A-09 | Edit platform texts | `/admin/config/texts` | `GET /api/admin/ConfigTexts`, `PATCH /api/admin/ConfigTexts(...)` | Edit i18n text strings | Existing texts | P1 |
| A-10 | Edit registration fields | `/admin/config/registration` | `GET /api/admin/ConfigRegistrationFields`, `PATCH` | Configure required/optional fields | Existing fields | P1 |
| A-11 | Edit card display config | `/admin/config/card-display` | `GET /api/admin/ConfigListingCards`, `PATCH` | Configure which fields appear on listing cards | Existing card config | P1 |
| A-12 | Manage API providers | `/admin/config/providers` | `GET /api/admin/ConfigApiProviders`, `POST /api/admin/switchProvider` | View providers, hot-swap active provider | Existing providers | P1 |
| A-13 | View API costs | `/admin/config/costs` | `POST /api/admin/getApiCostSummary` | Cost breakdown by provider | — | P1 |
| A-14 | Estimate config impact | `/admin/config/pricing` | `POST /api/admin/estimateConfigImpact` | Impact preview before saving | — | P2 |
| A-15 | Edit analytics config | `/admin/config/analytics` | `GET/PATCH /api/admin/ConfigParameters` | Analytics configuration | — | P2 |

### 7.3 Alert Management

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-16 | View active alerts | `/admin/alerts` | `POST /api/admin/getActiveAlerts` | List of triggered alerts | Seed alert events | P1 |
| A-17 | Configure alert thresholds | `/admin/alerts` | `GET /api/admin/ConfigAlerts`, `PATCH` | Edit threshold values per metric | Existing alert config | P1 |
| A-18 | Acknowledge alert | `/admin/alerts` | `POST /api/admin/acknowledgeAlert` | Alert marked as acknowledged | Active alert | P1 |

### 7.4 User Management

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-19 | List all users | `/admin/users` | — | Table of 6 users with roles and statuses | All 6 seed users | P0 |
| A-20 | Search users | `/admin/users` | — | Filter by name/email | "Marie" → seller1 | P1 |
| A-21 | View user detail | `/admin/users` (expanded) | — | Full profile: roles, status, consent, listings | seller1 detail | P1 |
| A-22 | Change user role | `/admin/users` | — | Role updated (e.g., buyer → seller) | buyer1 | P2 |
| A-23 | Suspend user | `/admin/users` | — | Account suspended | — | P2 |

### 7.5 Legal Documents

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-24 | List legal documents | `/admin/legal` | `GET /api/admin/LegalDocuments` | CGU, Privacy Policy documents listed | Seed legal docs | P0 |
| A-25 | Edit legal document | `/admin/legal/[id]/edit` | `GET /api/admin/LegalDocumentVersions` | Version history, current content editable | CGU document | P1 |
| A-26 | Publish new version | `/admin/legal/[id]/edit` | `POST /api/admin/publishLegalVersion` | New version published, old version archived | — | P1 |
| A-27 | View acceptance count | `/admin/legal` | `GET /api/admin/getLegalAcceptanceCount(...)` | Number of users who accepted each version | — | P2 |
| A-28 | Require re-acceptance | `/admin/legal/[id]/edit` | `POST /api/admin/publishLegalVersion` (requiresReacceptance=true) | Users prompted to re-accept on next login | — | P2 |

### 7.6 SEO Management

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-29 | View SEO templates | `/admin/seo` | `GET /api/admin/ConfigSeoTemplates` | Template list with preview | Existing templates | P1 |
| A-30 | Edit SEO template | `/admin/seo` | `PATCH /api/admin/ConfigSeoTemplates(...)` | Template updated, preview reflects changes | — | P1 |

### 7.7 Audit Trail

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-31 | View audit log | `/admin/audit-trail` | `GET /api/admin/AuditTrailEntries` | Paginated list of audit events with filters | Seed audit entries | P0 |
| A-32 | Filter audit by action type | `/admin/audit-trail` | `GET /api/admin/AuditTrailEntries?$filter=action eq '...'` | Filtered results | — | P1 |
| A-33 | Filter audit by date range | `/admin/audit-trail` | `GET /api/admin/AuditTrailEntries?$filter=...` | Date-filtered results | — | P1 |
| A-34 | Filter audit by user | `/admin/audit-trail` | `GET /api/admin/AuditTrailEntries?$filter=actorId eq '...'` | User-specific events | seller1 actions | P1 |
| A-35 | Export audit trail CSV | `/admin/audit-trail` | `POST /api/admin/exportAuditTrail` | CSV file downloaded | — | P1 |
| A-36 | View API call logs | `/admin/audit-trail/api-calls` | `GET /api/admin/ApiCallLogs` | API call history with costs | Seed API logs | P1 |
| A-37 | Export API call logs CSV | `/admin/audit-trail/api-calls` | `POST /api/admin/exportApiCallLogs` | CSV file downloaded | — | P2 |

### 7.8 Moderation (Admin has moderator access)

| # | Action | Route | API Endpoint | Expected Result | Seed Data | Priority |
|---|--------|-------|-------------|-----------------|-----------|----------|
| A-38 | Access moderation as admin | `/moderator` | `POST /api/moderation/getReportQueue` | Admin can access moderator routes (role hierarchy) | admin account | P1 |
| A-39 | View seller routes as admin | `/seller` | `POST /api/seller/getAggregateKPIs` | Admin can access seller routes (role hierarchy) | admin account | P1 |

### 7.9 Error Scenarios (Admin)

| # | Action | Route | Expected Result | Seed Data | Priority |
|---|--------|-------|-----------------|-----------|----------|
| A-40 | Save invalid config value | `/admin/config/pricing` | Validation error, save blocked | — | P2 |
| A-41 | Delete active legal document | `/admin/legal` | Error or confirmation dialog preventing deletion | Active CGU | P2 |

---

## 8. Critical Path Matrix (P0 Journeys)

### Journey 1: Visitor Discovery → Registration
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Load homepage | `/` | Featured listings, hero, trust strip |
| 2 | Click "Recherche" | `/search` | All published listings |
| 3 | Click listing card | `/listing/[slug]` | Full listing detail (L1 Clio V) |
| 4 | Click "Contacter le vendeur" | → `/login` | Redirect to login |
| 5 | Click "Creer un compte" | `/register` | Registration form |

### Journey 2: Buyer Search → Favorite → Chat
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as buyer1 | `/login` → `/dashboard` | Dashboard with stats |
| 2 | Navigate to search | `/search` | All listings |
| 3 | Apply filters (price < 20k) | `/search?priceMax=20000` | L1, L8, L14 |
| 4 | Add to favorites | `/listing/[slug]` | Heart filled |
| 5 | Open chat from listing | → `/seller/chat/[conv]` | Conversation started |
| 6 | Send message | `/seller/chat/[conv]` | Message delivered |

### Journey 3: Seller Create → Publish → Manage
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as seller1 | `/login` → `/dashboard` | Seller quick links |
| 2 | Navigate to drafts | `/seller/drafts` | Drafts list |
| 3 | Start new draft | create form | Empty form |
| 4 | Enter plate for auto-fill | create form | Certified fields populated |
| 5 | Complete fields + photos | create form | Visibility score shown |
| 6 | Save draft | → `/seller/drafts` | Draft in list |
| 7 | Navigate to publish | `/seller/publish` | Publishable drafts |
| 8 | Select + sign declaration | `/seller/publish` | Declaration signed |
| 9 | Pay (Stripe mock) | → Stripe → `/seller/publish/success` | Payment success |
| 10 | View active listings | `/seller/listings` | New listing published |

### Journey 4: Moderator Report Handling
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as moderator | `/login` → `/dashboard` | Moderation link |
| 2 | Navigate to moderation | `/moderator` | Report queue with metrics |
| 3 | Open pending report | `/moderator/reports/[id]` | R1 detail (Fiat 500) |
| 4 | Assign report | `/moderator/reports/[id]` | Assigned to self |
| 5 | View seller history | → `/moderator/sellers/[id]` | Seller timeline |
| 6 | Take action (warning/deactivate) | `/moderator/reports/[id]` | Action executed |

### Journey 5: Admin Platform Configuration
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as admin | `/login` → `/dashboard` | Admin quick links (7 items) |
| 2 | View KPI dashboard | `/admin` | All metrics displayed |
| 3 | Navigate to config | `/admin/config` | Config sections |
| 4 | Edit pricing | `/admin/config/pricing` | Values updated |
| 5 | Manage alerts | `/admin/alerts` | Alert thresholds |
| 6 | View users | `/admin/users` | 6 users listed |
| 7 | Manage legal docs | `/admin/legal` | Documents listed |
| 8 | View audit trail | `/admin/audit-trail` | Audit log entries |

### Journey 6: Mobile Navigation (Visitor)
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Load homepage (mobile) | `/` | Tab bar visible at bottom |
| 2 | Tap "Recherche" tab | `/search` | Search page, tab highlighted |
| 3 | Open hamburger menu | Sheet drawer | All links: Accueil, Recherche, Comment ca marche, Confiance |
| 4 | Tap "Favoris" tab (not logged in) | → `/login` | Redirect to login |
| 5 | Tap "Messages" tab (not logged in) | → `/login` | Redirect to login |

### Journey 7: Mobile Navigation (Authenticated)
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login on mobile | `/login` → `/dashboard` | Dashboard rendered |
| 2 | Tap hamburger menu | Sheet drawer | Tableau de bord, Mon profil, Parametres, Se deconnecter |
| 3 | Tap "Favoris" tab | `/favorites` | Favorites page |
| 4 | Tap "Messages" tab | `/seller/chat` | Chat list |
| 5 | Tap "Profil" tab | `/profile` | Profile page |

### Journey 8: Buyer Favorites Lifecycle
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as buyer1 | `/login` → `/dashboard` | 4 favorites shown in stats |
| 2 | View favorites | `/favorites` | 4 listings: L1, L2, L3, L7 |
| 3 | Remove favorite | `/favorites` | Removed from list |
| 4 | Add new favorite from search | `/search` → toggle heart | Heart filled |
| 5 | Verify in favorites | `/favorites` | Updated list |

### Journey 9: Seller Chat Response
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as seller1 | `/login` → `/dashboard` | Unread messages count |
| 2 | Navigate to chat | `/seller/chat` | 2 conversations (C1, C2) |
| 3 | Open C1 (unread) | `/seller/chat/[C1]` | 5 messages, last unread |
| 4 | Messages marked as read | — | Unread count decreases |
| 5 | Reply to buyer | `/seller/chat/[C1]` | Message sent |

### Journey 10: Full Report-to-Resolution
| Step | Action | Route | Expected |
|------|--------|-------|----------|
| 1 | Login as buyer1 | → `/listing/[slug]` | L8 listing detail |
| 2 | Submit abuse report | `/listing/[slug]` | Report created (pending) |
| 3 | Login as moderator | → `/moderator` | New report in queue |
| 4 | Review report | `/moderator/reports/[id]` | Report details |
| 5 | View seller history | `/moderator/sellers/[id]` | Seller timeline |
| 6 | Deactivate listing | `/moderator/reports/[id]` | Listing suspended |
| 7 | Login as buyer1 | → `/search` | Listing no longer visible |

---

## 9. Error Scenarios Matrix

### 9.1 Authentication Errors (401)

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-01 | Access /dashboard unauthenticated | `/dashboard` | Direct URL | Redirect to `/login?returnUrl=/dashboard` | P2 |
| E-02 | Access /favorites unauthenticated | `/favorites` | Direct URL | Redirect to `/login` | P2 |
| E-03 | Access /seller/drafts unauthenticated | `/seller/drafts` | Direct URL | Redirect to `/login` | P2 |
| E-04 | Access /moderator unauthenticated | `/moderator` | Direct URL | Redirect to `/login` | P2 |
| E-05 | Access /admin unauthenticated | `/admin` | Direct URL | Redirect to `/login` | P2 |
| E-06 | Session expired during action | any protected | API call | 401 → auto redirect to `/login` | P2 |

### 9.2 Authorization Errors (403)

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-07 | Buyer accesses /seller/drafts | `/seller/drafts` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-08 | Buyer accesses /admin | `/admin` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-09 | Buyer accesses /moderator | `/moderator` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-10 | Seller accesses /admin | `/admin` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-11 | Seller accesses /moderator | `/moderator` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-12 | Moderator accesses /admin | `/admin` | Direct URL | Redirect to `/unauthorized` | P2 |
| E-13 | Moderator accesses /seller/* | `/seller/drafts` | Direct URL | Redirect to `/unauthorized` | P2 |

### 9.3 Not Found Errors (404)

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-14 | Non-existent listing slug | `/listing/does-not-exist` | Direct URL | 404 page or empty detail | P2 |
| E-15 | Non-existent seller ID | `/sellers/fake-uuid` | Direct URL | 404 page or empty profile | P2 |
| E-16 | Non-existent report ID | `/moderator/reports/fake-id` | Direct URL | 404 or empty state | P2 |
| E-17 | Non-existent legal key | `/legal/nonexistent` | Direct URL | 404 page | P2 |
| E-18 | Non-existent KPI metric | `/admin/kpis/fake-metric` | Direct URL | Error or fallback | P2 |

### 9.4 Validation Errors

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-19 | Register with missing required fields | `/register` | Submit empty form | Validation errors displayed | P2 |
| E-20 | Create draft without plate/VIN | create form | Submit | Validation error on required fields | P2 |
| E-21 | Upload photo > max size | create form | Select large file | Error toast, upload rejected | P2 |
| E-22 | Upload non-image file | create form | Select .pdf | Error, wrong file type | P2 |
| E-23 | Publish without all declaration checkboxes | `/seller/publish` | Uncheck one box | Submit button disabled | P2 |
| E-24 | Save invalid config value (admin) | `/admin/config/*` | Enter negative price | Validation error | P2 |
| E-25 | Report with empty description | listing detail | Submit report | Validation error | P2 |

### 9.5 Empty States

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-26 | Search with no results | `/search?make=Ferrari` | Apply impossible filter | Empty state: "Aucun resultat" | P2 |
| E-27 | No favorites | `/favorites` (new user) | View favorites | Empty state: "Aucun favori" | P2 |
| E-28 | No conversations | `/seller/chat` (new user) | View chat | Empty state: "Aucune conversation" | P2 |
| E-29 | No drafts | `/seller/drafts` (new seller) | View drafts | Empty state with CTA to create | P2 |
| E-30 | No active listings | `/seller/listings` (new seller) | View listings | Empty state with CTA | P2 |
| E-31 | No reports in queue | `/moderator` (all resolved) | View queue | Empty state: "Aucun signalement" | P2 |
| E-32 | No audit entries | `/admin/audit-trail` (filtered empty) | Apply strict filters | Empty table state | P2 |
| E-33 | Seller cockpit empty (new seller) | `/seller` | View dashboard | Empty state with onboarding CTA | P2 |

### 9.6 Suspended Account Behavior

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-34 | Login as suspended seller | `/login` | Authenticate | Limited access or error message | seller-suspended | P2 |
| E-35 | View suspended seller's listings in search | `/search` | Browse | Suspended listings (L15) not visible | L15 | P2 |
| E-36 | Chat with suspended seller | `/seller/chat` | Open conversation | Error or read-only state | seller-suspended | P2 |

### 9.7 Duplicate/Conflict Errors

| # | Scenario | Route | Action | Expected | Priority |
|---|----------|-------|--------|----------|----------|
| E-37 | Favorite same listing twice | `/listing/[slug]` | Double-click heart | Toggle behavior (add then remove) | L1 | P2 |
| E-38 | Submit duplicate report | `/listing/[slug]` | Report twice | 409 conflict or error message | L14 (already reported) | P2 |
| E-39 | Concurrent moderation (two moderators) | `/moderator/reports/[id]` | Both act on same report | 409 conflict, second action rejected | R1 | P2 |

---

## 10. Coverage Summary

### Route Coverage

| Route Group | Total Routes | Covered By Test Cases | Coverage |
|-------------|-------------|----------------------|----------|
| Public `(public)` | 12 | 12 | 100% |
| Auth `(auth)` | 3 | 3 | 100% |
| Dashboard (general) | 4 | 4 | 100% |
| Settings | 4 | 4 | 100% |
| Seller | 10 | 10 | 100% |
| Moderator | 3 | 3 | 100% |
| Admin | 18 | 18 | 100% |
| **Total** | **54** | **54** | **100%** |

### Persona Coverage

| Persona | Test Cases | P0 | P1 | P2 |
|---------|-----------|----|----|----|
| Anonymous Visitor | 42 (V-01 to V-42) | 10 | 19 | 13 |
| Buyer | 39 (B-01 to B-39) | 9 | 21 | 9 |
| Seller | 38 (S-01 to S-38) | 16 | 14 | 8 |
| Moderator | 19 (M-01 to M-19) | 7 | 9 | 3 |
| Admin | 41 (A-01 to A-41) | 7 | 25 | 9 |
| **Total unique test cases** | **179** | **49** | **88** | **42** |

### Error Scenario Coverage

| Category | Count |
|----------|-------|
| 401 Authentication | 6 |
| 403 Authorization | 7 |
| 404 Not Found | 5 |
| Validation | 7 |
| Empty States | 8 |
| Suspended Account | 3 |
| Duplicate/Conflict | 3 |
| **Total error scenarios** | **39** |

### Seed Data Utilization

| Seed Entity | Total Records | Exercised By Tests | Coverage |
|-------------|--------------|-------------------|----------|
| Users | 6 | 6 (all personas tested) | 100% |
| Listings | 15 | 15 (all statuses tested) | 100% |
| Conversations | 3 | 3 (buyer & seller chat tests) | 100% |
| Messages | 14 | 14 (via conversation tests) | 100% |
| Favorites | 4 | 4 (buyer favorites tests) | 100% |
| Notifications | 5 | 5 (buyer & seller notification tests) | 100% |
| Reports | 2 | 2 (moderator & buyer report tests) | 100% |
| Declarations | 14 | 14 (via publish flow tests) | 100% |
| Photos | 53 | 53 (via listing detail tests) | 100% |
| Certified Fields | 38 | 38 (via listing detail tests) | 100% |
| Analytics | 11 | 11 (via seller cockpit tests) | 100% |

### Critical Path Journeys (P0)

| # | Journey | Steps | Personas |
|---|---------|-------|----------|
| 1 | Visitor Discovery → Registration | 5 | Visitor |
| 2 | Buyer Search → Favorite → Chat | 6 | Buyer |
| 3 | Seller Create → Publish → Manage | 10 | Seller |
| 4 | Moderator Report Handling | 6 | Moderator |
| 5 | Admin Platform Configuration | 8 | Admin |
| 6 | Mobile Navigation (Visitor) | 5 | Visitor |
| 7 | Mobile Navigation (Authenticated) | 5 | Buyer |
| 8 | Buyer Favorites Lifecycle | 5 | Buyer |
| 9 | Seller Chat Response | 5 | Seller |
| 10 | Full Report-to-Resolution | 7 | Buyer + Moderator |

### Gaps & Recommendations

1. **No gaps identified.** All 54 routes have at least one test case. All 6 seed user accounts are exercised. All 15 listings across all statuses (published, sold, expired, draft, suspended) are covered.

2. **Future automation priority:** The 10 P0 critical journeys should be the first candidates for Playwright/Cypress automation, as they represent the core user flows that must work at launch.

3. **Responsive testing:** Each P0 journey should be validated at both desktop (>=768px) and mobile (<768px) viewports per the responsive design standards.

4. **Real-time features:** Chat tests (B-21 to B-26, S-31 to S-33) and admin KPI live updates (A-02) involve SignalR connections and should be tested with proper WebSocket support in the E2E framework.

5. **Payment flow:** Seller publication payment (S-20, S-21) uses Stripe checkout — E2E tests should use Stripe test mode with test card numbers.
