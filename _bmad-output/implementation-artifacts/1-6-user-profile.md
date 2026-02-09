# Story 1.6: User Profile & Seller Rating Contribution

Status: done

## Story

As a user,
I want to manage my profile information, and as a seller, I want my profile completion rate to contribute to my seller rating,
so that buyers can assess my trustworthiness based on how thoroughly I've filled out my profile.

## Acceptance Criteria (BDD)

### AC1: Profile View and Edit
**Given** an authenticated user navigates to their profile page
**When** the profile form loads
**Then** the user can view and edit their personal information (name, email, phone, address, SIRET for pros)
**And** changes are saved to the `User` CDS entity and synced with Azure AD B2C custom attributes if applicable

### AC2: Seller Profile Completion and Rating
**Given** a user with role Seller views their profile
**When** they see their profile completion indicator
**Then** a percentage of filled fields is displayed
**And** the completion rate contributes to their public seller rating (FR26)
**And** tips are shown: "Ajoutez votre numero SIRET pour renforcer votre credibilite" (positive framing, never punitive)

### AC3: Public Seller Profile Card
**Given** a buyer views a seller's public profile on a listing
**When** the profile card renders
**Then** it shows the seller's rating, profile completion level, number of listings, and account seniority

## Tasks / Subtasks

### Task 1: Extend CDS User model for profile fields (AC1, AC2)
1.1. Extend `db/schema/user.cds` `User` entity with additional profile fields (if not already present):
    - `displayName: String` (computed or editable)
    - `phone: String`
    - `addressStreet: String`
    - `addressCity: String`
    - `addressPostalCode: String`
    - `addressCountry: String` (default 'FR')
    - `siret: String(14)` (for professional sellers, with format validation)
    - `companyName: String` (for professionals)
    - `avatarUrl: String` (URL to avatar image)
    - `bio: String(500)` (optional seller bio)
    - `accountCreatedAt: Timestamp` (for seniority calculation)
1.2. Create `db/schema/seller-rating.cds` with `SellerRating` entity (or extend User):
    - `user: Association to User` (key)
    - `profileCompletionRate: Decimal(5,2)` (percentage, 0-100)
    - `overallRating: Decimal(3,2)` (composite score, 0-5)
    - `totalListings: Integer` (cached count)
    - `lastCalculatedAt: Timestamp`
    Note: The overall rating formula will be expanded in later epics (reviews, transactions). For now, it is based solely on profile completion.
1.3. Create `ConfigProfileField` entity in config schema:
    - `ID: UUID` (key)
    - `fieldName: String` (maps to User entity field)
    - `isVisibleToPublic: Boolean` (shown on public profile card)
    - `contributesToCompletion: Boolean` (counts toward profile completion %)
    - `weight: Integer` (weight in completion calculation, default 1)
    - `tipKey: String` (i18n key for the encouragement tip when field is empty)
    - `displayOrder: Integer`
1.4. Add seed data for `ConfigProfileField` with standard fields and their completion weights.

### Task 2: Create backend profile service (AC1, AC2)
2.1. Create `srv/profile-service.cds` exposing:
    - `entity UserProfile as projection on db.User` (authenticated user, self-only read/write)
    - `entity PublicSellerProfile as projection on db.User` (public read, limited fields)
    - `action updateProfile(input: ProfileUpdateInput): ProfileResult`
    - `function getProfileCompletion(userId: UUID): ProfileCompletionResult`
    - `function getPublicSellerProfile(sellerId: UUID): PublicSellerProfileResult`
2.2. Create `srv/handlers/profile-handler.ts` implementing:
    - `updateProfile(req)`:
      a. Validate input (Zod schema for profile fields, SIRET format check).
      b. Update `User` entity in database.
      c. Sync relevant fields to Azure AD B2C custom attributes via identity provider adapter (e.g., display name, phone).
      d. Recalculate profile completion rate.
      e. Return updated profile.
    - `getProfileCompletion(req)`:
      a. Fetch `ConfigProfileField` entries where `contributesToCompletion = true`.
      b. Check which fields are filled in the user's profile.
      c. Calculate weighted completion percentage.
      d. Return percentage + list of incomplete fields with their tips.
    - `getPublicSellerProfile(req)`:
      a. Fetch seller's User record.
      b. Filter to only `isVisibleToPublic` fields (from config).
      c. Include rating, completion level (as badge: "Profil complet", "Profil avance", etc.), listing count, seniority.
      d. If user is anonymized, return "Utilisateur anonymise" placeholder.
