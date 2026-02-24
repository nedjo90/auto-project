# Responsive Design Standards — Auto Platform

**Status**: BINDING — All current and future development MUST comply
**Created**: 2026-02-24
**Enforced by**: AC-RESPONSIVE gate on every story

---

## 1. Device Classes

The platform targets **3 device classes**, each with distinct interaction models:

| Class | Breakpoint | Input Model | Primary Context |
|-------|-----------|-------------|-----------------|
| **Mobile** | `< 640px` (default) | Touch, single-hand | On-the-go browsing, quick actions |
| **Tablet** | `sm: (640px)` to `lg: (1023px)` | Touch + pointer hybrid | Comfortable browsing, form filling |
| **Desktop** | `lg: (1024px+)` | Pointer + keyboard | Full admin, power features |

Tailwind breakpoints: `sm:` (640px), `md:` (768px), `lg:` (1024px), `xl:` (1280px), `2xl:` (1536px)

**Design approach**: Mobile-first. Base styles = mobile. Layer up with `sm:`, `md:`, `lg:`.

---

## 2. Component Adaptation Rules

Components MUST **transform** per device class — not just shrink/grow.

### 2.1 Navigation

| Component | Mobile (< md) | Tablet (md–lg) | Desktop (lg+) |
|-----------|--------------|-----------------|----------------|
| Dashboard nav | Hamburger icon → Sheet overlay with full nav | Same as mobile OR sidebar | Fixed sidebar (w-64) |
| Public header nav | Hamburger icon → Sheet overlay | Inline horizontal nav | Inline horizontal nav |
| Dashboard actions | Bottom action bar (sticky) | Contextual buttons | Contextual buttons |
| Breadcrumbs | Collapsed (show last 2 levels) | Full path | Full path |

### 2.2 Data Display

| Component | Mobile (< md) | Tablet (md–lg) | Desktop (lg+) |
|-----------|--------------|-----------------|----------------|
| Data tables | Card list (stacked) | Card list or compact table | Full table with columns |
| KPI cards | 1 column, full-width | 2 columns grid | 3–6 columns grid |
| Lists | Full-width stacked | 2-column grid | 3-column grid or table |
| Charts | Full-width, simplified | Full-width, standard | Side-by-side possible |

### 2.3 Forms

| Component | Mobile (< md) | Tablet (md–lg) | Desktop (lg+) |
|-----------|--------------|-----------------|----------------|
| Form layout | Single column, full-width inputs | 2-column grid where logical | 2–3 column grid |
| Form actions | Sticky bottom bar | Sticky bottom bar or inline | Inline at form end |
| Multi-step forms | Full-screen steps | Card-based steps | Card-based steps |

### 2.4 Dialogs & Overlays

| Component | Mobile (< md) | Desktop (md+) |
|-----------|--------------|----------------|
| Confirmation dialogs | Bottom Sheet (slides up) | Centered Dialog |
| Form dialogs | Full-screen Sheet | Centered Dialog (max-w-lg) |
| Menus | Full-width bottom sheet | Dropdown positioned |
| Toasts | Full-width bottom | Bottom-right corner |

### 2.5 Media

| Component | Mobile | Tablet | Desktop |
|-----------|--------|--------|---------|
| Image galleries | Swipe carousel | Grid 2-col | Grid 3–4 col |
| Photo upload | Camera + gallery picker | Drag & drop + picker | Drag & drop zone |
| Thumbnails | 3 across | 4 across | 5–6 across |

---

## 3. Touch Targets

- **Minimum touch target**: 44x44px on mobile (per WCAG 2.5.8)
- **Recommended**: 48x48px for primary actions
- **Spacing between targets**: minimum 8px gap
- **Button sizing**:
  - Mobile: `h-11` (44px) minimum, full-width for primary actions
  - Desktop: `h-9` (36px) or `h-10` (40px), auto-width

---

## 4. Typography Scale

Responsive typography using Tailwind classes:

| Element | Mobile | Tablet (sm:) | Desktop (lg:) |
|---------|--------|-------------|---------------|
| Page title (h1) | `text-xl font-bold` | `sm:text-2xl` | `lg:text-3xl` |
| Section title (h2) | `text-lg font-semibold` | `sm:text-xl` | `lg:text-2xl` |
| Subsection (h3) | `text-base font-semibold` | `sm:text-lg` | — |
| Body text | `text-sm` | — | `lg:text-base` |
| Caption/helper | `text-xs` | — | — |
| Button text | `text-sm` | — | — |

---

## 5. Spacing Scale

| Context | Mobile | Tablet (sm:) | Desktop (lg:) |
|---------|--------|-------------|---------------|
| Page padding | `p-4` | `sm:p-6` | `lg:p-8` |
| Card padding | `p-4` | `sm:p-6` | — |
| Section gap | `space-y-4` | `sm:space-y-6` | `lg:space-y-8` |
| Grid gap | `gap-3` | `sm:gap-4` | `lg:gap-6` |
| Inline gap | `gap-2` | `sm:gap-3` | `lg:gap-4` |

---

## 6. Responsive Infrastructure (Shared Components)

These MUST be used instead of raw primitives:

| Component | Location | Purpose |
|-----------|----------|---------|
| `useBreakpoint()` | `hooks/use-breakpoint.ts` | Programmatic breakpoint detection |
| `useIsMobile()` | `hooks/use-mobile.ts` | Quick mobile check (< md) |
| `ResponsiveDialog` | `components/ui/responsive-dialog.tsx` | Dialog on desktop, Sheet on mobile |
| `MobileNav` | `components/layout/mobile-nav.tsx` | Hamburger + Sheet nav for mobile |

### Usage Rules:
- **NEVER** use `<Dialog>` directly for user-facing modals → use `<ResponsiveDialog>`
- **NEVER** hide navigation without providing a mobile alternative
- **ALWAYS** use `useBreakpoint()` when component behavior (not just layout) must change per screen

---

## 7. Mandatory Grid Patterns

### Standard responsive grid:
```tsx
// Cards / tiles
className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3"

// KPI / metric cards
className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"

// Settings / config sections
className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3"
```

### Content with sidebar:
```tsx
// Mobile: stacked, Desktop: sidebar + content
className="flex flex-col lg:flex-row lg:gap-8"
```

---

## 8. AC-RESPONSIVE Gate

Every story acceptance criteria MUST include:

```markdown
### Responsive Validation
- [ ] **Mobile (375px)**: All content accessible, touch-friendly (44px targets),
      adapted layout (single column, bottom sheets, card lists)
- [ ] **Tablet (768px)**: Hybrid layout works, no horizontal overflow
- [ ] **Desktop (1280px)**: Full layout, all features accessible
- [ ] Uses `ResponsiveDialog` instead of raw `Dialog` for all modals
- [ ] Uses responsive typography scale (text-xl sm:text-2xl lg:text-3xl)
- [ ] Uses responsive spacing (p-4 sm:p-6 lg:p-8)
- [ ] Navigation accessible at all breakpoints
```

**No story passes code review without this checklist completed.**

---

## 9. Anti-Patterns (FORBIDDEN)

- `hidden md:block` without a mobile alternative
- Fixed-width containers that overflow on mobile
- Tables without a card-list mobile alternative
- Dialog/Modal without Sheet fallback on mobile
- Text sizes that don't scale (`text-2xl` without responsive variants)
- Touch targets smaller than 44px
- Horizontal scroll as the only way to access content
- Hover-only interactions without touch alternatives
