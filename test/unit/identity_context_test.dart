import 'package:flutter_test/flutter_test.dart';
import 'package:winger/features/auth/domain/entities/account_type.dart';
import 'package:winger/features/auth/domain/entities/identity_context.dart';
import 'package:winger/features/auth/domain/entities/organization.dart';
import 'package:winger/features/auth/domain/entities/user_profile.dart';
import 'package:winger/features/auth/domain/entities/verification_status.dart';
import 'package:winger/features/auth/domain/entities/workspace.dart';

void main() {
  group('IdentityContext & Account Type Tests', () {
    test('IdentityContext resolves client-side permissions correctly', () {
      const user = UserProfile(id: 'usr_1', email: 'vendor@winger.co');
      final context = IdentityContext(
        profile: user,
        accountTypes: const [AccountType.vendor, AccountType.customer],
        activeOrganization: const Organization(
            id: 'org_1', name: 'Winger Vendors', slug: 'winger-vendors'),
        activeWorkspace: const Workspace(
            id: 'ws_1',
            organizationId: 'org_1',
            name: 'Store 1',
            slug: 'store-1'),
        effectivePermissions: const {'catalog:product:create', 'orders:view'},
        verificationStatus: VerificationStatus.verified,
      );

      expect(context.can('catalog:product:create'), isTrue);
      expect(context.can('escrow:release'), isFalse);
      expect(context.hasVendorCapabilities, isTrue);
      expect(context.hasAffiliateCapabilities, isFalse);
      expect(context.isVerified, isTrue);
    });

    test('AccountType maps from string keys', () {
      expect(AccountType.fromKey('VENDOR'), AccountType.vendor);
      expect(AccountType.fromKey('AFFILIATE'), AccountType.affiliate);
      expect(AccountType.fromKey('UNKNOWN'), AccountType.customer);
    });
  });
}
