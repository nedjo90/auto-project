# Story 8.3: Complete Public Navigation

Status: done

## Story

As a visitor (desktop or mobile),
I want clear navigation to all public sections of the site,
so that I can explore the marketplace without guessing URLs.

## Acceptance Criteria (BDD)

**AC-NAV-01: Desktop header navigation links**
**Given** a visitor on desktop (>= 768px)
**When** any public page loads
**Then** the header displays navigation links between the logo and auth buttons:
- "Recherche" navigating to `/search`
- "Comment ca marche" navigating to `/how-it-works`
- "Confiance" navigating to `/trust`
- The active link is visually highlighted based on current pathname
- Links use consistent styling with the existing header design

**AC-NAV-02: Mobile public tab bar**
**Given** a visitor on mobile (< 768px) on any public page (not dashboard)
**When** the page loads
**Then** a fixed tab bar at the bottom displays 5 tabs:
- Accueil (home icon) navigating to `/`
- Recherche (search icon) navigating to `/search`
- Favoris (heart icon) navigating to `/favorites` if authenticated, `/login` if not
- Messages (message-circle icon) navigating to `/seller/chat` if authenticated, `/login` if not
- Profil (user icon) navigating to `/profile` if authenticated, `/login` if not
- The active tab is visually highlighted based on current pathname
- The tab bar is NOT visible on dashboard pages (which have their own Sidebar/MobileNav)

**AC-NAV-03: Footer links corrected**
**Given** a visitor on any public page
**When** they look at the footer
**Then** links point to real working routes:
- "Mentions legales" navigating to `/legal/cgu`
- "Politique de confidentialite" navigating to `/legal/privacy-policy`
- "A propos" navigating to `/about`
- "Comment ca marche" navigating to `/how-it-works`
- "Confiance & Transparence" navigating to `/trust`

**AC-NAV-04: Dashboard hub replacing stub**
**Given** an authenticated user navigates to `/dashboard`
**When** the page loads
**Then** instead of a stub, a role-aware hub displays:
- Welcome message with user's name
- **Buyer view:** recent favorites, suggested searches, recent conversations, quick link to search
- **Seller view:** active listings count, unread messages count, total views, quick links to cockpit sections (drafts, publish, chat, market)
- **Moderator view:** pending reports count, quick link to moderator cockpit
- **Admin view:** quick links to KPIs, config, alerts, users, legal, SEO, audit

**AC-NAV-05: Responsive compliance**
**Given** all navigation changes
**When** tested across breakpoints (mobile, tablet, desktop)
**Then** fully compliant with `responsive-design-standards.md`

## Tasks / Subtasks

### T1: Frontend - Desktop Header Navigation (AC-NAV-01)
- [ ] T1.1: Add `publicNavLinks` array to `src/components/layout/header.tsx` with Recherche, Comment ca marche, Confiance
- [ ] T1.2: Render links between logo and auth section, visible only on md+ breakpoint
- [ ] T1.3: Implement active link highlighting using `usePathname()` with `startsWith` matching
- [ ] T1.4: Ensure consistent styling with existing header (font size, spacing, hover states)
- [ ] T1.5: Write unit tests for desktop nav links rendering and active state

### T2: Frontend - Mobile Public Tab Bar (AC-NAV-02)
- [ ] T2.1: Create `src/components/layout/public-tab-bar.tsx` with 5 tabs (Accueil, Recherche, Favoris, Messages, Profil)
- [ ] T2.2: Use lucide-react icons: Home, Search, Heart, MessageCircle, User
- [ ] T2.3: Implement auth-aware navigation: Favoris/Messages/Profil redirect to `/login` if not authenticated
- [ ] T2.4: Implement active tab detection using `usePathname()` with pathname matching
- [ ] T2.5: Style: fixed bottom, h-16, bg-background, border-top, z-50, safe-area-inset-bottom padding
- [ ] T2.6: Add to `src/app/(public)/layout.tsx` — hidden on md+ breakpoint, visible on mobile only
- [ ] T2.7: Ensure main content has bottom padding (pb-16) on mobile to avoid tab bar overlap
- [ ] T2.8: Write unit tests for PublicTabBar (rendering, active tab, auth-aware redirects)

