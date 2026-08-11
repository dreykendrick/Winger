/// Domain entity for historical order line items preserving historical purchase prices.
class OrderItem {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String vendorName;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.vendorName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final unitPrice =
        (json['unit_price'] as num? ?? json['price'] as num? ?? 0.0).toDouble();
    final quantity = json['quantity'] as int? ?? 1;

    return OrderItem(
      id: json['id'] as String? ?? 'item_1',
      productId: json['product_id'] as String? ?? 'p_1',
      title: json['title'] as String? ?? 'Product Title',
      imageUrl: json['image_url'] as String? ?? '',
      unitPrice: unitPrice,
      quantity: quantity,
      lineTotal:
          (json['line_total'] as num? ?? (unitPrice * quantity)).toDouble(),
      vendorName: json['vendor_name'] as String? ?? 'Merchant',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'title': title,
        'image_url': imageUrl,
        'unit_price': unitPrice,
        'quantity': quantity,
        'line_total': lineTotal,
        'vendor_name': vendorName,
      };
}
