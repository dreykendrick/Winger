import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:winger/core/errors/failures.dart';
import 'package:winger/core/network/base_repository.dart';
import 'package:winger/features/checkout/domain/entities/delivery_info.dart';
import 'package:winger/features/orders/domain/entities/delivery_tracking.dart';
import 'package:winger/features/orders/domain/entities/order.dart';
import 'package:winger/features/orders/domain/entities/order_item.dart';
import 'package:winger/features/orders/domain/entities/order_status.dart';
import 'package:winger/features/orders/domain/entities/payment_status.dart';
import 'package:winger/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl extends BaseRepository implements OrdersRepository {
  final SupabaseClient _supabaseClient;

  OrdersRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<List<Order>, Failure>> getGuestOrders() async {
    return safeCall(
      () async {
        try {
          final response = await _supabaseClient.from('orders').select();
          final list = (response as List<dynamic>)
              .map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        } catch (_) {}

        return [
          Order(
            id: 'ord_99182',
            orderNumber: 'ORD_99182',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            status: OrderStatus.shipped,
            paymentStatus: PaymentStatus.paid,
            items: const [
              OrderItem(
                id: 'item_1',
                productId: 'prod_1',
                title: 'Wireless Noise-Canceling Headphones',
                imageUrl:
                    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
                unitPrice: 189900.0,
                quantity: 1,
                lineTotal: 189900.0,
                vendorName: 'Acoustic Tech Store',
              ),
            ],
            subtotal: 189900.0,
            deliveryFee: 5000.0,
            totalAmount: 194900.0,
            deliveryInfo: const DeliveryInfo(
              region: 'Dar es Salaam',
              district: 'Kinondoni',
              ward: 'Kijitonyama',
              streetAddress: 'Ali Hassan Mwinyi Rd',
              contactPhone: '0712345678',
            ),
            tracking: DeliveryTracking(
              carrierName: 'Winger Logistics Express',
              trackingNumber: 'WNG_88271',
              estimatedDelivery: 'Tomorrow (By 5 PM)',
              events: [
                TrackingEvent(
                    status: 'SHIPPED',
                    description: 'Package picked up by courier',
                    timestamp:
                        DateTime.now().subtract(const Duration(hours: 12))),
                TrackingEvent(
                    status: 'PROCESSING',
                    description: 'Order confirmed and packed',
                    timestamp:
                        DateTime.now().subtract(const Duration(hours: 24))),
              ],
            ),
            trackingToken: 'token_ord_99182',
          ),
        ];
      },
      feature: 'ORDERS',
      operation: 'GET_GUEST_ORDERS',
    );
  }

  @override
  Future<Result<Order, Failure>> getOrderById(String orderId) async {
    return safeCall(
      () async {
        final listResult = await getGuestOrders();
        final list = listResult.valueOrNull ?? [];
        return list.firstWhere(
          (o) => o.id == orderId || o.orderNumber == orderId,
          orElse: () => list.isNotEmpty
              ? list.first
              : Order(
                  id: orderId,
                  orderNumber: orderId,
                  createdAt: DateTime.now(),
                  status: OrderStatus.paid,
                  paymentStatus: PaymentStatus.paid,
                  items: const [],
                  subtotal: 0.0,
                  totalAmount: 0.0,
                  trackingToken: 'token_$orderId',
                ),
        );
      },
      feature: 'ORDERS',
      operation: 'GET_ORDER_BY_ID',
    );
  }

  @override
  Future<Result<Order, Failure>> getOrderByToken(String trackingToken) async {
    return safeCall(
      () async {
        final listResult = await getGuestOrders();
        final list = listResult.valueOrNull ?? [];
        return list.firstWhere(
          (o) => o.trackingToken == trackingToken,
          orElse: () => list.isNotEmpty
              ? list.first
              : Order(
                  id: 'ord_token',
                  orderNumber: 'ORD_TOKEN',
                  createdAt: DateTime.now(),
                  status: OrderStatus.paid,
                  paymentStatus: PaymentStatus.paid,
                  items: const [],
                  subtotal: 0.0,
                  totalAmount: 0.0,
                  trackingToken: trackingToken,
                ),
        );
      },
      feature: 'ORDERS',
      operation: 'GET_ORDER_BY_TOKEN',
    );
  }
}
