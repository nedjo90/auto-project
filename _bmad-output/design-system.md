# Auto Platform - Design System

> Single source of truth for the French car/motorcycle classifieds platform.
> Stack: Next.js 16 + React 19 + shadcn/ui (New York) + Tailwind CSS v4 + Radix UI

---

## 1. Foundations

### 1.1 Color System

The platform uses **OKLCH** for base colors (perceptually uniform) and **HSL** for platform-specific semantic tokens. Full dark mode support via `next-themes` + `.dark` class.

#### Base Palette

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--background` | `oklch(1 0 0)` white | `oklch(0.145 0 0)` near-black | Page background |
| `--foreground` | `oklch(0.145 0 0)` near-black | `oklch(0.985 0 0)` off-white | Primary text |
| `--card` | `oklch(1 0 0)` | `oklch(0.205 0 0)` | Card surfaces |
| `--primary` | `oklch(0.205 0 0)` dark | `oklch(0.922 0 0)` light | Primary actions, CTAs |
| `--secondary` | `oklch(0.97 0 0)` near-white | `oklch(0.269 0 0)` dark gray | Secondary actions |
| `--muted` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` | Muted backgrounds |
| `--muted-foreground` | `oklch(0.556 0 0)` | `oklch(0.708 0 0)` | Secondary text, placeholders |
| `--accent` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` | Hover states, highlights |
| `--destructive` | `oklch(0.577 0.245 27.325)` | `oklch(0.704 0.191 22.216)` | Errors, delete actions |
| `--border` | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` | Borders, dividers |
| `--input` | `oklch(0.922 0 0)` | `oklch(1 0 0 / 15%)` | Input borders |
| `--ring` | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` | Focus rings |

#### Platform Semantic Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--certified` | `hsl(142 71% 45%)` green | `hsl(142 71% 55%)` | Certified field badges |
| `--declared` | `hsl(38 92% 50%)` amber | `hsl(38 92% 60%)` | Declared field badges |
| `--success` | `hsl(142 71% 45%)` green | `hsl(142 71% 55%)` | Success states |
| `--market-below` | `hsl(142 71% 45%)` green | `hsl(142 71% 55%)` | Price below market |
| `--market-aligned` | `hsl(38 92% 50%)` amber | `hsl(38 92% 60%)` | Price aligned with market |
| `--market-above` | `hsl(0 84% 60%)` red | `hsl(0 84% 70%)` | Price above market |

#### Chart Colors (5-color palette)

| Token | Light | Dark |
|-------|-------|------|
| `--chart-1` | `oklch(0.646 0.222 41.116)` orange | `oklch(0.488 0.243 264.376)` blue-purple |
| `--chart-2` | `oklch(0.6 0.118 184.704)` cyan | `oklch(0.696 0.17 162.48)` cyan |
| `--chart-3` | `oklch(0.398 0.07 227.392)` dark blue | `oklch(0.769 0.188 70.08)` orange-yellow |
| `--chart-4` | `oklch(0.828 0.189 84.429)` yellow-green | `oklch(0.627 0.265 303.9)` magenta |
| `--chart-5` | `oklch(0.769 0.188 70.08)` orange-yellow | `oklch(0.645 0.246 16.439)` red-orange |

#### Sidebar Colors

Separate token set for sidebar component (`--sidebar`, `--sidebar-foreground`, `--sidebar-primary`, `--sidebar-accent`, `--sidebar-border`, `--sidebar-ring`).

#### Usage Guidelines

- **Do**: Use semantic tokens (`bg-primary`, `text-destructive`) — never raw color values.
- **Do**: Respect dark mode — all custom components must reference CSS variables.
- **Don't**: Mix OKLCH and HSL in the same context. Base palette = OKLCH, platform semantics = HSL.
- **Don't**: Use opacity hacks when a semantic token exists.

---

### 1.2 Typography

#### Font Families

| Variable | Font | Category | Usage |
|----------|------|----------|-------|
| `--font-inter` / `--font-sans` | Inter | Sans-serif | Body text, UI elements, forms |
| `--font-lora` / `--font-serif` | Lora | Serif | Editorial content, headings (optional) |
| `--font-jetbrains-mono` / `--font-mono` | JetBrains Mono | Monospace | Code, technical data, VIN numbers |

