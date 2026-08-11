import 'package:go_router/go_router.dart';
import 'navigation_analytics_observer.dart';
import 'route_names.dart';
import '../../features/affiliate/presentation/screens/affiliate_dashboard_screen.dart';
import '../../features/affiliate/presentation/screens/affiliate_earnings_screen.dart';
import '../../features/affiliate/presentation/screens/affiliate_links_screen.dart';
import '../../features/affiliate/presentation/screens/affiliate_settings_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_confirmation_screen.dart';
import '../../features/checkout/presentation/screens/checkout_customer_info_screen.dart';
import '../../features/checkout/presentation/screens/checkout_delivery_screen.dart';
import '../../features/checkout/presentation/screens/checkout_handoff_screen.dart';
import '../../features/checkout/presentation/screens/checkout_payment_screen.dart';
import '../../features/checkout/presentation/screens/checkout_processing_screen.dart';
import '../../features/checkout/presentation/screens/checkout_status_screens.dart';
import '../../features/marketplace/presentation/screens/marketplace_home_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_products_screen.dart';
import '../../features/marketplace/presentation/screens/product_detail_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../../features/order_guardian/presentation/screens/dispute_form_screen.dart';
import '../../features/order_guardian/presentation/screens/order_guardian_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/profile/presentation/screens/profile_placeholder_screen.dart';
import '../../features/search/presentation/screens/category_products_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_placeholder_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/screens/vendor_orders_screen.dart';
import '../../features/vendor/presentation/screens/vendor_placeholder_screen.dart';
import '../../features/vendor/presentation/screens/vendor_product_create_edit_screen.dart';
import '../../features/vendor/presentation/screens/vendor_products_screen.dart';
import '../../features/vendor/presentation/screens/vendor_settings_screen.dart';
import '../../features/vendor/presentation/screens/vendor_store_screen.dart';
import '../../features/vendor/presentation/screens/vendor_verification_screen.dart';
import '../../features/wallet/presentation/screens/wallet_dashboard_screen.dart';
import '../../shared/screens/forbidden_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import '../../shared/screens/unauthorized_screen.dart';
import '../../shared/shells/admin_shell.dart';
import '../../shared/shells/affiliate_shell.dart';
import '../../shared/shells/marketplace_shell.dart';
import '../../shared/shells/vendor_shell.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    observers: [NavigationAnalyticsObserver()],
    errorBuilder: (context, state) => NotFoundScreen(path: state.uri.path),
    routes: [
      GoRoute(
        path: RouteNames.root,
        redirect: (context, state) => RouteNames.home,
      ),

      // Public Auth Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) {
          final email = state.extra as String?;
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        builder: (context, state) {
          final email = state.extra as String?;
          return VerifyEmailScreen(email: email);
        },
      ),

      // Standalone Search & Cart Top-Level Routes
      GoRoute(
        path: RouteNames.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final initialQuery = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: initialQuery);
        },
      ),

      // Guest Checkout & Post-Checkout Lifecycle Routes
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const CheckoutHandoffScreen(),
      ),
      GoRoute(
        path: '/checkout/:sessionId/customer',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'chk_1';
          return CheckoutCustomerInfoScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/:sessionId/delivery',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'chk_1';
          return CheckoutDeliveryScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/:sessionId/payment',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'chk_1';
          return CheckoutPaymentScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/:sessionId/processing',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'chk_1';
          return CheckoutProcessingScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/:sessionId/confirmation',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? 'chk_1';
          return CheckoutConfirmationScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return CheckoutSuccessScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/pending',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return CheckoutPendingScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/checkout/failed',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return CheckoutFailedScreen(sessionId: sessionId);
        },
      ),

      // Guest Orders & Order Guardian Sub-Routes
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? 'ord_1';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? 'ord_1';
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/:id/guardian',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? 'ord_1';
          return OrderGuardianScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/:id/dispute',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? 'ord_1';
          return DisputeFormScreen(orderId: orderId);
        },
      ),

      // Notifications Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: '/notifications/preferences',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),

      // Category Route
      GoRoute(
        path: '/category/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return CategoryProductsScreen(categoryId: categoryId);
        },
      ),

      // Vendor Direct Routes
      GoRoute(
        path: '/vendor/products/create',
        builder: (context, state) => const VendorProductCreateEditScreen(),
      ),
      GoRoute(
        path: '/vendor/products/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          return VendorProductCreateEditScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/vendor/store',
        builder: (context, state) => const VendorStoreScreen(),
      ),
      GoRoute(
        path: '/vendor/verification',
        builder: (context, state) => const VendorVerificationScreen(),
      ),

      // Authoritative Public Marketplace 5-Destination Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MarketplaceShell(navigationShell: navigationShell),
        branches: [
          // 1. HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const MarketplaceHomeScreen(),
              ),
            ],
          ),
          // 2. PRODUCTS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.marketplace,
                builder: (context, state) => const MarketplaceProductsScreen(),
              ),
            ],
          ),
          // 3. ORDERS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.orders,
                builder: (context, state) => const OrdersListScreen(),
              ),
            ],
          ),
          // 4. WALLET
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.wallet,
                builder: (context, state) => const WalletDashboardScreen(),
              ),
            ],
          ),
          // 5. MORE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) =>
                        const ProfilePlaceholderScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Public Product Detail & Deep Links
      GoRoute(
        path: RouteNames.productDetail,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? 'prod_1';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/affiliate/:affiliateCode',
        builder: (context, state) {
          return const MarketplaceHomeScreen();
        },
      ),

      // Vendor Actor Stateful Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            VendorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/dashboard',
                builder: (context, state) => const VendorDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/products',
                builder: (context, state) => const VendorProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/orders',
                builder: (context, state) => const VendorOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/settings',
                builder: (context, state) => const VendorSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Affiliate Actor Stateful Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AffiliateShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/affiliate/dashboard',
                builder: (context, state) => const AffiliateDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/affiliate/links',
                builder: (context, state) => const AffiliateLinksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/affiliate/earnings',
                builder: (context, state) => const AffiliateEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/affiliate/settings',
                builder: (context, state) => const AffiliateSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Actor Stateful Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const VendorPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/vendors',
                builder: (context, state) => const VendorPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/affiliates',
                builder: (context, state) => const AffiliateDashboardScreen(),
              ),
            ],
          ),
        ],
      ),

      // Protected Settings & Auxiliary Routes
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPlaceholderScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfilePlaceholderScreen(),
      ),
      GoRoute(
        path: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: RouteNames.forbidden,
        builder: (context, state) => const ForbiddenScreen(),
      ),
    ],
  );
}
