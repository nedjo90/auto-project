# Story 3.4: Photo Management

Status: ready-for-dev

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

### Task 1: Backend - Photo Storage Service (AC2)
1.1. Define CDS entity `ListingPhoto`: id, listingId, blobUrl, cdnUrl, sortOrder, isPrimary, fileSize, mimeType, width, height, uploadedAt
1.2. Implement Azure Blob Storage integration in `srv/lib/photo-storage.ts`:
  - Create listing-specific blob container path: `listings/{listingId}/photos/`
  - Generate unique blob names with UUID + original extension
  - Upload blob with proper content-type headers
  - Return blob URL and CDN URL after successful upload
1.3. Configure Azure CDN endpoint for the blob storage container
1.4. Implement photo deletion from Blob Storage (cascade on listing delete)
1.5. Read `MAX_PHOTOS` from `ConfigParameter` table and enforce limit on upload

### Task 2: Backend - Photo Management Actions (AC1, AC3)
2.1. Create CAP action `uploadPhoto`:
  - Accept multipart file upload
  - Validate file type (JPEG, PNG, WebP, HEIC) and max file size (from ConfigParameter)
  - Call photo-storage.ts to upload to Azure Blob
  - Create `ListingPhoto` record with sortOrder = next available position
  - Trigger visibility score recalculation (photos contribute to score)
  - Return photo metadata including CDN URL
2.2. Create CAP action `reorderPhotos`:
  - Accept array of photo IDs in new order
  - Update `sortOrder` for each photo
  - Set `isPrimary = true` for sortOrder = 0 (first photo)
2.3. Create CAP action `deletePhoto`:
  - Remove blob from Azure Blob Storage
  - Delete `ListingPhoto` record
  - Reorder remaining photos to fill gap
  - Trigger visibility score recalculation
2.4. Write unit tests for all photo actions

### Task 3: Frontend - Photo Upload Component (AC1, AC2, AC4)
3.1. Create `src/components/listing/photo-upload.tsx`:
  - File picker with multi-select support (`accept="image/jpeg,image/png,image/webp,image/heic"`)
  - Camera capture button using `navigator.mediaDevices` / `input[capture="environment"]` for PWA
  - Display remaining upload slots: "{current}/{max} photos"
3.2. Implement client-side compression before upload:
  - Use browser Canvas API or a library (e.g., browser-image-compression)
  - Target: max 2MB per photo, maintain aspect ratio, strip EXIF location data (privacy)
  - HEIC to JPEG conversion for compatibility
3.3. Implement per-photo upload progress indicator:
  - Show thumbnail preview immediately (from local file)
  - Overlay progress bar during upload
  - Show success checkmark or error state on completion
3.4. Ensure all touch targets >= 44x44px for mobile (AC4)
3.5. Write unit tests for compression, upload state management, and mobile touch targets

### Task 4: Frontend - Photo Gallery with Drag-and-Drop (AC3)
4.1. Create `src/components/listing/photo-gallery.tsx`:
  - Grid layout showing uploaded photo thumbnails
  - First photo highlighted with "Photo principale" badge
  - Delete button on each photo (with confirmation)
4.2. Implement drag-and-drop reordering:
  - Use `@dnd-kit/core` or similar accessible drag-and-drop library
  - On reorder, call backend `reorderPhotos` action
  - Optimistic UI update (reorder locally, sync with backend)
4.3. Implement keyboard-accessible reordering (arrow keys to move photo position) for WCAG compliance
4.4. Write unit tests for gallery rendering, drag-and-drop, and keyboard reordering

### Task 5: Frontend - Image Optimization and CDN Delivery (AC2)
5.1. Configure Next.js `<Image>` component for Azure CDN:
  - Add Azure CDN domain to `next.config.js` image domains
  - Use `<Image>` with responsive `sizes` attribute and `loading="lazy"`
  - Enable automatic format negotiation (WebP/AVIF where supported)
5.2. Implement responsive image sizes for listing card (thumbnail), listing detail (full), and gallery (medium)
5.3. Write integration test verifying CDN URLs are correctly constructed and served

### Task 6: Integration Tests
6.1. Test full upload flow: select file -> compress -> upload -> verify blob in storage -> verify CDN URL works
6.2. Test reorder flow: upload multiple photos -> reorder -> verify sortOrder and isPrimary updates
6.3. Test delete flow: delete photo -> verify blob removed from storage -> verify record removed from DB
6.4. Test max photo limit enforcement
6.5. Test mobile camera capture path (manual/device testing)

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
### Completion Notes List
### Change Log
### File List
