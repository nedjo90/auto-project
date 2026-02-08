# CarVertical B2B API Investigation Report
## For French Vehicle Classifieds Platform Integration
### Date: 2026-02-08

---

## Table of Contents
1. [Developer Portal & Documentation Access](#1-developer-portal--documentation-access)
2. [API Endpoints & Technical Architecture](#2-api-endpoints--technical-architecture)
3. [Authentication](#3-authentication)
4. [Data Fields Returned in Reports](#4-data-fields-returned-in-reports)
5. [B2B Pricing](#5-b2b-pricing)
6. [Integration Examples & SDKs](#6-integration-examples--sdks)
7. [Webhook / Async Behavior](#7-webhook--async-behavior)
8. [Rate Limits & Quotas](#8-rate-limits--quotas)
9. [Coverage for France](#9-coverage-for-france)
10. [Competitor Comparison](#10-competitor-comparison)
11. [White-Label / Embed Options](#11-white-label--embed-options)
12. [Affiliate / Partner Program](#12-affiliate--partner-program)
13. [GDPR & Data Protection](#13-gdpr--data-protection)
14. [Blockchain & Technology Stack](#14-blockchain--technology-stack)
15. [Integration Architecture Recommendations](#15-integration-architecture-recommendations)
16. [Risk Assessment & Gaps](#16-risk-assessment--gaps)
17. [Sources](#17-sources)

---

## 1. Developer Portal & Documentation Access

### Portal URL
- **Developer Portal**: https://developer.carvertical.com/
- **Business API Page**: https://www.carvertical.com/en/business/api
- **Business Overview**: https://www.carvertical.com/en/business

### Access Model: GATED DOCUMENTATION
CarVertical operates a **closed/gated developer portal**. The documentation is NOT publicly accessible. The portal landing page contains only:
- A tagline: "Data-driven API for smarter car deals"
- A "Request API access" button (links to `/auth/request-access`)
- A "Log in" button (links to `/auth/login`)

**No public OpenAPI/Swagger spec, no public endpoint documentation, no public code samples.**

### What This Means for Integration Planning
- You must **request API access** through `developer.carvertical.com/auth/request-access` before receiving any technical documentation.
- The sales/partnership team will qualify your use case before granting access.
- Expect a sales engagement process before seeing actual API specs.
- CarVertical appears to provide **custom API solutions** tailored to each partner, rather than a standardized self-service API.

### Known API Capabilities (from marketing materials)
1. **VIN Decoder API** - ML-powered, identifies variations across markets, manufacturers, models, years
2. **Vehicle History Report API** - Full report generation via API
3. **PDF Report Generation** - Reports can be generated in PDF format via API
4. **Dynamic Web Page Reports** - Reports presentable as dynamic web pages
5. **US-Origin Alert** - Feature to flag cars imported from the US
6. **License Plate / Registration Lookup** - Can search by VIN or vehicle registration number (REG)

---

## 2. API Endpoints & Technical Architecture

### What Is Publicly Known

| Aspect | Detail |
|--------|--------|
| **Base URL** | Not publicly documented; likely `api.carvertical.com` or similar |
| **API Version** | Not publicly documented; no evidence of v1/v2 versioning in public materials |
| **Protocol** | REST API (HTTP/HTTPS) |
| **Request Format** | Likely JSON (based on industry standard and their TypeScript tech stack) |
| **Response Formats** | JSON (structured data), PDF (downloadable report) |
| **OpenAPI/Swagger Spec** | Not publicly available |
| **Postman Collection** | Not publicly available |

### Inferred API Flow (based on product behavior and marketing materials)

```
1. INPUT: VIN (17-character) or Registration Number (plate)
   |
2. API CALL: Submit VIN/plate to report generation endpoint
   |
3. PROCESSING: CarVertical scans 900+ data sources (takes ~55 seconds)
   |
4. OUTPUT: Structured report data (JSON) or PDF download
```

### Likely Endpoints (inferred, NOT confirmed)

```
POST /api/reports          - Request a new vehicle history report
GET  /api/reports/{id}     - Retrieve a generated report
GET  /api/reports/{id}/pdf - Download PDF version
POST /api/vin-decode       - Decode a VIN number
POST /api/plate-lookup     - Convert license plate to VIN (market-specific)
```

### Report Generation Time
- **Standard web**: ~55 seconds per report
- **Batch (up to 10 VINs)**: ~1 minute for all (parallel processing)
- **API**: Likely similar timing; exact SLA not public

---

## 3. Authentication

### What Is Known
- **Method**: Not publicly documented
- **Likely approach**: API Key-based authentication (standard for B2B vehicle data APIs)
- **Access**: Credentials provided after partnership/sales agreement

### What to Expect (based on industry patterns)
```
Authorization: Bearer <api_key>
# or
X-API-Key: <api_key>
```

### What Is NOT Known
- Whether OAuth 2.0 is supported
- Whether there are separate staging/production environments
- Whether API keys are scoped (read-only, full access, etc.)
- Whether IP whitelisting is required
- Token refresh/rotation policies

---

## 4. Data Fields Returned in Reports

### Report Sections (13 documented sections)

#### 4.1 Accident and Damage History
- Reported accidents
- Accident severity levels
- Repair costs
- Assessment cards showing "signs of possible accidents"
- AI-powered photo analysis for damage detection

#### 4.2 Odometer / Mileage Records
- Historical odometer readings from multiple sources
- Mileage rollback detection
- Readings from: maintenance visits, police records, inspections, registry data
- Statistical benchmarks (typical mileage for vehicle type/age)

#### 4.3 Theft Records
- Whether the car has been reported stolen
- Cross-referenced against international and local law enforcement databases
- Interpol database checks

#### 4.4 Ownership History
- Number of previous owners
- Dates of ownership changes
- Registration history

#### 4.5 Title Check / Title Branding
- Salvage title
- Rebuilt title
- Junk title
- (Primarily for US-origin vehicles)

#### 4.6 Vehicle Specifications & Equipment
- Make, model, variant
- Engine type and displacement
- Fuel type and consumption
- Vehicle dimensions
- Factory equipment list
- Market-specific variations identified by ML

#### 4.7 Market Value Estimation
- Current estimated market price
- Based on current market trends
- Price history data

#### 4.8 Safety Ratings & Recalls
- Official safety ratings (Euro NCAP, etc.)
- Active manufacturer recalls
- Safety-related notices

#### 4.9 Historical Photos
- Photos of the vehicle when available
- Sourced from classifieds, auctions, insurance

#### 4.10 Financial and Legal Status
- Financial restrictions (leases, liens)
- Legal encumbrances
- Last technical inspection data
- Scrap/destruction status overview

#### 4.11 Vehicle Purpose / Usage Classification
- Whether used as taxi
- Whether used as rental vehicle
- Whether used as fleet vehicle

#### 4.12 Emissions
- Vehicle emissions rating
- CO2 emissions data
- Environmental classification

#### 4.13 Timeline
- Chronological overview of vehicle's entire history
- Ownership changes mapped on timeline
- Inspections
- Major events
- Cross-referenced from all data sources

### Important Caveats
- **Not all sections appear in every report** - depends on data availability
- **Data varies by country** - some countries have richer data than others
- **Newer vehicles may have limited data**
- **Administrative errors in source data can affect completeness**

---

## 5. B2B Pricing

### Consumer Pricing (reference baseline)

| Package | Price | Per Report |
|---------|-------|-----------|
| 1 report | ~EUR 16.99 | EUR 16.99 |
| 2 reports | ~EUR 10.49 each | EUR 10.49 |
| 3 reports | ~EUR 8.99 each | EUR 8.99 |

### Business Bulk Packages

| Package | Approximate Per-Report Cost | Notes |
|---------|---------------------------|-------|
| 10 reports (one-time) | ~EUR 7.99 | Valid for 6 months |
| 30 reports (one-time) | ~EUR 7.49 | Valid for 6 months |
| 100 reports (one-time) | Custom pricing (contact sales) | Valid for 6 months |
| 10 reports/month subscription | ~EUR 7.99/report | Auto-renews monthly, credits expire after 30 days |
| 30 reports/month subscription | ~EUR 7.49/report | Auto-renews monthly, credits expire after 30 days |
| Custom/Enterprise | Custom pricing | Requires sales consultation |

### Business Plan Details
- **Unused reports in one-time bundles**: Valid for 6 months from purchase
- **Subscription credits**: Expire after 30 days per billing cycle
- **Auto-renewal**: Monthly subscriptions auto-renew
- **Cancellation**: No penalties; credits remain valid until next billing date
- **Payment methods**: Credit card, PayPal, bank transfer, proforma invoice
- **Discount vs. individual pricing**: Up to 75% reduction at bulk rates

### API Pricing
- **Not publicly listed** - requires direct sales engagement
- Expected to be negotiated based on volume
- Likely structured as per-report cost with monthly minimums
- For a classifieds platform with high volume, expect significant volume discounts

### What to Negotiate
- Per-report API pricing for 1,000+ reports/month
- Annual commitment discounts
- Dedicated SLA terms
- Priority report generation (faster than 55s)
- Dedicated support channel

---

## 6. Integration Examples & SDKs

### Official SDKs
**NONE publicly available.** CarVertical does not publish:
- No npm package
- No Python SDK
- No Java/Kotlin SDK
- No public SDK in any language

### GitHub Organization (github.com/carVertical)
9 public repositories, **none are API SDKs**:

| Repository | Language | Purpose |
|-----------|----------|---------|
| helm-charts | Go Template | Forked Helm charts |
| react-native-homework | - | Hiring exercise |
| data-integration-homework | - | Hiring exercise |
| ml-engineering-homework | - | Hiring exercise |
| homework-backend | TypeScript | Backend hiring exercise |
| postmark-cli | TypeScript | Forked Postmark CLI (MIT) |
| frontend-homework | TypeScript | Frontend hiring exercise |
| data-engineering-homework | - | Hiring exercise |
| qa-homework | TypeScript | QA hiring exercise |

### Technology Insights from GitHub
- CarVertical's backend is **TypeScript/Node.js** based
- They use **React Native** for mobile apps
- They use **Helm/Kubernetes** for infrastructure
- They use **Postmark** for email delivery
- They use **PostHog** for analytics and feature flags

### Third-Party Integrations
- **Spider-VO**: Integrated CarVertical's API for one-click report access across all channels (confirmed working integration)

### What You Will Need to Build
Since there is no SDK, you will need to build a custom API client. Based on the TypeScript tech stack, a typical integration would look like:

```typescript
// Pseudocode - actual endpoints/auth not publicly documented
interface CarVerticalClient {
  generateReport(vin: string): Promise<ReportResponse>;
  getReport(reportId: string): Promise<Report>;
  downloadPdf(reportId: string): Promise<Buffer>;
  decodeVin(vin: string): Promise<VinDecodeResult>;
}
```

---

## 7. Webhook / Async Behavior

### What Is Known
- Report generation takes approximately **55 seconds** (web interface)
- Batch processing of up to 10 VINs takes approximately **1 minute**
- The API page mentions reports being available "in just 55 seconds"

### What Is NOT Known
- **Webhooks**: No public documentation of webhook support for report completion callbacks
- **Polling vs. Push**: Unknown whether the API uses polling (client checks status) or push (webhook notification)
- **Async pattern**: Unknown whether the API returns immediately with a report ID for later retrieval, or blocks until the report is ready

### Likely Implementation (inferred)
Given the 55-second generation time, the API almost certainly uses an **asynchronous pattern**:
```
1. POST /reports {vin: "..."} -> Returns {reportId: "abc123", status: "processing"}
2. Poll GET /reports/abc123 -> Returns {status: "processing"} or {status: "completed", data: {...}}
   OR
   Webhook callback to your URL when report is ready
```

### Recommendation
When engaging with CarVertical sales, specifically ask:
1. Does the API support webhook callbacks?
2. What is the recommended polling interval if webhooks are not available?
3. Is there a synchronous mode for pre-cached reports?
4. What is the timeout for report generation?

---

## 8. Rate Limits & Quotas

### What Is Known
- **Batch limit**: Up to 10 VINs can be processed simultaneously (web interface)
- **No publicly documented API rate limits**

### What Is NOT Known
- Requests per second/minute limits
- Concurrent request limits
- Monthly quota limits beyond purchased credits
- Burst vs. sustained rate policies
- Rate limit response headers/codes

### Recommendation for Integration Planning
- Implement client-side rate limiting (suggest starting at 10 requests/second)
- Implement exponential backoff on 429 (Too Many Requests) responses
- Queue VIN lookups and process them in controlled batches
- Cache results to avoid redundant API calls

---

## 9. Coverage for France

### CarVertical's French Coverage

| Aspect | Status |
|--------|--------|
| **Available in France** | Yes - carvertical.com/fr with French-language interface |
| **French license plate (plaque) lookup** | Yes - supports registration number searches |
| **Data sources** | 900+ across 40+ countries; France included |
| **Support language** | French-speaking staff available |
| **Currency** | EUR |
| **Local domain** | carvertical.com/fr?l=fr |

### Data Available for French Vehicles

**What CarVertical CAN provide for French vehicles:**
- VIN decoding and specifications
- International damage/accident history (if reported across borders)
- International theft checks (Interpol + local databases)
- Mileage records (from maintenance, inspections)
- Market value estimates
- Safety ratings and recalls
- Emissions data
- Vehicle purpose classification (taxi, rental, fleet)
- Historical photos (from classifieds/auctions)

**What CarVertical may LACK for French vehicles compared to Histovec:**
- Direct SIV (Systeme d'Immatriculation des Vehicules) integration is uncertain
- French administrative status (gage, opposition, etc.) may be less detailed
- French-specific controle technique history may be limited
- Number of French owners may be less accurate than Histovec

### Histovec - The French Government Alternative

| Feature | Histovec | CarVertical |
|---------|----------|-------------|
| **Cost** | Free | ~EUR 7-17/report |
| **Data source** | SIV (official French registry) | 900+ international sources |
| **French vehicle status** | Comprehensive (gage, opposition, vol) | Partial |
| **International data** | None | Extensive (40+ countries) |
| **Accident history** | Limited | More comprehensive |
| **Mileage verification** | Limited | Better (multiple sources) |
| **Import history** | No | Yes |
| **API availability** | No public API | Yes (B2B API) |
| **Controle technique** | Yes (via SIV) | Limited |

### Recommendation for French Market
For a French classifieds platform, **the optimal strategy is to combine both**:
1. **CarVertical API** for comprehensive vehicle history, damage, mileage, international checks
2. **Histovec data** (manual or via user-shared reports) for official French administrative status

CarVertical's main value-add for France is:
- Imported vehicle checks (especially from Germany, Belgium, Netherlands - common import origins)
- Damage history from insurance databases across Europe
- Mileage fraud detection using international data
- Professional API integration capability (which Histovec does not offer)

---

## 10. Competitor Comparison

### CarVertical vs. AutoDNA vs. Carfax Europe

| Feature | CarVertical | AutoDNA | Carfax (Europe) |
|---------|------------|---------|-----------------|
| **HQ** | Vilnius, Lithuania | Warsaw, Poland | London, UK / US |
| **Founded** | 2017 | 2009 | 1984 (US) |
| **Single report price** | ~EUR 14.99-16.99 | EUR 24.99 | ~EUR 39 |
| **5-report bundle** | ~EUR 59.99 | ~EUR 124.95 | N/A |
| **European coverage** | 35+ countries | 26+ markets | Limited EU |
| **US coverage** | Yes | Yes | Excellent |
| **Blockchain** | Yes (ERC20 token) | No | No |
| **API available** | Yes (B2B) | Yes (WebAPI) | Yes (B2B) |
| **France specific** | Good | Good | Weak |
| **Country-specific reports** | No | Yes | N/A |
| **Report granularity** | Comprehensive | More granular | Very detailed (US) |
| **Data sources** | 900+ | 50,000+ institutions | Extensive (US-focused) |
| **B2B partner count** | 3,500+ | Not disclosed | Large |
| **Report generation time** | ~55 seconds | Not disclosed | Not disclosed |
| **Trust badge** | Yes | Not prominent | Not in EU |
| **White-label** | Yes | Limited | Limited |

### Key Differentiators

**CarVertical Advantages:**
- Lower per-report pricing
- Blockchain-based data integrity
- ML-powered VIN decoder
- Trust Badge for dealer listings (21% more clicks claimed)
- French-language support
- Comprehensive white-label offering
- 55-second generation time

**CarVertical Disadvantages:**
- Documentation accuracy concerns reported in long-term studies
- No country-specific report option (unlike AutoDNA)
- Newer company (less historical data depth)
- Some documented delays in recording damage events
- No public API documentation

**AutoDNA Advantages:**
- More granular, country-specific reporting
- Longer operational history (since 2009)
- 50,000+ institutional data sources
- Country-specific report option
- Public API documentation (WebAPI)

**Carfax Advantages:**
- Gold standard for US vehicles
- Deepest US data coverage
- Strongest brand recognition globally

### Alternative Providers to Consider

| Provider | Specialty | API | France |
|----------|----------|-----|--------|
| **AutoRef** | License plate to VIN conversion, VIN checks | Yes (public API docs) | Yes |
| **Odopass** | French-focused vehicle history | Unknown | Excellent |
| **CarVerif** | French vehicle verification | Unknown | Excellent |
| **VinAudit** | US/Canada focused | Yes | No |
| **EpicVIN** | US focused | Yes | No |

---

## 11. White-Label / Embed Options

### Confirmed White-Label Offerings

CarVertical offers a **"White Label Buyer Solution"** that includes:

| Component | Description |
|-----------|-------------|
| **Website Templates** | Pre-built templates for dealer/partner websites |
| **Automatic Reporting** | Automated report creation system |
| **CMS** | Content Management System for managing listings |
| **CRM** | Customer Relationship Management system |
| **API** | Full API integration |
| **Payment Processing** | Integrated payment handling |

**Cost**: Monthly fee (amount requires sales consultation)

### Trust Badge Integration
- URL: https://trust.carvertical.com/
- Dealers display CarVertical Trust Badge on listings
- Claims 21% more clicks on ads with the badge
- Physical branding materials also available for on-premises display

### Report Presentation Options via API
1. **Dynamic Web Page** - Report rendered as an interactive web page (can be embedded/linked)
2. **PDF Download** - Precisely formatted PDF for sharing/printing

### What Is NOT Confirmed
- Whether iframe embedding of reports is supported
- Whether reports can be rendered with custom branding (your logo instead of CarVertical's)
- Whether JavaScript widget/snippet is available for embedding
- Whether there is a co-branded report option (both your brand and CarVertical's)

### Recommendation
For a classifieds platform, the most likely integration patterns are:
1. **API + Custom UI**: Fetch report data via API, render in your own UI/design system
2. **Link-out**: Provide a link to the CarVertical hosted report page
3. **PDF embed**: Embed/display the PDF report within your listing page
4. **Trust Badge**: Display the CarVertical Trust Badge on listings that have verified reports

---

## 12. Affiliate / Partner Program

### Affiliate Program

| Feature | Detail |
|---------|--------|
| **URL** | https://www.carvertical.com/en/affiliate-program |
| **Commission** | Starting from EUR 4 per sale |
| **Sub-affiliate commission** | 5% of sub-affiliate's sales |
| **Cookie window** | 90 days |
| **Minimum payout** | EUR 50 |
| **Maximum payout** | No cap (examples up to EUR 50,000) |
| **Payment frequency** | Monthly (15th of month for previous month) |
| **Payment methods** | Bank transfer, PayPal |
| **Joining bonus** | EUR 10 for new affiliates |
| **Joining fee** | Free |
| **Dedicated manager** | Yes |
| **Promotional materials** | Yes (provided free) |
| **Markets** | 38+ |
| **Restrictions** | No PPC advertising allowed |

### Partner / Dealership Program

| Feature | Detail |
|---------|--------|
| **Trust Badge** | Free for verified dealer partners |
| **Co-marketing** | Social media exposure (230,000+ followers) |
| **Media coverage** | PR support for long-term partners |
| **Bulk pricing** | Discounted per-report rates |
| **Dedicated support** | Multilingual B2B team |

### Platform Networks
CarVertical affiliate program is available through:
- **Awin** (affiliate network)
- **Admitad** (affiliate network)
- Direct sign-up via carvertical.com

### Relevance for Classifieds Platform
For a B2B integration, the **affiliate program is NOT the right model**. Instead, pursue the **API partnership**:
- Affiliate = you send traffic to CarVertical, earn commission per sale
- API Partner = you integrate CarVertical data directly into your platform, pay per report via API

However, you could potentially combine both:
- Use API for deep integration
- Use affiliate links for upselling premium reports to users who want more detail

---

## 13. GDPR & Data Protection

### Compliance Framework
- **GDPR Compliant**: Yes (EU General Data Protection Regulation 2016/679)
- **Jurisdiction**: Republic of Lithuania (EU member state)
- **Security Certification**: ISO/IEC 27001:2017 certified
- **DPO Contact**: dpo@carvertical.com
- **General Contact**: info@carvertical.com

### Vehicle Data Processing
- CarVertical states that under Article 11(2) GDPR, they **cannot directly link vehicle data to the owner/holder** of that vehicle
- Vehicle data is considered as data where the data subject is not directly identifiable
- Data retained for **30 years** from receipt

### Data Sources & Legal Basis
- Processing based on **legitimate interest** (Article 6(1)(f) GDPR)
- Data sourced from: official vehicle registers, maintenance/repair providers, authorized repairers, vehicle dealers, insurance claims administrators, publicly available internet data
- Data used for: AI training, performance statistics, dispute handling

### Privacy Documentation
- **Vehicle Data Privacy Notice**: https://www.carvertical.com/en/vehicle-data-privacy-notice
- **User Privacy Policy**: https://www.carvertical.com/privacy-policy
- **User Research Privacy Policy**: https://www.carvertical.com/privacy-policy-for-user-research

### Implications for French Platform
- As a Lithuanian (EU) company, CarVertical's data processing is subject to EU law
- Standard Contractual Clauses or Data Processing Agreements should be established
- Your platform will likely be a **Data Controller** and CarVertical a **Data Processor** for API-generated reports
- French CNIL requirements apply to your handling of the data
- Vehicle data is generally not considered personal data per se, but VIN linked to owner information may be

---

## 14. Blockchain & Technology Stack

### Blockchain Heritage
- CarVertical launched with a blockchain-based vehicle registry concept
- **cV Token**: ERC20 token on Ethereum (contract: 0x50bc2ecc0bfdf5666640048038c1aba7b7525683)
- Original concept: decentralized vehicle data storage, tamper-proof records
- **Current status of blockchain**: The cV token has minimal trading volume (~$70/day). The blockchain component appears to be largely vestigial; the core product now operates as a standard SaaS platform with API access.

### Technology Stack (inferred from hiring exercises and tools)
| Layer | Technology |
|-------|-----------|
| **Backend** | TypeScript / Node.js |
| **Frontend** | React, React Native (mobile) |
| **Infrastructure** | Kubernetes (Helm charts) |
| **Email** | Postmark |
| **Analytics** | PostHog (feature flags + analytics) |
| **Data/ML** | ML-powered VIN decoder, AI photo analysis |
| **Security** | ISO/IEC 27001:2017 |

---

## 15. Integration Architecture Recommendations

### Recommended Architecture for French Classifieds Platform

```
+---------------------------+
|  Your Classifieds         |
|  Platform (Frontend)      |
+----------+----------------+
           |
           v
+----------+----------------+
|  Your Backend API         |
|  (Integration Layer)      |
+----+-------+------+------+
     |       |      |
     v       v      v
+----+--+ +--+---+ ++------+
|CarVert| |Cache  | |Your DB|
|API    | |(Redis)| |       |
+-------+ +------+ +-------+
```

### Integration Flow

```
1. User views vehicle listing on your platform
2. Your backend checks cache for existing CarVertical report
3. If cached: Return report data immediately
4. If not cached:
   a. Submit VIN to CarVertical API
   b. Wait for report generation (~55s) or receive webhook callback
   c. Store report data in your database/cache
   d. Return report data to frontend
5. Frontend renders report data in your UI/design system
6. Optionally: Provide PDF download link
```

### Key Design Decisions

| Decision | Recommendation |
|----------|---------------|
| **When to generate reports** | On-demand when user views listing, with aggressive caching |
| **Or pre-generate** | For featured/promoted listings, generate proactively |
| **Cache TTL** | 24-48 hours (vehicle history doesn't change frequently) |
| **Error handling** | Graceful degradation - show listing without report if API fails |
| **User experience** | Show "Generating report..." spinner for first-time requests |
| **Report display** | Custom UI rendering from API JSON data (not iframe/embed) |
| **PDF** | Offer as downloadable document for serious buyers |
| **License plate input** | Convert French plates to VIN first, then query CarVertical |

### Pre-Integration Checklist
- [ ] Request API access at developer.carvertical.com/auth/request-access
- [ ] Negotiate B2B pricing for expected volume (estimate monthly report count)
- [ ] Obtain API documentation, authentication credentials, sandbox access
- [ ] Establish Data Processing Agreement (GDPR)
- [ ] Confirm French license plate to VIN conversion capability
- [ ] Clarify webhook vs. polling for async reports
- [ ] Confirm rate limits and SLA terms
- [ ] Determine report caching/storage rights (can you store report data?)
- [ ] Clarify white-label/co-branding options for report display

---

## 16. Risk Assessment & Gaps

### HIGH RISK Items

| Risk | Detail | Mitigation |
|------|--------|-----------|
| **Gated documentation** | No public API docs; you cannot evaluate technical fit without requesting access first | Request access immediately; parallel-evaluate AutoDNA API |
| **No public SLA** | No documented uptime guarantee, latency SLA, or support SLA | Negotiate explicit SLA terms in contract |
| **French data depth** | CarVertical's French-specific data may be less comprehensive than Histovec/French-native services | Consider complementing with Histovec data |
| **No SDK** | No official SDK means custom client development | Budget engineering time for custom API client |

### MEDIUM RISK Items

| Risk | Detail | Mitigation |
|------|--------|-----------|
| **Report accuracy** | Long-term comparisons show some accuracy concerns (delayed damage recording, potential omissions) | Clearly communicate data limitations to users |
| **Vendor lock-in** | Proprietary API with no standardized format | Design abstraction layer to swap providers |
| **55-second latency** | Report generation time may feel slow for UX | Pre-generate reports for popular listings; cache aggressively |
| **Pricing opacity** | B2B API pricing not public | Get written pricing commitment before development starts |

### LOW RISK Items

| Risk | Detail |
|------|--------|
| **GDPR compliance** | CarVertical is EU-based, ISO 27001 certified, has DPO |
| **Market presence** | 3,500+ B2B partners, operates in 35+ markets |
| **French language** | Full French support available |
| **Company stability** | Operating since 2017, growing customer base |

### Critical Information Gaps (Must Resolve Before Integration)

1. **Exact API endpoint documentation** (request/response schemas)
2. **Authentication mechanism** (API key, OAuth, JWT?)
3. **Webhook support** (yes/no, callback format)
4. **Rate limits** (per-second, per-minute, per-day)
5. **SLA terms** (uptime, latency, support response time)
6. **Data caching rights** (can you store report data? for how long?)
7. **License plate to VIN** (is this a separate endpoint or integrated?)
8. **Sandbox/test environment** (available for development?)
9. **Pricing for API access** (per-report cost at volume)
10. **Contract terms** (minimum commitment, exclusivity clauses?)

---

## 17. Sources

### Official CarVertical URLs
- [CarVertical Developer Portal](https://developer.carvertical.com/)
- [CarVertical Business API Page](https://www.carvertical.com/en/business/api)
- [CarVertical Business Offers](https://www.carvertical.com/en/business)
- [CarVertical Pricing](https://www.carvertical.com/en/pricing)
- [CarVertical Affiliate Program](https://www.carvertical.com/en/affiliate-program)
- [CarVertical Trust Badge](https://trust.carvertical.com/)
- [CarVertical Data Sources Blog](https://www.carvertical.com/en/blog/carvertical-data-sources)
- [CarVertical Report Content Help](https://www.carvertical.com/en/help/about-the-service/what-information-may-appear-in-the-carvertical-report)
- [CarVertical Report Formats Help](https://www.carvertical.com/en/help/about-the-service/what-format-are-your-reports-available-in)
- [CarVertical Batch Reports](https://www.carvertical.com/blog/generate-up-to-10-reports-at-once)
- [CarVertical Subscription Help](https://www.carvertical.com/en/help/for-business-clients/how-does-a-monthly-subscription-work)
- [CarVertical Report Bundles Help](https://www.carvertical.com/en/help/for-business-clients/what-are-carvertical-report-bundles)
- [CarVertical Vehicle Data Privacy Notice](https://www.carvertical.com/en/vehicle-data-privacy-notice)
- [CarVertical Privacy Policy](https://www.carvertical.com/privacy-policy)
- [CarVertical GitHub](https://github.com/carVertical)
- [CarVertical France](https://www.carvertical.com/fr?l=fr)

### Comparison and Review Sources
- [CarVertical vs AutoDNA: 7-Year Comparison Study](https://www.csabastefan.com/en/carvertical-experiences-comparison-autodna.php)
- [CarVertical vs Carfax Alternative](https://detailedvehiclehistory.com/blog/carvertical-vs-carfax-alternative)
- [AutoDNA vs CarVertical vs VinAudit](https://www.vinaudit.com/autodna-vs-carvertical-vs-vinaudit)
- [CarVertical vs Carfax - EpicVIN](https://epicvin.com/blog/carvertical-vs-carfax-which-report-should-you-trust)
- [CarVertical vs Histovec - Odopass](https://www.odopass.fr/blog/carvertical-versus-histovec-historique-vehicule-occasion)
- [CarVertical vs Histovec - CarVerif](https://carverif.fr/blogs/news/carvertical-vs-histovec-comparer-ces-outils)
- [10 Best Vehicle History Reports 2025](https://vehicledatabases.com/articles/best-vehicle-history-report)
- [CarVertical Review - DollarBreak](https://www.dollarbreak.com/carvertical-vin-review/)

### Alternative Provider Sources
- [AutoDNA Partners Area](https://www.autodna.com/company/partners-area)
- [AutoRef API Documentation](https://autoref.eu/en/api-overview)
- [Histovec Official](https://histovec.interieur.gouv.fr/)

### Technology and Business Sources
- [CarVertical PostHog Case Study](https://posthog.com/customers/carvertical)
- [CarVertical cV Token - Etherscan](https://etherscan.io/address/0x50bc2ecc0bfdf5666640048038c1aba7b7525683)
- [CarVertical Affiliate Terms](https://www.carvertical.com/affiliate-program-terms)
- [CarVertical 2024 In Review](https://www.carvertical.com/en/blog/carverticals-2024-in-review)
- [CarVertical Awin Affiliate](https://ui.awin.com/merchant-profile-terms/79086)
- [CarVertical Startup Showcase - EU Startup News](https://eustartup.news/startup-showcase-carvertical-blockchain-based-solution-for-car-history/)

---

*Report generated: 2026-02-08*
*This investigation is based on publicly available information. Actual API specifications, pricing, and capabilities should be confirmed directly with CarVertical's B2B sales team after requesting developer portal access.*
