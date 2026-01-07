/// OrderCardModel represents a complete order with all its details
/// ready for display on an order card
class OrderCardModel {
  final int ordersId;
  final int? wholesaleCustomersId;
  final String? wholesaleCustomersName;
  final int totalItemsCount;
  final double subtotal;
  final double discountAmount;
  final double total;
  final bool isWholesale;
  final String status; // 'local' or 'uploaded'
  final int posSource; // 1 or 2
  final String createdAt;
  final List<OrderItemCardModel> items;

  OrderCardModel({
    required this.ordersId,
    this.wholesaleCustomersId,
    this.wholesaleCustomersName,
    required this.totalItemsCount,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    required this.isWholesale,
    required this.status,
    required this.posSource,
    required this.createdAt,
    required this.items,
  });

  /// Calculate discount percentage (rounded to 2 decimals)
  double get discountPercentage {
    if (subtotal == 0) return 0.0;
    return (discountAmount / subtotal) * 100;
  }

  /// Check if order has discount
  bool get hasDiscount => discountAmount > 0;

  /// Format discount percentage for display (e.g., "5%")
  String get formattedDiscountPercentage {
    return "${discountPercentage.toStringAsFixed(2)}%";
  }

  /// Format prices for display
  String get formattedSubtotal => subtotal.toStringAsFixed(2);
  String get formattedDiscount => discountAmount.toStringAsFixed(2);
  String get formattedTotal => total.toStringAsFixed(2);

  /// Check if order is ready to be uploaded (local status)
  bool get canBeUploaded => status == 'local';

  /// Check if order has been uploaded to server
  bool get isUploaded => status == 'uploaded';

  /// Get customer display name
  String get customerName => wholesaleCustomersName ?? 'عميل أفراد';

  /// Get POS source label
  String get posSourceLabel => 'نقطة البيع $posSource';
}

/// OrderItemCardModel represents a single item within an order
class OrderItemCardModel {
  final int ordersdetailsId;
  final int itemsId;
  final String itemsName;
  final String? itemsImage;
  final int itemsQuantity;
  final double itemsUnitPrice;
  final double itemsDiscountPercentage;
  final double itemsPriceBeforeDiscount;
  final double itemsPriceAfterDiscount;
  final double itemsTotalPrice;
  final bool isWholesale;

  OrderItemCardModel({
    required this.ordersdetailsId,
    required this.itemsId,
    required this.itemsName,
    this.itemsImage,
    required this.itemsQuantity,
    required this.itemsUnitPrice,
    required this.itemsDiscountPercentage,
    required this.itemsPriceBeforeDiscount,
    required this.itemsPriceAfterDiscount,
    required this.itemsTotalPrice,
    required this.isWholesale,
  });

  /// Check if item has discount
  bool get hasDiscount => itemsDiscountPercentage > 0;

  /// Format discount percentage for display
  String get formattedDiscountPercentage =>
      "${itemsDiscountPercentage.toStringAsFixed(2)}%";

  /// Format prices for display
  String get formattedUnitPrice => itemsUnitPrice.toStringAsFixed(2);
  String get formattedPriceBeforeDiscount =>
      itemsPriceBeforeDiscount.toStringAsFixed(2);
  String get formattedPriceAfterDiscount =>
      itemsPriceAfterDiscount.toStringAsFixed(2);
  String get formattedTotalPrice => itemsTotalPrice.toStringAsFixed(2);

  /// Get customer type label
  String get customerTypeLabel => isWholesale ? 'جملة' : 'تجزئة';

  /// Calculate and format the discount amount for this item
  double get itemDiscountAmount =>
      (itemsPriceBeforeDiscount - itemsPriceAfterDiscount) * itemsQuantity;
  String get formattedItemDiscountAmount =>
      itemDiscountAmount.toStringAsFixed(2);
}
