import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../auth/domain/entities/verification_status.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final identityContext = ref.watch(identityContextProvider);

    final initialChar = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!.substring(0, 1).toUpperCase()
        : (user?.email.isNotEmpty == true
            ? user!.email.substring(0, 1).toUpperCase()
            : 'W');

    final primaryRole = identityContext.accountTypes.isNotEmpty
        ? identityContext.accountTypes.first.name.toUpperCase()
        : 'MEMBER';

    final isPhoneVerified =
        identityContext.verificationStatus == VerificationStatus.verified;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('User Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        children: [
          // Header Card
          WingerCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: WingerTokens.primaryOrange,
                  child: Text(
                    initialChar,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Winger User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'guest@winger.co',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: WingerTokens.primaryOrange
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              primaryRole,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: WingerTokens.primaryOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isPhoneVerified
                                      ? WingerTokens.primaryEmerald
                                      : WingerTokens.dangerCoral)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPhoneVerified
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 10,
                                  color: isPhoneVerified
                                      ? WingerTokens.primaryEmerald
                                      : WingerTokens.dangerCoral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPhoneVerified ? 'VERIFIED' : 'UNVERIFIED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPhoneVerified
                                        ? WingerTokens.primaryEmerald
                                        : WingerTokens.dangerCoral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account Details Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ACCOUNT & IDENTITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _ProfileItemTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            value: user?.fullName ?? 'Not set',
          ),
          _ProfileItemTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: user?.email ?? 'Not set',
          ),
          _ProfileItemTile(
            icon: Icons.verified_user_outlined,
            title: 'Identity Verification State',
            value: isPhoneVerified
                ? '● Phone Verification Approved'
                : '○ Phone Verification Pending',
          ),
          const SizedBox(height: 16),

          // Security Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SECURITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _ProfileItemTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            value: 'Send Password Reset Email',
            onTap: () {
              if (user?.email != null) {
                ref
                    .read(authControllerProvider.notifier)
                    .sendPasswordReset(user!.email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to your email.'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Sign Out Action
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
              side: const BorderSide(color: Colors.white10),
            ),
            tileColor: WingerTokens.darkSurface,
            leading: const Icon(Icons.logout, color: WingerTokens.dangerCoral),
            title: const Text(
              'Sign Out of Winger',
              style: TextStyle(
                color: WingerTokens.dangerCoral,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: WingerTokens.darkSurface,
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                      'Are you sure you want to sign out of your account?',
                      style: TextStyle(color: Colors.grey)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authControllerProvider.notifier).signOut();
                        context.go('/login');
                      },
                      child: const Text('Sign Out',
                          style: TextStyle(color: WingerTokens.dangerCoral)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ProfileItemTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: WingerTokens.darkSurface,
        borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: WingerTokens.primaryOrange),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey, size: 18)
            : null,
        onTap: onTap,
      ),
    );
  }
}
