import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/app_navigator.dart';
import '../../../../shared/components/winger_loading.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../../checkout/presentation/providers/checkout_providers.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/empty_cart_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);
    final checkoutAsync = ref.watch(checkoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Cart',
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clearCart();
            },
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.isEmpty) {
            return EmptyCartView(
              onBrowseMarketplace: () => AppNavigator.toMarketplace(context),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CartItemCard(
                      item: item,
                      onQuantityChanged: (newQty) {
                        ref
                            .read(cartControllerProvider.notifier)
                            .updateQuantity(item.id, newQty);
                      },
                      onRemove: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .removeItem(item.id);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CartSummaryCard(
                  cart: cart,
                  isLoading: checkoutAsync.isLoading,
                  onProceedToCheckout: () async {
                    final validation = await ref
                        .read(cartControllerProvider.notifier)
                        .validateCart();
                    if (validation != null &&
                        !validation.isValid &&
                        context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Some items in your cart are no longer available.')),
                      );
                      return;
                    }

                    if (context.mounted) {
                      AppNavigator.toCheckout(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const WingerLoading(message: 'Loading cart...'),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
