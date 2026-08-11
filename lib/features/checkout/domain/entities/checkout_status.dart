/// Explicit state lifecycle enum for Winger Checkout Session.
enum CheckoutStatus {
  initializing('INITIALIZING', 'Initializing Checkout'),
  cartReady('CART_READY', 'Cart Ready'),
  validating('VALIDATING', 'Validating Cart'),
  creatingCheckout('CREATING_CHECKOUT', 'Creating Checkout Session'),
  awaitingCustomerInformation(
      'AWAITING_CUSTOMER_INFO', 'Customer Contact Info Required'),
  awaitingDeliveryInformation(
      'AWAITING_DELIVERY_INFO', 'Delivery Address Required'),
  awaitingPayment('AWAITING_PAYMENT', 'Ready for Payment Selection'),
  paymentProcessing('PAYMENT_PROCESSING', 'Processing Payment Transaction'),
  pending('PENDING', 'Payment Pending Verification'),
  completed('COMPLETED', 'Payment Successful'),
  failed('FAILED', 'Payment Failed'),
  cancelled('CANCELLED', 'Checkout Cancelled'),
  expired('EXPIRED', 'Session Expired');

  final String code;
  final String label;

  const CheckoutStatus(this.code, this.label);

  factory CheckoutStatus.fromCode(String? code) {
    return CheckoutStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => CheckoutStatus.cartReady,
    );
  }
}
