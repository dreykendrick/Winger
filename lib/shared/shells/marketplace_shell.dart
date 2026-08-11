import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system/tokens/design_tokens.dart';

class MarketplaceShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MarketplaceShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: WingerTokens.darkBackground,
        indicatorColor: WingerTokens.darkSurface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.home, color: WingerTokens.primaryOrange),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined, color: Colors.grey),
            selectedIcon:
                Icon(Icons.storefront, color: WingerTokens.primaryOrange),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: Colors.grey),
            selectedIcon:
                Icon(Icons.receipt_long, color: WingerTokens.primaryOrange),
            label: 'Orders',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: WingerTokens.primaryOrange),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined, color: Colors.grey),
            selectedIcon:
                Icon(Icons.more_horiz, color: WingerTokens.primaryOrange),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
