---
stepsCompleted: [1, 2, 3]
inputDocuments: ['brainstorming-session-2026-02-07.md']
workflowType: 'research'
lastStep: 3
research_type: 'technical'
research_topic: 'APIs données véhicules — publiques et privées'
research_goals: 'Cartographier toutes les APIs disponibles pour récupération automatique de données véhicule (publiques gratuites + privées payantes) et définir la stratégie V1 (gratuites + mock data)'
user_name: 'Nhan'
date: '2026-02-07'
web_research_enabled: true
source_verification: true
---

# Research Report: APIs Données Véhicules — France

**Date:** 2026-02-07
**Author:** Nhan
**Research Type:** Technical Feasibility
**Statut:** Complet

---

## Table des Matières

1. [Résumé Exécutif](#1-résumé-exécutif)
2. [APIs Publiques / État — Non Accessibles](#2-apis-publiques--état--non-accessibles)
3. [APIs Publiques Gratuites — Utilisables en V1](#3-apis-publiques-gratuites--utilisables-en-v1)
   - 3.1 [RappelConso — Rappels produits/véhicules](#31-rappelconso--rappels-produitsvéhicules)
   - 3.2 [ADEME Car Labelling — Émissions CO2 & consommation](#32-ademe-car-labelling--émissions-co2--consommation)
   - 3.3 [Crit'Air — Calcul local (algorithme)](#33-critair--calcul-local-algorithme)
4. [APIs Privées / Payantes — Mock Data en V1](#4-apis-privées--payantes--mock-data-en-v1)
   - 4.1 [apiplaqueimmatriculation.com](#41-apiplaqueimmatriculationcom)
   - 4.2 [AAA Data / SIVin](#42-aaa-data--sivin)
   - 4.3 [CarVertical B2B](#43-carvertical-b2b)
   - 4.4 [Autobiz — Cotation véhicule](#44-autobiz--cotation-véhicule)
   - 4.5 [Vincario (vindecoder.eu)](#45-vincario-vindecodereu)
   - 4.6 [OpenCars VIN Decoder](#46-opencars-vin-decoder)
5. [Tableau Comparatif Global](#5-tableau-comparatif-global)
6. [Stratégie d'Intégration V1](#6-stratégie-dintégration-v1)
7. [Architecture Adapter Pattern](#7-architecture-adapter-pattern)
8. [Sources & Références](#8-sources--références)

---

## 1. Résumé Exécutif

### Constat principal
Les APIs gouvernementales françaises directes (HistoVec, SIV, Contrôle Technique) ne sont **PAS accessibles** pour une plateforme de petites annonces. En revanche, il existe **3 sources publiques gratuites** exploitables immédiatement et **6 sources privées** utilisables à terme.

### Stratégie V1 retenue
- **Développer** avec les 3 APIs/données gratuites (RappelConso, ADEME, Crit'Air calcul local)
- **Mock data** pour les APIs payantes (structure identique, données fictives)
- **Architecture Adapter Pattern** pour brancher les vraies APIs plus tard sans modifier le code métier

### Cartographie rapide

| Source | Type | Coût | V1 | Données clés |
|--------|------|------|----|-------------|
| RappelConso | Publique | Gratuit | ✅ Réel | Rappels sécurité véhicules |
| ADEME Car Labelling | Publique | Gratuit | ✅ Réel | CO2, consommation, classe énergie |
| Crit'Air | Calcul local | Gratuit | ✅ Réel | Vignette Crit'Air (0-5) |
| apiplaqueimmatriculation | Privée | Dès 59€/mois | 🔶 Mock | 80+ champs techniques via plaque |
| AAA Data SIVin | Privée | Sur devis | 🔶 Mock | 51 champs, référence marché |
| CarVertical | Privée | ~7-25€/rapport | 🔶 Mock | Historique, fraude, km |
| Autobiz | Privée | Sur devis | 🔶 Mock | Cotation/valorisation B2B/B2C |
| Vincario | Privée | Dès $50/200 VIN | 🔶 Mock | Décodage VIN, 40-50 champs |
| OpenCars | Open Source | Gratuit | ⚪ Optionnel | Validation VIN basique |
| **NHTSA vPIC** | **Publique US** | **Gratuit** | **✅ Réel** | **136+ champs VIN (moteur, ADAS, sécurité)** |
| JATO Dynamics | Privée | Sur devis (élevé) | 🔶 Mock | 1000+ datapoints, plaque+VIN, options usine |
| TecDoc (TecAlliance) | Privée | ~219€/an + devis API | 🔶 Mock | Catalogue 9.8M pièces, K-Type |
| ETAI / Atelio Data | Privée | Sur devis | 🔶 Mock | Données tech FR, recherche plaque, réparation |
| Autodata | Privée | Sur devis | 🔶 Mock | Entretien, couples serrage, schémas |
| HaynesPro | Privée | Dès 69$/mois | 🔶 Mock | Réparation, 100K+ dessins techniques |
| Auto-Data.net | Privée | Sur devis | 🔶 Mock | 55K specs, 120+ paramètres |

> **Rapport complémentaire détaillé :** Voir [`technical-mechanical-apis-research-2026-02-08.md`](./technical-mechanical-apis-research-2026-02-08.md) pour les APIs techniques/mécaniques (pièces, moteur, entretien, sécurité)

---

## 2. APIs Publiques / État — Non Accessibles

### 2.1 HistoVec (histovec.interieur.gouv.fr)
- **Statut :** ❌ PAS d'API publique
- **Confirmation :** Issue GitHub #336 sur le dépôt officiel confirme l'absence d'API
- **Accès :** Uniquement via l'interface web, nécessite la carte grise du propriétaire
- **Alternative :** CarVertical ou AAA Data SIVin pour l'historique

### 2.2 SIV — Système d'Immatriculation des Véhicules
- **Statut :** ❌ Accès habilitation uniquement
- **Conditions :** 1 an d'activité minimum, autorisation préfectorale, contrôles réguliers
- **Cible :** Professionnels de l'automobile habilités (concessionnaires, assureurs)
- **Alternative :** AAA Data SIVin (accès commercial aux mêmes données)

### 2.3 API Particulier ANTS
- **Statut :** ❌ Réservé aux collectivités territoriales
- **Non applicable** pour une entreprise privée

### 2.4 Contrôle Technique (UTAC-OTC)
- **Statut :** ❌ Pas d'API publique
- **Les données CT** ne sont pas accessibles programmatiquement
- **Alternative :** Upload du rapport CT par le vendeur (déjà prévu dans le cahier des charges)

---

## 3. APIs Publiques Gratuites — Utilisables en V1

### 3.1 RappelConso — Rappels produits/véhicules

**Plateforme :** OpenDataSoft hébergé par le Ministère de l'Économie
**Licence :** Licence Ouverte v2.0 (Etalab) — usage commercial autorisé
**Authentification :** Aucune requise
**Format :** JSON, CSV, XLSX, Parquet

#### Base URL
```
https://data.economie.gouv.fr/api/explore/v2.1
```

#### Dataset recommandé
`rappelconso-v2-gtin-espaces` — contient **1 533 rappels** catégorie "automobiles, motos, scooters"

⚠️ **Important :** Ne PAS utiliser `rappelconso-v2-gtin-trie` qui ne contient que 123 entrées auto.

#### Endpoints principaux

| Endpoint | Usage |
|----------|-------|
| `/catalog/datasets/{id}/records` | Recherche avec filtres (max 100/page) |
| `/catalog/datasets/{id}/exports/json` | Export complet sans limite |
| `/catalog/datasets/{id}/facets` | Valeurs agrégées (marques, catégories) |

#### Exemples de requêtes

**Rappels par marque :**
```
GET /catalog/datasets/rappelconso-v2-gtin-espaces/records
  ?where=sous_categorie_produit="automobiles, motos, scooters"
    AND marque_produit="peugeot"
  &order_by=date_publication DESC
  &limit=20
```

**Recherche texte libre :**
```
GET .../records?where=search(marque_produit,"mercedes")&limit=10
```

**Comptage par marque :**
```
GET .../records
  ?select=count(*) as total, marque_produit
  &group_by=marque_produit
  &where=sous_categorie_produit="automobiles, motos, scooters"
  &order_by=total DESC
```

#### Champs de réponse (35 champs)

| Champ | Type | Description |
|-------|------|-------------|
| `id` | int | ID unique du rappel |
| `numero_fiche` | text | Numéro de fiche (ex: "sr/00280/26") |
| `date_publication` | datetime | Date de publication (ISO 8601) |
| `categorie_produit` | text | Catégorie produit |
| `sous_categorie_produit` | text | Sous-catégorie |
| `marque_produit` | text | Marque (lowercase) |
| `modeles_ou_references` | text | Modèles concernés |
| `motif_rappel` | text | **Motif du rappel** (texte libre) |
| `risques_encourus` | text | Risques (blessures, incendie...) |
| `identification_produits` | array | Identification lot/dates |
| `informations_complementaires` | text | Infos complémentaires |
| `lien_vers_affichette_pdf` | text | Lien PDF affichette |
| `lien_vers_la_fiche_rappel` | text | Lien fiche complète |
| `liens_vers_les_images` | text | URLs images (pipe-delimited) |
| `modalites_de_compensation` | text | Remboursement/échange |
| `date_de_fin_de_la_procedure_de_rappel` | date | Fin procédure |

#### Notes d'intégration
- ⚠️ Toutes les valeurs sont en **lowercase** — requêtes en minuscules obligatoires
- ⚠️ Noms de marques **inconsistants** (ex: "citroen", "citroën", "citroen & ds") → utiliser `search()` ou `LIKE`
- Champs multi-valeurs séparés par `|`
- Rate limits via headers `X-RateLimit-*` (quotas quotidiens, généralement très généreux)
- Mise à jour : **hebdomadaire**

---

### 3.2 ADEME Car Labelling — Émissions CO2 & consommation

**Source :** ADEME (Agence de l'Environnement et de la Maîtrise de l'Énergie)
**Données origine :** UTAC (homologation véhicules France)
**Licence :** Open Data — usage commercial autorisé
**Authentification :** Aucune requise
**Couverture :** ~3 650 à 8 000+ véhicules/an, données depuis 2001

#### Sources de données (3 accès)

| Plateforme | URL | Type |
|------------|-----|------|
| **ADEME Data-Fair** | `https://data.ademe.fr/data-fair/api/v1/datasets/ademe-car-labelling` | API REST |
| **OpenDataSoft** | `https://data.opendatasoft.com/api/explore/v2.1/catalog/datasets/vehicules-commercialises@public` | API REST |
| **data.gouv.fr** | `https://www.data.gouv.fr/datasets/ademe-car-labelling` | CSV téléchargement |

#### Accès recommandé : OpenDataSoft (meilleure syntaxe de requêtes)

**Base URL :**
```
https://data.opendatasoft.com/api/explore/v2.1/catalog/datasets/vehicules-commercialises@public/records
```

**Exemple — Recherche Renault Clio :**
```
GET .../records
  ?where=marque="RENAULT" AND designation_commerciale LIKE "CLIO"
  &select=marque,designation_commerciale,co2_mixte,energie
  &limit=50
```

#### Accès alternatif : ADEME Data-Fair (bulk/pagination)

**Téléchargement CSV complet :**
```
GET https://data.ademe.fr/data-fair/api/v1/datasets/ademe-car-labelling/raw
```

**Requête paginée :**
```
GET .../lines?qs=RENAULT&size=100&page=1
```

**Spec OpenAPI :**
```
GET .../api-docs.json
```

#### Champs disponibles (49+ champs)

**Identification véhicule :**

| Champ | Description |
|-------|-------------|
| `Marque` | Marque (RENAULT, PEUGEOT, BMW...) |
| `Libelle modele` | Nom commercial |
| `Modele` | Code modèle |
| `Groupe` | Groupe constructeur |
| `Description Commerciale` | Description complète |
| `Gamme` | Segment (berline, SUV...) |
| `Carrosserie` | Type carrosserie |

**Motorisation & technique :**

| Champ | Description |
|-------|-------------|
| `Energie` | Type carburant (Essence, Diesel, Electrique, Hybride) |
| `Cylindree` | Cylindrée (cm³) |
| `Puissance fiscale` | Chevaux fiscaux (CV) |
| `Puissance maximale` | Puissance max (kW) |
| `Puissance nominale electrique` | Puissance électrique (kW) — hybride/EV |
| `Poids a vide` | Poids à vide (kg) |
| `Type de boite` | Boîte (manuelle, automatique) |
| `Nombre rapports` | Nombre de vitesses |

**Consommation WLTP (L/100km) :**

| Champ | Description |
|-------|-------------|
| `Conso basse vitesse Min/Max` | Conso basse vitesse |
| `Conso moyenne vitesse Min/Max` | Conso moyenne vitesse |
| `Conso haute vitesse Min/Max` | Conso haute vitesse |
| `Conso T-haute vitesse Min/Max` | Conso très haute vitesse |
| `Conso vitesse mixte Min/Max` | **Conso mixte** (valeur principale) |
| `Conso elec Min/Max` | Conso électrique (kWh/100km) |

**Émissions CO2 WLTP (g/km) :**

| Champ | Description |
|-------|-------------|
| `CO2 vitesse mixte Min/Max` | **CO2 mixte** (valeur principale) |
| `CO2 basse/moyenne/haute/T-haute vitesse` | CO2 par phase WLTP |
| `Essai CO2 type 1` | CO2 homologation officielle |

**Émissions polluants :**

| Champ | Description |
|-------|-------------|
| `Essai HC` | Hydrocarbures |
| `Essai Nox` | Oxydes d'azote |
| `Essai particules` | Particules fines |

**Véhicules électriques :**

| Champ | Description |
|-------|-------------|
| `Autonomie elec Min/Max` | Autonomie électrique (km) |
| `Autonomie elec urbain Min/Max` | Autonomie urbaine (km) |

**Champs enrichis ADEME :**

| Champ | Description |
|-------|-------------|
| `Classe Energie / CO2` | Classe énergie (A à G) |
| `Bonus / Malus` | Montant bonus/malus écologique (€) |
| `Cout annuel carburant` | Coût annuel carburant (15 000 km/an) |
| `Crit'Air` | Classe Crit'Air (0-5) |
| `Norme Euro` | Norme Euro |

#### Notes d'intégration
- Mise à jour **trimestrielle** (janvier, avril, juillet, octobre)
- Dernière mise à jour : **décembre 2025**
- Recherche par marque/modèle — **pas par immatriculation ni VIN**
- Idéal pour : enrichir une fiche véhicule avec données techniques officielles après identification du modèle

---

### 3.3 Crit'Air — Calcul local (algorithme)

**Source :** Arrêté du 21 juin 2016, modifié 4 octobre 2022 et 5 juillet 2023
**Coût :** Gratuit — calcul interne, pas d'API nécessaire
**Données requises :** Type carburant + Norme Euro (ou date 1ère immatriculation)

#### Algorithme de classification

**Étape 1 — Vérification prioritaire du carburant :**
```
SI carburant = Électrique OU Hydrogène → Crit'Air 0
SI carburant = GPL/GNV/CNG/LNG/biogaz → Crit'Air 1
SI carburant = Hybride rechargeable (PHEV) → Crit'Air 1
```
⚠️ **Les hybrides NON rechargeables** suivent les règles de leur carburant thermique.

**Étape 2 — Détermination norme Euro si inconnue (par date 1ère immatriculation) :**

*Voitures & utilitaires légers (M1, N1) :*

| Norme Euro | Date début | Date fin |
|------------|-----------|----------|
| Euro 1 | 01/01/1993 | 30/06/1996 |
| Euro 2 | 01/07/1996 | 31/12/2000 |
| Euro 3 | 01/01/2001 | 31/12/2005 |
| Euro 4 | 01/01/2006 | 31/12/2010 |
| Euro 5 | 01/01/2011 | 31/08/2015 |
| Euro 6 | 01/09/2015 | (actuel) |

*Poids lourds (N2, N3, M3) :*

| Norme Euro | Date début | Date fin |
|------------|-----------|----------|
| Euro I | 01/10/1993 | 30/09/1996 |
| Euro II | 01/10/1996 | 30/09/2001 |
| Euro III | 01/10/2001 | 30/09/2006 |
| Euro IV | 01/10/2006 | 30/09/2009 |
| Euro V | 01/10/2009 | 31/12/2013 |
| Euro VI | 01/01/2014 | (actuel) |

*Deux-roues (catégorie L) :*

| Norme Euro | Date début | Date fin |
|------------|-----------|----------|
| Aucune | avant 01/06/2000 | 31/05/2000 |
| Euro 1 | 01/06/2000 | 30/06/2004 |
| Euro 2 | 01/07/2004 | 31/12/2006 |
| Euro 3 | 01/01/2007 | 31/12/2016 |
| Euro 4 | 01/01/2017 | (actuel) |

⚠️ Cyclomoteurs (L1e, L2e) : Euro 4 à partir du 01/01/**2018**.

**Étape 3 — Classification Carburant × Norme Euro :**

*Voitures & utilitaires légers (M1, N1) :*

| Carburant | Norme Euro | Crit'Air |
|-----------|-----------|----------|
| Essence | Euro 5, 6 | **1** 🟣 |
| Essence | Euro 4 | **2** 🟡 |
| Diesel | Euro 5, 6 | **2** 🟡 |
| Essence | Euro 2, 3 | **3** 🟠 |
| Diesel | Euro 4 | **3** 🟠 |
| Diesel | Euro 3 | **4** 🟤 |
| Diesel | Euro 2 | **5** ⚪ |
| Tout (non-élec) | Euro 1 ou avant | **Non classé** |

*Poids lourds (N2, N3, M3) :*

| Carburant | Norme Euro | Crit'Air |
|-----------|-----------|----------|
| Essence | Euro VI | **1** 🟣 |
| Essence | Euro V | **2** 🟡 |
| Diesel | Euro VI | **2** 🟡 |
| Essence | Euro III, IV | **3** 🟠 |
| Diesel | Euro V | **3** 🟠 |
| Diesel | Euro IV | **4** 🟤 |
| Diesel | Euro III | **5** ⚪ |
| Tout | Euro I, II ou avant | **Non classé** |

*Deux-roues (catégorie L) :*

| Norme Euro | Crit'Air |
|-----------|----------|
| Euro 4 | **1** 🟣 |
| Euro 3 | **2** 🟡 |
| Euro 2 | **3** 🟠 |
| Euro 1 | **4** 🟤 |
| Aucune | **Non classé** |

#### Couleurs des vignettes

| Classe | Couleur | Hex approx. |
|--------|---------|-------------|
| 0 | Vert/Blanc | #00A651 |
| 1 | Violet | #7B2D8E |
| 2 | Jaune | #F7D117 |
| 3 | Orange | #F5841F |
| 4 | Bordeaux | #8B2332 |
| 5 | Gris | #6D6E71 |
| Non classé | Pas de vignette | — |

#### Cas spéciaux
- **Retrofit électrique** (P.3 = "EL" sur carte grise) → Crit'Air 0
- **Retrofit GPL/GNV** avec carte grise mise à jour → Crit'Air 1
- **E85/Bioéthanol** → classé comme essence (même normes)
- **Camping-cars** → selon catégorie administrative (M1 si ≤3.5t, sinon PL)
- **Sous-variantes Euro 6** (6b, 6c, 6d-TEMP, 6d, 6e) → tous traités identiquement
- **Classification permanente** pour la vie du véhicule (sauf changement carburant carte grise)

#### Pseudocode d'implémentation
```javascript
function getCritAir(vehicleCategory, fuelType, euroNorm, registrationDate) {
  // Priorité 1 : carburant spécial
  if (['electric', 'hydrogen'].includes(fuelType)) return 0;
  if (['GPL', 'GNV', 'CNG', 'LNG', 'biogaz'].includes(fuelType)) return 1;
  if (fuelType === 'hybrid_rechargeable') return 1;

  // Priorité 2 : déterminer norme Euro si inconnue
  if (!euroNorm) euroNorm = getEuroFromDate(vehicleCategory, registrationDate);

  // Priorité 3 : classification par catégorie
  if (['M1', 'N1'].includes(vehicleCategory)) {
    if (fuelType === 'petrol') {
      if (['Euro 6', 'Euro 5'].includes(euroNorm)) return 1;
      if (euroNorm === 'Euro 4') return 2;
      if (['Euro 3', 'Euro 2'].includes(euroNorm)) return 3;
      return 'non_classe';
    }
    if (fuelType === 'diesel') {
      if (['Euro 6', 'Euro 5'].includes(euroNorm)) return 2;
      if (euroNorm === 'Euro 4') return 3;
      if (euroNorm === 'Euro 3') return 4;
      if (euroNorm === 'Euro 2') return 5;
      return 'non_classe';
    }
  }
  // ... (poids lourds et deux-roues : même logique)
}
```

#### Règle mnémotechnique
> Le diesel est **toujours 1 classe Crit'Air de plus** (= pire) que l'essence pour la même norme Euro.

---

## 4. APIs Privées / Payantes — Mock Data en V1

### 4.1 apiplaqueimmatriculation.com

**Statut V1 :** 🔶 Mock Data
**Intérêt :** AUTO-REMPLISSAGE formulaire via plaque — **API principale pour le flux vendeur**

| Caractéristique | Détail |
|-----------------|--------|
| **Base URL** | `https://api.apiplaqueimmatriculation.com/plaque` |
| **Méthode** | POST |
| **Recherche par** | Plaque d'immatriculation (FR: AB-123-CD) |
| **Auth** | Token API (fourni à l'inscription) |
| **Paramètres** | `immatriculation`, `token`, `pays` |
| **Format réponse** | JSON ou XML |
| **Couverture** | France, Espagne, UK (500M+ plaques) |
| **Temps réponse** | < 2 secondes |

**Tarifs :**

| Plan | Prix | Requêtes/mois |
|------|------|--------------|
| Standard | 59€/mois | ~800 |
| Business | ~99€/mois | ~1 000 |
| Annuel | ~20% remise | Variable |

**Pas de tier gratuit.** Page démo sur le site pour test unitaire.

**Champs retournés (80+) :**
- Marque, Modèle, Version, Type MINE
- VIN
- Couleur
- Puissance fiscale, Puissance réelle (kW)
- Type carrosserie
- Code moteur, Cylindres, Cylindrée
- Énergie (carburant), CO2
- Poids, PTAC
- Places, Vitesses
- Date mise en circulation
- TecDoc K-Type ID, Dimensions

**Mock data spec :** Créer un JSON avec les 80+ champs, valeurs réalistes par marque/modèle.

---

### 4.2 AAA Data / SIVin

**Statut V1 :** 🔶 Mock Data
**Intérêt :** Référence du marché français — données les plus complètes

| Caractéristique | Détail |
|-----------------|--------|
| **Base URL** | `https://api.sivin.fr` |
| **Recherche par** | Plaque OU VIN OU SIREN (flottes) |
| **Auth** | OAuth2 + JWT (1h lifetime) + IP whitelistée |
| **Couverture** | France — 75 millions de véhicules |
| **Opérationnel depuis** | 2008 |

**Tarifs :** Sur devis uniquement. Contact via `aaa-data.fr`. Référence : service Auto-Immat ~52€ HT/mois (abo annuel).

**Champs retournés (51) :**
- Marque, Modèle, Version
- Type véhicule (voiture, moto, camionnette, camping-car)
- Puissance, Cylindrée, Énergie
- CO2, Date 1ère immatriculation
- Couleur, Poids, PTAC, Places

**Sécurité :** HTTP 401 (token invalide), HTTP 403 (IP non autorisée ou quota dépassé).

**Mock data spec :** Créer un JSON avec 51 champs incluant la structure OAuth2.

---

### 4.3 CarVertical B2B

**Statut V1 :** 🔶 Mock Data
**Intérêt :** Historique véhicule, détection fraude — **confiance acheteur**

| Caractéristique | Détail |
|-----------------|--------|
| **Portail dev** | `developer.carvertical.com` |
| **Recherche par** | VIN uniquement (pas de plaque) |
| **Auth** | Inscription portail développeur, API key après validation |
| **Couverture** | 40+ pays, 900+ sources, 300M+ historiques dommages |

**Tarifs :**

| Plan | Prix |
|------|------|
| Particulier | 24,99€/rapport |
| Bundle 3 | ~34,99€ |
| Bundle 5 | ~43,99€ |
| B2B (10/30/100) | Jusqu'à **-75%** vs prix unitaire |
| API | Sur devis, volume-based |

**Données retournées :**
- Historique kilométrique + détection rollback
- Historique dommages (localisation, timing)
- Vérification vol
- Alerte import US
- Photos anciennes du véhicule
- Décodage VIN basique (marque, modèle, année, specs)

**⚠️ Limitation :** VIN uniquement — nécessite une étape plaque→VIN en amont.

**Mock data spec :** Créer un rapport type avec sections historique km, dommages, vol, photos.

---

### 4.4 Autobiz — Cotation véhicule

**Statut V1 :** 🔶 Mock Data
**Intérêt :** Estimation prix marché — **comparaison prix annonce**

| Caractéristique | Détail |
|-----------------|--------|
| **Accès** | Endpoint custom (via package npm `autobiz-client`) |
| **Recherche par** | Marque/Modèle/Version/Caractéristiques |
| **Auth** | API Key + email/password → JWT |
| **Couverture** | 22 pays européens, 15 Md+ data points |

**Tarifs :** Sur devis. Enterprise B2B uniquement.

**Données retournées (cotation) :**

| Donnée | Description |
|--------|-------------|
| Valeur B2C | Prix marché retail |
| Valeur B2B | Prix marché wholesale |
| VRADE | Valeur Résiduelle à Dire d'Expert |
| Valeur reprise | Prix trade-in |
| Rotation stock | Turnover |
| Score attractivité | Attractivité véhicule |
| Ventes 12 mois | Volume transactions |
| Temps de vente | Time-to-sell |

**Postman public :** Workspace "AUTOBIZAPP" disponible pour explorer la structure.

**Mock data spec :** Créer un JSON cotation avec fourchettes prix B2B/B2C/reprise et métriques marché.

---

### 4.5 Vincario (vindecoder.eu)

**Statut V1 :** 🔶 Mock Data (mais free tier testable)
**Intérêt :** Décodage VIN détaillé

| Caractéristique | Détail |
|-----------------|--------|
| **Base URL** | `https://api.vincario.com/3.2/` |
| **Recherche par** | VIN uniquement (format: `VIN|ID|API_key|Secret_key`) |
| **Auth** | API Key + Secret Key |

**Tarifs :**

| Plan | Lookups | Prix | /lookup |
|------|---------|------|---------|
| **Free Trial** | **20** | **$0** | $0 |
| Basic | 200 | $50 | $0.25 |
| Standard | 1 000 | $200 | $0.20 |
| Custom | Négociable | SEPA/facture | Volume |

✅ **VIN invalides non facturés.** Re-queries sur même VIN gratuites.

**Endpoints :**

| Endpoint | Description |
|----------|-------------|
| VIN Decode Info | Spécifications techniques complètes |
| OEM VIN Lookup | Données constructeur |
| Vehicle Market Value | Estimation prix marché |
| Stolen Check | Base police nationale |
| Balance | Vérifier crédits restants |

**Champs retournés (~40-50) :**
- Marque, Modèle, Année, Type produit
- Carrosserie, Série, Transmission
- Carburant, Type moteur, Cylindrée
- Vitesses, Portes, Places
- Norme Euro, CO2 moyen
- Constructeur, Usine
- Direction, Freins, Suspension
- Dimensions (L×l×h en mm)
- Poids (à vide, PTAC)
- Volume coffre, Vitesse max

---

### 4.6 OpenCars VIN Decoder

**Statut V1 :** ⚪ Optionnel (validation VIN pré-appel API payante)
**Intérêt limité :** Décodage structure VIN basique uniquement

| Caractéristique | Détail |
|-----------------|--------|
| **Repository** | `github.com/opencars/vin-decoder-api` |
| **Langage** | Go |
| **BDD** | PostgreSQL (WMI data) |
| **Licence** | MIT |
| **Interfaces** | HTTP REST + gRPC |

**Données :** WMI (positions 1-3), VDS (4-9), VIS (10-17), check digit, pays d'origine, constructeur.

**Limitations :**
- ❌ Ne retourne PAS les specs détaillées (modèle, moteur, carburant...)
- ❌ Pas de recherche par plaque
- ❌ Projet principal marqué DEPRECATED
- ❌ Conçu initialement pour données ukrainiennes
- Self-hosted uniquement

**Usage potentiel :** Validation checksum VIN avant appel API payante → économie de crédits.

---

## 5. Tableau Comparatif Global

| API | Plaque | VIN | Gratuit | Specs tech | Historique | Prix marché | Rappels | Émissions |
|-----|--------|-----|---------|------------|------------|-------------|---------|-----------|
| RappelConso | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| ADEME | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Crit'Air (calcul) | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| apiplaqueimmat. | ✅ | ❌ | ❌ | ✅✅ | ❌ | ❌ | ❌ | ✅ |
| AAA Data SIVin | ✅ | ✅ | ❌ | ✅✅ | ❌ | ❌ | ❌ | ✅ |
| CarVertical | ❌ | ✅ | ❌ | ✅ | ✅✅ | ❌ | ❌ | ❌ |
| Autobiz | ❌ | ❌ | ❌ | ❌ | ❌ | ✅✅ | ❌ | ❌ |
| Vincario | ❌ | ✅ | 🟡 20 | ✅✅ | ❌ | ✅ | ❌ | ✅ |
| OpenCars | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 6. Stratégie d'Intégration V1

### Phase V1 : APIs gratuites + mock data

```
┌─────────────────────────────────────────────────────────┐
│                    FLUX VENDEUR V1                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. Vendeur entre PLAQUE ou VIN                          │
│     └─→ [MOCK] apiplaqueimmatriculation / SIVin          │
│         → Auto-remplissage 80+ champs (données fictives) │
│                                                          │
│  2. VIN identifié → enrichissement technique             │
│     ├─→ [RÉEL] NHTSA vPIC → specs moteur, ADAS, sécurité│
│     ├─→ [RÉEL] ADEME → CO2, consommation, classe énergie│
│     ├─→ [RÉEL] Crit'Air (calcul local)                  │
│     └─→ [RÉEL] RappelConso → rappels sécurité           │
│                                                          │
│  3. Vendeur complète infos manuelles                     │
│     └─→ Kilométrage, état, photos, CT upload             │
│                                                          │
│  4. Enrichissement historique                             │
│     └─→ [MOCK] CarVertical → historique, fraude          │
│                                                          │
│  5. Estimation prix                                      │
│     └─→ [MOCK] Autobiz → cotation B2B/B2C               │
│                                                          │
│  6. Badge certification par champ                        │
│     ├─ 🟢 Source publique (ADEME, RappelConso, Crit'Air,│
│     │      NHTSA vPIC)                                   │
│     ├─ 🔵 Rapport tiers (CarVertical mock)               │
│     ├─ 📄 Document vendeur (CT upload)                   │
│     └─ 🟡 Déclaré vendeur (saisie manuelle)             │
│                                                          │
│  7. Déclaration sur l'honneur                            │
│     └─→ Toutes données (état + vendeur) + signature N2  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Phase V2 : Branchement APIs payantes

Grâce à l'**Adapter Pattern**, le passage mock → réel se fait par :
1. Changement de configuration en base de données (table `config_api_providers`)
2. Implémentation du nouvel adapter (même interface)
3. Aucune modification du code métier

### Données à stocker en base (résilience)

Toutes les données récupérées via API sont **persistées en base** pour :
- Fonctionnement offline si API down
- Historique des valeurs
- Job de rafraîchissement configurable (admin dashboard)

---

## 7. Architecture Adapter Pattern

```
┌──────────────────────────────────────────────────────────┐
│                   SERVICE LAYER                           │
│                                                           │
│  VehicleDataService                                       │
│  ├── getVehicleByPlate(plate) → VehicleData              │
│  ├── getVehicleByVIN(vin) → VehicleData                  │
│  ├── getEmissions(brand, model) → EmissionData           │
│  ├── getRecalls(brand, model) → RecallData[]             │
│  ├── getCritAir(fuel, euroNorm, date) → CritAirClass     │
│  ├── getHistory(vin) → HistoryReport                     │
│  └── getMarketValue(vehicle) → ValuationData             │
│                                                           │
├──────────────────────────────────────────────────────────┤
│                   ADAPTER INTERFACE                        │
│                                                           │
│  IVehicleLookupAdapter                                    │
│  ├── MockVehicleLookupAdapter     ← V1 (mock data)      │
│  ├── ApiPlaqueLookupAdapter       ← V2 (payant)         │
│  └── SIVinLookupAdapter           ← V2+ (entreprise)    │
│                                                           │
│  IEmissionAdapter                                         │
│  ├── ADEMEEmissionAdapter         ← V1 (gratuit)        │
│  └── VincarioEmissionAdapter      ← V2 (par VIN)        │
│                                                           │
│  IRecallAdapter                                           │
│  └── RappelConsoAdapter           ← V1 (gratuit)        │
│                                                           │
│  ICritAirCalculator                                       │
│  └── LocalCritAirCalculator       ← V1 (calcul local)   │
│                                                           │
│  IHistoryAdapter                                          │
│  ├── MockHistoryAdapter           ← V1 (mock)           │
│  └── CarVerticalAdapter           ← V2 (payant)         │
│                                                           │
│  IValuationAdapter                                        │
│  ├── MockValuationAdapter         ← V1 (mock)           │
│  └── AutobizAdapter               ← V2 (payant)         │
│                                                           │
│  IVINTechnicalAdapter  (NOUVEAU — specs moteur/ADAS)     │
│  ├── NHTSAVpicAdapter             ← V1 (gratuit)        │
│  ├── VincarioTechnicalAdapter     ← V2 (payant)         │
│  └── JATOSpecsAdapter             ← V3 (premium)        │
│                                                           │
│  IPartsAdapter  (NOUVEAU — catalogue pièces)             │
│  ├── MockPartsAdapter             ← V1 (mock)           │
│  └── TecDocPartsAdapter           ← V3 (payant)         │
│                                                           │
│  IMaintenanceAdapter  (NOUVEAU — entretien/réparation)   │
│  ├── MockMaintenanceAdapter       ← V1 (mock)           │
│  ├── AutodataAdapter              ← V3 option A         │
│  ├── HaynesProAdapter             ← V3 option B         │
│  └── ETAIAtelioAdapter            ← V3 option C (FR)    │
│                                                           │
│  ISafetyRatingAdapter  (NOUVEAU — notes sécurité)        │
│  ├── NHTSANcapAdapter             ← V1 (gratuit/vPIC)   │
│  └── EuroNcapAdapter              ← V3 (licence)        │
│                                                           │
├──────────────────────────────────────────────────────────┤
│                   CONFIG (PostgreSQL)                      │
│                                                           │
│  config_api_providers                                     │
│  ├── provider_key: 'vehicle_lookup'                      │
│  │   adapter_class: 'MockVehicleLookupAdapter'           │
│  │   active: true                                         │
│  ├── provider_key: 'emissions'                            │
│  │   adapter_class: 'ADEMEEmissionAdapter'               │
│  │   active: true                                         │
│  └── ...                                                  │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

---

## 8. Sources & Références

### APIs Publiques
- [RappelConso V2 — data.economie.gouv.fr](https://data.economie.gouv.fr/explore/dataset/rappelconso-v2-gtin-espaces/api/)
- [API RappelConso — api.gouv.fr](https://api.gouv.fr/les-api/api-rappel-conso)
- [ADEME Car Labelling — data.ademe.fr](https://data.ademe.fr/datasets/ademe-car-labelling)
- [ADEME Car Labelling — carlabelling.ademe.fr](https://carlabelling.ademe.fr/)
- [ADEME sur OpenDataSoft](https://data.opendatasoft.com/explore/dataset/vehicules-commercialises@public/)
- [Certificat-air.gouv.fr — Tables de classification](https://www.certificat-air.gouv.fr/docs/tableaux_classement.pdf)
- [Arrêté du 21 juin 2016 — Legifrance](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000032749723)
- [Service-public.fr — Vignette Crit'Air](https://www.service-public.fr/particuliers/vosdroits/F33371)

### APIs Privées
- [apiplaqueimmatriculation.com](https://www.apiplaqueimmatriculation.com/)
- [AAA Data — SIVin](https://www.aaa-data.fr/informations-sivin-api-rest/)
- [CarVertical Business](https://www.carvertical.com/business/api)
- [CarVertical Developer Portal](https://developer.carvertical.com/)
- [Autobiz Corporate](https://corporate.autobiz.com/)
- [Vincario / vindecoder.eu](https://vindecoder.eu/pricing/api)
- [OpenCars VIN Decoder — GitHub](https://github.com/opencars/vin-decoder-api)

### APIs Techniques / Pièces / Entretien (détail dans rapport complémentaire)
- [NHTSA vPIC API — Gratuit](https://vpic.nhtsa.dot.gov/api/)
- [JATO Dynamics Developer Portal](https://developer.jato.com/)
- [TecAlliance TecDoc](https://www.tecalliance.net/tecdoc-catalogue/)
- [Autodata Developer Portal](https://developer.autodata-group.com/)
- [HaynesPro WebAPI](https://www.haynespro.co.uk/products/vehicle-technical-webapi)
- [ETAI / Infopro Digital Automotive](https://www.infopro-digital-automotive.com/fr/)
- [Auto-Data.net API](https://api.auto-data.net/)

### APIs État — Non accessibles
- [HistoVec — GitHub Issue #336](https://github.com/histovec/histovec-beta/issues/336)
- [API Particulier ANTS — api.gouv.fr](https://api.gouv.fr/les-api/api-particulier)

---

*Document généré le 2026-02-07 — Recherche technique complète pour le projet de plateforme petites annonces véhicules.*
