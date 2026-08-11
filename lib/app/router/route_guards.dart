import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/account_type.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'route_names.dart';

/// Centralized Navigation Route Guards for Auth & Actor verification.
class RouteGuards {
  static String? evaluateRedirect(
      BuildContext context, GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState is Authenticated;
    final path = state.uri.path;

    // 1. Always Allow Guest Checkout & Public Routes
    if (isPublicOrCheckoutRoute(path)) {
      return null;
    }

    // 2. Public Auth Form Routes (Login, Register, Forgot Password)
    final isAuthFormRoute = path == RouteNames.login ||
        path == RouteNames.register ||
        path == RouteNames.forgotPassword ||
        path == RouteNames.resetPassword ||
        path == RouteNames.verifyEmail;

    if (!isAuthenticated && !isAuthFormRoute) {
      return '/401';
    }

    if (isAuthenticated && isAuthFormRoute) {
      return RouteNames.home;
    }

    // 3. Protected Actor Routes Check
    if (authState is Authenticated) {
      final identity = authState.identityContext;

      if (path.startsWith('/vendor') && !identity.hasVendorCapabilities) {
        return '/403';
      }
      if (path.startsWith('/affiliate') && !identity.hasAffiliateCapabilities) {
        return '/403';
      }
      if (path.startsWith('/admin') &&
          !identity.accountTypes.contains(AccountType.admin)) {
        return '/403';
      }
    }

    return null;
  }

  static bool isPublicOrCheckoutRoute(String path) {
    if (path == RouteNames.root ||
        path == RouteNames.home ||
        path == RouteNames.marketplace ||
        path == RouteNames.checkout ||
        path == RouteNames.unknown ||
        path == '/401' ||
        path == '/403' ||
        path.startsWith('/product/') ||
        path.startsWith('/categories') ||
        path.startsWith('/search') ||
        path.startsWith('/affiliate/') ||
        path.startsWith('/about') ||
        path.startsWith('/help') ||
        path.startsWith('/legal')) {
      return true;
    }
    return false;
  }
}
