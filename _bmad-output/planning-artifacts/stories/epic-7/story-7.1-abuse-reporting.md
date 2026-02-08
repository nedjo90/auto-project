# Story 7.1: Abuse Reporting System

**Epic:** 7 - Modération & Qualité du Contenu
**FRs:** FR37
**NFRs:** —

## User Story

As a user,
I want to report a listing or abusive behavior with specific categorization,
So that the platform maintains quality and trust through community-driven moderation.

## Acceptance Criteria

**Given** a user views a listing or interacts with another user
**When** they click "Signaler" (FR37)
**Then** a reporting dialog opens with: report type categories (from `ConfigReportReason` table), severity indicator, free-text description field
**And** report categories are configurable admin (zero-hardcode)

**Given** a user submits a report
**When** the report is processed
**Then** a `Report` CDS record is created with: reporter ID, target type (listing/user/chat), target ID, reason category, severity, description, timestamp, status (`Pending`)
**And** the reporter receives confirmation: "Votre signalement a été enregistré"
**And** the report appears in the moderation queue