### T3: Frontend - Footer Links Fix (AC-NAV-03)
- [ ] T3.1: Update `src/components/layout/footer.tsx` links to point to real routes
- [ ] T3.2: Add missing links: A propos, Comment ca marche, Confiance
- [ ] T3.3: Organize footer in columns (Plateforme, Legal, Support) if not already structured
- [ ] T3.4: Write unit tests for footer link hrefs

### T4: Frontend - Dashboard Hub (AC-NAV-04)
- [ ] T4.1: Rewrite `src/app/(dashboard)/dashboard/page.tsx` with role-aware content
- [ ] T4.2: Create `src/components/dashboard/dashboard-hub.tsx` as the main layout component
- [ ] T4.3: Implement buyer section: recent favorites (fetch top 4), recent conversations, search shortcut
- [ ] T4.4: Implement seller section: active listings count, unread messages count, total views, quick action cards (Mes brouillons, Publier, Chat, Suivi marche)
- [ ] T4.5: Implement moderator section: pending reports count with badge, link to moderator cockpit
- [ ] T4.6: Implement admin section: quick links grid to all admin sections (KPIs, Config, Alertes, Utilisateurs, Legal, SEO, Audit)
- [ ] T4.7: Use `useAuth()` to determine user roles and render appropriate sections
- [ ] T4.8: Multiple roles: show all applicable sections (e.g., admin sees admin + seller sections)
- [ ] T4.9: Write unit tests for each role variant (buyer, seller, moderator, admin, multi-role)

### T5: Integration Tests
- [ ] T5.1: Test desktop header nav renders links and highlights active page
- [ ] T5.2: Test mobile tab bar renders on public pages, hidden on dashboard
- [ ] T5.3: Test footer links all resolve to real routes
- [ ] T5.4: Test dashboard hub renders role-appropriate content

## Dev Notes

### Architecture & Patterns
- The `PublicTabBar` lives in `(public)/layout.tsx` so it automatically excludes dashboard pages — no conditional logic needed for visibility between layouts.
- The `MobileHeaderNav` (hamburger Sheet drawer) already contains the public links — the desktop nav mirrors these. Consider extracting a shared `PUBLIC_NAV_LINKS` constant.
- The dashboard hub aggregates data from multiple existing API endpoints. Use parallel `Promise.all` for data fetching to minimize load time.
- Active link detection should use `pathname.startsWith('/search')` pattern to handle sub-routes.

### Key Technical Context
- **Stack:** Next.js 16, React 19, Tailwind CSS v4, shadcn/ui, lucide-react
- **Existing header:** `src/components/layout/header.tsx` — has logo, MobileHeaderNav (mobile), UserMenu (desktop)
- **Existing footer:** `src/components/layout/footer.tsx` — minimal, has 2 links
- **Existing MobileHeaderNav:** `src/components/layout/mobile-header-nav.tsx` — Sheet drawer with public links (already has Recherche)
- **Dashboard layout:** `src/app/(dashboard)/layout.tsx` — has Sidebar + TopBar, separate from public layout
- **Auth hook:** Available from auth store/provider for role checking
- **Icons:** lucide-react already in project dependencies

### Naming Conventions
- Components in `src/components/layout/` for nav elements
- Components in `src/components/dashboard/` for dashboard hub
- Follow existing kebab-case file naming with PascalCase exports

### Anti-Patterns (FORBIDDEN)
- Do NOT duplicate the Sidebar nav in the public tab bar — different navigation for different contexts
- Do NOT hide navigation behind a hamburger menu on desktop — links must be directly visible
- Do NOT hardcode role checks — use the existing RBAC utilities
- Do NOT create new API endpoints for the dashboard hub — aggregate from existing endpoints
- Do NOT use raw Dialog — use ResponsiveDialog per responsive standards

### Dependencies
- **No blockers.** This story is independent and can be developed in parallel with Story 8-1 (seed data).
- Story 8-1 enhances the dashboard hub experience (non-zero counts) but is not required for the navigation structure.

### References
- Existing header: `auto-frontend/src/components/layout/header.tsx`
- Existing footer: `auto-frontend/src/components/layout/footer.tsx`
- Existing MobileHeaderNav: `auto-frontend/src/components/layout/mobile-header-nav.tsx`
- Responsive standards: `_bmad-output/responsive-design-standards.md`
- UX specification: `_bmad-output/planning-artifacts/ux-design-specification.md`
- Dashboard page: `auto-frontend/src/app/(dashboard)/dashboard/page.tsx`
