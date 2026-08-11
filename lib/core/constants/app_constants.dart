/// Application constants.
abstract class AppConstants {
  static const String appTitle = 'Winger Social Commerce';
  static const String defaultCurrency = 'TZS';
  static const String defaultLocale = 'en';

  // HTTP Header Keys
  static const String headerWorkspaceId = 'X-Workspace-ID';
  static const String headerCorrelationId = 'X-Correlation-ID';
  static const String headerAuthorization = 'Authorization';

  // Local Storage Keys
  static const String storageAuthToken = 'winger_auth_jwt';
  static const String storageRefreshToken = 'winger_refresh_token';
  static const String storageWorkspaceId = 'winger_active_workspace_id';
  static const String storageUserId = 'winger_user_id';
  static const String storageUserRole = 'winger_user_role';

  // Pagination Defaults
  static const int defaultPageSize = 20;
}
