# Story 2.2: Platform Configuration UI (Prices, Texts, Rules, Features)

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR47, FR48, FR49, FR50
**NFRs:** NFR19 (extensible without code)

## User Story

As an administrator,
I want to configure prices, display texts, business rules, feature toggles, registration fields, and auth-required features through a dedicated admin interface,
So that I can adapt the platform to business needs without touching code.

## Acceptance Criteria

**Given** an admin accesses the configuration section
**When** they navigate to Pricing configuration
**Then** they can modify the listing price (currently €15) via `ConfigParameter`
**And** a preview shows the estimated impact ("Cette modification affectera les X prochaines annonces")

**Given** an admin accesses Texts configuration
**When** they edit a `ConfigText` entry
**Then** they can modify UI texts by key and language (i18n support)
**And** changes are reflected immediately on the platform

**Given** an admin accesses Feature Toggles
**When** they toggle a `ConfigFeature` entry (FR49)
**Then** they can enable/disable features (e.g., "require auth for contact", "show price comparison")
**And** the frontend respects the feature flag via config cache

**Given** an admin accesses Registration Fields configuration (FR50)
**When** they modify a field's required/optional status
**Then** the registration form dynamically adjusts

**Given** an admin accesses Card Display configuration (FR48)
**When** they configure which fields appear on listing cards
**Then** the public listing cards reflect the configuration

**Given** an admin modifies any configuration
**When** the change is saved
**Then** a confirmation dialog shows: what changed, estimated impact, before/after preview (UX principle: "Preview before commit")
