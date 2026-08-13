import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/account_type.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AccountType _selectedType = AccountType.vendor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Branding Logo Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color:
                          WingerTokens.primaryEmerald.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            WingerTokens.primaryEmerald.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: WingerTokens.primaryEmerald,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to Winger',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to build your business on Winger Marketplace.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  WingerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Select Account Role',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildRoleCard(
                          type: AccountType.vendor,
                          title: 'Vendor / Merchant',
                          subtitle:
                              'Sell products, manage store catalog, handle orders & payments.',
                          icon: Icons.storefront_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildRoleCard(
                          type: AccountType.affiliate,
                          title: 'Affiliate Promoter',
                          subtitle:
                              'Promote marketplace products, earn commission & track referral links.',
                          icon: Icons.campaign_outlined,
                        ),
                        const SizedBox(height: 28),
                        WingerButton(
                          label: 'Create Account',
                          onPressed: () {
                            context.push(
                              '/register?role=${_selectedType.name}',
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        WingerButton(
                          label: 'Sign In to Existing Account',
                          variant: WingerButtonVariant.secondary,
                          onPressed: () {
                            context.push(
                              '/login?role=${_selectedType.name}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Browse Marketplace as Guest →',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required AccountType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? WingerTokens.primaryEmerald.withValues(alpha: 0.12)
              : const Color(0xFF1B2033),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? WingerTokens.primaryEmerald
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? WingerTokens.primaryEmerald
                  : Colors.grey.shade400,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? WingerTokens.primaryEmerald
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? WingerTokens.primaryEmerald
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? WingerTokens.primaryEmerald
                      : Colors.grey.shade600,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
