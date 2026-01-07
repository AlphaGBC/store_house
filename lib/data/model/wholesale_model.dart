class WholesaleModel {
  int? wholesaleCustomersId;
  String? wholesaleCustomersName;
  String? wholesaleCustomersDate;

  WholesaleModel({
    this.wholesaleCustomersId,
    this.wholesaleCustomersName,
    this.wholesaleCustomersDate,
  });

  WholesaleModel.fromJson(Map<String, dynamic> json) {
    wholesaleCustomersId = json['wholesale_customers_id'];
    wholesaleCustomersName = json['wholesale_customers_name'];
    wholesaleCustomersDate = json['wholesale_customers_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wholesale_customers_id'] = wholesaleCustomersId;
    data['wholesale_customers_name'] = wholesaleCustomersName;
    data['wholesale_customers_date'] = wholesaleCustomersDate;
    return data;
  }
}
