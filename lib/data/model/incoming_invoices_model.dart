class IncomingInvoicesModel {
  int? incomingInvoiceItemsId;
  int? itemsInvoiceId;
  int? itemsSupplierId;
  int? incomingInvoiceItemsItemsId;
  int? storehouseCount;
  int? pos1Count;
  int? pos2Count;
  String? costPrice;
  String? incomingInvoiceItemsNote;
  int? invoiceId;
  String? invoiceDate;
  int? supplierId;
  String? supplierName;
  String? supplierDate;
  String? itemsName;

  IncomingInvoicesModel({
    this.incomingInvoiceItemsId,
    this.itemsInvoiceId,
    this.itemsSupplierId,
    this.incomingInvoiceItemsItemsId,
    this.storehouseCount,
    this.pos1Count,
    this.pos2Count,
    this.costPrice,
    this.incomingInvoiceItemsNote,
    this.invoiceId,
    this.invoiceDate,
    this.supplierId,
    this.supplierName,
    this.supplierDate,
    this.itemsName,
  });

  IncomingInvoicesModel.fromJson(Map<String, dynamic> json) {
    incomingInvoiceItemsId = json['incoming_invoice_items_id'];
    itemsInvoiceId = json['items_invoice_id'];
    itemsSupplierId = json['items_supplier_id'];
    incomingInvoiceItemsItemsId = json['incoming_invoice_items_items_id'];
    storehouseCount = json['storehouse_count'];
    pos1Count = json['pos1_count'];
    pos2Count = json['pos2_count'];
    costPrice = json['cost_price'];
    incomingInvoiceItemsNote = json['incoming_invoice_items_note'];
    invoiceId = json['invoice_id'];
    invoiceDate = json['invoice_date'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    supplierDate = json['supplier_date'];
    itemsName = json['items_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['incoming_invoice_items_id'] = incomingInvoiceItemsId;
    data['items_invoice_id'] = itemsInvoiceId;
    data['items_supplier_id'] = itemsSupplierId;
    data['incoming_invoice_items_items_id'] = incomingInvoiceItemsItemsId;
    data['storehouse_count'] = storehouseCount;
    data['pos1_count'] = pos1Count;
    data['pos2_count'] = pos2Count;
    data['cost_price'] = costPrice;
    data['incoming_invoice_items_note'] = incomingInvoiceItemsNote;
    data['invoice_id'] = invoiceId;
    data['invoice_date'] = invoiceDate;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    data['supplier_date'] = supplierDate;
    data['items_name'] = itemsName;
    return data;
  }
}
