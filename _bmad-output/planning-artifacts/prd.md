---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
inputDocuments:
  - product-brief-auto-2026-02-08.md
  - brainstorming-session-2026-02-07.md
  - technical-apis-etat-vehicules-research-2026-02-07.md
  - technical-mechanical-apis-research-2026-02-08.md
  - carvertical-alternatives-europe-france-research-2026-02-08.md
  - carvertical-b2b-api-investigation-2026-02-08.md
workflowType: 'prd'
documentCounts:
  briefs: 1
  research: 4
  brainstorming: 1
  projectDocs: 0
classification:
  projectType: 'web_app (SaaS Marketplace/Platform)'
  domain: 'automotive (marketplace)'
  complexity: 'high'
  projectContext: 'greenfield'
  liabilityModel: 'transfer - platform as technical intermediary, not guarantor'
communication_language: 'French'
date: 2026-02-08
author: Nhan
project_name: auto
---

# Product Requirements Document - auto

**Author:** Nhan
**Date:** 2026-02-08

## Résumé Exécutif

**auto** est une plateforme française de petites annonces véhicules d'occasion fondée sur la transparence certifiée et les données officielles.

**Problème :** Le marché français du véhicule d'occasion souffre d'asymétrie d'information (acheteurs ne peuvent pas vérifier les déclarations vendeur), d'un manque d'outils pour les vendeurs honnêtes (impossible de prouver sa transparence), et de coûts plateforme prohibitifs (€29-39/annonce pour un service basique).

**Solution :** Une marketplace où chaque champ de données d'une annonce est visuellement marqué 🟢 Certifié (source API officielle) ou 🟡 Déclaré (saisie vendeur). Le vendeur entre sa plaque d'immatriculation ou son VIN → les champs se remplissent automatiquement depuis des sources officielles. Le rapport historique véhicule est inclus dans le prix. Le tout pour €15/annonce, soit 2x moins cher que la concurrence.

**Différenciateurs clés :**
- **Certification au niveau du champ** — chaque donnée est traçable à sa source (aucun concurrent ne le fait)
- **Prix + valeur** — €15 tout inclus vs €29-39 chez les concurrents, avec plus de fonctionnalités
- **Cockpit professionnel** — outil de travail quotidien avec KPIs, positionnement marché, suivi stock
- **Architecture zero-hardcode** — 100% configurable via admin sans code (vision ERP appliquée à la marketplace)
- **Responsabilité architecturée** — la plateforme est un intermédiaire technique, la responsabilité est sur la source (API ou vendeur)

**Utilisateurs cibles :** Professionnels de l'automobile (cible primaire), acheteurs de véhicules d'occasion (trafic), particuliers vendeurs (horizon V2+).

**Modèle économique :** Paiement par annonce (€15) incluant le rapport historique véhicule. Marge nette = €15 - coûts API cumulés, suivie en temps réel par l'admin.

**Lancement :** 3 000 véhicules prêts J1 via un client ancre (réseau de concessionnaires). Pas de problème de cold-start. Trajectoire : client ancre → son réseau → pros indépendants → particuliers.

**Stack technique :** SAP CAP (Node.js), PostgreSQL, Next.js (SSR + SPA hybride), Azure AD B2C, Azure SignalR, Stripe, PWA mobile-first.

---

## Critères de Succès

### Succès Utilisateur

**Vendeur (particulier & pro) :**
- Auto-fill certifié via plaque/VIN le plus rapidement possible (aspiration ~3 secondes) — le moment "wahou"
- Création d'annonce complète en moins de 5 minutes (vs ~20 min chez les concurrents)
- Chaque champ étiqueté : 🟢 Certifié (source API) ou 🟡 Déclaré (saisie vendeur) — la plateforme affiche la source, n'engage pas sa responsabilité
- Score de visibilité temps réel pendant la création — gamification de la transparence

**Vendeur pro (cockpit) :**
- Le cockpit devient l'outil de travail quotidien, mesuré par : fréquence de connexion, temps passé, nombre d'annonces gérées activement
- KPIs business : vues, contacts, jours en ligne, positionnement prix marché

**Acheteur :**
- Confiance accrue grâce à la transparence champ par champ (certifié vs déclaré)
- Rapport historique véhicule inclus dans l'annonce (pas de coût supplémentaire)
- Filtres avancés : budget, CT valide, en-dessous du prix marché, niveau de certification
- Indicateurs principaux : taux de contact vendeur et données de vente

### Succès Business

- 3 000 véhicules en ligne dès J1 — stock client ancre confirmé
- Objectif stretch 3 mois : 10 000 annonces, 1 000 ventes, centaines de milliers de visiteurs mensuels
- €15/annonce tout inclus — marge saine maintenue grâce à la sélection de fournisseurs API optimisés en coût
- Fournisseurs API interchangeables (Adapter Pattern) — pas de verrouillage fournisseur
- Visibilité temps réel sur la marge nette par annonce (revenu €15 — coûts API cumulés) via dashboard admin
- Trajectoire de croissance : client ancre → son réseau → pros indépendants → particuliers

### Succès Technique

- **Résilience API** : tolérance de 48h d'indisponibilité grâce au cache local + mode dégradé (saisie manuelle avec re-sync automatique au retour)
- **Performance auto-fill** : aspiration ~3 secondes — objectif de performance, pas promesse contractuelle
- **Architecture zero-hardcode** : 100% des valeurs, textes, règles et configurations pilotés par BDD, modifiables via admin sans intervention développeur
- **SOLID & Clean Code** : architecture maintenable, testable, extensible — pas de dette technique acceptée
- **Fournisseurs API interchangeables** : Adapter Pattern permettant de switcher de fournisseur sans modifier le code métier
- **Coût API maîtrisé** : paiement AVANT appel API, choix de fournisseurs qui préservent la marge
- **Logging systématique** de chaque appel API (fournisseur, coût, statut) pour calcul de marge par annonce
- **Alertes admin configurables** sur seuil de marge minimum

