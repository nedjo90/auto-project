# Story 2.6: SEO Templates Management

**Epic:** 2 - Configuration Zero-Hardcode & Administration
**FRs:** FR51
**NFRs:** —

## User Story

As an administrator,
I want to manage SEO templates (meta title, meta description) per page type,
So that I can optimize organic search acquisition without developer intervention.

## Acceptance Criteria

**Given** an admin accesses the SEO configuration page (FR51)
**When** they view the SEO templates
**Then** templates are listed by page type: listing detail, search results, brand page, model page, city page, landing page
**And** each template supports dynamic placeholders (e.g., `{{brand}}`, `{{model}}`, `{{city}}`, `{{price}}`)

**Given** an admin modifies a SEO template
**When** they save the change
**Then** a preview shows the rendered meta title and description with sample data
**And** all affected SSR pages use the updated template on next render

**Given** the system generates pages
**When** a public page is rendered (SSR)
**Then** the meta tags are populated from the `ConfigSeoTemplate` table via config cache
**And** Schema.org structured data (Vehicle, Product, Offer) is generated
