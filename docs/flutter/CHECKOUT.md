# Winger Checkout Experience Architecture Specification

**Document Title**: Sprint G Customer-Facing Guest Checkout Architecture Specification  
**Version**: 1.0.0  
**Target Backend**: Winger Checkout System & Backend V2  
**Author**: Principal Flutter Architect  

---

## 1. Overview & Separation of Concerns

The Winger Checkout architecture operates strictly as a **Customer-Facing Client Interface** communicating with the authoritative **Winger Checkout System**.

```
                  GUEST CUSTOMER CHECKOUT ARCHITECTURE
Marketplace ──► Guest Cart ──► Create Checkout Session ──► Contact Info ──► Delivery Info ──► Payment Method ──► Verified Order Confirmation
                              (Session Lifecycle)          (Name/Email)    (Fee/Speed)    (Selcom Gateways)  (Order Guardian Escrow)
```

### Core Architectural Boundaries

1. **Backend Source of Truth**: The Checkout System is authoritative for session lifecycle, cart validation, price validation, inventory reservation, delivery fee calculation, payment orchestration, Selcom/Meetpay gateway integration, HMAC verification, payment status, and order creation.
2. **Zero Payment Credentials in Client**: Flutter contains **ZERO secret keys, HMAC keys, or gateway credentials**. Payment processing is delegated to Selcom / Gateway Adapters behind Backend V2.
3. **100% Guest Customer Flow**: Customers are guest users and can browse products, manage cart, enter contact & delivery details, choose payment options, and complete purchases without creating a Winger account or signing in.
4. **Order Guardian Escrow Boundary**: Order Guardian protection begins after backend payment confirmation. Funds are safely held in escrow until delivery verification.

---

## 2. Component Layout (`lib/features/checkout/`)

- `CheckoutHandoffScreen`: Cart validation & checkout session initialization screen.
- `CheckoutCustomerInfoScreen`: Guest contact form (Name, Email, Phone).
- `CheckoutDeliveryScreen`: Delivery address & backend-authoritative shipping speed selector.
- `CheckoutPaymentScreen`: Payment method selection (Selcom Mobile Money / Card) & Order Summary.
- `CheckoutProcessingScreen`: Asynchronous payment authorization & polling screen.
- `CheckoutConfirmationScreen`: Verified order confirmation & Order Guardian escrow notification.
- `CheckoutStatusScreens`: Success, Pending, and Failed post-checkout status screens.