### Résultats Mesurables

| KPI | J1 | 3 mois | 12 mois |
|-----|-----|--------|---------|
| Annonces en ligne | 3 000 | 10 000 | À définir |
| Ventes réalisées | — | 1 000 | À définir |
| Visiteurs mensuels | — | 100K+ | À définir |
| Temps création annonce | < 5 min | < 5 min | < 3 min |
| Connexions pro/semaine | — | À mesurer | Objectif quotidien |
| Marge nette par annonce | Mesurée dès J1 | > seuil configurable | Optimisée |

---

## Parcours Utilisateur

### Parcours 1 : Karim, acheteur — "Trouver le bon utilitaire en confiance"

**Contexte :** Karim, gérant d'une PME de livraison à Lyon, cherche un Kangoo occasion fiable. Il a été échaudé par un achat précédent où le vendeur avait maquillé le kilométrage.

**Scène d'ouverture :** Karim tape "Kangoo occasion Lyon" sur Google. Il tombe sur une page d'annonce **auto** (SEO). Il voit les photos, le prix (€12 500), le kilométrage (87 000 km) avec un badge 🟢 Certifié, la date de l'annonce, la note du vendeur. Les cards sont visuelles, les infos critiques sont là. Il clique pour en savoir plus.

**Montée en tension :** Sur la fiche, il voit les données gratuites — infos issues des APIs publiques, photos, prix, quelques caractéristiques. Mais pour le rapport historique, les données techniques détaillées issues d'APIs payantes, et pour contacter le vendeur — un bandeau l'invite à créer un compte. Karim hésite 2 secondes, mais la transparence des badges certifiés l'a déjà accroché. Il s'inscrit.

**Climax :** Compte créé, Karim accède maintenant à tout. Il voit le rapport historique véhicule inclus, le détail champ par champ — kilométrage 🟢 Certifié, CT valide 🟢, couleur 🟡 Déclarée vendeur. Il compare avec le prix du marché (indicateur visuel). Le Kangoo est 8% en dessous du marché, CT valide, 92% de données certifiées. **C'est le moment de confiance** — il contacte le vendeur directement via le chat intégré.

**Résolution :** Karim négocie via le chat, prend rendez-vous, achète le véhicule. Il sait exactement ce qu'il a acheté parce que chaque info était sourcée et transparente.

**Capacités révélées :** SEO/landing pages, cards configurables, mur d'inscription configurable, système de badges certifié/déclaré, rapport historique intégré, comparaison prix marché, chat lié au véhicule, inscription rapide.

---

### Parcours 2 : Sophie, vendeuse pro — "Publier 30 véhicules sans perdre sa journée"

**Contexte :** Sophie, responsable stock chez un concessionnaire multimarque à Marseille. Elle gère 80 véhicules et vient de rejoindre **auto** via le réseau du client ancre. Elle en a marre de payer €35/annonce sur La Centrale pour un service basique.

**Scène d'ouverture :** Sophie s'inscrit sur **auto**. On lui demande ses infos — SIRET, nom de l'entreprise, coordonnées. Certains champs sont obligatoires, d'autres facultatifs (configurable admin), mais elle sait que plus elle remplit, meilleure sera sa note vendeur. Pas de validation par un modérateur — son compte est actif immédiatement. Son cockpit est vide et l'invite à publier sa première voiture ou à explorer le marché.

**Montée en tension :** Sophie entre la plaque de son premier véhicule — un Peugeot 3008. **Boom** — les champs se remplissent automatiquement : marque, modèle, motorisation, cylindrée, CO2, Crit'Air, tout ce qui vient des APIs. Chaque champ apparaît avec son badge 🟢. Un score de visibilité s'affiche en temps réel. Elle ajoute les photos, le prix, l'état général (🟡 Déclaré). Le score monte. Elle signe la déclaration sur l'honneur numérique — checkboxes structurées, horodatée.

**Mais elle ne publie pas encore.** Elle répète l'opération pour 29 autres véhicules. Chacun est sauvegardé en brouillon.

**Climax :** Sophie va dans sa rubrique "Publication". Elle voit ses 30 brouillons prêts. Elle en sélectionne 25 (les 5 autres manquent encore de photos). Le système calcule : 25 × €15 = €375. Elle paie en une fois. **Les 25 annonces passent en ligne instantanément**, visibles sur le marketplace avec toutes les données certifiées.

**Résolution :** Le lendemain, Sophie ouvre son cockpit. Elle voit les premières vues, les premiers contacts. Elle consulte aussi le marché — elle met en favoris des véhicules concurrents pour suivre leur prix et leur évolution. Le cockpit est devenu son outil de travail, pas juste un canal de pub. Elle publie les 5 restants dans la semaine.

**Capacités révélées :** Inscription pro avec champs configurables (obligatoire/facultatif), auto-fill via plaque, score de visibilité temps réel, brouillons multiples, publication par lot avec paiement groupé, déclaration sur l'honneur par annonce, cockpit pro (vues/contacts/jours en ligne), favoris et suivi de véhicules marché.

---

### Parcours 3 : Modératrice Yasmine — "Protéger la réputation de la plateforme"

**Contexte :** Yasmine est modératrice sur **auto**. Son rôle : traiter les signalements d'abus pour maintenir la qualité et la confiance sur la plateforme. Elle n'accepte ni ne rejette les inscriptions — elle intervient uniquement quand il y a un problème.

