# Story 3.4: Photo Management

**Epic:** 3 - Création d'Annonces Certifiées, Publication & Paiement
**FRs:** FR4
**NFRs:** NFR7 (image optimization & CDN)

## User Story

As a seller,
I want to add, reorder, and manage photos for my listing,
So that buyers see high-quality images that showcase my vehicle.

## Acceptance Criteria

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
