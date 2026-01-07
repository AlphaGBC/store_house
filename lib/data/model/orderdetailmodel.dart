class OrderDetailModel {
  int? ordersdetailsId;
  int? ordersId;
  int? itemsId;
  String? itemsName;
  String? itemsImage;
  int? itemsQuantity;
  double? itemsUnitPrice;
  double? itemsDiscountPercentage;
  double? itemsPriceBeforeDiscount;
  double? itemsPriceAfterDiscount;
  double? itemsTotalPrice;
  int? isWholesale;
  int? wholesaleCustomersId;
  String? wholesaleCustomersName;
  String? createdAt;

  OrderDetailModel({
    this.ordersdetailsId,
    this.ordersId,
    this.itemsId,
    this.itemsName,
    this.itemsImage,
    this.itemsQuantity,
    this.itemsUnitPrice,
    this.itemsDiscountPercentage,
    this.itemsPriceBeforeDiscount,
    this.itemsPriceAfterDiscount,
    this.itemsTotalPrice,
    this.isWholesale,
    this.wholesaleCustomersId,
    this.wholesaleCustomersName,
    this.createdAt,
  });

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    ordersdetailsId = json['ordersdetails_id'];
    ordersId = json['orders_id'];
    itemsId = json['items_id'];
    itemsName = json['items_name'];
    itemsImage = json['items_image'];
    itemsQuantity = json['items_quantity'] ?? 1;
    itemsUnitPrice = (json['items_unit_price'] ?? 0).toDouble();
    itemsDiscountPercentage =
        (json['items_discount_percentage'] ?? 0).toDouble();
    itemsPriceBeforeDiscount =
        (json['items_price_before_discount'] ?? 0).toDouble();
    itemsPriceAfterDiscount =
        (json['items_price_after_discount'] ?? 0).toDouble();
    itemsTotalPrice = (json['items_total_price'] ?? 0).toDouble();
    isWholesale = json['is_wholesale'] ?? 0;
    wholesaleCustomersId = json['wholesale_customers_id'];
    wholesaleCustomersName = json['wholesale_customers_name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ordersdetails_id': ordersdetailsId,
      'orders_id': ordersId,
      'items_id': itemsId,
      'items_name': itemsName,
      'items_image': itemsImage,
      'items_quantity': itemsQuantity,
      'items_unit_price': itemsUnitPrice,
      'items_discount_percentage': itemsDiscountPercentage,
      'items_price_before_discount': itemsPriceBeforeDiscount,
      'items_price_after_discount': itemsPriceAfterDiscount,
      'items_total_price': itemsTotalPrice,
      'is_wholesale': isWholesale,
      'wholesale_customers_id': wholesaleCustomersId,
      'wholesale_customers_name': wholesaleCustomersName,
      'created_at': createdAt,
    };
  }
}
