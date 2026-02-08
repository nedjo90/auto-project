---
stepsCompleted: [1, 2]
inputDocuments: ['brainstorming-session-2026-02-07.md', 'technical-apis-etat-vehicules-research-2026-02-07.md', 'technical-mechanical-apis-research-2026-02-08.md', 'carvertical-b2b-api-investigation-2026-02-08.md', 'carvertical-alternatives-europe-france-research-2026-02-08.md', 'projectinit.txt']
date: 2026-02-08
author: Nhan
project_name: auto
---

# Product Brief: auto

<!-- Content will be appended sequentially through collaborative workflow steps -->

## Executive Summary

**auto** is a French vehicle classifieds platform built on radical transparency and certified data. In a market where buyers suffer from information asymmetry and sellers struggle to stand out, auto leverages government and third-party APIs to auto-fill and certify listing data at the field level — creating a dual-layer system where every data point is visibly marked as Certified (API-sourced) 🟢 or Manual (seller-entered) 🟡.

The platform competes on three fronts simultaneously: **price** (€15/listing vs €29-39 on competitors), **trust** (field-level data certification powered by official sources), and **value** (professional-grade cockpit with business intelligence, not just basic listings).

Built on SAP CAP (Node.js), PostgreSQL, and Next.js with a zero-hardcode architecture — every value, text, feature, and business rule is stored in database tables and configurable through an admin panel without code changes. The platform launches with a confirmed anchor client (professional dealer network with existing inventory), eliminating the cold-start problem.

---

## Core Vision

### Problem Statement

The French used vehicle market suffers from three interconnected problems:

1. **Information Asymmetry** — Buyers cannot independently verify seller claims about vehicle condition, history, or maintenance. Current platforms rely entirely on seller declarations with no systematic verification against official data sources.

2. **Seller Visibility Gap** — Honest sellers, particularly professionals managing multiple vehicles, lack tools to differentiate themselves. Good-faith sellers have no way to prove their transparency, competing on equal footing with those who omit unfavorable information.

3. **Prohibitive Platform Costs** — Existing classifieds platforms charge €29-39+ per listing with basic functionality, offering little business intelligence or certification tools in return. This pricing excludes small dealers and private sellers from reaching buyers effectively.

### Problem Impact

| Stakeholder | Impact |
|---|---|
| **Buyers** | Risk overpaying for vehicles with hidden defects; spend hours cross-referencing information across multiple sources; distrust the market and delay purchases |
| **Sellers** | Cannot prove good faith; professional sellers lack business tools (performance tracking, market positioning); pay high platform fees for basic listing services |
| **Market** | Reduced transaction volume due to distrust; downward pressure on prices as buyers assume the worst; no incentive for transparency since honest and dishonest sellers look identical |

### Why Existing Solutions Fall Short

| Criteria | LeBonCoin | La Centrale | Autoscout24 | **auto** |
|---|---|---|---|---|
| **Data certification** | None — 100% declarative | None — 100% declarative | None — 100% declarative | **Field-level certified 🟢 vs manual 🟡** |
| **Vehicle history report** | Optional (buyer pays) | Optional (buyer pays) | Optional (buyer pays) | **Included in listing fee** |
| **Listing price** | €29+ (pro) | €39+ (pro) | ~€30+ (pro) | **€15 all-inclusive** |
| **Seller dashboard** | Basic stats | Basic stats | Basic stats | **Full cockpit: KPIs, market positioning, performance** |
| **Market price comparison** | Manual | Partial (Argus) | Partial | **Auto-calculated, visual indicator** |
| **Declaration of honor** | None | None | None | **Mandatory digital, timestamped, archived** |
| **Admin configurability** | Fixed | Fixed | Fixed | **Zero-hardcode, 100% DB-driven** |

### Proposed Solution

**For Sellers:**
- Enter license plate or VIN → 15+ fields auto-filled from official APIs in 3 seconds (the "wow moment")
- Each field visually marked: Certified 🟢 (API-sourced) or Manual 🟡 (seller-entered)
- Real-time visibility score during listing creation (gamification)
- Professional cockpit: views, contacts, days online, market positioning, stock rotation KPIs
- Mandatory digital declaration of honor with structured checkboxes (not a PDF upload)

**For Buyers:**
- Every listing backed by verifiable certified data — see exactly what's official vs. declared
- Vehicle history report included (no extra cost)
- Advanced filters: budget, valid technical inspection, below market price, certification level
- Market price comparison with visual indicator (below/aligned/above)
- Trust score based on certification rate and seller history

**For Platform (Admin):**
- Complete business control without code: pricing, features, moderation rules, API providers, texts, SEO templates
- Feature-gating architecture: any feature can become free/paid/subscription via admin toggle
- Moderation system with configurable thresholds, granular reporting, and smooth communication
- Audit trail on all operations via middleware

### Key Differentiators

1. **Field-Level Data Certification** — Not just "verified listings" — each individual data field is transparently marked as certified or manual. No other platform offers this granularity.

2. **Price + Value Competition** — At €15/listing (vs €29-39), auto is 2x cheaper while delivering 10x more value through certified data, professional tools, and included vehicle history reports.

3. **Professional Cockpit as Business Tool** — Beyond basic listings: real-time business intelligence, market positioning, stock rotation analytics. Sellers use auto as a work tool, not just an advertising channel (positive lock-in).

4. **Zero-Hardcode Architecture** — 100% database-driven configuration means the business can evolve without developer intervention. New vehicle types, pricing rules, features, moderation policies — all manageable from the admin panel.

5. **Anchor Client Strategy** — Launch with a confirmed professional dealer network bringing existing inventory and buyer relationships. No cold-start problem. Growth path: anchor client → their network → organic professionals → private sellers.

6. **Mandatory Digital Declaration** — Structured digital declaration of honor with timestamped, archived checkboxes. Combined with certified API data, creates an unprecedented level of accountability in the French used vehicle market.
