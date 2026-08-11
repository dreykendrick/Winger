import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/order_guardian/presentation/screens/orders_list_screen.dart';
import '../../features/vendor_dashboard/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/growth_affiliate/presentation/screens/affiliate_hub_screen.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerOrders,
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorDashboard,
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.affiliateDashboard,
        builder: (context, state) => const AffiliateHubScreen(),
      ),
    ],
  );
}
