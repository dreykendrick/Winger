import 'route_names.dart';

class RouteGuards {
  RouteGuards._();

  static const List<String> publicRoutes = [
    RouteNames.roleSelection,
    RouteNames.login,
    RouteNames.register,
    RouteNames.infoCollection,
    RouteNames.forgotPassword,
    '/verify-phone',
    '/reset-password',
    '/splash',
  ];

  static bool isPublicRoute(String location) {
    if (publicRoutes.contains(location)) {
      return true;
    }
    if (location == '/' ||
        location == RouteNames.home ||
        location == RouteNames.marketplace ||
        location == RouteNames.checkout ||
        location.startsWith('/product/') ||
        location.startsWith('/categories/') ||
        location.startsWith('/affiliate/')) {
      return true;
    }
    return false;
  }

  static bool isPublicOrCheckoutRoute(String location) {
    return isPublicRoute(location);
  }

  static String? evaluateRedirect({
    required bool isAuthenticated,
    required String currentLocation,
    required bool hasVendorCapabilities,
    required bool hasAffiliateCapabilities,
    required bool isAdmin,
  }) {
    final isPublic = isPublicRoute(currentLocation);

    if (!isAuthenticated) {
      if (!isPublic) {
        return RouteNames.roleSelection;
      }
      return null;
    }

    if (isAuthenticated &&
        (currentLocation == RouteNames.login ||
            currentLocation == RouteNames.register ||
            currentLocation == RouteNames.roleSelection)) {
      return RouteNames.home;
    }

    if (currentLocation.startsWith('/vendor/') &&
        !hasVendorCapabilities &&
        !isAdmin) {
      return RouteNames.unauthorized;
    }

    if (currentLocation.startsWith('/affiliate/') &&
        !hasAffiliateCapabilities &&
        !isAdmin) {
      return RouteNames.unauthorized;
    }

    if (currentLocation.startsWith('/admin/') && !isAdmin) {
      return RouteNames.unauthorized;
    }

    return null;
  }
}
