import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/incoming_invoices_data.dart';
import 'package:store_house/data/model/incoming_invoices_model.dart';
import 'package:store_house/sqflite.dart';
import 'view_controller.dart';

class IncomingInvoicesEditController extends GetxController {
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());
  SqlDb sqlDb = SqlDb();
  StatusRequest statusRequest = StatusRequest.none;

  late IncomingInvoicesModel model;
  
  late TextEditingController storehouseCount;
  late TextEditingController pos1Count;
  late TextEditingController pos2Count;
  late TextEditingController costPrice;
  late TextEditingController note;

  @override
  void onInit() {
    model = Get.arguments['model'];
    storehouseCount = TextEditingController(text: model.storehouseCount.toString());
    pos1Count = TextEditingController(text: model.pos1Count.toString());
    pos2Count = TextEditingController(text: model.pos2Count.toString());
    costPrice = TextEditingController(text: model.costPrice.toString());
    note = TextEditingController(text: model.incomingInvoiceItemsNote);
    super.onInit();
  }

  Future<void> editData() async {
    statusRequest = StatusRequest.loading;
    update();

    Map<String, dynamic> data = {
      "incoming_invoice_items_id": model.incomingInvoiceItemsId,
      "items_id": model.incomingInvoiceItemsItemsId,
      "storehouse_count": int.tryParse(storehouseCount.text) ?? 0,
      "pos1_count": int.tryParse(pos1Count.text) ?? 0,
      "pos2_count": int.tryParse(pos2Count.text) ?? 0,
      "cost_price": double.tryParse(costPrice.text) ?? 0.0,
      "note": note.text,
    };

    // 1. Update Server
    var response = await incomingInvoicesData.edit(data);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        // 2. Update Local DB
        await sqlDb.update(
          "incoming_invoice_itemsview",
          {
            "storehouse_count": data["storehouse_count"],
            "pos1_count": data["pos1_count"],
            "pos2_count": data["pos2_count"],
            "cost_price": data["cost_price"],
            "incoming_invoice_items_note": data["note"],
          },
          "incoming_invoice_items_id = ${model.incomingInvoiceItemsId}"
        );

        Get.snackbar("نجاح", "تم تعديل البيانات بنجاح");
        
        // Refresh View Controller and go back
        IncomingInvoicesController c = Get.find();
        c.getData();
        Get.back();
      } else {
        Get.snackbar("خطأ", "فشل التعديل على السيرفر");
      }
    } else {
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر");
    }

    statusRequest = StatusRequest.success;
    update();
  }
}