2.3. Implement SIRET validation (14 digits, Luhn check for SIREN component).
2.4. Write unit tests: profile update, completion calculation, public profile, SIRET validation, anonymized user handling.

### Task 3: Create frontend profile page (AC1, AC2)
3.1. Create `src/app/(dashboard)/profile/page.tsx`:
    - Fetch user profile data on load.
    - Render profile form with editable fields.
    - Show profile completion indicator (circular progress or progress bar).
3.2. Create `src/components/profile/profile-form.tsx`:
    - Form fields for: first name, last name, email (read-only), phone, address fields, SIRET (for sellers), company name (for sellers), bio.
    - Use shadcn/ui form components (Input, Textarea, Button).
    - Zod validation with `react-hook-form`.
    - Save button with loading state.
    - Success/error toast notifications on save.
3.3. Create `src/components/profile/profile-completion-indicator.tsx`:
    - Circular progress indicator showing completion percentage.
    - Color coding: red (<50%), orange (50-79%), green (>=80%).
    - Expandable section showing missing fields with positive tips.
    - Tips rendered from i18n keys (e.g., "Ajoutez votre numero SIRET pour renforcer votre credibilite").
3.4. Create `src/components/profile/avatar-upload.tsx`:
    - Avatar display (current image or initials fallback).
    - Upload button to change avatar.
    - Image preview before save.
    - Integration with blob storage (Azure Blob Storage adapter, placeholder for now).
3.5. Conditionally show seller-specific fields (SIRET, company name, bio) only for users with Seller role.

### Task 4: Create public seller profile card (AC3)
4.1. Create `src/components/profile/public-seller-card.tsx`:
    - Compact card component for displaying on listing pages.
    - Shows: seller display name (or "Utilisateur anonymise"), rating (stars), profile completion badge, listing count, "Membre depuis [date]" seniority.
    - Rating displayed as stars (0-5) using a custom star rating component.
    - Profile completion as a badge: "Profil complet" (>=90%), "Profil avance" (>=70%), "Profil intermediaire" (>=40%), "Nouveau vendeur" (<40%).
    - Link to full seller public profile page.
4.2. Create `src/app/(public)/sellers/[id]/page.tsx`:
    - Full public seller profile page (SSR for SEO).
    - Shows all public-visible fields, rating, listings by this seller.
    - If seller is anonymized: show "Utilisateur anonymise" with no personal information.
4.3. Create `src/components/ui/star-rating.tsx`:
    - Reusable star rating display component (read-only for now).
    - Props: `rating: number`, `maxRating: number`, `size: 'sm' | 'md' | 'lg'`.

### Task 5: Azure AD B2C sync for profile updates (AC1)
5.1. Extend the `IIdentityProviderAdapter` interface (from Story 1.2) with `updateUserAttributes(externalId, attributes)`.
5.2. Update `azure-ad-b2c-adapter.ts` to implement attribute sync:
    - Sync display name, phone number to AD B2C custom attributes.
    - Handle sync failures gracefully (log error, do not block profile save).
5.3. Write unit tests for attribute sync with mocked Graph API.

### Task 6: Shared types and validators (all ACs)
6.1. In `auto-shared`, create `src/types/profile.ts`:
    - `IProfileUpdateInput`, `IProfileCompletionResult`, `IPublicSellerProfile`, `IConfigProfileField`.
    - `ProfileCompletionBadge` enum: `'complete' | 'advanced' | 'intermediate' | 'new_seller'`.
6.2. In `auto-shared`, create `src/validators/profile.validator.ts`:
    - Zod schema for profile update input.
    - SIRET validation schema (14 digits, format check).
6.3. Publish updated `@auto/shared` package.

