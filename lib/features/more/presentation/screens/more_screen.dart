import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winger/features/auth/presentation/providers/auth_providers.dart';
import 'package:winger/shared/components/winger_card.dart';
import 'package:winger/shared/components/winger_logo.dart';
import 'package:winger/shared/design_system/tokens/design_tokens.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final initialChar = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!.substring(0, 1).toUpperCase()
        : (user?.email.isNotEmpty == true
            ? user!.email.substring(0, 1).toUpperCase()
            : 'W');

    return Scaffold(
      appBar: AppBar(
        title: const WingerLogo(size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(WingerTokens.space16),
        children: [
          // User Account Header Card
          WingerCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: WingerTokens.primaryOrange,
                  child: Text(
                    initialChar,
                    style: const TextStyle(
                      fontSize: 22,
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
                          fontSize: 16,
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
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              WingerTokens.primaryOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MEMBER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: WingerTokens.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () => context.push('/more/profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Section: Account & Identity
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
          _MoreMenuItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            subtitle: 'Manage personal details and account info',
            onTap: () => context.push('/more/profile'),
          ),
          _MoreMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications & Preferences',
            subtitle: 'Configure order and promo alerts',
            onTap: () => context.push('/notifications/preferences'),
          ),
          const SizedBox(height: 16),

          // Menu Section: Portals & Workspaces
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'PORTALS & WORKSPACES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _MoreMenuItem(
            icon: Icons.storefront_outlined,
            title: 'Vendor Store Workspace',
            subtitle: 'Manage inventory, sales and store profile',
            onTap: () => context.push('/vendor/dashboard'),
          ),
          _MoreMenuItem(
            icon: Icons.campaign_outlined,
            title: 'Affiliate Portal',
            subtitle: 'Track affiliate links, clicks and commissions',
            onTap: () => context.push('/affiliate/dashboard'),
          ),
          const SizedBox(height: 16),

          // Menu Section: Support & Legal
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SUPPORT & LEGAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _MoreMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Customer Support',
            subtitle: 'Order Guardian protection and support',
            onTap: () => _showDialog(context, 'Help & Support',
                'For customer support or Order Guardian disputes, visit the Orders tab or contact support@winger.co.'),
          ),
          _MoreMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacy & Terms of Service',
            subtitle: 'Platform security and escrow terms',
            onTap: () => _showDialog(context, 'Privacy & Terms',
                'Winger Platform 2.0 operates under authoritative Supabase Backend V2 security and Order Guardian double-entry escrow protocols.'),
          ),
          _MoreMenuItem(
            icon: Icons.info_outline,
            title: 'App Information',
            subtitle: 'Winger Commerce v1.0.0+1 (Build 2.0)',
            onTap: () => _showDialog(context, 'Winger Platform',
                'Winger Social Commerce Application\nVersion 1.0.0+1 (Release Candidate 2.0)\nPowered by Winger Backend V2.'),
          ),
          const SizedBox(height: 20),

          // Logout Action Button
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
              side: const BorderSide(color: Colors.white10),
            ),
            tileColor: WingerTokens.darkSurface,
            leading: const Icon(Icons.logout, color: WingerTokens.dangerCoral),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: WingerTokens.dangerCoral,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WingerTokens.darkSurface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: WingerTokens.primaryOrange)),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }
}
