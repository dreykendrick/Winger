# Winger Backend V2 – Shipping Details Specification

The shipping subsystem captures recipient details, delivery addresses, and tracking numbers.

---

## 1. Shipping Details Schema
- **Entity**: `orders.shipping_details`
- **Fields**: `recipient_name`, `phone_number`, `address_line1`, `address_line2`, `city`, `region`, `country`, `postal_code`, `delivery_instructions`, `shipping_method`, `estimated_delivery_at`, `tracking_number`, `courier_name`.

---

## 2. Tracking Integration
Tracking references (`tracking_number`, `courier_name`) are populated when couriers collect parcels, enabling realtime shipment tracking in the Flutter mobile application.
