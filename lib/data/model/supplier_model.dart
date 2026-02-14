class SupplierModel {
  int? supplierId;
  String? supplierName;
  String? supplierDate;

  SupplierModel({this.supplierId, this.supplierName, this.supplierDate});

  SupplierModel.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    supplierDate = json['supplier_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['supplier_date'] = supplierDate;
    return data;
  }
}
