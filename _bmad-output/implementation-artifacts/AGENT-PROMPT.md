# BMAD Dev Agent - Autonomous Story Implementation Prompt

## REGLE ABSOLUE N°1

Tu es 100% AUTONOME. L'utilisateur n'est PAS devant l'ecran. Tu ne DOIS JAMAIS :
- Utiliser AskUserQuestion
- Poser une question dans le texte et attendre une reponse
- Demander confirmation avant d'agir
- Proposer des choix a l'utilisateur

Si tu as un doute, prends la decision toi-meme en te basant sur le fichier story, l'architecture, et le code existant. Si un outil echoue, essaie une autre approche. Si un test echoue, corrige et relance. Ne t'arrete jamais en attendant une reponse humaine.

## REGLE ABSOLUE N°2 - Zero erreur avant de continuer

A CHAQUE etape ou tu lances des tests :
- Si UN SEUL test echoue → corriger → relancer les tests
- Boucler jusqu'a 0 erreur, 0 failure
- Ne JAMAIS passer a l'etape suivante avec des tests rouges
- Ne JAMAIS commit avec des tests rouges
- Maximum 10 tentatives de correction par cycle de test. Si apres 10 tentatives il reste des erreurs, documenter le probleme dans le story file et passer a la suite.

## Mission

Tu implementes UNE SEULE story par session, en suivant le cycle ci-dessous, puis tu t'arretes.
Determine la story a implementer en lisant `sprint-status.yaml` : prends la PREMIERE story `ready-for-dev` dans l'ordre du fichier.

## Cycle complet par story

### Phase 1 - Preparation
1. Lire `_bmad-output/implementation-artifacts/sprint-status.yaml` pour identifier la story
2. Lire le fichier story `_bmad-output/implementation-artifacts/{story-id}.md`
3. Lire `~/.claude/projects/C--Users-nhan-projects-auto/memory/MEMORY.md`
4. Lire les fichiers existants pertinents pour comprendre les patterns en place
5. Mettre le status de la story a `in-progress`

### Phase 2 - Implementation
6. Implementer chaque task du story file dans l'ordre (task 1, task 2, etc.)
7. Pour chaque task :
   a. Coder le backend (CDS entities, handlers, middleware si necessaire)
   b. Coder le frontend (composants, pages, hooks, stores si necessaire)
   c. Coder les types shared si necessaire (types, validators, constants)
   d. Ecrire les tests unitaires correspondants
8. Apres CHAQUE task implementee, lancer les tests :
   ```
   cd auto-shared && npm run build && npx vitest run
   cd auto-backend && npx jest --no-cache
   cd auto-frontend && npx vitest run
   ```
9. Si des tests echouent → corriger → relancer → boucler jusqu'a 0 erreur
10. NE PAS commit apres chaque task (un seul commit a la fin de la phase)

### Phase 3 - Premier commit
11. Verifier une derniere fois que TOUS les tests passent dans les 3 repos
12. Commit + push chaque repo separement avec des messages Conventional Commits
13. Respecter les scopes autorises par commitlint de chaque repo
14. Ajouter les eslint-disable en haut des fichiers test si pre-commit hook echoue sur `no-explicit-any` dans les tests
15. Mettre le status de la story a `review`

### Phase 4 - Code Review Adversariale
16. Lancer 3 agents Task en parallele (subagent_type=general-purpose) :
    - Agent backend : review de tous les fichiers backend de cette story
    - Agent frontend : review de tous les fichiers frontend de cette story
    - Agent shared : review de tous les fichiers shared de cette story
17. Chaque agent doit chercher des bugs reels, failles de securite, problemes de logique
18. Compiler les findings : ne garder que HIGH et MEDIUM
19. Fixer TOUS les HIGH et MEDIUM trouves (pas de question, pas de choix, tout fixer)
20. Relancer les tests dans les 3 repos
21. Si des tests echouent → corriger → relancer → boucler jusqu'a 0 erreur
22. Commit + push les fixes de review dans chaque repo

### Phase 5 - Validation Finale
23. Lancer les tests une DERNIERE fois dans les 3 repos
24. Si des tests echouent → corriger → commit → push → retour a l'etape 23
25. Compter le nombre total de tests (shared + backend + frontend)
26. Mettre a jour :
    - Le fichier story (change log, file list, completion notes)
    - `sprint-status.yaml` (story reste en `review`)
    - `MEMORY.md` (mettre a jour le test count et le status de la story)
27. Commit + push le repo auto-project
28. Afficher le resume final en texte

## Ordre des stories (respecter imperativement)

Les stories en `done` ou `review` sont deja faites. Toujours prendre la PREMIERE `ready-for-dev` :

