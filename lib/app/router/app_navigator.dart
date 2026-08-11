import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Centralized Type-Safe Navigation Helper abstraction.
class AppNavigator {
  static void toHome(BuildContext context) => context.go(RouteNames.home);
  static void toMarketplace(BuildContext context) =>
      context.go(RouteNames.marketplace);
  static void toProduct(BuildContext context, String productId) =>
      context.push('/product/$productId');
  static void toCategory(BuildContext context, String categoryId) =>
      context.push('/categories/$categoryId');
  static void toSearch(BuildContext context, {String? query}) =>
      context.push('/search${query != null ? '?q=$query' : ''}');
  static void toAffiliateLink(BuildContext context, String affiliateCode) =>
      context.go('/affiliate/$affiliateCode');

  // Guest Checkout (Independent of Main App Auth)
  static void toCheckout(BuildContext context, {String? sessionId}) => context
      .push('/checkout${sessionId != null ? '?session=$sessionId' : ''}');

  // Authentication
  static void toLogin(BuildContext context) => context.push(RouteNames.login);
  static void toRegister(BuildContext context) => context.push('/register');
  static void toForgotPassword(BuildContext context) =>
      context.push('/forgot-password');

  // Protected Actor Destinations
  static void toVendorDashboard(BuildContext context) =>
      context.go('/vendor/dashboard');
  static void toAffiliateDashboard(BuildContext context) =>
      context.go('/affiliate/dashboard');
  static void toAdminDashboard(BuildContext context) =>
      context.go('/admin/dashboard');

  // Error & Status Destinations
  static void toForbidden(BuildContext context) => context.go('/403');
  static void toNotFound(BuildContext context) => context.go('/404');
}
