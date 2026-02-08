# Auto Platform

Marketplace française de véhicules d'occasion avec **certification au niveau du champ** : chaque donnée d'une annonce est marquée 🟢 Certifié (source API officielle) ou 🟡 Déclaré (saisie vendeur).

**15 EUR/annonce tout inclus** — rapport historique véhicule inclus, 2x moins cher que la concurrence.

## Architecture

Le projet est organisé en **multi-repo** : chaque composant a son propre dépôt Git.

| Repo | Description | Stack |
|------|-------------|-------|
| [`auto-frontend`](https://github.com/nedjo90/auto-frontend) | Application web (SSR + SPA) | Next.js 16, React 19, Tailwind CSS v4, shadcn/ui, Zustand |
| [`auto-backend`](https://github.com/nedjo90/auto-backend) | API & logique métier | SAP CAP 8, TypeScript, PostgreSQL, Azure AD B2C |
| [`auto-shared`](https://github.com/nedjo90/auto-shared) | Types, constantes, validateurs partagés | TypeScript, Zod v4 |

```
auto-project/          ← ce repo (orchestration, docs, BMAD)
├── auto-frontend/     → github.com/nedjo90/auto-frontend
├── auto-backend/      → github.com/nedjo90/auto-backend
├── auto-shared/       → github.com/nedjo90/auto-shared
└── _bmad-output/      → artefacts de planification (PRD, architecture, epics)
```

`auto-frontend` et `auto-backend` dépendent de `@auto/shared` via `file:../auto-shared`.

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Frontend | Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS v4, shadcn/ui, Zustand |
| Backend | SAP CAP 8, Node.js, TypeScript, cds-typer |
| Base de données | SQLite (dev), PostgreSQL (prod) |
| Auth | Azure AD B2C, MSAL |
| Shared | TypeScript, Zod v4 |
| Tests | Vitest (frontend, shared), Jest + ts-jest (backend) |
| CI/CD | Azure Pipelines |

## Mise en route

### Prérequis

- Node.js >= 20
- npm >= 10
- Git

### Installation

```bash
# Cloner les 4 repos
git clone https://github.com/nedjo90/auto-project.git auto
cd auto
git clone https://github.com/nedjo90/auto-shared.git
git clone https://github.com/nedjo90/auto-backend.git
git clone https://github.com/nedjo90/auto-frontend.git

# Installer les dépendances (shared en premier)
cd auto-shared && npm install && npm run build && cd ..
cd auto-backend && npm install && cd ..
cd auto-frontend && npm install && cd ..
```

### Lancer en développement

```bash
# Terminal 1 — Backend
cd auto-backend && npm run watch

# Terminal 2 — Frontend
cd auto-frontend && npm run dev
```

### Tests

```bash
cd auto-shared && npm test      # Vitest
cd auto-backend && npm test     # Jest
cd auto-frontend && npm test    # Vitest
```

## Convention de commits

Tous les repos utilisent [Conventional Commits](https://www.conventionalcommits.org/) avec enforcement automatique via **commitlint** + **husky**.

### Format

```
type(scope): description
```

### Types autorisés

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `docs` | Documentation |
| `style` | Formatage (pas de changement de logique) |
| `refactor` | Refactoring (ni feat ni fix) |
| `perf` | Amélioration de performance |
| `test` | Ajout ou modification de tests |
| `build` | Système de build ou dépendances externes |
| `ci` | CI/CD |
| `chore` | Tâches de maintenance |
| `revert` | Revert d'un commit précédent |

### Scopes par repo

**auto-frontend** : `auth`, `user`, `listing`, `consent`, `config`, `messaging`, `moderation`, `ui`, `layout`, `store`, `hooks`, `deps`, `release`

**auto-backend** : `auth`, `user`, `listing`, `consent`, `config`, `messaging`, `moderation`, `db`, `api`, `middleware`, `deps`, `release`

**auto-shared** : `types`, `constants`, `validators`, `utils`, `config`, `deps`, `release`

**auto-project** (root) : `bmad`, `docs`, `ci`, `config`, `deps`

### Hooks Git

Chaque repo est configuré avec :
- **pre-commit** : `lint-staged` — ESLint + Prettier sur les fichiers modifiés (repos de code)
- **commit-msg** : `commitlint` — validation du format du message de commit

### Exemples

```bash
# Bon
git commit -m "feat(auth): add Azure AD B2C login flow"
git commit -m "fix(listing): correct price validation for zero values"
git commit -m "docs(bmad): update sprint status after story 1-3"

# Rejeté
git commit -m "fixed stuff"           # pas de type ni scope
git commit -m "feat: Add New Feature" # PascalCase interdit dans le subject
```

## Licence

UNLICENSED — Projet privé.
