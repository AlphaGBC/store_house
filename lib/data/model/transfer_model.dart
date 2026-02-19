class TransferModel {
  int? transferOfItemsId;
  int? transferOfItemsTransferId;
  int? transferOfItemsItemsId;
  int? storehouseCount;
  int? pos1Count;
  int? pos2Count;
  String? transferOfItemsNote;
  int? transferId;
  String? transferDate;
  String? itemsName;

  TransferModel({
    this.transferOfItemsId,
    this.transferOfItemsTransferId,
    this.transferOfItemsItemsId,
    this.storehouseCount,
    this.pos1Count,
    this.pos2Count,
    this.transferOfItemsNote,
    this.transferId,
    this.transferDate,
    this.itemsName,
  });

  TransferModel.fromJson(Map<String, dynamic> json) {
    transferOfItemsId = json['transfer_of_items_id'];
    transferOfItemsTransferId = json['transfer_of_items_transfer_id'];
    transferOfItemsItemsId = json['transfer_of_items_items_id'];
    storehouseCount = json['storehouse_count'];
    pos1Count = json['pos1_count'];
    pos2Count = json['pos2_count'];
    transferOfItemsNote = json['transfer_of_items_note'];
    transferId = json['transfer_id'];
    transferDate = json['transfer_date'];
    itemsName = json['items_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transfer_of_items_id'] = transferOfItemsId;
    data['transfer_of_items_transfer_id'] = transferOfItemsTransferId;
    data['transfer_of_items_items_id'] = transferOfItemsItemsId;
    data['storehouse_count'] = storehouseCount;
    data['pos1_count'] = pos1Count;
    data['pos2_count'] = pos2Count;
    data['transfer_of_items_note'] = transferOfItemsNote;
    data['transfer_id'] = transferId;
    data['transfer_date'] = transferDate;
    data['items_name'] = itemsName;
    return data;
  }
}
