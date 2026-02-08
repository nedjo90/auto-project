---
stepsCompleted: [1, 2, 3, 4]
session_active: false
workflow_completed: true
inputDocuments: ['projectinit.txt']
session_topic: 'Car & Motorcycle Classifieds Platform - Transparency-First Marketplace'
session_goals: 'Explore gaps, trust mechanisms, competitive differentiation, growth strategies, edge cases, and monetization for a mandatory-disclosure vehicle classifieds platform'
selected_approach: 'progressive-flow'
techniques_used: ['What If Scenarios', 'Six Thinking Hats', 'SCAMPER Method', 'Chaos Engineering']
ideas_generated: [115]
context_file: '_bmad/bmm/data/project-context-template.md'
---

# Brainstorming Session Results

**Facilitator:** Nhan
**Date:** 2026-02-07

## Session Overview

**Topic:** Car & Motorcycle Classifieds Platform focused on transparency, trust, and mandatory disclosure — reducing hidden defects and overpriced listings.

**Goals:** Explore and expand the existing functional specification across gaps, trust score design, competitive positioning, technical architecture, growth strategies, edge cases, abuse prevention, and monetization expansion.

### Context Guidance

_Project context loaded from functional specification (projectinit.txt) covering: scope (cars/motorcycles, private/professional sellers), mandatory listing requirements, market price comparison, CarVertical integration (€4), buyer experience with trust score, business model (€15/listing), moderation system, and future roadmap (identity verification, ratings, insurance/financing)._

### Session Setup

_Approach: Progressive Technique Flow — Start broad with divergent thinking, then systematically narrow focus through increasingly targeted techniques. Ideal for a well-defined project that needs creative expansion and stress-testing._

## Technique Selection

**Approach:** Progressive Technique Flow
**Journey Design:** Systematic development from exploration to action

**Progressive Techniques:**

- **Phase 1 - Exploration:** What If Scenarios for maximum idea generation and assumption-shattering
- **Phase 2 - Pattern Recognition:** Six Thinking Hats for multi-perspective analysis and clustering
- **Phase 3 - Development:** SCAMPER Method for systematic refinement of top concepts
- **Phase 4 - Action Planning:** Chaos Engineering for stress-testing and anti-fragile implementation

**Journey Rationale:** The existing functional specification is well-defined, so we need techniques that push beyond the obvious — challenging assumptions first, then organizing insights, refining winners, and battle-testing before implementation.

## Phase 1 — What If Scenarios (Expansive Exploration)

**~93 idées générées à travers 17 territoires**

