# Winger Affiliate Experience Architecture Specification

**Document Title**: Sprint F Authenticated Affiliate Experience Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Backend V2 (Affiliate Engine)  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Separation of Concerns

The Winger Affiliate architecture clearly separates **Public Referral Attribution** from the **Authenticated Affiliate Experience**.

```
                           PUBLIC USER EXPERIENCE
Visitor Click ──► Public Referral Link ──► Cart Preservation ──► Checkout Conversion
                 (/affiliate/:code)        (attributable payload)  (Backend Attribution)

                        AUTHENTICATED AFFILIATE EXPERIENCE
Affiliate Login ──► Identity Context ──► Affiliate Dashboard ──► Catalog & Link Generator
                   (AccountType.affiliate) (/affiliate/dashboard) (/affiliate/links)
```

### Core Architecture Rules

1. **Backend Source of Truth**: Winger Backend V2 Affiliate Engine owns all affiliate eligibility rules, click/conversion tracking, commission calculations, payout statuses, and anti-fraud enforcement.
2. **Zero Client Financial Authority**: Flutter displays backend-computed earnings (Pending, Approved, Available, Paid) without locally calculating or modifying commission amounts.
3. **Actor Identity Guarding**: Only authenticated users with `AccountType.affiliate` identity context can access `/affiliate/*` routes. Unauthenticated visitors accessing affiliate routes are redirected to sign in.

---

## 2. Component Layout (`lib/features/affiliate/`)

- `AffiliateDashboardScreen`: Financial metrics, partner status card, active promotional links, and recent conversions.
- `AffiliateProductsScreen`: Affiliate catalog listing commission rates and "Promote" CTA.
- `AffiliateLinksScreen`: Generated referral links list with copy & share actions.
- `AffiliateConversionsScreen`: Customer order conversions and commission status breakdown.
- `AffiliateEarningsScreen`: Available payout balance vs Pending/Approved/Paid breakdown.
- `AffiliateSettingsScreen`: Partner referral code and account settings.
