class UsdModel {
  int? usdId;
  String? usdPrice;
  String? usdData;

  UsdModel({this.usdId, this.usdPrice, this.usdData});

  UsdModel.fromJson(Map<String, dynamic> json) {
    usdId = json['usd_id'];
    usdPrice = json['usd_price'];
    usdData = json['usd_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['usd_id'] = usdId;
    data['usd_price'] = usdPrice;
    data['usd_data'] = usdData;
    return data;
  }
}
