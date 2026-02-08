# Story 3.5: Real-Time Visibility Score

Status: ready-for-dev

## Story

As a seller,
I want to see a visibility score that updates in real time as I fill in my listing,
so that I'm motivated to provide more data and understand how it affects my listing's visibility.

## Acceptance Criteria (BDD)

**Given** a seller is creating or editing a listing
**When** they modify any field (add data, upload photo, complete a section)
**Then** the visibility score recalculates and the UI updates within 500ms (NFR3) (FR9)
**And** the score is displayed as an animated gauge (spring 500ms animation)
**And** a qualitative label is shown based on configurable thresholds: "Tres documente" / "Bien documente" / "Partiellement documente"

**Given** a vehicle is more than 15 years old
**When** the score is calculated
**Then** the score is normalized by vehicle category/age with a contextual message: "Bon score pour un vehicule de [year]"
**And** the normalization thresholds are configurable admin via `ConfigBoostFactor`

**Given** the score is displayed
**When** the seller views improvement tips
**Then** positive suggestions are shown: "Ajoutez le CT pour gagner en visibilite" (never punitive)
**And** each suggestion indicates the approximate score boost

**Given** a user has `prefers-reduced-motion`
**When** the score updates
**Then** the gauge updates without animation

## Tasks / Subtasks

### Task 1: Backend - Visibility Score Calculation Engine (AC1, AC2)
1.1. Implement `srv/lib/visibility-score.ts` with a `calculateVisibilityScore(listing)` function:
  - Input: full listing data (certified fields, declared fields, photo count, history report presence)
  - Output: `{ score: number (0-100), label: string, suggestions: Suggestion[], normalizedScore?: number, normalizationMessage?: string }`
1.2. Define scoring weights in `ConfigBoostFactor` CDS entity: fieldName, weight, boostCategory
  - Example weights: certifiedField = 5pts each, declaredField = 2pts each, photo = 3pts each (up to max), historyReport = 10pts, description length bonus = 5pts
  - All weights configurable admin, not hardcoded
1.3. Read scoring weights from `ConfigBoostFactor` table at calculation time (cache locally with short TTL for performance)
1.4. Implement vehicle age normalization (AC2):
  - If vehicle > 15 years old, apply age-based normalization factor from `ConfigBoostFactor`
  - Adjust score ceiling and thresholds proportionally
  - Generate contextual message: "Bon score pour un vehicule de [year]"
1.5. Implement suggestion engine:
  - Compare current listing data against all scoreable fields
  - For each missing field, calculate potential score boost
  - Return sorted suggestions (highest boost first) with positive messaging
  - Example: `{ field: "controle_technique", message: "Ajoutez le CT pour gagner en visibilite", boost: 8 }`
1.6. Write comprehensive unit tests: empty listing = 0, fully filled = 100, partial scenarios, age normalization, suggestion accuracy

### Task 2: Backend - Score Persistence and Update Action (AC1)
2.1. Add `visibilityScore` and `visibilityLabel` fields to the `Listing` CDS entity
2.2. Create CAP action `recalculateScore(listingId)`:
  - Loads listing with all related data (certified fields, photos, etc.)
  - Calls `calculateVisibilityScore()`
  - Updates Listing entity with new score and label
  - Returns full score result including suggestions
2.3. Integrate score recalculation into all listing modification flows:
  - After auto-fill (Story 3.2)
  - After field update (Story 3.3)
  - After photo upload/delete (Story 3.4)
2.4. Ensure the entire recalculation path completes in < 500ms (NFR3)

### Task 3: Backend - SignalR Live Score Hub (AC1)
3.1. Set up SignalR hub at `/live-score` endpoint for real-time score push
3.2. When a score is recalculated, broadcast to the seller's active session:
  - `{ score, label, suggestions, normalizedScore?, normalizationMessage? }`
3.3. Implement connection management: associate SignalR connection with seller session and listing ID
3.4. Write integration test for SignalR score broadcast

### Task 4: Frontend - Visibility Score Gauge Component (AC1, AC4)
4.1. Create `src/components/listing/visibility-score.tsx`:
  - Animated circular or semicircular gauge displaying score 0-100
  - Spring animation (500ms duration) when score changes
  - Color gradient: red (0-33) -> yellow (34-66) -> green (67-100)
4.2. Display qualitative label below gauge based on configurable thresholds:
  - "Partiellement documente" (0-33)
  - "Bien documente" (34-66)
  - "Tres documente" (67-100)
  - Thresholds loaded from backend configuration
4.3. Implement `prefers-reduced-motion` check (AC4):
  - If enabled, update gauge value instantly without spring animation
  - Use `window.matchMedia('(prefers-reduced-motion: reduce)')` or CSS `@media`
4.4. Display age normalization message when applicable (AC2): "Bon score pour un vehicule de [year]"
4.5. Make gauge component sticky (fixed position on scroll) so it is always visible while editing
4.6. Write unit tests for gauge rendering, animation toggle, and label thresholds

### Task 5: Frontend - Improvement Suggestions Panel (AC3)
5.1. Create `src/components/listing/score-suggestions.tsx`:
  - List of positive suggestions below the gauge
  - Each suggestion shows: icon, message text, approximate boost ("+8 pts")
  - Suggestions are ordered by highest boost first
5.2. Clicking a suggestion scrolls to the relevant form section/field
5.3. Ensure suggestions update in real-time as fields are filled (suggestion disappears when field is completed)
5.4. Tone must be positive/encouraging, never punitive (AC3)
5.5. Write unit tests for suggestion rendering, ordering, and removal on field completion

### Task 6: Frontend - SignalR Integration (AC1)
6.1. Create `src/hooks/useVisibilityScore.ts` custom hook:
  - Establishes SignalR connection to `/live-score` hub
  - Receives real-time score updates
  - Falls back to polling if SignalR connection fails
  - Manages score state (current score, previous score for animation delta)
6.2. Integrate hook into listing form page, connecting to gauge and suggestions components
6.3. Write unit tests for hook with mocked SignalR connection

### Task 7: Integration Tests
7.1. End-to-end: fill fields progressively -> verify score increases at each step -> verify < 500ms update time
7.2. Test age normalization: create listing for 20-year-old vehicle -> verify normalized score and message
7.3. Test suggestion accuracy: verify suggestions match missing fields and disappear when filled
7.4. Test SignalR real-time push: open two sessions for same listing -> verify both receive score updates
7.5. Test reduced-motion: enable preference -> verify no animation on gauge update

## Dev Notes

### Architecture & Patterns
- The visibility score is a core gamification/motivation element. It must feel instant (< 500ms) to maintain seller engagement.
- The scoring engine is a pure function in `srv/lib/visibility-score.ts` with no external dependencies, ensuring fast execution. Weights are read from `ConfigBoostFactor` (cached in-memory).
- SignalR provides push-based updates so the frontend does not need to poll. The `/live-score` hub broadcasts score changes scoped to a seller's session and listing.
- Age normalization ensures that older vehicles (with inherently less available data) are not penalized unfairly. The normalization factors are admin-configurable.
- Suggestions must always be positive in tone. The UX principle is "encourage more data" not "punish missing data."

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
