import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/affiliate/presentation/screens/affiliate_dashboard_screen.dart';
import '../../features/auth/domain/entities/account_type.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_placeholder_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_phone_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/marketplace/presentation/screens/product_detail_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/category_products_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/vendor_dashboard/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/wallet/presentation/screens/wallet_dashboard_screen.dart';
import '../../shared/screens/forbidden_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/unauthorized_screen.dart';
import '../../shared/shells/admin_shell.dart';
import '../../shared/shells/affiliate_shell.dart';
import '../../shared/shells/marketplace_shell.dart';
import '../../shared/shells/vendor_shell.dart';
import 'navigation_analytics_observer.dart';
import 'route_guards.dart';
import 'route_names.dart';
import 'route_parameters.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authObserver = ref.watch(authObserverProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: authObserver,
    observers: [NavigationAnalyticsObserver()],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final identityContext = ref.read(identityContextProvider);

      final isAuthenticated = authState is Authenticated;
      final isAuthenticating = authState is Authenticating;
      final currentLocation = state.uri.path;

      // During cold start on splash, stay on splash while authenticating
      if (currentLocation == '/splash') {
        if (isAuthenticating) return null;
        return isAuthenticated ? RouteNames.home : RouteNames.login;
      }

      final hasVendorCapabilities =
          identityContext.accountTypes.contains(AccountType.vendor);
      final hasAffiliateCapabilities =
          identityContext.accountTypes.contains(AccountType.affiliate);
      final isAdmin = identityContext.accountTypes.contains(AccountType.admin);

      return RouteGuards.evaluateRedirect(
        isAuthenticated: isAuthenticated,
        currentLocation: currentLocation,
        hasVendorCapabilities: hasVendorCapabilities,
        hasAffiliateCapabilities: hasAffiliateCapabilities,
        isAdmin: isAdmin,
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-phone',
        name: 'verify-phone',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return VerifyPhoneScreen(initialPhone: phone);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),

      // Primary Marketplace Shell (Tab Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MarketplaceShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.marketplace,
                name: RouteNames.marketplace,
                builder: (context, state) {
                  final catId =
                      state.uri.queryParameters['category_id'] ?? 'all';
                  return CategoryProductsScreen(categoryId: catId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.orders,
                name: RouteNames.orders,
                builder: (context, state) => const OrdersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.wallet,
                name: RouteNames.wallet,
                builder: (context, state) => const WalletDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.more,
                name: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/more/profile',
        name: 'more-profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: RouteNames.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final productId =
              state.pathParameters[RouteParameters.productId] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters[RouteParameters.orderId] ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),

      // Vendor Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            VendorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.vendor,
                name: RouteNames.vendor,
                builder: (context, state) => const VendorDashboardScreen(),
              ),
            ],
          ),
        ],
      ),

      // Affiliate Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AffiliateShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.affiliate,
                name: RouteNames.affiliate,
                builder: (context, state) => const AffiliateDashboardScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                name: 'admin',
                builder: (context, state) => const AuthPlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: RouteNames.unauthorized,
        name: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: RouteNames.forbidden,
        name: RouteNames.forbidden,
        builder: (context, state) => const ForbiddenScreen(),
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(path: state.uri.path),
  );
});