### Données & Transparence (9 idées)
- **[Transparence #1]** Auto-fill API État via immatriculation/VIN — fiche pré-remplie automatiquement
- **[Transparence #2]** Double couche de données : Certifié État 🟢 vs Complémentaire
- **[Transparence #3]** Badges certification au niveau du CHAMP (pas de l'annonce)
- **[Transparence #4]** Cycle Certifié → Modifié manuellement → Re-certifié via API
- **[Transparence #5]** Vendeur affiche optionnellement sa valeur + la valeur certifiée (bonne foi)
- **[Transparence #6]** Vendeur active optionnellement l'historique complet du véhicule
- **[Transparence #7]** 3 niveaux de transparence : minimum / enrichi / maximum
- **[Transparence #8]** Sources multiples : HistoVec, SIV, CT, CarVertical, VIN decode, Euro NCAP, Argus
- **[Transparence #9]** Trust score véhicule basé sur le taux de certification

### Résilience API (6 idées)
- **[Résilience #1]** Cache local BDD de toutes les données API — indépendance totale
- **[Résilience #2]** Job refresh planifié — fréquence configurable admin (min/h/j/sem/mois/CRON)
- **[Résilience #3]** Refresh à la consultation (acheteur ou vendeur visite la fiche)
- **[Résilience #4]** Délai minimum entre 2 refreshes configurable
- **[Résilience #5]** Mode dégradé : saisie manuelle si API down, sync auto au retour
- **[Résilience #6]** Job activable/désactivable (maîtrise des coûts API)

### Admin Dashboard (7 idées)
- **[Admin #1]** Filtres de recherche par défaut configurables
- **[Admin #2]** Prix annonce modifiable sans code
- **[Admin #3]** Règles de modération évolutives
- **[Admin #4]** APIs activables/désactivables individuellement
- **[Admin #5]** CGU/CGV éditables et versionnées (re-acceptation forcée si maj)
- **[Admin #6]** SEO configurable (templates meta, pages auto on/off)
- **[Admin #7]** Modules transactionnels activables (paiement, livraison, etc.)

### Boost de Visibilité (6 idées)
- **[Boost #1]** Système de poids pondérés par facteur
- **[Boost #2]** Facteurs dynamiques : admin CRÉE de nouveaux facteurs sans code
- **[Boost #3]** Facteurs liés à TOUTES les données vendeur + véhicule
- **[Boost #4]** Rule builder : conditions + poids combinables
- **[Boost #5]** Facteurs activables/désactivables individuellement
- **[Boost #6]** Score de visibilité temps réel pendant création annonce (gamification)

### Cockpit Pro (7 idées)
- **[Cockpit #1]** Dashboard vendeur : vues, contacts, vendus, CA, graphiques performance
- **[Cockpit #2]** Insights IA automatiques ("votre Kangoo stagne, ajustez -8%")
- **[Cockpit #3]** Dashboard acheteur : budget restant, économies, meilleures affaires
- **[Cockpit #4]** Alertes acheteur configurables (filtres sauvegardés + push/email)
- **[Cockpit #5]** Historique recherches et achats
- **[Cockpit #6]** Comparaison multi-véhicules côte à côte
- **[Cockpit #7]** KPIs rotation stock, taux conversion, positionnement prix marché

### Modération & Signalement (9 idées)
- **[Modération #1]** Signalement granulaire : véhicule spécifique OU vendeur
- **[Modération #2]** Impact signalement sur note vendeur (pondération configurable)
- **[Modération #3]** Désactivation auto compte après seuil configurable
- **[Modération #4]** Blocage annonce spécifique sans bloquer le compte
- **[Modération #5]** Pattern : X annonces bloquées → compte désactivé
- **[Modération #6]** Communication lissée : "En traitement" / "Traité" (jamais "rejeté")
- **[Modération #7]** Détection signalements abusifs côté admin uniquement
- **[Modération #8]** Admin : désactiver/réactiver, avertir, contacter manuellement
- **[Modération #9]** Seuils et impacts tous configurables dans l'admin

### Feature-gating & Monétisation (2 idées)
- **[Gating #1]** Architecture feature-gating dormante (toute feature peut devenir payante)
- **[Gating #2]** Switch Libre ↔ Payant ↔ Inclus abonnement dans l'admin

### Pricing & Fidélisation (6 idées)
- **[Pricing #1]** Packages hiérarchiques illimités (packages/sous-packages/sous-sous-packages)
- **[Pricing #2]** Offres globales (promotions, codes promo, limites quantité)
- **[Pricing #3]** Offres particulières par client (fidélisation personnalisée)
- **[Pricing #4]** Types d'offres : %, fixe, annonces offertes, upgrade, durée, boost, prix négocié
- **[Pricing #5]** Règles fidélisation auto (paliers volume, ancienneté, réactivation)
- **[Pricing #6]** Parrainage (parrain + filleul récompensés)

### Architecture Véhicule (4 idées)
- **[Archi #1]** Classe abstraite Véhicule → héritage (Voiture, Moto, Camionnette)
- **[Archi #2]** Champs spécifiques par type de véhicule
- **[Archi #3]** Types configurables admin (activer/désactiver/ajouter)
- **[Archi #4]** Coeur : voitures, motos, camionnettes — extensible tout immatriculé

### Parcours de Vente (7 idées)
- **[Vente #1]** Durée annonce configurable → impact prix
- **[Vente #2]** Marquage "Vendu" avec données vente optionnelles pour KPIs
- **[Vente #3]** Vie du véhicule sur la plateforme (données persistent après vente)
- **[Vente #4]** Transaction interne : revente facilitée avec données pré-chargées
- **[Vente #5]** Conversations survivent à la vente
- **[Vente #6]** Contrat de vente pré-rempli données certifiées (PDF)
- **[Vente #7]** Évaluation bilatérale : transaction + personne (acheteur ↔ vendeur)

### Messagerie (7 idées)
- **[Msg #1]** Chat fluide temps réel (socle)
- **[Msg #2]** Actions structurées dans le chat (prix, RDV, docs, confirmation vente)
- **[Msg #3]** Actions configurables admin (créer/modifier/supprimer/activer)
- **[Msg #4]** Conversations liées à un véhicule spécifique
- **[Msg #5]** Négociation prix tracée (offre/contre-offre)
- **[Msg #6]** Prise de RDV intégrée
- **[Msg #7]** Confirmation vente bilatérale → déclenche contrat pré-rempli

### Acquisition & Concurrence (7 idées)
- **[Acqui #1]** Stratégie client ancre (réseau + stock existant dès J1)
- **[Acqui #2]** Expansion : noyau pro → réseau → particuliers → croissance
- **[Acqui #3]** Cockpit pro comme outil de travail (pas juste des annonces)
- **[Acqui #4]** Effet réseau par la data véhicule (avantage cumulatif incopiable)
- **[Acqui #5]** 2x moins cher, 10x plus de valeur que la concurrence
- **[Acqui #6]** 3 min vs 20 min par annonce (temps gagné)
- **[Acqui #7]** Intelligence business vs chiffres basiques (La Centrale/LeBonCoin)

### SEO & Contenu (7 idées)
- **[SEO #1]** Longue traîne "transparence/certifié/vérifié" (terrain vierge)
- **[SEO #2]** Pages annonces riches (contenu unique = données certifiées)
- **[SEO #3]** Pages cote auto-générées par marque/modèle
- **[SEO #4]** Blog/guides éditoriaux (contenu confiance)
- **[SEO #5]** Pages géographiques auto-générées
- **[SEO #6]** Schema.org / données structurées véhicule
- **[SEO #7]** Templates SEO configurables admin

### Mobile (3 idées)
- **[Mobile #1]** PWA mobile-first au lancement
- **[Mobile #2]** Installable, push, caméra, géoloc, mode hors-ligne
- **[Mobile #3]** Porte ouverte vers app native en phase 2 (activable admin)

### Légal — noté pour plus tard (5 idées)
- **[Légal #1]** RGPD : consentement, suppression, portabilité, conservation
- **[Légal #2]** Responsabilité plateforme clarifiée dans CGU
- **[Légal #3]** Déclaration sur l'honneur horodatée et archivée
- **[Légal #4]** Architecture juridique multi-pays
- **[Légal #5]** Admin : CGU versionnées, cookies, mentions légales par pays

### Paiement en ligne — Phase ultérieure (1 idée)
- **[Paiement #1]** Séquestre, livraison, transfert carte grise, commission — porte ouverte dans l'architecture

## Phase 2 — Six Thinking Hats (Pattern Recognition)

### ⚪ Chapeau Blanc — Faits
- Client fondateur avec réseau et stock existant
- Utilise LeBonCoin + La Centrale, principal problème = prix
- APIs État existent (HistoVec, SIV)
- Zones d'ombre : coûts API réels, couverture données, budget dev, contraintes légales

### 🔴 Chapeau Rouge — Ressenti
- **Excite :** Double couche certifié/manuel, cockpit pro, vie du véhicule, prix 15€
- **Inquiète :** Dépendance APIs, complexité admin, volume critique, V1 trop ambitieuse
- **Impatient :** Voir le premier pro publier en 3 min, voir la confiance acheteur

### 🟡 Chapeau Jaune — Forces
1. Avantage incopiable : data certifiée État
2. Client ancre élimine le démarrage à froid
3. 15€ = arme tarifaire ET filtre qualité
4. Cockpit pro = lock-in positif (outil de travail)
5. Cercle vertueux transparence → confiance → ventes → vendeurs
6. Architecture tout configurable = agilité business

### ⚫ Chapeau Noir — Risques
1. V1 trop ambitieuse (93 idées pour un lancement)
2. Dépendance APIs État (changements, quotas, disponibilité)
3. Adoption au-delà du réseau fondateur
4. Complexité admin (back-office coûteux à développer)
5. Cadre légal non clarifié (responsabilité données certifiées)
6. Dépendance CarVertical (coûts, pérennité)

### 🟢 Chapeau Vert — Idées oubliées
- **[Green #1]** Onboarding vendeur pro (tutoriel première annonce)
- **[Green #2]** Multi-langue dès la base (i18n architecture V1)
- **[Green #3]** Import en masse véhicules (CSV/Excel → auto-fill par immatriculation)
- **[Green #4]** Statistiques marché publiques (tendances prix, SEO)
- **[Green #5]** API ouverte pour les pros (sync logiciel gestion stock)

### 🔵 Chapeau Bleu — Priorisation

**V1 Critique :**
- Auto-fill certifié API, double couche certifié/manuel
- Cockpit vendeur basique, chat simple, signalement/modération
- Admin (prix, filtres, on/off APIs), PWA, multi-langue architecture
- Cache local + mode dégradé, signature numérique N2

**V2 Rapide (1-3 mois) :**
- Cockpit acheteur + alertes, boost configurable, évaluations bilatérales
- Actions structurées messagerie, contrat pré-rempli, insights IA
- SEO pages auto, import en masse

**V3 Croissance (6+ mois) :**
- Packages/sous-packages pricing, offres personnalisées, fidélisation auto
- Feature-gating complet, rule builder boost avancé, blog/contenu
- Traductions effectives nouvelles langues

**Futur :**
- Paiement en ligne/séquestre, app native, API ouverte, stats marché publiques

## Phase 3 — SCAMPER Method (Idea Development)

### S — Substituer
- **[SCAMPER-S #1]** Déclaration sur l'honneur = formulaire numérique intégré (checkboxes structurées, pas un PDF uploadé)
- **[SCAMPER-S #2]** Fournisseur rapport véhicule interchangeable (pas verrouillé sur CarVertical)
- **[SCAMPER-S #3]** Déclaration complète = données État + données complémentaires + déclarations vendeur + signature numérique N2 (N3 futur)

### C — Combiner
- **[SCAMPER-C #1]** Flux unique création annonce : auto-fill + score visibilité + déclaration + paiement en un parcours fluide
- **[SCAMPER-C #2]** Fin de transaction combinée : confirmation vente → contrat auto → évaluations bilatérales

### A — Adapter
- **[SCAMPER-A #1]** Profil vendeur type Airbnb (vérifié, noté, réactif, badges)
- **[SCAMPER-A #2]** Avis sur le véhicule type Waze (acheteurs qui l'ont vu en vrai)

### M — Modifier / Magnifier
- **[SCAMPER-M #1]** Magnifier le moment "wahou" auto-fill (15 champs certifiés en 3 secondes = spectaculaire visuellement)
- **[SCAMPER-M #2]** Réduire la complexité pour particuliers (flux simplifié vs cockpit pro complet)

### P — Put to other uses
- **[SCAMPER-P #1]** Données certifiées = service B2B vendable à des tiers (assureurs, banques, loueurs)
- **[SCAMPER-P #2]** Score de certification = label de qualité reconnu dans le marché VO

### E — Éliminer de la V1
- Insights IA → V2, contrat pré-rempli → V2, actions structurées chat → V2
- Boost configurable avancé → V2, import en masse → V2

### R — Renverser
- **[SCAMPER-R #1]** Inversion du modèle : l'acheteur publie une RECHERCHE, les vendeurs viennent à lui (feature future / feature-gating)

## Phase 4 — Chaos Engineering (Stress-test)

### Scénarios testés et résultats

| Scénario | Survit ? | Faille identifiée |
|---|---|---|
| Toutes APIs État down 48h | ✅ Cache + mode dégradé | Resync massive au retour à prévoir |
| Réseau de fraudeurs (faux SIRET) | ✅ Data certifiée + signalement | Vérification SIRET ↔ identité à renforcer |
| Succès viral (5 000 annonces/semaine) | ⚠️ Partiel | Coûts CarVertical linéaires, paiement AVANT appel API |
| Données certifiées fausses (erreur API) | ✅ CGU + disclaimer | Wording "certifié" ≠ "garanti" — CRITIQUE |
| Client fondateur quitte | ⚠️ Partiel | Diversifier rapidement, valeur propre du cockpit |
| Fuite de données / cyberattaque | ❌ Sans protection | Chiffrement, 2FA, HTTPS, logs — OBLIGATOIRE V1 |

### Vulnérabilités — Actions requises

**CRITIQUE (V1) :**
- Wording juridique : "données officielles" jamais "garanties par la plateforme"
- Sécurité : chiffrement BDD, 2FA comptes pro, HTTPS, logs accès
- Paiement AVANT appel CarVertical (maîtrise coûts)
- Validation manuelle premiers comptes pro

**IMPORTANT (V1/V2) :**
- Vérification SIRET ↔ identité réelle
- Négociation tarif volume CarVertical
- Assurance RC professionnelle
- Diversification rapide au-delà du client ancre

**SURVEILLÉ :**
- Dépendance APIs État (mitigé par cache)
- Scalabilité infrastructure
- Concentration client fondateur

## Stack Technique

### Choix technologiques

| Composant | Technologie | Justification |
|---|---|---|
| **Backend** | SAP CAP (Node.js) | Expertise ABAP/SAP du fondateur, CDS pour modélisation, services REST auto-générés |
| **Base de données** | Azure Database for PostgreSQL | Managed, JSONB pour config dynamique, PostGIS pour géo, full-text search |
| **Frontend** | Next.js (React/TypeScript) | SSR pour SEO, PWA natif, écosystème React |
| **Auth** | Azure AD B2C (Entra ID) | 2FA natif, OAuth, gestion rôles Admin/Pro/Particulier |
| **Temps réel** | Azure SignalR Service | Chat, notifications push, score visibilité live, managé |
| **Stockage** | Azure Blob Storage + CDN | Photos, PDFs, rapports, contrats |
| **Paiement** | Stripe | Annonces, futur séquestre via Stripe Connect |
| **CI/CD** | Azure DevOps | Pipelines, repos, boards |
| **Monitoring** | Azure Monitor + App Insights | Logs, alertes, dashboards opérationnels |
| **Hébergement** | Azure App Service | Scaling auto, slots staging/prod, SSL natif |

### Principe fondateur : Zéro Hardcode — Tout en BDD

**RÈGLE ABSOLUE : Aucune valeur, aucun texte, aucune configuration en dur dans le code.**

Tout est piloté par des tables PostgreSQL :
- `config_parameters` — toutes les valeurs métier (prix, seuils, délais...)
- `config_texts` — tous les textes et labels avec clé de langue (i18n)
- `config_features` — feature flags (enabled, access_type, price)
- `config_boost_factors` — facteurs de boost dynamiques
- `config_vehicle_types` — types de véhicules et champs spécifiques
- `config_listing_durations` — durées et tarifs d'annonces
- `config_report_reasons` — motifs de signalement
- `config_chat_actions` — actions structurées messagerie
- `config_moderation_rules` — règles de modération
- `config_api_providers` — fournisseurs API (État, tiers)

Cache intelligent en mémoire, invalidé à chaque modification admin → effet immédiat.

### Principes SOLID

- **S** — Single Responsibility : un service = une responsabilité (VehicleService, ListingService, BoostService, ConfigService)
- **O** — Open/Closed : nouveau type véhicule ou fournisseur = nouvelle classe, pas de modification existante
- **L** — Liskov Substitution : Voiture, Moto, Camionnette substituables en Véhicule ; CarVertical, Autorigin substituables en ReportProvider
- **I** — Interface Segregation : ISearchable, ICertifiable, IReportable — contrats précis
- **D** — Dependency Inversion : le code dépend d'abstractions (IVehicleDataProvider, IConfigRepository), jamais de concrétions

### Design Patterns

- **Repository Pattern** — tout accès BDD via repository
- **Adapter Pattern** (style SAP BADI) — chaque intégration externe interchangeable
- **Factory Pattern** — création véhicules pilotée par config BDD
- **Observer Pattern** — événements métier déclenchent des réactions chaînées
- **Strategy Pattern** — comportements chargés dynamiquement depuis la config BDD

### Coût Azure estimé (lancement)

| Service | Estimation mensuelle |
|---|---|
| App Service backend | ~30-50€ |
| App Service frontend | ~30-50€ |
| PostgreSQL (Basic) | ~25-40€ |
| Blob Storage | ~5-10€ |
| SignalR (free tier) | 0€ |
| Azure AD B2C | 0€ (50k auth/mois) |
| CDN | ~5-10€ |
| Azure DevOps | 0€ (5 users) |
| **TOTAL** | **~100-160€/mois** |

---

## Priorisation finale — Feuille de route

### V1 — MVP (Lancement)

**Moteur de confiance :**
- Auto-fill certifié API (HistoVec, SIV, CT)
- Double couche certifié 🟢 / manuel 🟡 avec badges par champ
- Déclaration numérique intégrée + signature numérique N2
- CarVertical intégré (architecture fournisseur interchangeable)
- Paiement AVANT appel CarVertical

**Cockpit pro (basique) :**
- Dashboard vendeur : vues, contacts, jours en ligne
- Flux création gamifié avec score de visibilité temps réel
- Moment "wahou" auto-fill (15 champs en 3 secondes)
- Expérience simplifiée pour particuliers

**Transaction :**
- Chat simple temps réel lié au véhicule
- Signalement granulaire (véhicule / vendeur)
- Modération basique + désactivation auto configurable
- Communication lissée : "En traitement" / "Traité"

**Admin :**
- Prix annonce, filtres défaut, on/off APIs
- Seuils modération configurables
- Job refresh configurable + activable/désactivable
- Wording juridique : "données officielles" (jamais "garanties")

**Technique :**
- SAP CAP + PostgreSQL + Next.js + Azure
- PWA mobile-first
- Architecture i18n multi-langue dès la base
- Cache local + mode dégradé API
- Héritage Véhicule → Voiture/Moto/Camionnette
- Sécurité : chiffrement, 2FA, HTTPS
- ZÉRO HARDCODE — tout en tables BDD
- SOLID + Design Patterns (Repository, Adapter, Factory, Observer, Strategy)
- Validation manuelle premiers comptes pro

### V2 — Enrichissement (1-3 mois après lancement)

- Cockpit acheteur + alertes configurables + gestion budget
- Boost visibilité avec facteurs dynamiques (rule builder)
- Évaluations bilatérales post-vente (transaction + personne)
- Actions structurées messagerie (négo prix, RDV, docs)
- Contrat pré-rempli PDF avec données certifiées
- Insights IA vendeur
- SEO pages auto-générées (cote, marque/modèle, géo)
- Import en masse véhicules (CSV → auto-fill par immatriculation)
- Vie du véhicule (persistance inter-ventes)
- Vérification SIRET ↔ identité réelle
- Profil vendeur type Airbnb (vérifié, noté, badges)

### V3 — Scale (6+ mois)

- Packages/sous-packages pricing hiérarchique complet
- Offres personnalisées par client + fidélisation automatique
- Feature-gating complet (Libre ↔ Payant ↔ Abonnement)
- Rule builder boost avancé
- Blog/contenu éditorial SEO
- Onboarding guidé vendeur pro (tutoriel)
- Signature numérique N3 (Yousign ou équivalent)
- Traductions effectives nouvelles langues (EN, DE, ES...)
- Expansion Belgique/Luxembourg

### Futur

- Paiement en ligne / séquestre / commission (Stripe Connect)
- App native iOS/Android
- API ouverte pour logiciels de gestion stock pro
- Statistiques marché publiques (tendances prix)
- Recherche inversée acheteur (publie sa demande → vendeurs viennent)
- Données certifiées comme service B2B (assureurs, banques, loueurs)
- Score certification comme label de qualité reconnu

---

## Session Summary

### Chiffres clés
- **115+ idées** générées à travers 4 phases
- **4 techniques** utilisées : What If Scenarios, Six Thinking Hats, SCAMPER, Chaos Engineering
- **6 thèmes** principaux : Confiance, Cockpit Pro, Admin, Résilience, Transaction, Croissance
- **6 scénarios** de stress-test (Chaos Engineering)
- **4 niveaux** de priorisation : V1 / V2 / V3 / Futur

### Concepts breakthrough
1. **Vie du véhicule** — historique qui persiste entre ventes, avantage incopiable
2. **Double couche certifié/manuel** — transparence au niveau du champ, jamais vu ailleurs
3. **Admin zéro-code** — pilotage business complet depuis le dashboard
4. **Zéro hardcode** — architecture 100% pilotée par BDD, évolutive sans développeur
5. **Client ancre** — pas de problème de démarrage à froid, réseau et stock dès J1

### Vulnérabilités identifiées et mitigées
- APIs État → cache local + mode dégradé
- CarVertical → architecture fournisseur interchangeable
- Fraude → signalement granulaire + données certifiées non manipulables
- Wording juridique → "données officielles" jamais "garanties"
- Sécurité → chiffrement, 2FA, HTTPS obligatoire en V1

### Prochaines étapes
1. Relire et valider ce document de session
2. Valider la priorisation V1 avec le client fondateur
3. Définir les aspects légaux en détail (session brainstorming dédiée)
4. Démarrer le développement V1 — Product Brief puis spécifications techniques
5. Investiguer les APIs État (HistoVec, SIV) — accès, coûts, quotas, couverture
