abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';

  // Customer Marketplace
  static const home = '/home';
  static const search = '/search';
  static const productDetail = '/product/:id';
  static const storeProfile = '/store/:slug';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const checkoutPay = '/checkout/pay';
  static const orderSuccess = '/order/success/:id';
  static const customerOrders = '/customer/orders';
  static const customerOrderDetail = '/customer/order/:id';
  static const deliveryVerify = '/customer/order/:id/verify';
  static const raiseDispute = '/customer/order/:id/dispute';
  static const disputeDetail = '/customer/dispute/:id';

  // Vendor Dashboard
  static const vendorDashboard = '/vendor/dashboard';
  static const vendorProducts = '/vendor/products';
  static const editProduct = '/vendor/product/edit';
  static const vendorOrders = '/vendor/orders';
  static const vendorOrderDetail = '/vendor/order/:id';
  static const vendorWallet = '/vendor/wallet';
  static const vendorPayout = '/vendor/payout';

  // Affiliate Growth
  static const affiliateDashboard = '/affiliate/dashboard';
  static const affiliateLinks = '/affiliate/links';
  static const campaigns = '/affiliate/campaigns';
  static const conversions = '/affiliate/conversions';

  // Admin Operations
  static const adminDashboard = '/admin/dashboard';
  static const adminDisputes = '/admin/disputes';
  static const adminLedger = '/admin/ledger';
}
