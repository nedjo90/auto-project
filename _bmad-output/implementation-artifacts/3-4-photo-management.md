# Story 3.4: Photo Management

Status: review

## Story

As a seller,
I want to add, reorder, and manage photos for my listing,
so that buyers see high-quality images that showcase my vehicle.

## Acceptance Criteria (BDD)

**Given** a seller is on the listing form
**When** they access the photo section
**Then** they can upload photos via file picker (multi-select) or direct camera capture (PWA)
**And** maximum number of photos is configurable via `ConfigParameter` (e.g., MAX_PHOTOS = 20)

**Given** a seller selects photos
**When** the upload processes
**Then** photos are compressed client-side to reduce upload time
**And** uploaded to Azure Blob Storage in a listing-specific container
**And** served via Azure CDN with Next.js `<Image>` optimization (lazy loading, modern formats, responsive) (NFR7)
**And** a progress indicator shows upload status per photo

**Given** photos are uploaded
**When** the seller views the photo gallery
**Then** they can reorder photos via drag-and-drop
**And** the first photo is marked as the primary/hero photo for the listing card
**And** they can delete individual photos

**Given** the photo upload runs on mobile
**When** the seller uses the PWA
**Then** the camera API is available for direct capture
**And** touch targets are minimum 44x44px

## Tasks / Subtasks

### Task 1: Backend - Photo Storage Service (AC2) ✅
- [x] 1.1. Define CDS entity `ListingPhoto` with composition in `Listing`
- [x] 1.2. Implement `srv/lib/photo-storage.ts` with blob upload/delete/CDN URL construction
- [x] 1.3. Configure CDN base URL and blob container path pattern
- [x] 1.4. Implement photo deletion (single + cascade via `deleteAllPhotosForListing`)
- [x] 1.5. Read `MAX_PHOTOS` from `ConfigParameter` table and enforce limit
- [x] 1.6. Add shared types (`IListingPhoto`, `UploadPhotoResult`, `ReorderPhotosInput`) and constants
- [x] 1.7. Add photo Zod validators (`photoMimeTypeSchema`, `reorderPhotosInputSchema`)
- [x] 1.8. Write 51 unit tests (33 photo-storage + 12 schema + 6 listing-schema)

### Task 2: Backend - Photo Management Actions (AC1, AC3) ✅
- [x] 2.1. Create CAP action `uploadPhoto` with MIME/size/limit validation
- [x] 2.2. Create CAP action `reorderPhotos` with ownership verification
- [x] 2.3. Create CAP action `deletePhoto` with blob cleanup and gap reordering
- [x] 2.4. Register handlers in `seller-service.ts` init()
- [x] 2.5. Write 17 unit tests for all photo handlers

### Task 3: Frontend - Photo Upload Component (AC1, AC2, AC4) ✅
- [x] 3.1. Create `photo-upload.tsx` with file picker, camera capture, drop zone
- [x] 3.2. Implement client-side compression (`photo-compression.ts`) with EXIF stripping
- [x] 3.3. Create `use-photo-upload.ts` hook with progress tracking
- [x] 3.4. Create `photo-store.ts` Zustand store for photo state management
- [x] 3.5. Create `photo-api.ts` API client for backend integration
- [x] 3.6. Ensure all touch targets >= 44x44px (AC4)
- [x] 3.7. Write 25 tests (14 photo-upload + 11 photo-store)

### Task 4: Frontend - Photo Gallery with Drag-and-Drop (AC3) ✅
- [x] 4.1. Create `photo-gallery.tsx` with grid layout, primary badge, delete confirmation
- [x] 4.2. Implement drag-and-drop via HTML5 DnD API (no new dependency)
- [x] 4.3. Implement keyboard-accessible reordering (ArrowLeft/ArrowRight)
- [x] 4.4. WCAG: role=list/listitem, aria-labels, 44px touch targets, focus management
- [x] 4.5. Write 16 tests for gallery rendering, DnD, keyboard, accessibility, disabled state

### Task 5: Frontend - Image Optimization and CDN Delivery (AC2) ✅
- [x] 5.1. Configure `next.config.ts` with Azure CDN + Blob Storage remote patterns
- [x] 5.2. Create `listing-image.tsx` with thumbnail/medium/full responsive variants
- [x] 5.3. Write 8 tests for image component + CDN config verification

### Task 6: Integration Tests ✅
- [x] 6.1. Test full upload flow (compress → store blob → create record → CDN URL)
- [x] 6.2. Test reorder flow (3 photos → reorder → verify sortOrder/isPrimary)
- [x] 6.3. Test delete flow (remove blob → remove DB → reorder remaining)
- [x] 6.4. Test MAX_PHOTOS enforcement (default + custom ConfigParameter)
- [x] 6.5. Test file type validation (accept JPEG/PNG/WebP/HEIC, reject GIF)
- [x] 6.6. Test ownership validation (reject non-owner for upload/reorder/delete)
- [x] 6.7. Write 13 integration tests, all passing

## Dev Notes