### Task 7: Testing (all ACs)
7.1. Backend unit tests: profile update, completion calculation (weighted), public profile, SIRET validation, AD B2C sync, anonymized seller.
7.2. Frontend component tests: profile form (edit/save), completion indicator (percentage/tips), public seller card (data display, anonymized state), avatar upload.
7.3. E2E Playwright tests:
    - Edit profile -> verify save -> verify completion percentage updates.
    - View public seller profile on listing page.
    - Anonymized seller shows placeholder.

## Dev Notes

### Architecture & Patterns
- Profile management follows the **config-driven** pattern: `ConfigProfileField` determines which fields contribute to completion and their weights. Admins can adjust the completion formula without code changes.
- **Profile completion rating** is calculated dynamically based on config. For sellers, it contributes to the public seller rating, which builds trust with buyers.
- The **positive framing** approach for tips is a UX decision: never tell users what they are missing in a negative way. Instead, encourage them with benefits ("Ajoutez votre SIRET pour renforcer votre credibilite").
- AD B2C attribute sync is **best-effort**: if the sync fails, the local database update still succeeds. This prevents external API failures from blocking user actions.
- The **public seller profile** is SSR-rendered for SEO. The seller card component is reused on listing pages.

### Key Technical Context
- **Stack:** SAP CAP (Node.js/TypeScript) backend, Next.js 16 App Router frontend, PostgreSQL, Azure ecosystem
- **Multi-repo:** auto-backend, auto-frontend, auto-shared (npm package @auto/shared via Azure Artifacts)
- **Auth:** Azure AD B2C (Authorization Code Flow + PKCE), MSAL.js frontend, custom JWT middleware backend
- **RBAC:** Hybrid - AD B2C for identity + user_roles table in PostgreSQL for permissions
- **API:** Hybrid OData v4 (auto-generated by CDS) + REST custom endpoints
- **Real-time:** Azure SignalR Service (4 hubs: /chat, /notifications, /live-score, /admin)
- **UI:** shadcn/ui + Tailwind CSS + Radix UI, Zustand for SPA state
- **Config:** Zero-hardcode - 10+ config tables in DB, InMemoryConfigCache
- **Adapter Pattern:** 8 interfaces for external APIs, Factory resolves from ConfigApiProvider
- **Testing:** Jest/Vitest, React Testing Library, Playwright E2E, >=90% unit coverage

### Naming Conventions
- CDS: PascalCase entities, camelCase elements
- Frontend: kebab-case files, PascalCase components
- API REST custom: kebab-case
- All technical naming in English, French only in i18n DB texts

### Anti-Patterns (FORBIDDEN)
- Hardcoded values (use config tables)
- Direct DB queries (use CDS service layer)
- Direct external API calls (use Adapter Pattern)
- French in code/files/variables
- Exposing internal errors to clients
- Skipping audit trail for sensitive ops
- Skipping tests

### Project Structure Notes
```
auto-backend/
  db/schema/user.cds                    # User entity (extended with profile fields)
  db/schema/seller-rating.cds           # SellerRating entity
  db/schema/config.cds                  # ConfigProfileField entity (extend)
  db/data/ConfigProfileField.csv        # Seed profile field config
  srv/profile-service.cds               # Profile service definition
  srv/handlers/profile-handler.ts       # Profile business logic
  srv/adapters/azure-ad-b2c-adapter.ts  # Extended with updateUserAttributes
  test/srv/handlers/profile-handler.test.ts

auto-frontend/
  src/app/(dashboard)/profile/page.tsx               # Profile management page
  src/app/(public)/sellers/[id]/page.tsx             # Public seller profile (SSR)
  src/components/profile/profile-form.tsx             # Editable profile form
  src/components/profile/profile-completion-indicator.tsx  # Completion % display
  src/components/profile/avatar-upload.tsx            # Avatar management
  src/components/profile/public-seller-card.tsx       # Compact seller card for listings
  src/components/ui/star-rating.tsx                   # Reusable star rating display

auto-shared/
  src/types/profile.ts
  src/validators/profile.validator.ts
```

### References
- [Source: _bmad-output/planning-artifacts/architecture.md]
- [Source: _bmad-output/planning-artifacts/prd.md]
- [Source: _bmad-output/planning-artifacts/epics.md]

## Dev Agent Record

### Agent Model Used
### Completion Notes List
### Change Log
### File List
