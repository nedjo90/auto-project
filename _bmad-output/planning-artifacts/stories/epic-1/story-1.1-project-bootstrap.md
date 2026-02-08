# Story 1.1: Project Bootstrap & Design System Foundation

**Epic:** 1 - Authentification & Gestion des Comptes
**FRs:** —
**NFRs:** NFR1 (performance foundation), NFR22-27 (accessibility foundation)

## User Story

As a developer,
I want the 3 repositories (auto-backend, auto-frontend, auto-shared) initialized with proper tooling, shared types package published to Azure Artifacts, design system tokens configured, and basic layouts (public SSR + dashboard SPA) in place,
So that the team can build features on a consistent, well-architected foundation.

## Acceptance Criteria

**Given** no project repositories exist
**When** the developer runs the initialization commands (`cds init`, `create-next-app`, `npm init @auto/shared`)
**Then** 3 Git repos are created with the directory structures defined in the Architecture document
**And** `auto-shared` is published to Azure Artifacts as `@auto/shared` and consumable by both repos

**Given** the frontend repo is initialized
**When** the developer opens the project
**Then** design system tokens are defined in `globals.css` (certified, declared, primary, background, foreground, muted, destructive, success, market-below/aligned/above colors in HSL format)
**And** Inter, Lora, and JetBrains Mono fonts are configured via `next/font`
**And** shadcn/ui is installed with base components (Button, Input, Card, Badge, Dialog, Select, Table, Tabs, Toast)
**And** two route group layouts exist: `(public)/layout.tsx` (SSR, header+footer) and `(dashboard)/layout.tsx` (SPA, sidebar)
**And** `(auth)/layout.tsx` exists for authentication pages

**Given** the backend repo is initialized
**When** the developer runs `cds watch`
**Then** the CAP server starts with TypeScript support and `cds-typer` generates types
**And** SQLite is used for local development

**Given** all repos are initialized
**When** the developer checks the tooling
**Then** ESLint, Prettier, and TypeScript strict mode are configured in all 3 repos
**And** basic Azure DevOps pipeline YAML files exist (lint → type-check → build)