All fonts loaded from Google Fonts with `latin` subset. Applied via CSS variables on `<body>` with `antialiased` rendering.

#### Type Scale

| Level | Class | Size | Weight | Usage |
|-------|-------|------|--------|-------|
| Page title | `text-2xl` | 1.5rem / 24px | `font-semibold` | Page headings |
| Section title | `text-lg` | 1.125rem / 18px | `font-semibold` | Dialog titles, card titles |
| Body | `text-sm` | 0.875rem / 14px | normal (400) | Default body text, table cells |
| Label | `text-sm` | 0.875rem / 14px | `font-medium` | Form labels, button text |
| Caption | `text-xs` | 0.75rem / 12px | normal (400) | Badges, helper text, timestamps |
| Overline | `text-xs` | 0.75rem / 12px | `font-medium` | Category labels, status text |

#### French Typography Notes

- Use `« guillemets »` (with non-breaking thin spaces) for French quotation marks.
- Dates: `dd/MM/yyyy` or `toLocaleString("fr-FR")`.
- Numbers: `toLocaleString("fr-FR")` — thousands separator = space, decimal = comma.
- Currency: `15 000,00 €` (space before `€`).

---

### 1.3 Spacing System

Base unit: **4px** (Tailwind's default `0.25rem` increments).

| Token | Value | Usage |
|-------|-------|-------|
| `gap-1` | 4px | Tight inline spacing (badge icon + text) |
| `gap-1.5` | 6px | Compact element groups |
| `gap-2` | 8px | Default element spacing, card header |
| `gap-4` | 16px | Section spacing, form field gaps |
| `gap-6` | 24px | Card content padding, page sections |
| `p-2` | 8px | Table cells, compact padding |
| `p-6` | 24px | Card padding, dialog padding |
| `px-3 py-1.5` | 12px / 6px | Default button padding |
| `px-4 py-2` | 16px / 8px | Large button padding |

#### Layout Spacing

- **Page padding**: `p-6` (24px)
- **Sidebar width**: `w-64` (256px)
- **TopBar height**: `h-16` (64px)
- **Max content width**: Container queries, not fixed max-width

---

### 1.4 Border Radius

Custom scale with calculated offsets from a base value of `0.625rem` (10px):

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 6px | Checkboxes (`rounded-[4px]`), small elements |
| `--radius-md` | 8px | Buttons, inputs, selects |
| `--radius-lg` | 10px | Dialogs, popovers |
| `--radius-xl` | 26px | Cards (iOS-inspired) |
| `rounded-full` | 9999px | Avatars, badges, pills |

---

### 1.5 Elevation (Shadows)

| Level | Class | Value | Usage |
|-------|-------|-------|-------|
| Level 0 | none | — | Flat elements |
| Level 1 | `shadow-xs` | `0 1px 2px 0 rgb(0 0 0 / 0.05)` | Inputs, outline buttons |
| Level 2 | `shadow-sm` | `0 1px 2px 0 rgb(0 0 0 / 0.05)` | Cards |
| Level 3 | `shadow-md` | `0 4px 6px -1px rgb(0 0 0 / 0.1)` | Dropdowns, select menus |
| Level 4 | `shadow-lg` | `0 20px 25px -5px rgb(0 0 0 / 0.1)` | Dialogs, modals |

Overlay: `bg-black/50` for modal backdrops.

---

### 1.6 Motion & Animation

| Pattern | Duration | Easing | Usage |
|---------|----------|--------|-------|
| Color transition | instant | `transition-colors` | Hover states |
| Opacity fade | 150ms | `ease` | Enter/exit animations |
| Gauge arc | 500ms | `cubic-bezier(0.34, 1.56, 0.64, 1)` spring | Visibility score gauge |
| Circular progress | 500ms | `ease` | Profile completion |
| Spinner | continuous | `animate-spin` | Loading (Loader2 icon) |
| Skeleton pulse | continuous | `animate-pulse` | Content placeholders |
| Radix enter | 150ms | `fade-in + zoom-in-95` | Dialog/popover open |
| Radix exit | 150ms | `fade-out-0 + zoom-out-95` | Dialog/popover close |

**Accessibility**: All motion respects `prefers-reduced-motion` via `useReducedMotion` hook. Animations disable gracefully.

---

### 1.7 Responsive Breakpoints

| Prefix | Min-width | Target |
|--------|-----------|--------|
| (none) | 0px | Mobile (default) |
| `sm:` | 640px | Large phones, small tablets |
| `md:` | 768px | Tablets, small laptops |
| `lg:` | 1024px | Desktops |
| `xl:` | 1280px | Large desktops |
| `2xl:` | 1536px | Ultra-wide |

**Strategy**: Mobile-first. Sidebar hidden below `md:`. Forms stack to single column on mobile. Dialogs go full-width on mobile → `sm:max-w-lg`.

---

## 2. Component Catalog

### 2.1 shadcn/ui Components (15 installed)

All components use the **New York** style variant, **Radix UI** primitives, and **CVA** (class-variance-authority) for variants.

| Component | Variants | Sizes | Key Props |
|-----------|----------|-------|-----------|
| **Avatar** | — | sm (24px), default (32px), lg (40px) | `AvatarImage`, `AvatarFallback`, `AvatarBadge`, `AvatarGroup` |
| **Badge** | default, secondary, destructive, outline, ghost, link | — | Rounded-full pills |
| **Button** | default, destructive, outline, secondary, ghost, link | xs (24px), sm (32px), default (36px), lg (40px), icon variants | Slot composition via Radix |
| **Card** | — | — | `CardHeader`, `CardTitle`, `CardAction`, `CardDescription`, `CardContent`, `CardFooter` |
| **Checkbox** | — | — | Radix primitive, square corners |
| **Dialog** | — | — | Portal-based, overlay, close button optional |
| **DropdownMenu** | — | — | 14 subcomponents, nested menus |
| **Input** | — | — | File upload styling, aria-invalid |
| **Label** | — | — | Radix primitive, disabled state |
| **Select** | — | default, sm | Portal-based, 10 subcomponents |
| **Skeleton** | — | — | `bg-accent` + `animate-pulse` |
| **Sonner** | — | — | Toast notifications, auto dark mode |
| **StarRating** | — | sm, md, lg | 0-5 stars, half-star support |
| **Table** | — | — | 7 subcomponents, horizontal scroll |
| **Tabs** | default (pill), line (underline) | — | Horizontal/vertical orientation |

### 2.2 Custom Component Inventory (42 components)

#### Layout (4)

| Component | File | Description |
|-----------|------|-------------|
| Header | `components/layout/header.tsx` | Public nav: logo + login/register or UserMenu |
| Sidebar | `components/layout/sidebar.tsx` | Dashboard nav: role-based links, w-64 |
| TopBar | `components/layout/top-bar.tsx` | Dashboard header: title + UserMenu, h-16 |
| Footer | `components/layout/footer.tsx` | Copyright + legal links |

#### Admin (11)

| Component | Description |
|-----------|-------------|
| AdminRoleIndicator | Role badge with Shield icon |
| AlertBanner | Info/warning/critical notification bar |
| AlertFormDialog | Create/edit alert thresholds |
| ConfigChangeConfirmDialog | Confirmation for config changes |
| KpiCard | Metric card with trend arrows (up/down/neutral) |
| KpiCardSkeleton | Loading placeholder for KPI cards |
| AuditLogTable | Timestamped audit trail table |
| RoleAssignmentDialog | Assign user roles dialog |
| SeoTemplateFormDialog | SEO template editor |
| SeoPreview | Google SERP preview (title/description/URL) |
| TrendChart | Custom SVG line chart (600x240px) |

#### Auth (8)

| Component | Description |
|-----------|-------------|
| MsalProvider | Azure AD MSAL wrapper |
| RegistrationForm | Dynamic config-driven form + RGPD consent |
| ConsentStep | RGPD consent checkboxes |
| ConsentReviewDialog | Review pending consents modal |
| RoleGuard | Client-side RBAC redirect |
| SessionTimeoutWarning | 30 min timeout countdown dialog |
| AuthRequiredWrapper | HOC for protecting content |
| RegistrationWall | Registration prompt overlay |

#### Listing (19)

| Component | Description |
|-----------|-------------|
| ListingForm | Main vehicle form with sticky section nav |
| ListingFormField | Field with certified/declared/empty badges |
| PhotoGallery | Drag-reorderable grid (2→3→4 cols responsive) |
| PhotoUpload | File upload with compression |
| VisibilityScoreGauge | Animated SVG semicircular gauge |
| DraftCard | Draft listing card with progress bar |
| DraftSaveFooter | Sticky save/cancel footer |
| DeleteDraftDialog | Delete confirmation |
| OverrideConfirmDialog | Override certified value confirmation |
| AutoFillTrigger | Vehicle lookup button (Search + Loader2) |
| DeclarationForm | Declaration of honor checkboxes |
| DeclarationStatus | Status indicator (ShieldCheck/ShieldAlert) |
| DeclarationStep | Declaration section in multi-step flow |
| ScoreSuggestions | Tips to improve visibility score |
| CertifiedField | Green-highlighted certified display |
| SourceStatus | Data source badge |
| SellerHistorySection | Seller transaction history |
| ListingImage | Next.js Image optimized |
| HistoryReport | Vehicle history report (ownership, accidents, mileage) |

#### Profile (4)

| Component | Description |
|-----------|-------------|
| ProfileForm | Profile editor with avatar upload |
| AvatarUpload | Drag-and-drop avatar upload with preview |
| ProfileCompletionIndicator | SVG circular progress (80px) with tips |
| PublicSellerCard | Public seller profile card |

#### Settings (3) + Legal (1)

| Component | Description |
|-----------|-------------|
| AnonymizationSection | RGPD account anonymization form |
| AnonymizationConfirmationDialog | Type "ANONYMISER" confirmation |
| DataExportSection | GDPR data export section |
| LegalAcceptanceModal | Sequential legal document acceptance |

---

## 3. Patterns & Templates

### 3.1 Page Layouts

#### Public Layout
```
┌─────────────────────────────────────────┐
│ Header: Logo | [Login] [Register]       │
├─────────────────────────────────────────┤
│                                         │
│              Main Content               │
│           (flex-1, centered)            │
│                                         │
├─────────────────────────────────────────┤
│ Footer: © Auto | Legal | Privacy        │
└─────────────────────────────────────────┘
```

#### Dashboard Layout
```
┌──────────┬──────────────────────────────┐
│          │ TopBar: Title  |  UserMenu   │
│ Sidebar  ├──────────────────────────────┤
│ w-64     │                              │
│ (hidden  │     Main Content (p-6)       │
│  mobile) │     (overflow-y-auto)        │
│          │                              │
│ - Dashboard                             │
│ - Config*│                              │
│ - Alerts*│                              │
│ - Users* │                              │
│          │                              │
│ *admin   │                              │
└──────────┴──────────────────────────────┘
```

#### Auth Layout
```
┌─────────────────────────────────────────┐
│                                         │
│         ┌───────────────┐               │
│         │  Auth Form    │               │
│         │  max-w-md     │               │
│         │  centered     │               │
│         └───────────────┘               │
│                                         │
└─────────────────────────────────────────┘
```

### 3.2 Form Patterns

#### Pattern A: Config-Driven Dynamic Form (Registration)
1. Fetch field configuration from API
2. Build Zod schema dynamically from config
3. Render fields based on `isVisible`, `displayOrder`
4. Show required indicator from `isRequired`
5. Apply `validationPattern` regex
6. End with RGPD consent checkboxes

#### Pattern B: Sectioned Form with Live Score (Listing)
1. Sticky section navigation bar (category buttons)
2. Fields grouped by `FieldCategory` in 2-column grid (`sm:grid-cols-2`)
3. Each field shows status badge (certified / declared / empty)
4. Live visibility score gauge updates on field change
5. Override confirmation dialog for certified fields
6. Sticky save footer

#### Pattern C: Admin Table + Dialog CRUD
1. Table with inline status toggles
2. Edit/Create buttons open modal dialog
3. Form with react-hook-form + Zod validation
4. Reload table data after save
5. Destructive actions require confirmation dialog

#### Pattern D: Multi-Step Modal (Legal Acceptance)
1. Progress indicator (step X of Y)
2. Load document content dynamically
3. Require checkbox before proceeding
4. Final step triggers callback

### 3.3 State Patterns

#### Loading
```
Page loading    → Skeleton grid (Skeleton component)
Component load  → Loader2 spinner (animate-spin)
Table loading   → Loader2 centered in tbody
Button loading  → Loader2 replacing icon, disabled state
```

#### Empty States
```
Centered layout:
  - Icon (optional, muted-foreground)
  - Title text (font-medium)
  - Description (text-muted-foreground)
  - CTA Button (optional)
Example: "Aucun brouillon. Créez votre première annonce!"
```

#### Error States
```
Page error      → bg-destructive/10 alert box with message
Field error     → text-xs text-destructive below input
Toast error     → toast.error(message) via Sonner
API error       → Inline error + retry option
```

#### Success Feedback
```
Action success  → toast.success(message)
Field certified → Green checkmark badge
Save complete   → Button state change + toast
```

### 3.4 Navigation Patterns

#### Breadcrumb-less
The platform uses **sidebar + tabs** navigation, not breadcrumbs.

#### Admin Config Navigation
Tab bar at top of `/admin/config/*` routes with sub-sections:
`Pricing | Texts | Features | Registration | Card Display | Providers | Costs | Analytics`

#### Listing Form Section Navigation
Sticky horizontal category buttons:
`Identité du véhicule | Détails techniques | État et description | Tarification | Options et équipements`

---

## 4. Data Display Conventions

### 4.1 Status Badges

| Status | Color | Icon |
|--------|-------|------|
| Certified | `bg-certified` green | ShieldCheck |
| Declared | `bg-declared` amber | — |
| Empty | `bg-muted` gray | — |
| Published | green badge | — |
| Draft | gray badge | — |
| Pending review | amber badge | — |
| Rejected | red badge | — |
| Expired | muted badge | — |
| Sold | blue/success badge | — |

### 4.2 Alert Severity

| Severity | Color | Icon |
|----------|-------|------|
| Info | blue | Info |
| Warning | orange/amber | AlertTriangle |
| Critical | red/destructive | XCircle |

### 4.3 KPI Trend Indicators

| Trend | Color | Icon |
|-------|-------|------|
| Up (positive) | green | ArrowUp |
| Down (negative) | red | ArrowDown |
| Neutral | muted | Minus |

### 4.4 Visibility Score

| Range | Label | Color |
|-------|-------|-------|
| 0–34 | Partiellement documenté | Red |
| 35–66 | Bien documenté | Yellow/Amber |
| 67–100 | Très documenté | Green |

### 4.5 Market Price Position

| Position | Color Token | Meaning |
|----------|-------------|---------|
| Below market | `--market-below` green | Good deal |
| Aligned | `--market-aligned` amber | Fair price |
| Above market | `--market-above` red | Expensive |

### 4.6 Crit'Air Environmental Badges

| Level | Color |
|-------|-------|
| 0 | Green |
| 1 | Purple |
| 2 | Yellow |
| 3 | Orange |
| 4 | Dark red |
| 5 | Gray |
| Non-classé | Black |

---

## 5. Iconography

**Library**: Lucide React v0.563.0 (500+ icons)

### Frequently Used Icons

| Icon | Context |
|------|---------|
| `Loader2` | Loading spinners (with `animate-spin`) |
| `Plus` | Create/add actions |
| `Trash2` | Delete actions |
| `Pencil` | Edit actions |
| `Copy` | Duplicate actions |
| `Calendar` | Date display |
| `Camera` | Photo count |
| `Star` | Primary photo, ratings |
| `GripVertical` | Drag handles |
| `Settings` | Settings navigation |
| `User` | Profile |
| `LogOut` | Logout |
| `Shield` | Admin/security |
| `ShieldCheck` | Certified, declaration complete |
| `ShieldAlert` | Warning status |
| `AlertTriangle` | Warnings |
| `Info` | Info alerts |
| `XCircle` | Critical alerts, errors |
| `Check` | Success, completed |
| `CheckCircle2` | Completed state |
| `Search` | Vehicle lookup |
| `Wifi` / `WifiOff` | SignalR connection |
| `ArrowUp` / `ArrowDown` | KPI trends |
| `ChevronUp` / `ChevronDown` | Expandable sections |
| `Lightbulb` | Tips/suggestions |
| `Clock` | Session timeout |

### Icon Sizing Convention

| Context | Class | Size |
|---------|-------|------|
| Inline with text | `size-4` | 16px |
| Button icon | `size-4` | 16px |
| Standalone small | `size-5` | 20px |
| Loading spinner | `size-6` | 24px |
| Feature icon | `size-8` | 32px |

---

## 6. Accessibility

### Standards
- **WCAG 2.1 AA** compliance target
- All interactive components built on **Radix UI** primitives (WAI-ARIA compliant)

### Focus Management
- Visible focus ring: `focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]`
- Tab order follows DOM order
- Dialog traps focus, returns on close
- Dropdown keyboard navigation (arrow keys)

### Screen Reader Support
- `sr-only` class for visually hidden labels
- `aria-label` on icon-only buttons
- `aria-invalid` on form fields with errors
- `role="alert"` for error messages
- `role="status"` for loading states
- `role="progressbar"` with `aria-valuenow/min/max` for progress indicators
- `aria-hidden="true"` on decorative elements (star rating icons)

### Motion
- `useReducedMotion` hook respects `prefers-reduced-motion`
- All animations degrade gracefully (instant transitions)

### Color Contrast
- OKLCH color space ensures perceptually uniform contrast
- Light mode: dark text on light backgrounds
- Dark mode: light text on dark backgrounds
- Never rely on color alone — always pair with icons or text labels

---

## 7. Localization (French Market)

### Language
- All UI copy in **French** (fr-FR)
- Validation messages in French
- Admin labels in French

### Formatting

| Type | Format | Example |
|------|--------|---------|
| Date | `dd/MM/yyyy` | 24/02/2026 |
| Date-time | `toLocaleString("fr-FR")` | 24/02/2026 14:30 |
| Number | `toLocaleString("fr-FR")` | 1 234 567 |
| Currency | `{amount} €` | 15 000,00 € |
| Phone | `+33 X XX XX XX XX` | +33 6 12 34 56 78 |
| Postal code | 5 digits | 75001 |

### Key French UI Labels

| English | French |
|---------|--------|
| Registration plate | Plaque d'immatriculation |
| VIN number | Numéro VIN |
| Make | Marque |
| Model | Modèle |
| Year | Année |
| Fuel type | Carburant |
| Mileage | Kilométrage |
| Gearbox | Boîte de vitesses |
| Condition | État général |
| Price | Prix (€) |
| Description | Description |
| Options | Options et équipements |
| Listings | Annonces |
| Draft | Brouillon |
| Published | Publiée |
| Search | Rechercher |

---

## 8. Role-Based UI

### Role Hierarchy

| Role | Level | Access |
|------|-------|--------|
| Visitor | 0 | Public pages only |
| Buyer | 1 | + Contact sellers, save favorites |
| Seller | 2 | + Create/manage listings, drafts |
| Moderator | 3 | + Moderate content, review reports |
| Administrator | 4 | + Full config, users, alerts, audit, KPIs |

Super-role pattern: each level inherits all permissions from levels below.

### Conditional UI Elements

| Element | Visible to |
|---------|------------|
| Login/Register buttons | Visitors only |
| UserMenu | All authenticated |
| Sidebar config links | Administrator only |
| Listing "Create" button | Seller+ |
| Moderation panel | Moderator+ |
| KPI dashboard | Administrator |
| Audit trail | Administrator |

---

## 9. File Reference

| File | Purpose |
|------|---------|
| `auto-frontend/src/app/globals.css` | All design tokens (colors, radii, fonts) |
| `auto-frontend/components.json` | shadcn/ui configuration |
| `auto-frontend/src/app/layout.tsx` | Root layout, font loading, providers |
| `auto-frontend/src/components/ui/` | shadcn/ui component library (15 files) |
| `auto-frontend/src/components/` | Custom components (42 files) |
| `auto-frontend/src/hooks/` | Custom hooks (16 files) |
| `auto-frontend/src/stores/` | Zustand state stores |
| `auto-frontend/src/lib/utils.ts` | `cn()` utility function |
| `auto-shared/src/constants/` | All enums, labels, validation rules |
| `auto-shared/src/types/` | TypeScript interfaces |
| `auto-shared/src/validators/` | Zod validation schemas |
