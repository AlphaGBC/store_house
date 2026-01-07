class ItemsModel {
  int? itemsId;
  String? itemsName;
  int? itemsStorehouseCount;
  int? itemsPointofsale1Count;
  int? itemsPointofsale2Count;
  dynamic itemsCostPrice;
  dynamic itemsWholesalePrice;
  dynamic itemsRetailPrice;
  dynamic itemsWholesaleDiscount;
  dynamic itemsRetailDiscount;
  String? itemsQr;
  int? itemsCategories;
  String? itemsDate;
  int? categoriesId;
  String? categoriesName;
  String? categoriesImage;
  String? categoriesDate;
  dynamic itemswholesalepricediscount;
  dynamic itemsretailpricediscount;

  ItemsModel({
    this.itemsId,
    this.itemsName,
    this.itemsStorehouseCount,
    this.itemsPointofsale1Count,
    this.itemsPointofsale2Count,
    this.itemsCostPrice,
    this.itemsWholesalePrice,
    this.itemsRetailPrice,
    this.itemsWholesaleDiscount,
    this.itemsRetailDiscount,
    this.itemsQr,
    this.itemsCategories,
    this.itemsDate,
    this.categoriesId,
    this.categoriesName,
    this.categoriesImage,
    this.categoriesDate,
    this.itemswholesalepricediscount,
    this.itemsretailpricediscount,
  });

  ItemsModel.fromJson(Map<String, dynamic> json) {
    itemsId = json['items_id'];
    itemsName = json['items_name'];
    itemsStorehouseCount = json['items_storehouse_count'];
    itemsPointofsale1Count = json['items_pointofsale1_count'];
    itemsPointofsale2Count = json['items_pointofsale2_count'];
    itemsCostPrice = json['items_cost_price'];
    itemsWholesalePrice = json['items_wholesale_price'];
    itemsRetailPrice = json['items_retail_price'];
    itemsWholesaleDiscount = json['items_wholesale_discount'];
    itemsRetailDiscount = json['items_retail_discount'];
    itemsQr = json['items_qr'];
    itemsCategories = json['items_categories'];
    itemsDate = json['items_date'];
    categoriesId = json['categories_id'];
    categoriesName = json['categories_name'];
    categoriesImage = json['categories_image'];
    categoriesDate = json['categories_date'];
    itemswholesalepricediscount = json['itemswholesalepricediscount'];
    itemsretailpricediscount = json['itemsretailpricediscount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items_id'] = itemsId;
    data['items_name'] = itemsName;
    data['items_storehouse_count'] = itemsStorehouseCount;
    data['items_pointofsale1_count'] = itemsPointofsale1Count;
    data['items_pointofsale2_count'] = itemsPointofsale2Count;
    data['items_cost_price'] = itemsCostPrice;
    data['items_wholesale_price'] = itemsWholesalePrice;
    data['items_retail_price'] = itemsRetailPrice;
    data['items_wholesale_discount'] = itemsWholesaleDiscount;
    data['items_retail_discount'] = itemsRetailDiscount;
    data['items_qr'] = itemsQr;
    data['items_categories'] = itemsCategories;
    data['items_date'] = itemsDate;
    data['categories_id'] = categoriesId;
    data['categories_name'] = categoriesName;
    data['categories_image'] = categoriesImage;
    data['categories_date'] = categoriesDate;
    data['itemswholesalepricediscount'] = itemswholesalepricediscount;
    data['itemsretailpricediscount'] = itemsretailpricediscount;
    return data;
  }
}
