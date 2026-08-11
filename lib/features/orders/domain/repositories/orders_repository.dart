import 'package:winger/core/errors/failures.dart';
import '../entities/order.dart';

abstract class OrdersRepository {
  Future<Result<List<Order>, Failure>> getGuestOrders();
  Future<Result<Order, Failure>> getOrderById(String orderId);
  Future<Result<Order, Failure>> getOrderByToken(String trackingToken);
}