### Epic 1 - Auth & Comptes (finir d'abord)
1. **1-6-user-profile** - Profil utilisateur
2. **1-7-anonymization-export** - Anonymisation RGPD et export donnees

### Epic 2 - Configuration & Admin
3. **2-1-config-engine** - Moteur de configuration dynamique
4. **2-2-platform-config-ui** - Interface admin de configuration
5. **2-3-api-provider-management** - Gestion des fournisseurs API
6. **2-4-admin-dashboard-kpis** - Dashboard admin KPIs
7. **2-5-configurable-alerts** - Alertes configurables
8. **2-6-seo-templates** - Templates SEO
9. **2-7-legal-texts** - Textes legaux configurables
10. **2-8-audit-trail** - Piste d'audit complete

### Epic 3 - Annonces & Publication
11. **3-1-adapter-pattern** - Pattern adaptateur pour APIs externes
12. **3-2-vehicle-autofill** - Auto-remplissage vehicule
13. **3-3-listing-form-declared-fields** - Formulaire annonce
14. **3-4-photo-management** - Gestion des photos
15. **3-5-visibility-score** - Score de visibilite
16. **3-6-draft-management** - Gestion des brouillons
17. **3-7-declaration-of-honor** - Declaration sur l'honneur
18. **3-8-vehicle-history-report** - Rapport historique vehicule
19. **3-9-batch-publication-payment** - Publication par lot + paiement
20. **3-10-listing-lifecycle** - Cycle de vie des annonces
21. **3-11-api-resilience** - Resilience API

### Epic 4 - Marketplace & Recherche
22. **4-1-public-listing-cards** - Cartes d'annonces publiques
23. **4-2-multi-criteria-search** - Recherche multi-criteres
24. **4-3-certification-market-price-filters** - Filtres certification/prix
25. **4-4-favorites-watchlist** - Favoris et watchlist
26. **4-5-seo-pages-structured-data** - Pages SEO + donnees structurees

### Epic 5 - Communication
27. **5-1-realtime-chat** - Chat temps reel
28. **5-2-notifications-push** - Notifications push

### Epic 6 - Cockpit Vendeur
29. **6-1-seller-dashboard-kpis** - Dashboard vendeur KPIs
30. **6-2-market-price-positioning** - Positionnement prix marche
31. **6-3-market-watch** - Veille marche
32. **6-4-empty-state-onboarding** - Empty states et onboarding

### Epic 7 - Moderation
33. **7-1-abuse-reporting** - Signalement d'abus
34. **7-2-moderation-cockpit** - Cockpit moderateur
35. **7-3-moderation-actions** - Actions de moderation
36. **7-4-seller-history** - Historique vendeur

## Contexte technique

- **Repos** : `C:\Users\nhan\projects\auto\` contient auto-shared, auto-backend, auto-frontend, et auto-project (root)
- **auto-shared** : npm package @auto/shared, types + constants + Zod validators, Vitest
- **auto-backend** : SAP CAP 8 + TypeScript, cds-typer, Jest + ts-jest, SQLite dev
- **auto-frontend** : Next.js 16, React 19, App Router, shadcn/ui, Tailwind v4, Zustand, Vitest
- **Commits** : Conventional Commits enforces par commitlint + husky
- **Bash** : Git Bash sur Windows, utiliser `/c/Users/...` pas `C:\Users\...`
- **Toujours push** apres chaque commit
- **Test counts actuels** : 85 shared + 154 backend + 168 frontend = 407 total
- **Stories 1-1 a 1-5** : done/review, ne pas toucher

## Resolution de problemes courants

### Pre-commit hook echoue sur ESLint `no-explicit-any` dans les tests
→ Ajouter `/* eslint-disable @typescript-eslint/no-explicit-any */` en premiere ligne du fichier test

### Commitlint scope invalide
→ Verifier les scopes autorises dans `.commitlintrc.json` de chaque repo. Scopes courants :
  - auto-backend : auth, user, listing, consent, config, messaging, moderation, db, api, middleware, deps
  - auto-frontend : auth, user, listing, consent, config, messaging, moderation, ui, deps
  - auto-shared : types, constants, validators, utils, config, deps

### `npm run build` echoue dans auto-shared
→ Corriger les erreurs TypeScript avant de lancer les tests backend/frontend

### Test "found multiple elements" dans React Testing Library
→ Utiliser `getByRole("button", { name: /texte/i })` au lieu de `getByText(/texte/i)`

### CDS mock patterns pour tests backend
→ Regarder les tests existants dans `test/srv/handlers/` pour les patterns de mock CDS

## Comment lancer une session

```
Lis le fichier _bmad-output/implementation-artifacts/AGENT-PROMPT.md et execute les instructions. Travaille de maniere 100% autonome sans poser aucune question. L'utilisateur n'est pas disponible.
```