**Scène d'ouverture :** Yasmine ouvre son cockpit modération le matin. Son dashboard affiche : 12 nouveaux signalements, 3 en cours de traitement, tendance de la semaine. Les signalements sont classés par gravité et type (annonce frauduleuse, contenu inapproprié, harcèlement dans le chat, etc.).

**Montée en tension :** Un signalement retient son attention — un acheteur signale qu'un vendeur pro a mis des photos qui ne correspondent pas au véhicule. Yasmine consulte l'annonce, compare les données certifiées avec les photos, vérifie l'historique du vendeur (autres signalements, note, ancienneté).

**Climax :** Les données certifiées 🟢 sont correctes (l'API ne ment pas), mais les photos 🟡 (contenu déclaré vendeur) sont effectivement trompeuses. Yasmine désactive l'annonce spécifique et envoie un avertissement au vendeur via le système — communication lissée : "Votre annonce a été mise en pause pour vérification". Le vendeur peut corriger et la re-soumettre. Si c'est récurrent, Yasmine peut désactiver le compte.

**Résolution :** Le vendeur corrige ses photos, l'annonce est réactivée. Le signalement est marqué "Traité". La plateforme n'a pas pris parti dans un conflit — elle a simplement protégé la qualité du contenu.

**Capacités révélées :** Dashboard modération avec file de signalements, classification par gravité/type, vue détaillée annonce + historique vendeur, actions (désactiver annonce, désactiver compte, avertir, réactiver), communication lissée, suivi des signalements traités.

---

### Parcours 4 : Nhan, administrateur — "Piloter le business sans toucher au code"

**Contexte :** Nhan est l'administrateur de la plateforme. Chaque matin, il ouvre son dashboard pour prendre le pouls du business.

**Scène d'ouverture :** Le dashboard admin s'ouvre sur les **KPIs critiques du jour** : nombre de visiteurs (hier vs semaine précédente), nouvelles inscriptions, annonces publiées, contacts initiés, ventes déclarées, revenus du jour. Un graphique montre la tendance sur 30 jours. Tout est en temps réel.

**Montée en tension :** Nhan remarque que la marge nette par annonce a baissé de 2% cette semaine. Il drill-down dans le suivi des coûts API — il voit que le fournisseur de rapports historiques a augmenté ses tarifs. Le coût moyen par annonce est passé de €3,20 à €4,10. À €15/annonce, la marge reste positive mais la tendance est mauvaise.

**Climax :** Nhan va dans la configuration des APIs. Il voit les fournisseurs actifs, leurs coûts par appel, leur taux de disponibilité. Il active un fournisseur alternatif (Adapter Pattern) qu'il avait configuré en standby — même données, €2,80/appel. Il désactive l'ancien. **Aucune ligne de code touchée.** Les nouvelles annonces utiliseront automatiquement le nouveau fournisseur. Il ajuste aussi le seuil d'alerte de marge minimum.

**Résolution :** Le lendemain, la marge est remontée. Nhan vérifie aussi les stats de visites par source (SEO, direct, réseaux), le taux de conversion visiteur → inscrit, et les pages les plus consultées. Il ajuste un template SEO pour les pages "cote véhicule" qui performent bien. Tout depuis le dashboard, sans développeur.

**Capacités révélées :** Dashboard KPIs temps réel (visiteurs, inscriptions, annonces, ventes, revenus), suivi coûts API par annonce et par fournisseur, alertes marge configurable, activation/désactivation fournisseurs API, configuration prix/textes/règles, stats par source de trafic, templates SEO configurables, audit trail.

---

### Résumé des Capacités par Parcours

| Capacité | Acheteur | Vendeur Pro | Modérateur | Admin |
|----------|----------|-------------|------------|-------|
| Cards configurables (infos affichées) | ✅ | | | Config |
| Mur d'inscription configurable | ✅ | | | Config |
| Auto-fill certifié via plaque/VIN | | ✅ | | |
| Badges 🟢/🟡 par champ | ✅ | ✅ | ✅ | |
| Brouillons + publication par lot | | ✅ | | |
| Paiement par annonce sélectionnée | | ✅ | | |
| Déclaration sur l'honneur numérique | | ✅ | | |
| Chat lié au véhicule | ✅ | ✅ | | |
| Favoris + suivi véhicules marché | ✅ | ✅ | | |
| Cockpit vendeur (KPIs) | | ✅ | | |
| Dashboard modération + signalements | | | ✅ | |
| Actions modération (désactiver/avertir) | | | ✅ | |
| Dashboard KPIs business temps réel | | | | ✅ |
| Suivi coûts API + marge par annonce | | | | ✅ |
| Config APIs, prix, textes, règles | | | | ✅ |
| Score de visibilité temps réel | | ✅ | | |
| Rapport historique véhicule | ✅ | | | |
| Comparaison prix marché | ✅ | ✅ | | |
| Signalement granulaire | ✅ | | ✅ | |
| Inscription pro (champs configurables) | | ✅ | | Config |

---

## Exigences Domaine

### Conformité & Réglementation

**RGPD / Protection des données :**
- **Anonymisation** à la suppression de compte : données personnelles anonymisées (pas supprimées) pour préserver l'intégrité des annonces et historiques
- **Portabilité des données** : l'utilisateur peut demander l'export de toutes ses données personnelles
- **Consentement explicite** : recueil du consentement lors de l'inscription, granulaire par type de traitement
- **Politique de conservation** : durées de conservation définies par type de donnée (déclarations sur l'honneur archivées, conversations, données de compte)

**Cadre juridique plateforme (LCEN) :**
- Mentions légales obligatoires
- Procédure de signalement de contenu illicite conforme LCEN
- Obligation de retrait rapide après signalement qualifié
- CGU/CGV versionnées — re-acceptation forcée en cas de mise à jour

**Responsabilité des données :**
- Wording systématique : "données issues de [source]" — jamais "garanties par la plateforme"
- Distinction claire 🟢 Certifié (responsabilité fournisseur API) / 🟡 Déclaré (responsabilité vendeur via déclaration sur l'honneur)
- La plateforme est un **intermédiaire technique**, pas un garant
- Déclaration sur l'honneur horodatée et archivée = preuve de bonne foi du vendeur

### Contraintes Techniques

**Textes juridiques — Architecture zero-hardcode :**
- Tous les textes juridiques (CGU, CGV, mentions légales, consentement, politique de confidentialité) stockés en BDD et configurables via admin
- Mock data en développement — versions finales rédigées par un avocat avant lancement
- CGU versionnées avec mécanisme de re-acceptation automatique si mise à jour
- Audit trail sur toutes les opérations (middleware) — horodatage, action, acteur

**Paiement :**
- Fournisseur de paiement interchangeable (Adapter Pattern) — Stripe recommandé en V1 (~1.4% + €0.25 par transaction)
- Conformité PSD2 (authentification forte SCA pour paiements européens)
- Support SEPA et moyens de paiement européens pour ambition multi-pays
- Paiement par annonce sélectionnée — pas d'abonnement en V1
- Architecture prête pour Stripe Connect (séquestre, commission, split payments) en futur

**Sécurité :**
- Chiffrement BDD (données sensibles)
- 2FA pour comptes professionnels
- HTTPS obligatoire
- Logs d'accès

### Pré-requis Avant Lancement

- Rédaction CGU/CGV par un avocat spécialisé
- Politique de confidentialité RGPD validée
- Mentions légales conformes LCEN
- Textes de consentement validés
- Validation du wording "données officielles" vs responsabilité plateforme

---

## Innovation & Patterns Novateurs

### Axes d'Innovation Identifiés

**1. Architecture Zero-Hardcode — Vision ERP appliquée à la marketplace**
Inspiré du monde ERP où tout est paramétrable, **auto** est conçu comme un moteur configurable : chaque valeur, texte, règle métier, fournisseur API, facteur de boost, type de véhicule et feature est piloté par des tables BDD. L'administrateur pilote le business, le développeur n'intervient que pour les évolutions structurelles.

**2. Certification transparente au niveau du champ**
Aucune plateforme de petites annonces véhicules ne distingue visuellement la source de chaque donnée. Le système dual 🟢 Certifié / 🟡 Déclaré est un changement de paradigme — l'acheteur voit exactement qui est responsable de quoi.

**3. Responsabilité architecturée dans le produit**
Le modèle de transfert de responsabilité (plateforme = intermédiaire technique) est intégré dans chaque écran, chaque champ, chaque interaction. Le produit ET le juridique sont alignés par design.

**4. Gamification de la transparence**
Le score de visibilité temps réel aligne les intérêts de tous les acteurs : le vendeur gagne en visibilité en étant transparent, l'acheteur gagne en confiance, la plateforme gagne en qualité de contenu. Les facteurs de boost sont configurables sans code.

### Contexte Concurrentiel

| Aspect | LeBonCoin / La Centrale / Autoscout24 | **auto** |
|--------|---------------------------------------|----------|
| Données | 100% déclaratives | Dual 🟢 Certifié / 🟡 Déclaré par champ |
| Configuration | Code figé, évolutions lentes | Zero-hardcode, 100% BDD, évolutions instantanées |
| Transparence | Aucune visibilité sur la source des données | Source affichée pour chaque champ |
| Responsabilité | Floue (plateforme vs vendeur) | Architecturée : API → fournisseur, Déclaré → vendeur |
| Adaptabilité business | Nécessite du développement | Admin autonome, développeur intervient rarement |

### Approche de Validation

- **Moment "wahou"** : taux de complétion d'annonce et temps de création vs concurrence
- **Confiance** : taux de contact acheteur sur annonces à fort taux de certification vs annonces classiques
- **Zero-hardcode** : capacité de l'admin à lancer une promotion, changer un prix, activer un fournisseur API sans ticket développeur
- **Score de visibilité** : corrélation entre score élevé et performance de l'annonce (vues, contacts)

---

## Exigences Spécifiques Web App (SaaS Marketplace)

### Architecture de Rendu

**Stratégie hybride SSR + SPA :**

| Zone | Rendu | Raison |
|------|-------|--------|
| Pages publiques (annonces, recherche, landing, pages SEO) | **SSR** | SEO, Core Web Vitals, Open Graph |
| Cockpit vendeur | **SPA** | Derrière auth, réactivité maximale |
| Cockpit modérateur | **SPA** | Derrière auth, flux de travail interactif |
| Dashboard admin | **SPA** | Derrière auth, dashboards temps réel |
| Fiche annonce détaillée | **SSR** | SEO critique — chaque annonce est indexable |

### Support Navigateurs & PWA

**Navigateurs evergreen uniquement :**
- Chrome, Firefox, Safari, Edge, Samsung Internet (dernières 2 versions chacun)
- Pas de support IE11 ni navigateurs legacy

**PWA mobile-first :**
- Installable sur mobile (manifest.json, service worker)
- Push notifications
- Accès caméra (photos véhicules)
- Géolocalisation (recherche par proximité)

### Stratégie SEO

**Pages à indexer (SSR) :**
- Pages annonces individuelles — contenu unique riche (données certifiées = contenu de qualité)
- Pages de recherche par critères (marque, modèle, ville, type)
- Pages cote véhicule auto-générées par marque/modèle (V2)
- Pages géographiques auto-générées (V2)
- Landing pages statiques (confiance, comment ça marche, etc.)

**Templates SEO configurables (admin) :**
- Meta title, meta description par type de page
- Données structurées Schema.org (Vehicle, Product, Offer)
- URLs propres et sémantiques (`/annonce/peugeot-3008-2022-marseille-{id}`)
- Sitemap XML auto-généré
- Robots.txt configurable

### Modèle de Permissions (RBAC)

| Rôle | Accès public | Annonces | Cockpit vendeur | Chat | Modération | Admin |
|------|-------------|----------|-----------------|------|------------|-------|
| **Visiteur anonyme** | ✅ (configurable) | Lecture (partielle) | ❌ | ❌ | ❌ | ❌ |
| **Acheteur inscrit** | ✅ | Lecture complète | ❌ | ✅ | ❌ | ❌ |
| **Vendeur** | ✅ | CRUD propres annonces | ✅ | ✅ | ❌ | ❌ |
| **Modérateur** | ✅ | Lecture + désactivation | ❌ | Lecture | ✅ | ❌ |
| **Administrateur** | ✅ | Tout | ✅ | Tout | ✅ | ✅ |

### Temps Réel

- **Chat** : messages instantanés entre acheteur et vendeur, liés à un véhicule
- **Notifications** : nouveau contact, nouvelle vue, annonce vendue, signalement traité
- **Score de visibilité** : mise à jour live pendant la création d'annonce
- **Dashboard admin** : KPIs temps réel (visiteurs, revenus, alertes)

### Intégrations API (Architecture Adapter Pattern)

| Interface | V1 (Lancement) | V2+ (Évolution) |
|-----------|----------------|-----------------|
| `IVehicleLookupAdapter` | Mock (plaque → données) | apiplaqueimmatriculation / SIVin / JATO |
| `IEmissionAdapter` | ADEME (gratuit) | Vincario / JATO |
| `IRecallAdapter` | RappelConso (gratuit) | — |
| `ICritAirCalculator` | Calcul local (gratuit) | — |
| `IVINTechnicalAdapter` | NHTSA vPIC (gratuit) | Vincario / JATO |
| `IHistoryAdapter` | Mock | CarVertical / AutoDNA / Autoviza |
| `IValuationAdapter` | Mock | Autobiz / Autovista |
| `IPaymentAdapter` | Stripe | Évolutif (Lemonway, etc.) |

Chaque fournisseur activable/désactivable dans `config_api_providers` sans code.

---

## Project Scoping & Développement Phasé

### Stratégie MVP & Philosophie

**Approche : Platform MVP — Fondations complètes**

Le MVP d'**auto** n'est pas un produit minimal — c'est une **plateforme fondatrice**. La philosophie zero-hardcode impose un investissement initial plus élevé mais garantit une vélocité d'itération maximale post-lancement. Chaque composant V1 est conçu comme une fondation extensible, pas comme un prototype jetable.

**Principes directeurs :**
- **Zero-hardcode non négociable** : 100% des valeurs, textes, règles et configurations en BDD, administrables sans code
- **SOLID & Clean Code** : architecture maintenable, testable, extensible — pas de dette technique acceptée
- **Design-first pour les annonces** : l'expérience visuelle acheteur est un différenciateur stratégique — UI/UX aux standards les plus exigeants (clarté, lisibilité, esthétique)
- **Adapter Pattern systématique** : chaque intégration externe est interchangeable par design

**Ressources :** Équipe complète pluridisciplinaire (développement, design UI/UX, QA, DevOps, produit, juridique, data)

### Phase 1 — MVP (Lancement)

**Parcours utilisateur supportés :**

| Parcours | Couverture V1 |
|----------|---------------|
| Acheteur (Karim) | Complet — recherche, filtres, badges certifiés, rapport historique, inscription, contact vendeur via chat |
| Vendeuse pro (Sophie) | Complet — inscription, auto-fill, brouillons, publication par lot, paiement, cockpit KPIs |
| Modératrice (Yasmine) | Complet — cockpit modération, signalements, actions (désactiver/avertir/réactiver) |
| Admin (Nhan) | Complet — dashboard KPIs, suivi coûts API, configuration APIs/prix/textes/règles |

**Capacités must-have :**

| # | Capacité | Justification |
|---|----------|---------------|
| 1 | Auto-fill certifié via plaque/VIN | Le moment "wahou" — différenciateur fondamental |
| 2 | Double couche 🟢 Certifié / 🟡 Déclaré par champ | Proposition de valeur unique — confiance par transparence |
| 3 | Score de visibilité temps réel | Gamification de la transparence — aligne les intérêts vendeur/acheteur/plateforme |
| 4 | Chat temps réel lié au véhicule | Canal de contact essentiel entre acheteur et vendeur |
| 5 | Déclaration sur l'honneur numérique horodatée | Cadre de responsabilité — archivée comme preuve |
| 6 | Rapport historique véhicule inclus | Différenciateur prix — inclus dans les €15 |
| 7 | Cockpit vendeur (vues, contacts, jours en ligne, positionnement prix) | Outil de travail quotidien, pas juste un canal pub |
| 8 | Cockpit modérateur (signalements, actions, suivi) | Protection de la réputation plateforme |
| 9 | Dashboard admin complet (KPIs, coûts API, marge, alertes) | Pilotage business sans code |
| 10 | Configuration admin complète (APIs, prix, textes, règles, features) | Zero-hardcode — le cœur de l'architecture |
| 11 | PWA mobile-first (installable, push notifications, caméra, géoloc) | Expérience multi-device dès J1 |
| 12 | Cache local + mode dégradé API avec re-sync automatique | Résilience — l'annonceur récupère ses données quand l'API revient |
| 13 | Paiement par annonce via Stripe | Modèle de revenu V1 |
| 14 | Brouillons + publication par lot + paiement groupé | Workflow pro — créer plusieurs, publier quand prêt |
| 15 | Système de signalement granulaire | Modération configurable par type/gravité |
| 16 | Design annonces premium (UI/UX état de l'art) | Les annonces doivent être claires, visibles, lisibles et belles |
| 17 | Architecture i18n | Prêt pour l'expansion européenne |
| 18 | Sécurité (chiffrement, 2FA, HTTPS, logs) | Fondation non négociable |
| 19 | Architecture zero-hardcode complète (tables config BDD) | Tout est configurable sans intervention développeur |
| 20 | Favoris + suivi véhicules marché | Engagement utilisateur — acheteurs ET vendeurs |
| 21 | SEO SSR (pages annonces, recherche, Schema.org, sitemap) | Acquisition organique dès J1 |

**Stratégie API V1 :**
- APIs gratuites actives : ADEME, RappelConso, Crit'Air (calcul local), NHTSA vPIC
- APIs payantes : mock data crédible + architecture Adapter prête pour intégration réelle (switch sans code)
- Logging systématique de chaque appel API (fournisseur, coût, statut, temps de réponse)

### Phase 2 — Croissance (1-3 mois post-lancement)

| # | Feature | Dépendance V1 |
|---|---------|---------------|
| 1 | Import en masse véhicules (CSV → auto-fill → suggestions → signature électronique) | Architecture auto-fill |
| 2 | Cockpit acheteur + alertes configurables | Système de favoris |
| 3 | Évaluations bilatérales post-vente | Système de contact |
| 4 | Profil vendeur type Airbnb (vérifié, noté, badges) | Évaluations + données certifiées |
| 5 | Boost visibilité avec facteurs dynamiques configurables | Score de visibilité |
| 6 | Actions structurées messagerie (négo prix, RDV, docs) | Chat |
| 7 | Contrat pré-rempli PDF avec données certifiées | Données certifiées |
| 8 | SEO pages auto-générées (cote véhicule par marque/modèle, pages géo) | Infrastructure SEO |
| 9 | Intégration APIs payantes réelles (remplacement des mocks) | Adapter Pattern |

### Phase 3 — Vision (6+ mois)

| # | Feature | Objectif |
|---|---------|----------|
| 1 | Packages/sous-packages pricing hiérarchique | Monétisation avancée |
| 2 | Feature-gating complet (Libre ↔ Payant ↔ Abonnement) | Flexibilité business |
| 3 | Fidélisation automatique + parrainage | Rétention et croissance organique |
| 4 | Blog/contenu éditorial SEO | Acquisition de trafic |
| 5 | Expansion Belgique/Luxembourg | Croissance géographique |
| 6 | Paiement en ligne / séquestre via Stripe Connect | Transaction sécurisée |
| 7 | API ouverte pour logiciels de gestion stock pro | Écosystème partenaires |
| 8 | Données certifiées comme service B2B (assureurs, banques) | Nouveau modèle de revenu |

### Stratégie de Mitigation des Risques

| Catégorie | Risque | Impact | Mitigation |
|-----------|--------|--------|------------|
| **Technique** | Zero-hardcode = complexité initiale élevée | Délai de développement | Investissement assumé — se rentabilise par l'agilité business post-lancement. Clean code et SOLID réduisent la dette technique |
| **Technique** | APIs payantes non disponibles J1 | Données incomplètes | Mock data crédible + Adapter Pattern prêt — switch vers fournisseur réel sans code |
| **Technique** | Performance auto-fill sous pression | UX dégradée | Cache local, appels parallèles, optimisation progressive |
| **Technique** | PWA multi-device = surface de test large | Bugs device-specific | QA dédiée, testing multi-device automatisé, progressive enhancement |
| **Technique** | Chat temps réel = complexité | Instabilité | Architecture éprouvée Azure SignalR, fallback polling si nécessaire |
| **Marché** | Pros ne voient pas la valeur vs concurrents | Adoption lente | Client ancre = preuve de concept + prix 2x inférieur + cockpit business |
| **Marché** | Acheteurs ne comprennent pas les badges 🟢/🟡 | Différenciateur invisible | Design UI/UX clair, onboarding visuel, tooltip explicatif |
| **Marché** | Concurrents copient le concept de certification | Avantage érodé | Avance architecturale + base utilisateur + données accumulées |
| **Domaine** | Données API erronées affichées comme "certifiées" | Responsabilité juridique | Wording "données officielles" + CGU claires + plateforme = intermédiaire |
| **Domaine** | Fraude vendeur (faux SIRET, photos trompeuses) | Réputation plateforme | Signalement granulaire + modération + note vendeur liée aux champs remplis |
| **Domaine** | Demande RGPD (suppression/portabilité) | Obligation légale | Anonymisation (pas suppression) + export données automatisé |
| **Domaine** | CGU insuffisantes au lancement | Exposition juridique | Validation par avocat AVANT lancement — textes mock en attendant |
| **Domaine** | Litige acheteur/vendeur impliquant la plateforme | Responsabilité | La plateforme modère, ne médie pas — CGU explicites |
| **Ressources** | Scope V1 ambitieux = risque de dépassement | Retard de lancement | Priorisation stricte dans l'ordre du tableau must-have, livraisons incrémentales |
| **Ressources** | Dépendance aux fournisseurs API | Blocage fonctionnel | Adapter Pattern + mocks = jamais bloqué par un fournisseur |
| **Ressources** | Complexité juridique (RGPD, LCEN, CGU) | Retard lancement | Textes mock configurables en dev, validation avocat en parallèle du dev |

---

## Exigences Fonctionnelles

### Gestion des Annonces

- **FR1:** Le vendeur peut créer une annonce en saisissant une plaque d'immatriculation ou un VIN, déclenchant le remplissage automatique des champs à partir de sources de données officielles
- **FR2:** Le système marque chaque champ de données d'une annonce avec son origine : certifié (source API) ou déclaré (saisie vendeur)
- **FR3:** Le vendeur peut compléter, modifier ou corriger les champs déclarés d'une annonce
- **FR4:** Le vendeur peut ajouter des photos à une annonce
- **FR5:** Le vendeur peut sauvegarder une annonce en brouillon sans la publier
- **FR6:** Le vendeur peut gérer plusieurs brouillons simultanément
- **FR7:** Le vendeur peut sélectionner plusieurs brouillons pour publication groupée
- **FR8:** Le vendeur doit compléter une déclaration sur l'honneur numérique horodatée avant publication de chaque annonce
- **FR9:** Le système calcule et affiche un score de visibilité en temps réel pendant la création d'annonce, basé sur le taux de complétion et de certification des champs
- **FR10:** Le système inclut un rapport historique du véhicule dans chaque annonce publiée
- **FR11:** Le vendeur peut marquer une annonce comme vendue ou la retirer du marketplace
- **FR12:** Le système archive les déclarations sur l'honneur avec horodatage comme preuve

### Découverte & Recherche Véhicules

- **FR13:** Le visiteur peut parcourir les annonces publiées sur le marketplace
- **FR14:** Le visiteur peut filtrer les annonces par critères multiples (budget, marque, modèle, localisation, kilométrage, type de carburant, etc.)
- **FR15:** Le visiteur peut filtrer les annonces par niveau de certification, contrôle technique valide, et positionnement par rapport au prix du marché
- **FR16:** Le système affiche une comparaison visuelle du prix de chaque annonce par rapport au prix du marché (en dessous, aligné, au-dessus)
- **FR17:** L'utilisateur inscrit peut ajouter des annonces en favoris et suivre l'évolution de leurs informations
- **FR18:** Le système génère des pages indexables pour chaque annonce, chaque combinaison de critères de recherche, et des landing pages statiques
- **FR19:** Le système produit des données structurées (Schema.org) et un sitemap pour le référencement
- **FR20:** Le système affiche les annonces sous forme de cards avec des informations configurables (photos, prix, kilométrage, date, note vendeur, etc.)

### Gestion des Comptes & Identité

- **FR21:** Le visiteur peut créer un compte avec des champs d'inscription dont le caractère obligatoire ou facultatif est configurable
- **FR22:** Le compte est actif immédiatement après inscription sans validation par un modérateur
- **FR23:** Le système attribue des rôles aux utilisateurs : acheteur inscrit, vendeur, modérateur, administrateur
- **FR24:** Le système contrôle l'accès aux fonctionnalités selon le rôle de l'utilisateur
- **FR25:** Le système restreint certaines fonctionnalités aux utilisateurs authentifiés, les fonctionnalités soumises à authentification étant configurables
- **FR26:** Le taux de remplissage des champs du profil vendeur contribue à la note du vendeur
- **FR27:** L'utilisateur peut demander l'anonymisation de son compte
- **FR28:** L'utilisateur peut demander l'export de toutes ses données personnelles
- **FR29:** Le système recueille le consentement explicite de l'utilisateur, granulaire par type de traitement

### Communication & Notifications

- **FR30:** L'acheteur et le vendeur peuvent communiquer en temps réel via un chat lié à un véhicule spécifique
- **FR31:** Le système envoie des notifications aux utilisateurs pour les événements pertinents (nouveau contact, nouvelle vue, signalement traité, etc.)
- **FR32:** Le système envoie des notifications push aux utilisateurs sur leurs appareils (mobile, tablette, ordinateur)

### Cockpit Vendeur

- **FR33:** Le vendeur accède à un tableau de bord affichant les KPIs de ses annonces (vues, contacts, jours en ligne)
- **FR34:** Le vendeur peut visualiser le positionnement prix de ses annonces par rapport au marché
- **FR35:** Le vendeur peut suivre des véhicules sur le marché et surveiller l'évolution de leurs informations
- **FR36:** Le cockpit invite le vendeur à publier sa première annonce ou explorer le marché lorsqu'il est vide

### Modération & Signalement

- **FR37:** L'utilisateur peut signaler une annonce ou un comportement abusif avec une catégorisation par type et gravité
- **FR38:** Le modérateur accède à un cockpit dédié affichant la file de signalements classés par gravité et type
- **FR39:** Le modérateur peut désactiver ou réactiver une annonce spécifique
- **FR40:** Le modérateur peut désactiver ou réactiver un compte utilisateur
- **FR41:** Le modérateur peut envoyer un avertissement à un utilisateur via le système de communication de la plateforme
- **FR42:** Le modérateur peut consulter l'historique d'un vendeur (signalements précédents, note, ancienneté)

### Administration & Configuration Plateforme

- **FR43:** L'administrateur accède à un dashboard affichant les KPIs globaux en temps réel (visiteurs, inscriptions, annonces, ventes, revenus, sources de trafic)
- **FR44:** L'administrateur peut consulter le coût API par annonce et par fournisseur, et visualiser la marge nette par annonce
- **FR45:** L'administrateur peut configurer des alertes sur des seuils (marge minimum, etc.)
- **FR46:** L'administrateur peut activer ou désactiver des fournisseurs API sans intervention technique
- **FR47:** L'administrateur peut modifier les prix, textes, règles métier, et paramètres de la plateforme sans intervention technique
- **FR48:** L'administrateur peut configurer les informations affichées sur les cards d'annonces
- **FR49:** L'administrateur peut configurer quelles fonctionnalités nécessitent une authentification
- **FR50:** L'administrateur peut configurer les champs d'inscription (obligatoire/facultatif)
- **FR51:** L'administrateur peut gérer les templates SEO (meta title, meta description) par type de page
- **FR52:** L'administrateur peut gérer les textes juridiques (CGU, CGV, mentions légales) avec versionnage et re-acceptation automatique
- **FR53:** Le système enregistre un audit trail de toutes les opérations (horodatage, action, acteur)
- **FR54:** L'administrateur possède toutes les capacités des autres rôles (vendeur, acheteur, modérateur)

### Paiement

- **FR55:** Le vendeur peut payer pour la publication d'annonces sélectionnées
- **FR56:** Le système traite le paiement groupé de plusieurs annonces en une seule transaction
- **FR57:** Le système ne publie les annonces qu'après confirmation du paiement

### Résilience & Continuité de Service

- **FR58:** Le système propose au vendeur une saisie manuelle lorsqu'une source de données est indisponible
- **FR59:** Le système propose automatiquement au vendeur de récupérer et mettre à jour ses données certifiées lorsque la source redevient disponible
- **FR60:** Le système fonctionne en mode dégradé (données partielles) sans blocage du parcours utilisateur

---

## Non-Functional Requirements

### Performance

- **NFR1:** Les pages publiques SSR (annonces, recherche, landing) atteignent un LCP < 2.5s, un INP < 200ms, un CLS < 0.1, et un TTFB < 800ms
- **NFR2:** Le remplissage automatique via plaque/VIN retourne les données le plus rapidement possible avec une aspiration cible de 3 secondes maximum
- **NFR3:** Le score de visibilité se met à jour en moins de 500ms après chaque modification de champ pendant la création d'annonce
- **NFR4:** Les messages chat sont délivrés en moins de 1 seconde entre les participants
- **NFR5:** Les cockpits SPA (vendeur, modérateur, admin) chargent en moins de 2 secondes après authentification
- **NFR6:** Les résultats de recherche avec filtres multiples s'affichent en moins de 2 secondes
- **NFR7:** Les images sont optimisées et servies via CDN avec lazy loading pour les cards d'annonces

### Sécurité

- **NFR8:** Toutes les communications sont chiffrées en transit (HTTPS/TLS obligatoire)
- **NFR9:** Les données sensibles (informations personnelles, données de paiement) sont chiffrées au repos dans la base de données
- **NFR10:** L'authentification à deux facteurs (2FA) est disponible pour tous les comptes professionnels
- **NFR11:** Le traitement des paiements est conforme PCI-DSS (délégué au fournisseur de paiement certifié)
- **NFR12:** L'authentification forte SCA est appliquée conformément à la directive PSD2 pour les paiements européens
- **NFR13:** Les sessions utilisateur expirent après une période d'inactivité configurable
- **NFR14:** Toutes les opérations sensibles (paiement, modification de compte, actions modération, changements admin) sont enregistrées dans un audit trail horodaté
- **NFR15:** Les données personnelles sont traitées conformément au RGPD (anonymisation, portabilité, consentement, durées de conservation)
- **NFR16:** Les accès aux données sont journalisés et traçables par acteur et action

### Scalabilité

- **NFR17:** Le système supporte 3 000 annonces simultanées au lancement avec montée à 10 000+ dans les 3 mois sans dégradation de performance
- **NFR18:** Le système supporte des centaines de milliers de visiteurs mensuels avec des pics de trafic sans dégradation perceptible
- **NFR19:** L'architecture supporte l'ajout de nouveaux types de véhicules, champs de données, fournisseurs API, et règles métier sans modification de code
- **NFR20:** L'architecture est prête pour une expansion multi-pays (i18n, multi-devise, réglementation locale) sans refonte structurelle
- **NFR21:** Le système de chat temps réel supporte la montée en charge proportionnelle au nombre d'utilisateurs actifs simultanés

### Accessibilité

- **NFR22:** Le système est conforme WCAG 2.1 niveau AA et RGAA (Référentiel Général d'Amélioration de l'Accessibilité)
- **NFR23:** Toute navigation est possible au clavier sans nécessiter de souris
- **NFR24:** Les contrastes de couleurs respectent un ratio minimum de 4.5:1 pour le texte et 3:1 pour les éléments d'interface
- **NFR25:** Les badges de certification (🟢/🟡) possèdent un équivalent textuel accessible (pas uniquement la couleur comme vecteur d'information)
- **NFR26:** Les formulaires de création d'annonce sont accessibles (labels associés, messages d'erreur explicites, gestion du focus)
- **NFR27:** La structure sémantique des pages est correcte (hiérarchie des titres, landmarks ARIA, textes alternatifs sur les images)

### Intégration

- **NFR28:** Chaque intégration API externe est encapsulée derrière une interface d'adaptation (Adapter Pattern) permettant le remplacement du fournisseur sans modification du code métier
- **NFR29:** Chaque appel API externe est journalisé avec le fournisseur, le coût, le statut de réponse et le temps de réponse
- **NFR30:** Le système supporte le fonctionnement avec des fournisseurs API en mode mock (données simulées) pour le développement et les cas où un fournisseur n'est pas encore contractualisé
- **NFR31:** Le système d'authentification est délégué à un fournisseur d'identité externe avec gestion des rôles et groupes
- **NFR32:** Le système de paiement est intégré via un fournisseur certifié avec support SEPA et moyens de paiement européens

### Fiabilité

- **NFR33:** Le système tolère jusqu'à 48h d'indisponibilité d'un fournisseur API sans bloquer les parcours utilisateur
- **NFR34:** En cas d'indisponibilité API, le système bascule automatiquement en mode dégradé (saisie manuelle) et propose la re-synchronisation au retour de la source
- **NFR35:** Les données en cache local sont servies quand la source primaire est indisponible
- **NFR36:** Le système notifie l'administrateur en cas de défaillance d'un fournisseur API ou de dépassement de seuil configurable
- **NFR37:** Les transactions de paiement sont atomiques — une annonce n'est publiée que si le paiement est confirmé, sans état intermédiaire incohérent
