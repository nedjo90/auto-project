---
stepsCompleted: [1, 2, 3]
inputDocuments: ['technical-apis-etat-vehicules-research-2026-02-07.md']
workflowType: 'research'
lastStep: 3
research_type: 'technical'
research_topic: 'APIs donnees techniques/mecaniques vehicules — specs moteur, pieces, maintenance'
research_goals: 'Identifier toutes les APIs fournissant des donnees techniques approfondies (specs moteur, catalogues pieces, intervalles entretien, diagrammes techniques) accessibles par plaque ou VIN'
user_name: 'Nhan'
date: '2026-02-08'
web_research_enabled: true
source_verification: true
---

# Research Report: APIs Donnees Techniques & Mecaniques Vehicules

**Date:** 2026-02-08
**Author:** Nhan
**Research Type:** Technical Feasibility (complement au rapport du 2026-02-07)
**Statut:** Complet

---

## Table des Matieres

1. [Resume Executif](#1-resume-executif)
2. [API Gratuite — NHTSA vPIC](#2-api-gratuite--nhtsa-vpic)
3. [APIs Catalogues Pieces — TecDoc & PartsLink24](#3-apis-catalogues-pieces--tecdoc--partslink24)
4. [APIs Donnees Techniques / Reparation — Autodata, HaynesPro, ETAI](#4-apis-donnees-techniques--reparation--autodata-haynespro-etai)
5. [APIs Specifications Vehicules — JATO, Auto-Data.net, CarAPI, VehicleDatabases](#5-apis-specifications-vehicules--jato-auto-datanet-carapi-vehicledatabases)
6. [APIs Securite — Euro NCAP & NHTSA NCAP](#6-apis-securite--euro-ncap--nhtsa-ncap)
7. [APIs France specifiques — AAA Data SIVin (complement)](#7-apis-france-specifiques--aaa-data-sivin-complement)
8. [OATS — Standards ouverts](#8-oats--standards-ouverts)
9. [Tableau Comparatif Global](#9-tableau-comparatif-global)
10. [Recommandations pour la plateforme](#10-recommandations-pour-la-plateforme)
11. [Sources & References](#11-sources--references)

---

## 1. Resume Executif

### Objectif
Ce document complete le rapport du 2026-02-07 (APIs donnees vehicules France) en se concentrant specifiquement sur les **donnees techniques/mecaniques approfondies** : specifications moteur, catalogues pieces, intervalles d'entretien, compatibilite pieces, diagrammes techniques.

### Synthese des trouvailles

| API | Type | Cout | Donnees cles | Pertinence FR |
|-----|------|------|-------------|---------------|
| **NHTSA vPIC** | Publique | Gratuit | 136+ champs VIN (moteur, securite, equipements) | Moyenne (US mais global) |
| **TecDoc (TecAlliance)** | Privee | ~219EUR/an (catalogue) + devis API | Catalogue 9.8M pieces, 190K vehicules, K-Type | Tres haute |
| **PartsLink24** | Privee | Sur devis | Catalogues OEM 15+ marques premium | Moyenne |
| **Autodata** | Privee | Sur devis | Specs, entretien, couples serrage, schemas | Haute |
| **HaynesPro** | Privee | Des 69$/mois | Reparation, schemas electriques, DTCs | Haute |
| **ETAI/Atelio Data** | Privee | Sur devis | Donnees techniques FR, methodes reparation | Tres haute |
| **JATO Dynamics** | Privee | Sur devis | 1000+ datapoints/vehicule, VIN/VRM decode | Tres haute |
| **Auto-Data.net** | Privee | Sur devis | 55K specs, 120+ parametres techniques | Haute |
| **CarAPI** | Privee | Annuel (Stripe) | Specs moteur/transmission US 1990+ | Faible |
| **VehicleDatabases** | Privee | Des ~100$/mois | 200+ champs VIN, Europe support | Moyenne |
| **Euro NCAP** | Publique | Pas d'API | Notes securite crash tests | Haute (si scrapable) |
| **AAA Data SIVin** | Privee | Sur devis | 75M vehicules FR, finitions, ADAS, chassis | Tres haute |

### API gratuite la plus utile en complement V1
**NHTSA vPIC** : gratuit, sans inscription, 136+ champs techniques par VIN, couvre vehicules vendus mondialement. Excellent complement aux donnees ADEME pour enrichir les fiches vehicules.

---

## 2. API Gratuite — NHTSA vPIC

### Vue d'ensemble

L'API vPIC (Vehicle Product Information Catalog) est fournie par la NHTSA (National Highway Traffic Safety Administration), l'agence federale americaine de securite routiere. C'est la **seule API gratuite, sans inscription, sans rate limiting** offrant un decodage VIN detaille.

### Caracteristiques principales

| Caracteristique | Detail |
|-----------------|--------|
| **Base URL** | `https://vpic.nhtsa.dot.gov/api/` |
| **Recherche par** | VIN (complet ou partiel, minimum 6 caracteres) |
| **Recherche par plaque** | Non |
| **Authentification** | Aucune requise |
| **Rate Limiting** | Aucun officiel (usage raisonnable recommande) |
| **Format reponse** | JSON, XML, CSV |
| **Disponibilite** | 24/7 |
| **Cout** | 100% gratuit |
| **Couverture** | Vehicules vendus aux USA principalement, mais couvre la plupart des constructeurs mondiaux |

### Endpoints principaux

| Endpoint | URL | Description |
|----------|-----|-------------|
| **DecodeVin** | `/vehicles/DecodeVin/{VIN}?format=json` | Decode VIN en paires cle-valeur |
| **DecodeVinValues** | `/vehicles/DecodeVinValues/{VIN}?format=json` | Decode VIN en format plat (1 objet) |
| **DecodeVinExtended** | `/vehicles/DecodeVinExtended/{VIN}?format=json` | Decode etendu avec donnees NCSA |
| **DecodeVinValuesBatch** | `/vehicles/DecodeVinValuesBatch/` | Decodage lot (POST, VINs separes par `;`) |
| **GetVehicleVariableList** | `/vehicles/GetVehicleVariableList?format=json` | Liste de toutes les variables disponibles |
| **GetVehicleVariableValuesList** | `/vehicles/GetVehicleVariableValuesList/{variable}?format=json` | Valeurs possibles pour une variable |
| **GetMakesForVehicleType** | `/vehicles/GetMakesForVehicleType/{type}?format=json` | Marques par type vehicule |
| **GetModelsForMakeYear** | `/vehicles/GetModelsForMakeYear/make/{make}/modelyear/{year}?format=json` | Modeles par marque et annee |

### Champs retournes (136+ variables)

**Identification vehicule :**
- `Make`, `MakeID`, `Model`, `ModelID`, `ModelYear`
- `Manufacturer`, `ManufacturerID`, `ManufacturerType`
- `VIN`, `VehicleType`, `Series`, `Series2`, `Trim`, `Trim2`
- `BodyClass`, `BodyCabType`
- `PlantCity`, `PlantCountry`, `PlantState`, `PlantCompanyName`
- `GVWR` (Gross Vehicle Weight Rating)

**Motorisation :**
- `EngineConfiguration` (V, Inline, Flat, Rotary...)
- `EngineCylinders` (nombre de cylindres)
- `EngineHP` (puissance en CV SAE)
- `EngineKW` (puissance en kW)
- `EngineManufacturer`
- `EngineModel`
- `DisplacementCC` (cylindree en cm3)
- `DisplacementCI` (cylindree en pouces cubes)
- `DisplacementL` (cylindree en litres)
- `FuelTypePrimary` (Gasoline, Diesel, Electric...)
- `FuelTypeSecondary`
- `FuelInjectionType`
- `Turbo`
- `ValveTrainDesign` (DOHC, SOHC, OHV...)
- `EngineNumberOfCylinders`

**Transmission & drivetrain :**
- `TransmissionStyle` (Automatic, Manual, CVT, DCT...)
- `TransmissionSpeeds` (nombre de rapports)
- `DriveType` (FWD, RWD, AWD, 4WD...)

**Securite & equipements :**
- `ABS` (Anti-lock Braking System)
- `ActiveSafetySysNote`
- `AdaptiveCruiseControl`
- `AdaptiveDrivingBeam`
- `AdaptiveHeadlights`
- `AirBagLocCurtain`, `AirBagLocFront`, `AirBagLocKnee`, `AirBagLocSeatCushion`, `AirBagLocSide`
- `AutoReverseSystem`
- `AutomaticPedestrianAlertingSound`
- `BackupCamera`
- `BlindSpotMon` (Blind Spot Monitoring)
- `BrakeSystemDesc`, `BrakeSystemType`
- `CIB` (Crash Imminent Braking)
- `DaytimeRunningLight`
- `DestinationMarket`
- `DynamicBrakeSupport`
- `EDR` (Event Data Recorder)
- `ESC` (Electronic Stability Control)
- `ForwardCollisionWarning`
- `KeylessIgnition`
- `LaneDepartureWarning`, `LaneKeepSystem`, `LaneCenteringAssistance`
- `NCSABodyType`, `NCSAMake`, `NCSAModel`
- `ParkAssist`
- `PedestrianAutomaticEmergencyBraking`
- `RearCrossTrafficAlert`
- `RearVisibilitySystem`
- `SAEAutomationLevel`
- `SemiautomaticHeadlampBeamSwitching`
- `SteeringLocation`
- `TPMS` (Tire Pressure Monitoring System)
- `TrailerBodyType`, `TrailerType`

**Electrique / Hybride :**
- `ElectrificationLevel` (BEV, PHEV, HEV, FCEV...)
- `EVDriveUnit`
- `BatteryType` (Lithium-Ion, NiMH...)
- `BatteryKWh`
- `BatteryCells`, `BatteryModules`, `BatteryPacks`
- `ChargerLevel`, `ChargerPowerKW`

**Dimensions & poids :**
- `Doors`, `Seats`, `Windows`
- `WheelBaseType`, `WheelBaseLong`, `WheelBaseShort`
- `WheelSizeFront`, `WheelSizeRear`
- `BedLength`, `BedType`, `CurbWeightLB`

### Exemple de requete et reponse

**Requete :**
```
GET https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/WVWZZZ3CZWE123456?format=json
```

**Reponse (extrait) :**
```json
{
  "Results": [{
    "Make": "VOLKSWAGEN",
    "Model": "Golf",
    "ModelYear": "2014",
    "BodyClass": "Hatchback/Liftback/Notchback",
    "DisplacementL": "1.4",
    "EngineCylinders": "4",
    "EngineHP": "140",
    "FuelTypePrimary": "Gasoline",
    "TransmissionStyle": "Automatic",
    "DriveType": "FWD",
    "ABS": "Standard",
    "ESC": "Standard",
    "TPMS": "Direct",
    "AirBagLocFront": "1st Row (Driver and Passenger)",
    "PlantCountry": "GERMANY"
  }]
}
```

### Pertinence pour plateforme FR

**Avantages :**
- 100% gratuit, pas de limite, pas d'inscription
- Couvre les constructeurs europeens (VW, BMW, Mercedes, Renault, PSA, Fiat...)
- 136+ champs incluant des donnees de securite tres detaillees (ADAS, airbags, freinage)
- Decodage VIN partiel possible (utile si VIN incomplet)
- Donnees sur equipements de securite specifiques (ABS, ESC, TPMS, cameras...)
- Informations electrification detaillees (batterie, charge, autonomie)

**Limitations :**
- Base centree US : certains modeles specifiques au marche francais peuvent manquer
- Pas de recherche par plaque d'immatriculation
- Pas de donnees de consommation/emissions CO2 WLTP (utiliser ADEME pour ca)
- Pas d'intervalles d'entretien
- Pas de catalogue pieces

**Strategie d'integration V1 :**
Utiliser comme **complement gratuit** apres identification du VIN (via plaque -> VIN). Les donnees de securite (ADAS) et les specs moteur enrichissent significativement la fiche vehicule sans cout.

---

## 3. APIs Catalogues Pieces — TecDoc & PartsLink24

### 3.1 TecDoc (TecAlliance) — Le plus grand catalogue pieces Europe

#### Vue d'ensemble

TecDoc est **la reference mondiale** du catalogue pieces auto aftermarket. Avec plus de 9.8 millions d'articles references et 190 000 types de vehicules, c'est la base de donnees la plus complete pour identifier les pieces compatibles avec un vehicule donne.

| Caracteristique | Detail |
|-----------------|--------|
| **Developpeur** | TecAlliance GmbH (Allemagne) |
| **Base URL API** | `https://webservice.tecalliance.net/pegasus-3-0/services/` (SOAP) |
| **Base URL OneDB** | `https://onedb.tecalliance.net/api/` (REST/JSON) |
| **Documentation** | `https://developer.tecalliance.cn/en/introduction/` |
| **Recherche par** | VIN -> K-Type, Katashiki -> K-Type, N de piece, N OE |
| **Recherche par plaque** | Non directement (VIN -> K-Type) |
| **Authentification** | API Key (fournie par TecAlliance apres contrat) |
| **Format reponse** | JSON (REST) ou XML (SOAP) |
| **Couverture** | 1 000+ marques, 190 000+ types vehicules, 9.8M articles |
| **Mise a jour** | Temps reel (IDP - Instant Data Processing) |

#### Architecture de recherche

```
Plaque -> VIN -> TecDoc K-Type ID -> Catalogue pieces compatibles
                                   -> Specifications vehicule (70+ champs)
                                   -> Liens OE (numeros constructeur)
```

Le concept central de TecDoc est le **K-Type** (Ktype), un identifiant unique TecDoc pour chaque variante vehicule. Tous les liens pieces passent par ce K-Type.

#### Endpoints principaux (OneDB REST API)

| Endpoint | Methode | Description |
|----------|---------|-------------|
| `GET /vehicles/{vin}` | VIN Search | VIN -> K-Type(s) correspondant(s) |
| `GET /vehicles/{ktypeId}` | Vehicle Info | Toutes les infos d'un vehicule (70+ champs) |
| `GET /vehicles/search` | Vehicle Search | Recherche par fabricant/modele/type |
| `POST /articles/search` | Parts Search | Recherche pieces par N article, N OE, marque, groupe produit |
| `GET /articles/{uid}/linkages` | Part Linkage | Vehicules compatibles pour une piece |
| `GET /articles/{uid}` | Article Detail | Details complets d'une piece |

#### Donnees vehicule disponibles (70+ champs)

- Fabricant, modele, type, variante
- Motorisation : type moteur, cylindree, puissance kW/CV, couple
- Transmission : type boite, nombre rapports, type traction
- Carrosserie : type, nombre portes, annee debut/fin production
- Carburant : type, norme Euro
- Poids, dimensions
- Code moteur constructeur

#### Donnees pieces disponibles

Pour chaque piece :
- Numero article TecDoc
- Numero(s) OE constructeur (cross-reference)
- Marque aftermarket (Bosch, Valeo, SKF, Sachs...)
- Designation produit (9 800 descriptions standardisees)
- Groupe produit / sous-groupe
- Criteres techniques (dimensions, capacites, specifications)
- Images / dessins techniques
- EAN / codes-barres
- Vehicules compatibles (linkages)

#### Tarification

| Produit | Prix indicatif | Description |
|---------|----------------|-------------|
| **TecDoc Catalogue Classic** | 219 EUR/an | Acces catalogue en ligne (pas API) |
| **TecDoc Catalogue Garage Data** | Sur devis | Donnees techniques garage |
| **API Web Service** | Sur devis (contrat annuel) | Acces programmatique complet |
| **RapidAPI (tiers)** | Variable | Acces via proxy non-officiel |

L'acces API direct necessite un **contrat TecAlliance** avec tarif negocie selon volume d'utilisation.

#### Pertinence pour plateforme FR

**Tres haute.** TecDoc est le standard de facto en Europe pour l'aftermarket automobile. L'integration permettrait de :
- Proposer un catalogue pieces compatibles pour chaque annonce
- Identifier le code moteur et les specs techniques precises
- Permettre aux acheteurs d'estimer les couts de maintenance
- Creer un lien vers des revendeurs de pieces

**Phase recommandee :** V3+ (monetisation via partenariats pieces)

---

### 3.2 PartsLink24 — Catalogues OEM Premium

#### Vue d'ensemble

PartsLink24 est un portail web donnant acces aux **catalogues pieces d'origine (OEM)** de 15+ marques premium. Contrairement a TecDoc (aftermarket), PartsLink24 fournit les catalogues **constructeur**.

| Caracteristique | Detail |
|-----------------|--------|
| **Site** | `https://www.partslink24.com/` |
| **Recherche par** | VIN (decode complet avec equipements d'usine) |
| **Couverture marques** | Audi, BMW, Land Rover, Porsche, Mercedes, VW, SEAT, Skoda, Bentley, Lamborghini, MAN, et autres |
| **Donnees** | Pieces OEM, illustrations originales, codes peinture, equipements d'usine |
| **Type d'acces** | Portail web + integration B2B |
| **API publique** | Non documentee publiquement |
| **Tarification** | Sur devis (abonnement professionnel) |

#### Donnees disponibles via VIN

- **Decodage VIN complet** avec code peinture
- **Equipements d'usine** (options montees a la commande)
- **Illustrations originales** constructeur (vues eclatees)
- **Informations pieces** : pieces remplacees, recommandees, frequemment commandees
- **Recherche intelligente** par mot-cle

#### Pertinence pour plateforme FR

**Moyenne.** Utile pour les marques premium (BMW, Audi, Mercedes, Porsche) mais :
- Pas d'API publique documentee
- Couverture limitee aux marques partenaires (pas de Renault, Peugeot, Citroen)
- Oriente ateliers/carrossiers, pas plateforme classifieds
- Integration necessiterait un partenariat B2B specifique

**Phase recommandee :** Pas prioritaire. TecDoc couvre mieux le besoin.

---

## 4. APIs Donnees Techniques / Reparation — Autodata, HaynesPro, ETAI

### 4.1 Autodata (Solera Group)

#### Vue d'ensemble

Autodata est un fournisseur leader de donnees techniques automobiles depuis 1972. Avec une couverture de 34 000+ modeles de 142 constructeurs, c'est une reference mondiale pour les donnees de reparation et maintenance.

| Caracteristique | Detail |
|-----------------|--------|
| **Editeur** | Autodata Group (filiale de Solera) |
| **Portail dev** | `https://developer.autodata-group.com/` |
| **Documentation** | `https://developer.autodata-group.com/docs` |
| **Code samples** | `https://github.com/AutodataGroup/API-code-samples` |
| **Recherche par** | VIN, Marque/Modele/Annee |
| **Authentification** | OAuth 2.0 |
| **Format reponse** | JSON (defaut), XML (option) |
| **Couverture** | 34 000+ modeles, 142 constructeurs |

#### Modules API disponibles

| Module | Description |
|--------|-------------|
| **Vehicle Identification** | Identification vehicule par VIN ou selection manuelle |
| **Technical Specifications** | Specs techniques completes (moteur, transmission, dimensions, poids, capacites) |
| **Service Schedules** | Plans d'entretien constructeur (taches, intervalles km/temps) |
| **Timing Belts/Chains** | Procedures remplacement distribution avec illustrations |
| **Tightening Torques** | Couples de serrage pour chaque composant |
| **Wiring Diagrams** | Schemas electriques interactifs |
| **Diagnostic Trouble Codes** | Codes defaut OBD (DTCs) avec procedures diagnostic |
| **Labour Times** | Temps baremes reparation |
| **Repair Procedures** | Procedures reparation pas a pas |
| **Technical Bulletins** | Bulletins techniques constructeur (TSB) |
| **Fluid Capacities** | Capacites fluides (huile, refroidissement, frein, boite) |

#### Donnees techniques detaillees

**Specifications moteur :**
- Type moteur, code moteur
- Cylindree, nombre cylindres, disposition
- Puissance kW/CV a regime specifie
- Couple Nm a regime specifie
- Taux compression
- Type injection, turbo/compresseur
- Norme Euro, type carburant
- Systeme de distribution (chaine/courroie)

**Entretien :**
- Intervalles d'entretien constructeur (km ET temps)
- Liste des operations par revision
- Pieces a remplacer (filtres, bougies, liquides...)
- Quantites de fluides
- Specifications huile moteur/boite

**Tarification :**

| Produit | Prix indicatif |
|---------|----------------|
| Abonnement atelier (1 poste) | ~50-80 EUR/mois |
| API developer access | Sur devis |

#### Pertinence pour plateforme FR

**Haute.** Les donnees Autodata permettraient d'afficher :
- Les intervalles d'entretien (le prochain entretien est dans X km)
- Les couts estimatifs de maintenance (pieces + main d'oeuvre)
- Les rappels techniques constructeur (TSB)

**Phase recommandee :** V3+ (fonctionnalite premium "cout de possession")

---

### 4.2 HaynesPro (Infopro Digital Automotive)

#### Vue d'ensemble

HaynesPro (anciennement WorkshopData) est une base de donnees de reparation automobile complete couvrant 80 marques. C'est une marque d'**Infopro Digital Automotive**, le meme groupe qui possede ETAI en France.

| Caracteristique | Detail |
|-----------------|--------|
| **Editeur** | Infopro Digital Automotive (Pays-Bas/France) |
| **Produit API** | E3Technical Vehicle Technical WebAPI |
| **Site** | `https://www.haynespro.co.uk/products/vehicle-technical-webapi` |
| **Recherche par** | VIN, Marque/Modele/Variante |
| **Couverture** | 80 marques, vehicules legers + utilitaires + PL |
| **Langues** | Multilingue (dont francais) |

#### Modules disponibles

| Module | Description |
|--------|-------------|
| **Tech** | Specifications techniques, entretien, courroies distribution |
| **Electronics** | Schemas electriques, localisation composants |
| **Smart** | SmartFIX (TSB), SmartCASE (solutions verifiees), diagnostics |
| **VESA** | Vehicle Electronic Smart Assistant (diagnostic assiste) |

#### Donnees techniques

- Specifications moteur et transmission
- Plans de maintenance constructeur
- 100 000+ dessins techniques haute qualite
- Schemas electriques complexes
- Codes defaut (DTC) avec procedures
- Temps baremes de reparation
- Couples de serrage
- Capacites fluides

#### Tarification

| Plan | Prix |
|------|------|
| Solo mechanic (base) | ~69 $/mois (604 $/an) |
| Team (par utilisateur) | ~69 $/user/mois (volume discounts) |
| Enterprise / API | Sur devis |

#### Pertinence pour plateforme FR

**Haute.** HaynesPro etant une marque d'Infopro Digital (meme groupe que ETAI), il existe une **synergie naturelle** avec le marche francais. Le support multilingue inclut le francais. L'API WebAPI permet une integration technique.

**Phase recommandee :** V3+ (memes fonctionnalites que Autodata, au choix)

---

### 4.3 ETAI / Atelio Data (Infopro Digital Automotive)

#### Vue d'ensemble

ETAI (Editions Techniques pour l'Automobile et l'Industrie) est **le leader francais** des donnees techniques automobiles depuis 1946. Leur produit SaaS principal est **Atelio Data**.

| Caracteristique | Detail |
|-----------------|--------|
| **Editeur** | Infopro Digital Automotive (France) |
| **Produit** | Atelio Data |
| **Site** | `https://www.infopro-digital-automotive.com/fr/` |
| **Recherche par** | **Plaque d'immatriculation**, VIN, Marque/Modele |
| **Couverture** | France principalement, Europe |
| **Langue** | Francais natif |

#### Donnees Atelio Data

| Categorie | Donnees |
|-----------|---------|
| **Identification** | Identification illimitee par plaque, VIN ou marque/modele |
| **Specifications techniques** | Donnees constructeur completes |
| **Methodes de reparation** | Procedures pas a pas illustrees |
| **Diagnostics electroniques** | Module intelligent de diagnostic |
| **Entretien** | Plans de maintenance, intervalles |
| **Schemas** | Schemas electriques et mecaniques |

#### Integration B2B

ETAI/Infopro Digital a ete **le premier a introduire les web services** dans le secteur automobile en France. Ils proposent :
- Solutions SaaS autonomes
- Integration dans plateformes partenaires
- APIs et web services pour integration tiers
- Livraison donnees flexible (standalone, echange, portail-a-portail)

#### Tarification

Sur devis exclusivement. Contact via le site Infopro Digital Automotive.

#### Pertinence pour plateforme FR

**Tres haute.** ETAI/Atelio Data est **la solution la plus adaptee au marche francais** :
- Identification par **plaque d'immatriculation francaise** (comme apiplaqueimmatriculation)
- Donnees en francais natif
- Couverture complete du parc francais
- Historique 80 ans dans l'automobile francaise
- Fait partie du meme groupe que HaynesPro (synergies possibles)

**Phase recommandee :** V2-V3 (alternative ou complement a apiplaqueimmatriculation.com pour identification + donnees techniques avancees)

---

## 5. APIs Specifications Vehicules — JATO, Auto-Data.net, CarAPI, VehicleDatabases

### 5.1 JATO Dynamics — La reference mondiale specs vehicules

#### Vue d'ensemble

JATO Dynamics est le **leader mondial** de la donnee vehicule pour l'industrie automobile. Avec 1 000+ datapoints par vehicule dans 50+ marches, c'est la source la plus complete.

| Caracteristique | Detail |
|-----------------|--------|
| **Editeur** | JATO Dynamics Ltd (UK) |
| **Portail dev** | `https://developer.jato.com/` |
| **Produit API** | JaaS (JATO as a Service) |
| **Recherche par** | **VIN**, **VRM (plaque)**, Marque/Modele |
| **Authentification** | Inscription portail developpeur |
| **Format** | REST + JSON |
| **Couverture** | 50+ marches dont France, 1000+ datapoints/vehicule |

#### APIs disponibles (JaaS)

| API | Description |
|-----|-------------|
| **VINView** | Decode VIN ou VRM en profil vehicule complet avec options |
| **Specifications** | Donnees techniques detaillees par version |
| **Options** | Equipements standard et optionnels avec prix |
| **Incentives** | Remises et promotions constructeur |
| **Configuration** | Regles de configuration (build rules) |
| **WLTP Data** | Donnees WLTP dynamiques (consommation, emissions) |
| **Transaction Analysis** | Prix de transaction reels (EU5) |

#### Donnees VINView (par VIN ou VRM/plaque)

Le decodage VIN/VRM retourne **1 000+ datapoints individuels** :
- Identification complete (marque, modele, version, finition)
- **Equipements d'usine** (options montees a la commande)
- **Prix estime** avec options
- Dimensions vehicule (L x l x h)
- Poids et capacite remorquage
- Tailles pneus (standard et optionnel)
- Specifications techniques completes
- Donnees WLTP (consommation, CO2)

#### Points differenciants

- **Decode par VRM (plaque)** : JATO supporte la recherche par plaque d'immatriculation dans certains marches europeens dont la France
- **Options d'usine** : seul JATO peut identifier les options specifiques montees sur un vehicule donne (via VIN)
- **50+ marches** : couverture France native
- **Donnees de prix** : MSRP, prix options, prix de transaction reels

#### Tarification

Sur devis. JATO propose un essai gratuit ("Request Free Trial" sur le portail developpeur). Tarification enterprise typiquement en milliers d'euros/an selon volume.

#### Pertinence pour plateforme FR

**Tres haute.** JATO est probablement la **meilleure source unique** pour une plateforme de classifieds vehicules en France :
- Recherche par plaque ET par VIN
- Equipements d'usine precis par vehicule
- Estimation de prix
- Couverture France native
- Donnees WLTP officielles

**Phase recommandee :** V2 (remplacement ou complement de apiplaqueimmatriculation + ADEME). Le cout sera probablement elevee mais la valeur ajoutee est maximale.

---

### 5.2 Auto-Data.net API

#### Vue d'ensemble

Auto-Data.net est une base de donnees de specifications techniques automobiles avec 55 000+ fiches detaillees et 120+ parametres par vehicule.

| Caracteristique | Detail |
|-----------------|--------|
| **Base URL** | `https://api.auto-data.net/` |
| **Documentation** | `https://api.auto-data.net/documentation` |
| **Parametres** | `https://api.auto-data.net/vehicle-api-parameters` |
| **Recherche par** | Marque/Modele/Generation (pas VIN, pas plaque) |
| **Format** | XML ou JSON (one-call API) |
| **Couverture** | 55 000+ specs, 3 500+ modeles, 10 000+ generations |

#### Parametres disponibles (120+ organises en 7 groupes)

**Groupe 1 - Performances :**
- Vitesse maximale (km/h)
- Acceleration 0-100 km/h, 0-200 km/h, 0-300 km/h, 0-60 mph
- Couple moteur (Nm)

**Groupe 2 - Moteur :**
- Type moteur, code moteur
- Cylindree, cylindres, disposition
- Puissance (kW, CV, PS)
- Regime puissance max, regime couple max
- Type injection, alimentation
- Taux compression

**Groupe 3 - Dimensions :**
- Longueur, largeur, hauteur (mm)
- Empattement
- Voie avant/arriere
- Volume coffre (litres)
- Poids a vide, PTAC

**Groupe 4 - Transmission :**
- Type boite (manuelle, auto, CVT, DCT, DSG...)
- Nombre rapports
- Type traction (FWD, RWD, AWD)

**Groupe 5 - Consommation :**
- Consommation urbaine, extra-urbaine, mixte (L/100km)
- Consommation WLTP (basse, moyenne, haute, tres haute, mixte)
- Consommation electrique (kWh/100km)

**Groupe 6 - Emissions :**
- CO2 (g/km) — toutes phases WLTP
- Norme Euro
- Norme d'emissions

**Groupe 7 - Electrique :**
- Autonomie electrique (km)
- Autonomie urbaine
- Capacite batterie (kWh)
- Puissance charge (kW)

#### Tarification

Tarification **a la carte** : achat par categorie, sous-categorie, ou mix personnalise. Pas de forfait fixe. Devis via formulaire sur le site.

#### Pertinence pour plateforme FR

**Haute** pour l'enrichissement de fiches vehicules (specs tres detaillees), mais :
- Pas de recherche par VIN ou plaque (uniquement marque/modele)
- Necessite d'avoir identifie le modele exact au prealable
- Donnees centrees specifications, pas entretien/reparation

**Phase recommandee :** V2-V3 (enrichissement fiches si JATO ou ADEME insuffisant)

---

### 5.3 CarAPI.app

#### Vue d'ensemble

CarAPI est une API RESTful orientee developpeur avec une documentation OpenAPI complete.

| Caracteristique | Detail |
|-----------------|--------|
| **Base URL** | `https://carapi.app/api` |
| **Documentation** | `https://carapi.app/api` (Swagger) + Postman collection |
| **Recherche par** | Year/Make/Model/Trim (pas VIN direct, sauf module separe) |
| **Format** | REST + JSON (OpenAPI) |
| **Couverture** | Vehicules US 1900-present, 90 000+ vehicules |

#### Specs moteur disponibles

- Engine type, fuel type
- Cylinder configuration, size (displacement)
- Horsepower (HP + RPM)
- Torque (lb-ft + RPM)
- Valves, valve timing, cam type
- Drive type, transmission
- Mileage/MPG

#### Tarification

| Plan | Prix | Tier gratuit |
|------|------|-------------|
| **Free** | 0$ | Donnees 2020 Ford et Toyota uniquement |
| **Paid** | Annuel via Stripe (prix non publie) | Toutes marques/annees |

#### Pertinence pour plateforme FR

**Faible.** Centree vehicules US, pas de support VIN europeen ni plaque. Pas de donnees WLTP. Utile uniquement comme reference secondaire.

---

### 5.4 VehicleDatabases.com

#### Vue d'ensemble

| Caracteristique | Detail |
|-----------------|--------|
| **Base URL** | `https://vehicledatabases.com/api/` |
| **Documentation** | `https://vehicledatabases.com/docs/` |
| **Recherche par** | VIN, Year/Make/Model/Trim, Plaque (module separe) |
| **Format** | REST + JSON |
| **Couverture** | US + Europe, 1981-present (VIN Europe), 200+ champs |

#### Tiers disponibles

| Produit | Description |
|---------|-------------|
| **Basic VIN Decode** | Donnees de base (year, make, model, trim) |
| **Premium VIN Decode** | Specs detaillees + features |
| **Premium Plus VIN Decode** | Specs completes + equipements + options |
| **Europe VIN Decode** | VINs europeens (1981-present) |
| **License Plate API** | Plaque -> VIN (marches specifiques) |

#### Tarification

A partir de ~100 $/mois. 15 credits gratuits pour test. Pas de free tier ongoing.

#### Pertinence pour plateforme FR

**Moyenne.** Le support Europe VIN est interessant mais la couverture France specifique n'est pas documentee en detail. Le License Plate API pourrait etre utile si le marche FR est supporte.

---

## 6. APIs Securite — Euro NCAP & NHTSA NCAP

### 6.1 Euro NCAP

| Caracteristique | Detail |
|-----------------|--------|
| **Site** | `https://www.euroncap.com/` |
| **API publique** | **Non disponible** |
| **Donnees disponibles** | Notes de securite (0-5 etoiles), scores detailles |
| **Acces** | Web scraping ou contact direct necessaire |
| **Couverture** | Vehicules vendus en Europe |

#### Donnees de notation

- **Note globale** : 0 a 5 etoiles
- **Adult Occupant** : pourcentage protection adulte
- **Child Occupant** : pourcentage protection enfant
- **Pedestrian** : pourcentage protection pieton
- **Safety Assist** : pourcentage systemes d'aide a la securite (AEB, LKA, SBR...)
- **Photos crash tests**
- **Videos crash tests**

#### Acces aux donnees

Euro NCAP n'offre **pas d'API publique**. Options :
1. **Contact direct** pour licence de donnees (B2B)
2. **Web scraping** (verifier CGU)
3. **Utiliser NHTSA vPIC** qui inclut certaines donnees de securite equivalentes

#### Pertinence pour plateforme FR

**Haute** en termes de valeur pour l'utilisateur (acheteurs tres sensibles a la securite), mais **difficile d'acces**. Les donnees ADAS du NHTSA vPIC peuvent partiellement compenser.

**Phase recommandee :** V3+ (licence donnees ou partenariat Euro NCAP)

---

### 6.2 NHTSA NCAP (US)

L'API NHTSA inclut deja des donnees NCAP americaines via l'endpoint `DecodeVinExtended`. Ces donnees sont gratuites et incluses dans la section NHTSA vPIC ci-dessus.

---

## 7. APIs France specifiques — AAA Data SIVin (complement)

### Complement au rapport du 2026-02-07

Le rapport precedent documentait AAA Data SIVin (51 champs). Des recherches complementaires revelent des **champs techniques supplementaires** :

#### Champs techniques avances SIVin

| Categorie | Champs |
|-----------|--------|
| **Finitions** | Version commerciale, niveau de finition, serie speciale |
| **ADAS** | Systemes d'aide a la conduite equipes d'origine |
| **Eclairage** | Type feux (halogene, xenon, LED, laser), feux adaptatifs |
| **Chassis & Suspensions** | Type suspension avant/arriere, direction assistee |
| **Securite vehicule** | Airbags, ABS, ESP, controle traction |
| **Code SRA** | Code assurance (permet calcul prime) |
| **TecDoc K-Type** | Identifiant TecDoc (lien vers catalogue pieces) |

Le champ **TecDoc K-Type** dans SIVin est particulierement precieux : il permet de **chainer SIVin -> TecDoc** pour obtenir le catalogue pieces compatible.

---

## 8. OATS — Standards ouverts

### Constat

La recherche "OATS" dans le contexte automobile ne correspond **pas** a un standard ouvert de specifications techniques vehicules. OATS est en realite une **marque d'Infopro Digital** specialisee dans les **donnees de lubrifiants** automobiles.

| Caracteristique | Detail |
|-----------------|--------|
| **Editeur** | Infopro Digital (meme groupe que ETAI et HaynesPro) |
| **Specialite** | Base de donnees lubrifiants (huiles moteur, transmission, frein...) |
| **Donnees** | Correspondance vehicule -> specification lubrifiant (API, ACEA, constructeur) |
| **Couverture** | Voiture, VUL, moto, PL, bus, agricole, marine |
| **Usage** | Optimisation portefeuille produits pour fabricants/distributeurs huile |

### Standards ouverts existants

Le W3C a une specification "Vehicle Data" (`https://w3c.github.io/automotive/vehicle_data/data_spec.html`) qui definit un standard pour les donnees vehicules en temps reel (telematique), mais ce n'est pas un standard de specifications techniques statiques.

**Conclusion :** Il n'existe pas de standard ouvert equivalent a ce que TecDoc, JATO ou Autodata fournissent en proprientaire.

---

## 9. Tableau Comparatif Global

### Par type de donnee recherche

| Donnee | NHTSA vPIC | TecDoc | Autodata | HaynesPro | ETAI | JATO | AAA SIVin |
|--------|-----------|--------|----------|-----------|------|------|-----------|
| **Specs moteur** | Oui (base) | Oui | Oui (detail) | Oui (detail) | Oui | Oui (1000+pts) | Oui (base) |
| **Liste equipements** | Oui (securite) | Non | Non | Non | Non | **Oui (d'usine)** | Oui (ADAS) |
| **Options disponibles** | Non | Non | Non | Non | Non | **Oui** | Non |
| **Catalogue pieces** | Non | **Oui (9.8M)** | Non | Non | Non | Non | Non |
| **Intervalles entretien** | Non | Non | **Oui** | **Oui** | **Oui** | Non | Non |
| **Schemas techniques** | Non | Non | **Oui** | **Oui (100K+)** | **Oui** | Non | Non |
| **Couples serrage** | Non | Non | **Oui** | **Oui** | **Oui** | Non | Non |
| **Schemas electriques** | Non | Non | **Oui** | **Oui** | **Oui** | Non | Non |
| **Recherche plaque** | Non | Non | Non | Non | **Oui** | **Oui** | **Oui** |
| **Recherche VIN** | **Oui** | **Oui** | **Oui** | **Oui** | **Oui** | **Oui** | **Oui** |
| **Gratuit** | **Oui** | Non | Non | Non | Non | Non | Non |
| **Couverture FR** | Partielle | Haute | Haute | Haute | **Tres haute** | **Tres haute** | **Tres haute** |

### Par critere business

| API | Cout entree | Complexite integ. | Time-to-value | ROI plateforme |
|-----|------------|-------------------|---------------|----------------|
| NHTSA vPIC | Gratuit | Faible | Immediat | Moyen |
| TecDoc | ~219+EUR/an | Moyenne | 2-4 sem | Eleve (monetisation) |
| Autodata | Devis (500+EUR/an) | Moyenne | 4-8 sem | Moyen |
| HaynesPro | ~69$/mois | Moyenne | 4-8 sem | Moyen |
| ETAI/Atelio | Devis | Moyenne | 4-8 sem | Eleve (marche FR) |
| JATO | Devis (eleve) | Moyenne | 4-8 sem | Tres eleve |
| AAA SIVin | Devis | Moyenne | 2-4 sem | Eleve |

---

## 10. Recommandations pour la plateforme

### V1 — Complement immediat (gratuit)

Ajouter **NHTSA vPIC** au mix V1 existant (ADEME + RappelConso + Crit'Air) :

```
Flux V1 enrichi :
1. Plaque -> [MOCK] apiplaqueimmatriculation -> VIN + specs base
2. VIN -> [REEL] NHTSA vPIC -> Specs moteur, securite (ADAS), drivetrain
3. Marque/Modele -> [REEL] ADEME -> CO2, consommation WLTP
4. Calcul local -> [REEL] Crit'Air
5. Marque -> [REEL] RappelConso -> Rappels securite
```

Nouvelle interface adapter :
```
IVINTechnicalAdapter
  |-- NHTSAVpicAdapter          <- V1 (gratuit)
  |-- VincarioAdapter           <- V2 (payant, specs plus completes)
  |-- JATOVINViewAdapter        <- V3 (premium, equipements d'usine)
```

### V2 — APIs payantes prioritaires

**Priorite 1 : JATO Dynamics VINView**
- Raison : decode plaque ET VIN, equipements d'usine, 1000+ datapoints, couverture FR native
- Impact : remplacement de apiplaqueimmatriculation ET ADEME en une seule source
- Cout : eleve mais valeur maximale

**Priorite 2 : AAA Data SIVin**
- Raison : reference du marche FR, 75M vehicules, inclut K-Type TecDoc
- Impact : identification vehicule fiable + passerelle vers TecDoc

### V3 — APIs de monetisation

**TecDoc** : catalogue pieces compatible par annonce -> partenariats revendeurs pieces
**Autodata ou HaynesPro** : donnees entretien -> fonctionnalite "cout de possession estime"
**Euro NCAP** : notes securite -> badge confiance acheteur

### Architecture Adapter mise a jour

```
IVehicleLookupAdapter
  |-- MockVehicleLookupAdapter       <- V1 (mock)
  |-- ApiPlaqueLookupAdapter         <- V2 option A
  |-- SIVinLookupAdapter             <- V2 option B
  |-- JATOVINViewAdapter             <- V2 option C (premium)

IVINTechnicalAdapter (NOUVEAU)
  |-- NHTSAVpicAdapter               <- V1 (gratuit)
  |-- VincarioTechnicalAdapter       <- V2
  |-- JATOSpecsAdapter               <- V3

IPartsAdapter (NOUVEAU)
  |-- MockPartsAdapter               <- V1 (mock)
  |-- TecDocPartsAdapter             <- V3

IMaintenanceAdapter (NOUVEAU)
  |-- MockMaintenanceAdapter         <- V1 (mock)
  |-- AutodataMaintenanceAdapter     <- V3 option A
  |-- HaynesProMaintenanceAdapter    <- V3 option B
  |-- ETAIAtelioAdapter              <- V3 option C (FR natif)

ISafetyRatingAdapter (NOUVEAU)
  |-- NHTSANcapAdapter               <- V1 (gratuit via vPIC)
  |-- EuroNcapAdapter                <- V3 (si licence obtenue)
```

---

## 11. Sources & References

### APIs Gratuites
- [NHTSA vPIC API](https://vpic.nhtsa.dot.gov/api/) — API gratuite de decodage VIN
- [NHTSA vPIC Variables List](https://vpic.nhtsa.dot.gov/api/vehicles/getvehiclevariablelist?format=json)
- [NHTSA vPIC on data.gov](https://catalog.data.gov/dataset/nhtsa-product-information-catalog-and-vehicle-listing-vpic-vehicle-api-json)
- [vpic-api Python wrapper (PyPI)](https://pypi.org/project/vpic-api/)
- [nhtsa-api-wrapper JS (GitHub)](https://github.com/ShaggyTech/nhtsa-api-wrapper)

### Catalogues Pieces
- [TecAlliance TecDoc Catalogue](https://www.tecalliance.net/tecdoc-catalogue/)
- [TecAlliance API Documentation](https://developer.tecalliance.cn/en/introduction/index.html)
- [TecAlliance OneDB Vehicle Search](https://developer.tecalliance.cn/en/tecdoc-api/function/vehicle-search/index.html)
- [TecDoc on RapidAPI](https://rapidapi.com/ronhartman/api/tecdoc-catalog)
- [TecDoc Laravel Wrapper (GitHub)](https://github.com/Composite-Solutions/laravel-tecdoc)
- [PartsLink24](https://www.partslink24.com/)

### Donnees Techniques / Reparation
- [Autodata Group API Developer Portal](https://developer.autodata-group.com/)
- [Autodata API Documentation](https://developer.autodata-group.com/docs)
- [Autodata API Code Samples (GitHub)](https://github.com/AutodataGroup/API-code-samples)
- [Autodata (Solera)](https://www.solera.com/solutions/vehicle-repair/autodata/)
- [HaynesPro WebAPI](https://www.haynespro.co.uk/products/vehicle-technical-webapi)
- [Infopro Digital Automotive — HaynesPro](https://www.infopro-digital-automotive.com/haynespro/)
- [ETAI — Infopro Digital](https://www.infopro-digital-automotive.com/fr/nous-connaitre/etai-editions-techniques-pour-automobile-et-industrie-marque/)

### Specifications Vehicules
- [JATO Dynamics Developer Portal](https://developer.jato.com/)
- [JATO VINView / CarSpecs API](https://info.jato.com/carspecs-api)
- [JATO Specifications](https://www.jato.com/our-capabilities/specifications)
- [Auto-Data.net API](https://api.auto-data.net/)
- [Auto-Data.net API Parameters](https://api.auto-data.net/vehicle-api-parameters)
- [CarAPI.app](https://carapi.app/)
- [CarAPI.app Pricing](https://carapi.app/pricing)
- [VehicleDatabases.com](https://vehicledatabases.com/)
- [VehicleDatabases VIN Decoder API](https://vehicledatabases.com/api/vin-decoder)
- [VinAudit Vehicle Specifications API](https://www.vinaudit.com/vehicle-specifications-api)

### Securite
- [Euro NCAP Ratings](https://www.euroncap.com/en/ratings-rewards/latest-safety-ratings/)
- [Euro NCAP Protocols](https://www.euroncap.com/en/for-engineers/protocols/)

### France specifique
- [AAA Data SIVin API](https://www.aaa-data.fr/api-sivin/)
- [AAA Data Solutions API](https://www.aaa-data.fr/nos-solutions-api/)
- [OATS Lubricants (Infopro Digital)](https://www.infopro-digital-automotive.com/oats-lubricants/)

### Standards
- [W3C Vehicle Data Specification](https://w3c.github.io/automotive/vehicle_data/data_spec.html)

---

*Document genere le 2026-02-08 — Recherche technique complementaire pour le projet de plateforme petites annonces vehicules. Ce document est a lire en complement du rapport du 2026-02-07.*
