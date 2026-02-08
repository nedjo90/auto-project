---
stepsCompleted: [1, 2, 3]
inputDocuments: ['technical-apis-etat-vehicules-research-2026-02-07.md']
workflowType: 'research'
lastStep: 3
research_type: 'technical'
research_topic: 'Alternatives to CarVertical for Vehicle History Reports in Europe (French Market Focus)'
research_goals: 'Comprehensive mapping of all CarVertical alternatives for vehicle history reports targeting the French market, with API availability, pricing, data coverage, and white-label options'
user_name: 'Nhan'
date: '2026-02-08'
web_research_enabled: true
source_verification: true
---

# Research Report: CarVertical Alternatives for Vehicle History Reports in Europe

**Date:** 2026-02-08
**Author:** Nhan
**Research Type:** Technical / Market Analysis
**Status:** Complete

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Tier 1: Pan-European Vehicle History Providers (with API)](#2-tier-1-pan-european-vehicle-history-providers-with-api)
   - 2.1 [AutoDNA](#21-autodna)
   - 2.2 [CARFAX Europe](#22-carfax-europe)
   - 2.3 [Vincario / vindecoder.eu](#23-vincario--vindecodereu)
   - 2.4 [CarsXE](#24-carsxe)
   - 2.5 [Vehicle Databases / Detailed Vehicle History (DVH)](#25-vehicle-databases--detailed-vehicle-history-dvh)
3. [Tier 2: France-Specific Vehicle History Providers](#3-tier-2-france-specific-vehicle-history-providers)
   - 3.1 [HistoVec (Government - Free)](#31-histovec-government---free)
   - 3.2 [Autoviza (by NGC-Data)](#32-autoviza-by-ngc-data)
   - 3.3 [Autorigin](#33-autorigin)
   - 3.4 [CarVerif](#34-carverif)
   - 3.5 [AAA Data / SIVin API](#35-aaa-data--sivin-api)
   - 3.6 [NGC-Data / NGC-VIN API](#36-ngc-data--ngc-vin-api)
4. [Tier 3: European Data & Valuation Platforms (Not Pure History)](#4-tier-3-european-data--valuation-platforms-not-pure-history)
   - 4.1 [Autovista Group / Eurotax](#41-autovista-group--eurotax)
   - 4.2 [Afteriize](#42-afteriize)
   - 4.3 [AutoPass Group](#43-autopass-group)
   - 4.4 [IZISCAR / AutomotivAPI](#44-iziscar--automotivapi)
5. [Tier 4: Other European / International Providers](#5-tier-4-other-european--international-providers)
   - 5.1 [EpicVIN](#51-epicvin)
   - 5.2 [VIN Data Hub](#52-vin-data-hub)
   - 5.3 [MotorCheck (UK/Ireland)](#53-motorcheck-ukireland)
6. [Providers Not Found / Non-Existent](#6-providers-not-found--non-existent)
7. [Comparative Summary Table](#7-comparative-summary-table)
8. [Recommendations for French Market B2B Integration](#8-recommendations-for-french-market-b2b-integration)
9. [Sources & References](#9-sources--references)

---

## 1. Executive Summary

### Key Findings

There are **12+ viable alternatives** to CarVertical for vehicle history reports in Europe, but their relevance to the **French market** varies dramatically. The landscape breaks down into:

- **Pan-European providers with APIs** (AutoDNA, CARFAX Europe, Vincario, CarsXE, Vehicle Databases) that cover France as part of their broader European data, but typically with less depth than France-specific providers.
- **France-specific providers** (HistoVec, Autoviza/NGC-Data, Autorigin, AAA Data/SIVin) that have deep French data from the SIV (government vehicle registration system) but limited or no pan-European coverage.
- **Data/valuation platforms** (Autovista/Eurotax, Afteriize, AutoPass) that provide vehicle specifications, valuations, and maintenance data but are NOT vehicle history report providers per se.

### Critical Insight for France

The French government's **HistoVec** service (free, official) provides the most authoritative French vehicle history data. However, it has **no public API** -- it requires the owner to generate and share a report link. All private French providers (Autoviza, Autorigin, CarVerif) get their French data from the **SIV** system via Ministry of Interior Level 1 licenses (e.g., NGC-Data, AAA Data). Pan-European providers like CarVertical, AutoDNA, and CARFAX rely on **aggregated data from multiple sources** across countries but typically have shallower French-specific data than the SIV-licensed providers.

### CarVertical Baseline for Comparison

| Feature | CarVertical |
|---|---|
| Website | carvertical.com |
| Consumer Price | 24.99 EUR / report (1x), 15.99 EUR/ea (2x), 12.99 EUR/ea (3x) |
| API | Yes (B2B API available) |
| Search Method | VIN + license plate |
| Countries | 35+ countries |
| Data | Mileage, damage, theft, ownership, recalls, photos |
| Blockchain | Yes (tamper-proof reports) |
| White Label | Available (contact sales) |

---

## 2. Tier 1: Pan-European Vehicle History Providers (with API)

### 2.1 AutoDNA

| Field | Details |
|---|---|
| **Website** | [autodna.com](https://www.autodna.com/) |
| **HQ** | Warsaw, Poland (founded 2009) |
| **API Availability** | **YES** -- WebAPI feature package available via Partners Area |
| **Search Method** | **VIN + License Plate** |
| **Countries Covered** | 26+ European countries + USA + Canada |
| **Data Included** | Mileage records, accident history, theft/stolen checks, ownership changes, service/maintenance records, auction data, title status, VIN decoding |
| **France Coverage** | **Moderate** -- Covers French vehicles but data depth depends on cross-border data availability. Strongest for imported vehicles (Germany, Belgium, Italy). French-specific SIV data access is limited compared to SIV-licensed providers. |
| **Consumer Pricing** | 1 report: 24.99 EUR, 2 reports: 19.99 EUR/ea, 3 reports: 16.66 EUR/ea |
| **Business Pricing** | 20 reports: 12.95 EUR/ea, 50 reports: 11.18 EUR/ea, 100 reports: 9.59 EUR/ea |
| **White Label / Embed** | Yes -- Partners area with WebAPI, VIN decoders and search engine widgets for embedding on websites |
| **Key Advantage vs CarVertical** | Lower per-report cost at volume (9.59 EUR vs ~13 EUR), more granular country-specific data, stronger position in Central/Eastern European data. No blockchain markup. |
| **Key Disadvantage** | Lower Trustpilot rating (2.2-2.3/5), French-specific data may be less comprehensive than SIV-based providers. |

**Sources:**
- [AutoDNA Individual Packages](https://www.autodna.com/blog/individual-packages/)
- [AutoDNA Business Packages](https://www.autodna.com/business-packages)
- [AutoDNA Partners Area](https://www.autodna.com/company/partners-area)
- [AutoDNA France Sample Report](https://www.autodna.com/sample-reports/vehicle-history-france)

---

### 2.2 CARFAX Europe

| Field | Details |
|---|---|
| **Website** | [carfax.eu](https://www.carfax.eu) |
| **HQ** | European division of CARFAX (US parent, owned by IHS Markit) |
| **API Availability** | **YES (B2B only)** -- Not public; requires contacting Business Development team. Available for dealers, insurance, banking, and software integrators. |
| **Search Method** | **VIN only** |
| **Countries Covered** | 20+ EU countries + USA + Canada |
| **Data Included** | Mileage/odometer readings, accident/damage records, theft/stolen records, ownership changes, import/export history, inspection records, chronological event timeline |
| **France Coverage** | **Moderate** -- France is covered. CARFAX specifically notes France has ~140,000 vehicle thefts/year. Coverage depends on data partnerships in each country. Not all accidents are reported. Strongest for cross-border/imported vehicles. |
| **Consumer Pricing** | Up to 39.99 EUR max per report (price varies by data availability; shown before purchase). One-time payment, no subscription. |
| **Business/B2B Pricing** | Volume-based, significantly lower per-report cost. Subscription model for dealers. Must contact Business Development for quotes. |
| **White Label / Embed** | Yes -- Dealer integration, DMS integration, software platform embedding available via partner program. |
| **Key Advantage vs CarVertical** | The CARFAX brand is the most recognized name globally in vehicle history. Strongest cross-border data (especially USA imports). Deep institutional trust with banks, insurers, and dealers. |
| **Key Disadvantage** | Higher consumer price (up to 39.99 EUR vs 24.99 EUR). VIN-only search (no plate lookup on carfax.eu). B2B pricing opaque; requires sales contact. |

**Sources:**
- [CARFAX Europe Pricing](https://www.carfax.eu/pricing)
- [CARFAX Partner Program](https://www.carfax.com/company/partners)
- [CARFAX Vehicle History Report](https://www.carfax.eu/vehicle-history-report)
- [CARFAX Stolen Car Check](https://www.carfax.eu/stolen-car-check)

---

### 2.3 Vincario / vindecoder.eu

| Field | Details |
|---|---|
| **Website** | [vincario.com](https://vincario.com/) / [vindecoder.eu](https://vindecoder.eu/) |
| **HQ** | Czech Republic |
| **API Availability** | **YES** -- Full REST JSON API, integration in <5 minutes. Available on RapidAPI and direct. |
| **Search Method** | **VIN only** |
| **Countries Covered** | Global (extended European + North American support). Vehicles from 1981 to present. |
| **Data Included** | VIN decoding (specs, make, model, year, engine), stolen vehicle check (CZ, HU, IT, RO, SI, SK + own database), market value estimates, odometer data, basic history |
| **France Coverage** | **Limited** -- Stolen vehicle database does NOT explicitly include France (covers CZ, HU, IT, RO, SI, SK). VIN decoding works for all EU vehicles. Market value data available for European vehicles. French-specific SIV data is NOT included. |
| **Consumer Pricing** | 3 free VIN lookups/month. Subscription-based with monthly lookup limits. API pricing starts at approx. $0.25/VIN decode. |
| **Business/B2B Pricing** | Subscription plans with monthly lookup limits. 20 free API VIN lookups for trial. Rate limit: 60 VIN lookups/minute. Scales by volume. Must visit vincario.com/pricing for current tiers. |
| **White Label / Embed** | Partial -- API can be used to build white-label solutions. WordPress plugin integration available (StylemixThemes Motors). |
| **Key Advantage vs CarVertical** | Developer-friendly API with very fast integration. Free tier for testing. Lower entry cost. Strong VIN decoding accuracy across EU. |
| **Key Disadvantage** | NOT a full vehicle history provider -- primarily a VIN decoder with some history data. French coverage is weak (no SIV data, no French stolen database). More useful as a supplementary data source than a primary history provider. |

**Sources:**
- [Vincario Pricing](https://vincario.com/pricing/)
- [Vincario VIN Decoder API](https://vincario.com/vin-decoder/)
- [Vincario Stolen Vehicle Check](https://vincario.com/stolen-vehicle-check/)
- [VIN Decoder API Pricing 2026](https://vincario.com/blog/vin-decoder-api-pricing/)

---

### 2.4 CarsXE

| Field | Details |
|---|---|
| **Website** | [api.carsxe.com](https://api.carsxe.com/) |
| **HQ** | USA |
| **API Availability** | **YES** -- Full developer API suite. REST API with 120ms response times, 99.9% uptime. |
| **Search Method** | **VIN + License Plate** (multi-country plate decoding including France) |
| **Countries Covered** | Global: North America (primary), Europe, Asia. 99.31% VIN coverage across Europe. France explicitly supported for plate decoding. |
| **Data Included** | VIN decoding, vehicle history, market value, recalls, vehicle images, license plate OCR, specifications |
| **France Coverage** | **Moderate** -- France is explicitly supported for plate decoding. European vehicle history is available but "not as extensive" as North American coverage (per their own documentation). |
| **Consumer Pricing** | N/A (API-only, B2B product) |
| **Business/B2B Pricing** | Starting at $99/month + API call fees. 7-day free trial available. Volume discounts. |
| **White Label / Embed** | Yes -- API designed for building into third-party applications and platforms. |
| **Key Advantage vs CarVertical** | API-first approach with fast integration. Multi-country plate decoding (including France). Comprehensive API suite (not just history -- also specs, values, images, OCR). 8,000+ customers, 2M+ daily API calls. |
| **Key Disadvantage** | European history data acknowledged as less comprehensive than North American data. Higher base cost ($99/month minimum). US-centric company. |

**Sources:**
- [CarsXE Vehicle History API](https://api.carsxe.com/vehicle-history)
- [CarsXE Pricing](https://api.carsxe.com/pricing)
- [CarsXE Plate Decoder](https://api.carsxe.com/vehicle-plate-decoder)
- [CarsXE EU VIN Decoding](https://api.carsxe.com/blog/top-apis-for-eu-vin-decoding)

---

### 2.5 Vehicle Databases / Detailed Vehicle History (DVH)

| Field | Details |
|---|---|
| **Website** | [vehicledatabases.com](https://vehicledatabases.com/) / [detailedvehiclehistory.com](https://detailedvehiclehistory.com/) |
| **HQ** | USA |
| **API Availability** | **YES** -- 25+ APIs available. Full REST API documentation. |
| **Search Method** | **VIN** (Europe VIN Decoder API supports 1981-present) |
| **Countries Covered** | US, Canada, Europe. 80+ million vehicle records. 250+ million vehicles in auction database. |
| **Data Included** | Title records, ownership history, service history, accident records, open liens, repair history, maintenance history, market value, warranty info, open recalls, mileage readings, auction history |
| **France Coverage** | **Moderate** -- France-specific VIN checks available via DVH (detailedvehiclehistory.com/france). European VIN decoding supported. Auction history from worldwide partnerships. |
| **Consumer Pricing** | Pay-as-you-go, monthly, and yearly subscription options |
| **Business/B2B Pricing** | Flexible pricing. Pay-as-you-go, monthly, and yearly plans. Enterprise pricing available on request. |
| **White Label / Embed** | Yes -- Powers multiple white-label brands (DVH, Smart Car Check, ShopSmartAutos, Vehicle History Europe/VHR.eu, CarTrackers, GoAutoVIN). |
| **Key Advantage vs CarVertical** | Largest number of APIs (25+). Powers multiple white-label brands proving the technology. Strong auction history coverage (250M+ vehicles). Flexible pricing models. |
| **Key Disadvantage** | US-centric data depth. European data is secondary focus. French-specific coverage details are sparse. |

**Sources:**
- [Vehicle Databases Documentation](https://vehicledatabases.com/docs/)
- [Vehicle Databases APIs](https://vehicledatabases.com/api)
- [DVH France](https://detailedvehiclehistory.com/france)
- [Vehicle History API](https://vehicledatabases.com/vehicle-history-api)

---

## 3. Tier 2: France-Specific Vehicle History Providers

### 3.1 HistoVec (Government - Free)

| Field | Details |
|---|---|
| **Website** | [histovec.interieur.gouv.fr](https://histovec.interieur.gouv.fr/) |
| **Operator** | French Ministry of Interior (beta.gouv.fr startup) |
| **API Availability** | **NO** -- No public API. Owner must log in with personal data + registration card info to generate a shareable link. |
| **Search Method** | **License plate + owner's personal data** (owner-initiated only) |
| **Countries Covered** | **France only** (all vehicles registered in the SIV system) |
| **Data Included** | First registration date, all ownership changes, accidents with controlled repair procedures, administrative status (liens, oppositions, theft declarations), technical inspection dates and results, mileage history from inspections, vehicle technical characteristics (brand, color, engine, power, noise, pollution, etc.) |
| **France Coverage** | **BEST** -- Official government source. Covers the entire French vehicle fleet. Most authoritative and complete French data available. |
| **Pricing** | **FREE** |
| **White Label / Embed** | **NO** -- Cannot be integrated. Owner must manually generate and share report links. |
| **Key Advantage vs CarVertical** | Free. Official government data. Most complete French history available (all technical inspections, all ownership changes, all declared accidents). |
| **Key Disadvantage** | No API. Requires vehicle owner cooperation (owner must generate report). Cannot be automated or embedded. No cross-border data. Consumer-only. |

**Sources:**
- [HistoVec Homepage](https://histovec.interieur.gouv.fr/)
- [HistoVec on beta.gouv.fr](https://beta.gouv.fr/startups/histovec.html)
- [Service Public - HistoVec](https://www.service-public.fr/particuliers/vosdroits/R52957)

---

### 3.2 Autoviza (by NGC-Data)

| Field | Details |
|---|---|
| **Website** | [autoviza.fr](https://autoviza.fr/) |
| **Operator** | NGC-Data (New General Company) -- Level 1 SIV licensee from Ministry of Interior |
| **API Availability** | **Likely YES (B2B)** -- NGC-Data operates the NGC-VIN API (80 million calls in 2022). Autoviza itself is the consumer product. NGC-VIN API provides vehicle identification from plates/VIN. Contact NGC-Data for B2B API access. |
| **Search Method** | **License plate (primary) + VIN** |
| **Countries Covered** | **France only** (all French-registered vehicles) |
| **Data Included** | Complete vehicle identification, technical data (SRA pricing data), ownership history, uses (individual/professional/rental), technical inspection history, mileage progression, manufacturer warranties, vehicle options and finishes from VIN |
| **France Coverage** | **EXCELLENT** -- Autoviza is self-described as "L'historique auto le plus complet en France" (the most complete vehicle history in France). SIV Level 1 licensed. Integrated into LeBonCoin and La Centrale (France's two largest classifieds platforms). |
| **Consumer Pricing** | 25 EUR TTC per report (accessible for 10 weeks) |
| **Business/B2B Pricing** | Professional rates available. Integrated into major French platforms (LeBonCoin, La Centrale). Contact NGC-Data for B2B pricing. |
| **White Label / Embed** | **YES** -- Already white-labeled/embedded into LeBonCoin and La Centrale. NGC-VIN API available for integration. Three product lines: NGC-VIN (plate-to-vehicle-data), NGC-TRENDS (market statistics), AUTOVIZA (history reports). |
| **Key Advantage vs CarVertical** | Deepest French data coverage (SIV Level 1 license). Already integrated into France's largest platforms. Plate-based search (natural for French users). NGC-VIN API handles 80M calls/year proving scalability. |
| **Key Disadvantage** | France-only coverage. No cross-border/international data. Higher consumer price (25 EUR) with less discount flexibility. |

**Sources:**
- [Autoviza Homepage](https://autoviza.fr/)
- [Autoviza Report Details](https://autoviza.fr/le-rapport-historique-vehicule-autoviza)
- [Autoviza on LeBonCoin](https://assistance.leboncoin.info/hc/fr/articles/11829677964178)
- [Autoviza on La Centrale](https://www.lacentrale.fr/autoviza.php)
- [NGC-Data](https://ngc-data.fr/)
- [Autoviza Professional Space](https://autoviza.fr/a-propos/historique-voiture-professionnels)

---

### 3.3 Autorigin

| Field | Details |
|---|---|
| **Website** | [autorigin.com](https://autorigin.com/) |
| **Operator** | Automobile Intelligence (French company, operating since 2016/launched 2017) |
| **API Availability** | **Unknown** -- No public API documentation found. Consumer web platform. May offer B2B access upon request. |
| **Search Method** | **License plate** |
| **Countries Covered** | **France only** (all French vehicles: cars, HGVs, motorcycles, commercial vehicles, camper vans, agricultural equipment) |
| **Data Included** | Ownership history, vehicle options, manufacturer warranties, technical inspection passages, police reports, mileage history, accident declarations |
| **France Coverage** | **Very Good** -- Covers all French vehicle types. Uses SIV-derived data. |
| **Consumer Pricing** | Standard report: 6.95 EUR (essential: owners, uses, technical inspections). Detailed report: 19.95 EUR (includes full loss history). Pack of 2 detailed: 13 EUR/unit. Seller report: 9.90 EUR. **FREE option** available (basic report since Dec 2020). |
| **Business/B2B Pricing** | Professional preferential rates based on volume. Contact sales for details. |
| **White Label / Embed** | **Unknown** -- No public white-label offering found. |
| **Key Advantage vs CarVertical** | Lowest entry price in France (6.95 EUR standard, or free for basic). Covers ALL French vehicle types including agricultural/commercial. Very competitive professional pricing. |
| **Key Disadvantage** | France-only. No API documentation publicly available. No cross-border data. Limited brand recognition compared to CarVertical/CARFAX. |

**Sources:**
- [Autorigin Homepage](https://autorigin.com/)
- [Autorigin Vehicle History](https://autorigin.com/historique-de-vo)
- [Auto Infos - Autorigin](https://www.auto-infos.fr/article/comment-les-historiques-autorigin-s-implantent-sur-le-marche-du-vehicule-d-occasion.281493)

---

### 3.4 CarVerif

| Field | Details |
|---|---|
| **Website** | [carverif.fr](https://carverif.fr/) |
| **Operator** | French company |
| **API Availability** | **NO** (consumer-only web platform; no API documentation found) |
| **Search Method** | **License plate** |
| **Countries Covered** | **France only** |
| **Data Included** | Mileage evolution (from technical inspections and dealer data), number of owners and profile (individual, professional, rental), theft status, accident history, previous uses |
| **France Coverage** | **Good** -- Uses technical inspection records and dealership maintenance data for French vehicles. |
| **Consumer Pricing** | 19.90 EUR per report (sent by email within 5-10 minutes) |
| **Business/B2B Pricing** | Not publicly available. |
| **White Label / Embed** | **NO** |
| **Key Advantage vs CarVertical** | Slightly lower price (19.90 EUR vs 24.99 EUR). Fast delivery (5-10 min by email). French-focused with owner profile data. |
| **Key Disadvantage** | No API. France-only. Consumer-only platform. No B2B/white-label options. Limited utility for platform integration. |

**Sources:**
- [CarVerif Homepage](https://carverif.fr/)
- [CarVerif Vehicle History Report](https://carverif.fr/products/rapport-historique-voiture)

---

### 3.5 AAA Data / SIVin API

| Field | Details |
|---|---|
| **Website** | [aaa-data.fr](https://www.aaa-data.fr/) |
| **Operator** | AAA Data (60+ years in French vehicle data) |
| **API Availability** | **YES** -- SIVin API available since 2008. |
| **Search Method** | **License plate + VIN** |
| **Countries Covered** | **France only** |
| **Data Included** | Technical vehicle data (75 million vehicles): cars, motorcycles, utility vehicles, camper vans. Vehicle identification, specifications, registration data. **Note: This is technical/identification data, NOT a full vehicle history report (no accident/theft/mileage history).** |
| **France Coverage** | **EXCELLENT for technical data** -- 75 million French vehicles covered. Real-time data access. |
| **Pricing** | B2B only. Contact AAA Data for pricing. Not publicly listed. |
| **White Label / Embed** | API integration available for B2B clients. |
| **Key Advantage vs CarVertical** | 60+ years of French automotive data expertise. 75M vehicles. Real-time technical data API. Deep French market knowledge and additional services (nominal data, market statistics, data visualization). |
| **Key Disadvantage** | NOT a vehicle history provider (no damage, theft, mileage tracking). Purely technical/identification data. France-only. Opaque pricing. |

**Sources:**
- [AAA Data SIVin API](https://www.aaa-data.fr/api-sivin/)
- [AAA Data Homepage](https://www.aaa-data.fr/)

---

### 3.6 NGC-Data / NGC-VIN API

| Field | Details |
|---|---|
| **Website** | [ngc-data.fr](https://ngc-data.fr/) |
| **Operator** | New General Company (also operates Autoviza) |
| **API Availability** | **YES** -- NGC-VIN API (80 million calls in 2022) |
| **Search Method** | **License plate + VIN** |
| **Countries Covered** | **France only** |
| **Data Included** | SIV blocks 4 & 5 data + exclusive NGC databases. Vehicle identification, technical data, SRA pricing data, vehicle options and finishes from VIN. |
| **France Coverage** | **EXCELLENT** -- Level 1 SIV licensee from Ministry of Interior. Most authoritative private access to French vehicle registration data. |
| **Pricing** | B2B only. Contact NGC-Data for pricing. Not publicly listed. |
| **White Label / Embed** | Yes -- Powers Autoviza consumer product. API available for B2B integration. |
| **Key Advantage vs CarVertical** | Direct SIV Level 1 access (highest level of government data access for private companies in France). Proven at scale (80M API calls/year). Powers major French platforms. |
| **Key Disadvantage** | France-only. Vehicle identification/technical data focus (Autoviza adds the history layer). Pricing opaque. |

**Sources:**
- [NGC-Data Homepage](https://ngc-data.fr/)
- [NGC-Data LinkedIn](https://fr.linkedin.com/company/ngc-data)

---

## 4. Tier 3: European Data & Valuation Platforms (Not Pure History)

### 4.1 Autovista Group / Eurotax

| Field | Details |
|---|---|
| **Website** | [autovista.com](https://autovista.com/) / [autovista.fr](https://autovista.fr/) / [autovistagroup.com](https://autovistagroup.com/) |
| **HQ** | European (part of J.D. Power) |
| **API Availability** | **YES** -- Autovista API available. Pay-per-use model. TecDoc-compatible. |
| **Search Method** | Unique vehicle code, VIN |
| **Countries Covered** | All major European markets (France included via autovista.fr) |
| **Data Included** | Vehicle specifications (350+ data fields per vehicle), 12+ years historical data, valuations (residual value forecasts), SMR (Service/Maintenance/Repair) costs, spare parts pricing, electric/hybrid technical data. **NOT a vehicle history report provider** -- no accident/theft/mileage tracking. |
| **France Coverage** | **EXCELLENT for valuation & specs** -- Dedicated French operation (autovista.fr). Sets the European standard in vehicle valuation. |
| **Pricing** | B2B only. Pay-per-use API model. Enterprise pricing. Contact sales. |
| **White Label / Embed** | Yes -- API and data feed integration. DMS integration available. |
| **Key Advantage vs CarVertical** | Industry standard for vehicle valuation in Europe. 350+ data fields per vehicle. Used by banks, insurers, lessors, dealers across Europe. J.D. Power backing. |
| **Key Disadvantage** | NOT a vehicle history provider. No accident, theft, or mileage data. Enterprise-only pricing (likely expensive). Different product category. |

**Sources:**
- [Autovista API](https://autovista.com/product/autovista-api/)
- [Autovista France Data & API](https://autovista.fr/produit/data-api-solutions/)
- [Eurotax Data](https://autovistagroup.com/products-and-services/eurotax-data)

---

### 4.2 Afteriize

| Field | Details |
|---|---|
| **Website** | [afteriize.com](https://www.afteriize.com/) |
| **API Availability** | **YES** -- Vehicle API, Oil API, Tire API, Spare Parts Catalog API |
| **Focus** | Automotive aftermarket data (NOT vehicle history) |
| **France Coverage** | French and European markets |
| **Key Note** | Useful for vehicle identification and spare parts data, NOT for vehicle history reports. |

**Sources:**
- [Afteriize API](https://www.afteriize.com/api/)

---

### 4.3 AutoPass Group

| Field | Details |
|---|---|
| **Website** | [autopassgroup.com](https://www.autopassgroup.com/) |
| **API Availability** | **YES** -- API Vehicle product available via marketplace |
| **Focus** | Digital catalogs and automotive data for aftermarket professionals |
| **France Coverage** | French-focused |
| **Key Note** | Vehicle identification API, not a vehicle history report provider. Focused on aftermarket parts catalogs. |

**Sources:**
- [AutoPass API Vehicle](https://autopassgroup.com/products/api/vehicle/)

---

### 4.4 IZISCAR / AutomotivAPI

| Field | Details |
|---|---|
| **Website** | [automotivapi.com](https://automotivapi.com/) / [iziscar.com](https://iziscar.com/) |
| **API Availability** | **YES** -- VIN decoding, registration data, mechanical history |
| **Focus** | Vehicle identification and mechanical data (uses DAT database since Oct 2023) |
| **France Coverage** | France-based, French market focused |
| **Key Note** | Provides "mechanical history" which may include service records. Uses DAT database. Not a full vehicle history report provider in the CarVertical sense. |

**Sources:**
- [IZISCAR Automotive API](https://automotivapi.com/)
- [IZISCAR Database](https://iziscar.com/base-de-donnee-automobile/)

---

## 5. Tier 4: Other European / International Providers

### 5.1 EpicVIN

| Field | Details |
|---|---|
| **Website** | [epicvin.com](https://epicvin.com/) |
| **API Availability** | **Unknown** -- No API documentation found. Consumer-facing web service. |
| **Search Method** | VIN |
| **Focus** | Primarily US vehicles (350M+ VIN records). International VIN decoder available. |
| **France Coverage** | **Minimal** -- US-focused. International VIN decoding is secondary. |
| **Pricing** | $1 trial, then subscription. |
| **Key Note** | Not relevant for French market B2B integration. |

---

### 5.2 VIN Data Hub

| Field | Details |
|---|---|
| **Website** | [vindatahub.com](https://vindatahub.com/) |
| **API Availability** | **Unknown** |
| **Focus** | Emerging CarVertical alternative in Europe. Limited public information available. |
| **France Coverage** | **Unknown** |
| **Key Note** | New entrant positioning against CarVertical. Insufficient public data to evaluate. |

---

### 5.3 MotorCheck (UK/Ireland)

| Field | Details |
|---|---|
| **Website** | [motorcheck.co.uk](https://www.motorcheck.co.uk/) / [motorcheck.ie](https://www.motorcheck.ie/) |
| **API Availability** | **YES** -- Full API with OAuth 2 authentication, SSL delivery. Postman documentation available. |
| **Search Method** | **VRM (Vehicle Registration Mark)** -- UK/Ireland plates |
| **Countries Covered** | **UK and Ireland only** |
| **Data Included** | Write-off check, finance check, stolen check, mileage check, 100+ vehicle data fields, market valuations (private sale, part exchange, auction, trade), running costs, 4,000+ EU vehicle recalls |
| **France Coverage** | **NONE** -- UK/Ireland only. EU recall data is the only cross-border element. |
| **Pricing** | B2B API pricing not publicly listed. Contact sales. |
| **White Label / Embed** | API available for third-party integration. |
| **Key Note** | Not relevant for French market. Included for completeness as a European provider. |

**Sources:**
- [MotorCheck API](https://www.motorcheck.co.uk/api/)
- [MotorCheck API Documentation (Postman)](https://documenter.getpostman.com/view/313931/SWLh5S5A)

---

## 6. Providers Not Found / Non-Existent

The following providers from the original research list could not be verified as existing or active services:

| Provider | Research Result |
|---|---|
| **Autobaza** | No results found. Does not appear to exist as a vehicle history API provider. |
| **CheckMyCar** | checkmycar.com exists (US DMV-based VIN check) but has no European coverage or API. |
| **Autotrust** | No vehicle history API provider by this name found in Europe. |
| **AutoExpose** | No vehicle history API provider by this name found in France or Europe. |

---

## 7. Comparative Summary Table

### Full Comparison Matrix

| Provider | API | Search | France Data | Price/Report | Mileage | Damage | Theft | Ownership | Recalls | White Label |
|---|---|---|---|---|---|---|---|---|---|---|
| **CarVertical** (baseline) | YES | VIN+Plate | Moderate | 12.99-24.99 EUR | Yes | Yes | Yes | Yes | Yes | Yes |
| **AutoDNA** | YES | VIN+Plate | Moderate | 9.59-24.99 EUR | Yes | Yes | Yes | Yes | Yes | Yes |
| **CARFAX Europe** | YES (B2B) | VIN | Moderate | Up to 39.99 EUR | Yes | Yes | Yes | Yes | Yes | Yes |
| **Vincario** | YES | VIN | Limited | ~$0.25/decode | Partial | No | Partial | No | No | Partial |
| **CarsXE** | YES | VIN+Plate | Moderate | $99/mo + calls | Yes | Yes | Yes | Yes | Yes | Yes |
| **Vehicle Databases** | YES | VIN | Moderate | Varies | Yes | Yes | Yes | Yes | Yes | Yes |
| **HistoVec** | NO | Plate+Owner | BEST | FREE | Yes | Yes | Yes | Yes | Yes | NO |
| **Autoviza/NGC** | YES (B2B) | Plate+VIN | EXCELLENT | 25 EUR (B2C) | Yes | Yes | Yes | Yes | Yes | Yes |
| **Autorigin** | Unknown | Plate | Very Good | 6.95-19.95 EUR | Yes | Yes | Yes | Yes | Partial | Unknown |
| **CarVerif** | NO | Plate | Good | 19.90 EUR | Yes | Yes | Yes | Yes | No | NO |
| **AAA Data/SIVin** | YES | Plate+VIN | EXCELLENT (tech) | B2B only | No | No | No | No | No | Yes |
| **Autovista/Eurotax** | YES | VIN/Code | EXCELLENT (val) | B2B only | No | No | No | No | No | Yes |
| **MotorCheck** | YES | VRM (UK) | NONE | B2B only | Yes | Yes | Yes | Yes | Yes | Yes |

### Best Providers for French Market B2B Integration (Ranked)

| Rank | Provider | Why |
|---|---|---|
| 1 | **Autoviza / NGC-Data** | Deepest French data (SIV Level 1). Proven at scale (80M calls/year, LeBonCoin/La Centrale). API available. |
| 2 | **AutoDNA** | Best pan-European API with French coverage. Competitive B2B pricing (9.59 EUR at volume). VIN+Plate search. |
| 3 | **CARFAX Europe** | Strongest brand. Best for imported vehicle history (cross-border). B2B API available. |
| 4 | **AAA Data / SIVin** | Best for French vehicle technical identification (75M vehicles). Complementary to a history provider. |
| 5 | **CarVertical** | Strong European coverage. Blockchain technology. Well-known B2B API. Good all-rounder. |
| 6 | **CarsXE** | Best API-first developer experience. Multi-country plate decoding. Good for a unified API approach. |

---

## 8. Recommendations for French Market B2B Integration

### Strategy: Dual-Provider Approach

For optimal coverage in the French market, consider a **dual-provider strategy**:

1. **Primary (French data):** Autoviza / NGC-Data for deep French vehicle history (SIV data, technical inspections, ownership, mileage). This gives you the richest French-specific data, equivalent to or better than what HistoVec provides, but via API.

2. **Secondary (Cross-border / imported vehicles):** AutoDNA or CARFAX Europe for vehicles imported from other EU countries (especially Germany, Belgium, Italy -- the top import origins for French used cars). These providers excel at tracking a vehicle's history across multiple countries.

### Alternative: Single-Provider Simplicity

If a single provider is preferred:
- **AutoDNA** offers the best balance of French coverage, pan-European data, API availability, and B2B pricing.
- **CarVertical** remains competitive with blockchain differentiation and good API documentation.

### Cost Optimization

| Volume | AutoDNA | CarVertical | CARFAX EU | Autoviza |
|---|---|---|---|---|
| 1 report | 24.99 EUR | 24.99 EUR | Up to 39.99 EUR | 25.00 EUR |
| 100 reports | 9.59 EUR/ea | ~13 EUR/ea (est.) | Custom B2B | Custom B2B |
| 1000+ reports | Contact sales | Contact sales | Contact sales | Contact sales |

### Technical Integration Priority

1. **NGC-VIN API** (Autoviza) -- For plate-to-vehicle-data (French vehicles)
2. **AutoDNA WebAPI** -- For VIN-based history reports (pan-European)
3. **AAA Data SIVin API** -- For supplementary French technical data
4. **Vincario API** -- For lightweight VIN decoding (free tier for dev/testing)

---

## 9. Sources & References

### Provider Websites
- AutoDNA: https://www.autodna.com/
- CARFAX Europe: https://www.carfax.eu
- Vincario: https://vincario.com/
- CarsXE: https://api.carsxe.com/
- Vehicle Databases: https://vehicledatabases.com/
- HistoVec: https://histovec.interieur.gouv.fr/
- Autoviza: https://autoviza.fr/
- NGC-Data: https://ngc-data.fr/
- Autorigin: https://autorigin.com/
- CarVerif: https://carverif.fr/
- AAA Data: https://www.aaa-data.fr/
- Autovista: https://autovista.fr/
- MotorCheck: https://www.motorcheck.co.uk/

### Comparison & Review Sources
- [AutoDNA vs CarVertical vs VinAudit](https://www.vinaudit.com/autodna-vs-carvertical-vs-vinaudit)
- [CarVertical vs AutoDNA: 7-Year Comparison](https://www.csabastefan.com/en/carvertical-experiences-comparison-autodna.php)
- [Top 5 VIN Check Tools for Europe (eCarsTrade)](https://ecarstrade.com/blog/best-vin-decoders-for-car-history)
- [Best Vehicle History Reports 2026](https://bestvehiclehistoryreport.com)
- [6 Best Free VIN Decoders 2026 (Vincario)](https://vincario.com/blog/best-free-vin-decoders/)
- [VIN Decoder API Pricing 2026](https://vincario.com/blog/vin-decoder-api-pricing/)
- [UFC-Que Choisir: Vehicle History Sites Review](https://www.quechoisir.org/actualite-voitures-d-occasion-que-valent-les-sites-d-historiques-de-vehicules-d-occasion-n166284/)
- [L'Argus: Vehicle History Sites](https://www.largus.fr/actualite-automobile/achat-occasion-quel-site-pour-connaitre-lhistorique-dun-vehicule-10825397.html)

### Technical References
- [AutoDNA Partners Area](https://www.autodna.com/company/partners-area)
- [MotorCheck API Documentation](https://documenter.getpostman.com/view/313931/SWLh5S5A)
- [CarsXE EU VIN Decoding Guide](https://api.carsxe.com/blog/top-apis-for-eu-vin-decoding)
- [Automotive APIs Overview (AIM Research)](https://research.aimultiple.com/automotive-api/)
- [api.gouv.fr](https://api.gouv.fr/)
