import 'package:flutter/material.dart';
import '../../core/logging/app_logger.dart';

/// Navigation Observer for logging screen transitions and tracking deep link analytics.
class NavigationAnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      AppLogger.info('Route Pushed: ${route.settings.name}',
          feature: 'NAVIGATION');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      AppLogger.info('Route Popped to: ${previousRoute?.settings.name}',
          feature: 'NAVIGATION');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      AppLogger.info('Route Replaced with: ${newRoute?.settings.name}',
          feature: 'NAVIGATION');
    }
  }
}