### Architecture & Patterns
- Photos are stored in Azure Blob Storage organized by listing ID. Azure CDN provides edge caching for fast delivery.
- Client-side compression is critical for mobile users on slower connections. EXIF location data must be stripped for privacy.
- The drag-and-drop library must be accessible (keyboard-operable) per WCAG requirements. `@dnd-kit` is recommended as it has built-in accessibility features.
- Photo count contributes to the visibility score. Adding/removing photos triggers score recalculation (dependency on Story 3.5).
- The `isPrimary` flag on the first photo determines the hero image shown on listing cards in search results.

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
Claude Opus 4.6 (claude-opus-4-6)

### Completion Notes List
- Used HTML5 Drag and Drop API instead of @dnd-kit/core to avoid new dependency (HALT condition). Keyboard reordering via ArrowLeft/ArrowRight provides WCAG-compliant alternative.
- Client-side compression uses Canvas/OffscreenCanvas API (no external library). Progressive quality reduction from 0.85 to 0.3, targeting max 2MB.
- HEIC→JPEG conversion implemented in photo-compression.ts for cross-browser compatibility.
- CDS mock pattern: `__esModule: true` + `MockApplicationService` class + global CQL builders (SELECT/INSERT/UPDATE/DELETE) required for Jest tests.
- Photo count contributes to visibility score via `PHOTO_VISIBILITY_WEIGHT = 10`.

### Change Log
- **auto-shared**: Added `IListingPhoto`, `UploadPhotoResult`, `ReorderPhotosInput` types; `PHOTO_ALLOWED_MIME_TYPES`, `PHOTO_DEFAULT_MAX`, `PHOTO_DEFAULT_MAX_SIZE_BYTES`, `PHOTO_VISIBILITY_WEIGHT` constants; `photoMimeTypeSchema`, `reorderPhotosInputSchema` validators
- **auto-backend**: Added `ListingPhoto` CDS entity with composition in `Listing`; `photo-storage.ts` library; `uploadPhoto`/`reorderPhotos`/`deletePhoto` CAP actions + handlers; `ListingPhotos` projection in seller-service.cds
- **auto-frontend**: Added `photo-upload.tsx`, `photo-gallery.tsx`, `listing-image.tsx` components; `photo-store.ts` Zustand store; `photo-api.ts` API client; `photo-compression.ts` utility; `use-photo-upload.ts` hook; updated `next.config.ts` with CDN remote patterns

### File List

#### auto-shared
- `src/types/listing.ts` — Added IListingPhoto, PhotoMimeType, UploadPhotoResult, ReorderPhotosInput
- `src/types/index.ts` — Added photo type exports
- `src/constants/listing.ts` — Added PHOTO_ALLOWED_MIME_TYPES, PHOTO_DEFAULT_MAX, PHOTO_DEFAULT_MAX_SIZE_BYTES, PHOTO_VISIBILITY_WEIGHT
- `src/constants/index.ts` — Added photo constant exports
- `src/validators/photo.validator.ts` — NEW: Zod schemas for photo MIME types and reorder input
- `src/validators/index.ts` — Added photo validator exports

#### auto-backend
- `db/schema/listing.cds` — Added ListingPhoto entity + photos composition on Listing
- `srv/lib/photo-storage.ts` — NEW: Photo storage service (upload, delete, CDN URL, validation, limits)
- `srv/seller-service.cds` — Added uploadPhoto, reorderPhotos, deletePhoto actions + ListingPhotos projection
- `srv/seller-service.ts` — Added handleUploadPhoto, handleReorderPhotos, handleDeletePhoto handlers
- `test/srv/lib/photo-storage.test.ts` — NEW: 33 unit tests
- `test/srv/handlers/photo-handler.test.ts` — NEW: 17 unit tests
- `test/srv/handlers/photo-integration.test.ts` — NEW: 13 integration tests
- `test/db/listing-schema.test.ts` — Extended with 6 ListingPhoto tests

#### auto-frontend
- `src/components/listing/photo-upload.tsx` — NEW: File picker, camera capture, drop zone
- `src/components/listing/photo-gallery.tsx` — NEW: Grid gallery, DnD, keyboard reorder, delete confirmation
- `src/components/listing/listing-image.tsx` — NEW: Next.js Image wrapper with responsive variants
- `src/stores/photo-store.ts` — NEW: Zustand photo state store
- `src/lib/api/photo-api.ts` — NEW: Photo API client
- `src/lib/photo-compression.ts` — NEW: Client-side compression + EXIF stripping
- `src/hooks/use-photo-upload.ts` — NEW: Upload orchestration hook
- `next.config.ts` — Added Azure CDN + Blob Storage remote patterns
- `tests/components/listing/photo-upload.test.tsx` — NEW: 14 tests
- `tests/components/listing/photo-gallery.test.tsx` — NEW: 16 tests
- `tests/components/listing/listing-image.test.tsx` — NEW: 8 tests
- `tests/stores/photo-store.test.ts` — NEW: 11 tests

### Test Results
- **auto-shared**: 356 tests passing
- **auto-backend**: 772 tests passing
- **auto-frontend**: 715 tests passing
- **Total**: 1843 tests green (up from 1725 in Story 3-3)
