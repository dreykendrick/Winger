import 'account_type.dart';
import 'organization.dart';
import 'role.dart';
import 'user_profile.dart';
import 'verification_status.dart';
import 'workspace.dart';

/// Aggregated Client-Side Identity Context loaded from Winger Backend V2.
class IdentityContext {
  final UserProfile profile;
  final List<AccountType> accountTypes;
  final Organization? activeOrganization;
  final Workspace? activeWorkspace;
  final List<Role> assignedRoles;
  final Set<String> effectivePermissions;
  final VerificationStatus verificationStatus;

  const IdentityContext({
    required this.profile,
    required this.accountTypes,
    this.activeOrganization,
    this.activeWorkspace,
    this.assignedRoles = const [],
    this.effectivePermissions = const {},
    this.verificationStatus = VerificationStatus.unverified,
  });

  /// Client-side UI presentation helper (Never treated as security boundary).
  bool can(String permissionKey) {
    if (effectivePermissions.contains('*') ||
        effectivePermissions.contains('admin:*')) {
      return true;
    }
    return effectivePermissions.contains(permissionKey);
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;
  bool get hasVendorCapabilities => accountTypes.contains(AccountType.vendor);
  bool get hasAffiliateCapabilities =>
      accountTypes.contains(AccountType.affiliate);

  factory IdentityContext.defaultCustomer(UserProfile profile) {
    return IdentityContext(
      profile: profile,
      accountTypes: const [AccountType.customer],
      verificationStatus: VerificationStatus.verified,
    );
  }
}
