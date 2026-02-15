import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/incoming_invoices_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/data/model/supplier_model.dart';
import 'package:store_house/sqflite.dart';

class IncomingInvoicesAddController extends GetxController {
  SqlDb sqlDb = SqlDb();
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());
  StatusRequest statusRequest = StatusRequest.none;

  List<ItemsModel> allItems = [];
  List<ItemsModel> filteredItems = [];
  TextEditingController searchItemController = TextEditingController();

  List<SupplierModel> allSuppliers = [];
  List<SupplierModel> filteredSuppliers = [];

  // List of items to be added to the invoice
  List<Map<String, dynamic>> selectedInvoiceItems = [];

  @override
  void onInit() {
    loadLocalData();
    super.onInit();
  }

  loadLocalData() async {
    statusRequest = StatusRequest.loading;
    update();

    // Load items from itemsview
    var itemsRes = await sqlDb.read("itemsview");
    allItems =
        itemsRes
            .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

    // Load suppliers from supplier
    var suppliersRes = await sqlDb.read("supplier");
    allSuppliers =
        suppliersRes
            .map((e) => SupplierModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

    statusRequest = StatusRequest.success;
    update();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems = [];
    } else {
      filteredItems =
          allItems
              .where(
                (item) =>
                    item.itemsName!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    update();
  }

  void filterSuppliers(String query) {
    if (query.isEmpty) {
      filteredSuppliers = [];
    } else {
      filteredSuppliers =
          allSuppliers
              .where(
                (s) =>
                    s.supplierName!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    update();
  }

  void selectItem(ItemsModel item) {
    // Add a new entry for this item in the invoice
    selectedInvoiceItems.insert(0, {
      "items_id": item.itemsId,
      "items_name": item.itemsName,
      "supplier_id": null,
      "supplier_name": "",
      "supplier_date": "",
      "supplier_search_controller": TextEditingController(),
      "storehouse_count": TextEditingController(),
      "pos1_count": TextEditingController(),
      "pos2_count": TextEditingController(),
      "cost_price": TextEditingController(
        text: item.itemsCostPrice?.toString() ?? "",
      ),
      "note": TextEditingController(),
      "show_supplier_suggestions": false,
    });

    searchItemController.clear();
    filteredItems = [];
    update();
  }

  void removeItem(int index) {
    selectedInvoiceItems.removeAt(index);
    update();
  }

  void selectSupplier(int itemIndex, SupplierModel supplier) {
    selectedInvoiceItems[itemIndex]["supplier_id"] = supplier.supplierId;
    selectedInvoiceItems[itemIndex]["supplier_name"] = supplier.supplierName;
    selectedInvoiceItems[itemIndex]["supplier_date"] = supplier.supplierDate;
    selectedInvoiceItems[itemIndex]["supplier_search_controller"].text =
        supplier.supplierName;
    selectedInvoiceItems[itemIndex]["show_supplier_suggestions"] = false;
    filteredSuppliers = [];
    update();
  }

  Future<void> saveData() async {
    if (selectedInvoiceItems.isEmpty) {
      Get.snackbar("تنبيه", "يرجى إضافة عنصر واحد على الأقل");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      // 1. Prepare data for local storage and server
      int invoiceId = DateTime.now().millisecondsSinceEpoch;
      String invoiceDate = DateTime.now().toString();

      List<Map<String, dynamic>> serverItems = [];

      for (var item in selectedInvoiceItems) {
        if (item["supplier_id"] == null) {
          Get.snackbar("خطأ", "يرجى اختيار مورد للعنصر: ${item["items_name"]}");
          statusRequest = StatusRequest.success;
          update();
          return;
        }

        double costPrice = double.tryParse(item["cost_price"].text) ?? 0.0;
        int sCount = int.tryParse(item["storehouse_count"].text) ?? 0;
        int p1Count = int.tryParse(item["pos1_count"].text) ?? 0;
        int p2Count = int.tryParse(item["pos2_count"].text) ?? 0;

        // Local row
        Map<String, Object?> row = {
          "incoming_invoice_items_id": DateTime.now().microsecondsSinceEpoch,
          "items_invoice_id": invoiceId,
          "items_supplier_id": item["supplier_id"],
          "incoming_invoice_items_items_id": item["items_id"],
          "storehouse_count": sCount,
          "pos1_count": p1Count,
          "pos2_count": p2Count,
          "cost_price": costPrice,
          "incoming_invoice_items_note": item["note"].text,
          "invoice_id": invoiceId,
          "invoice_date": invoiceDate,
          "supplier_id": item["supplier_id"],
          "supplier_name": item["supplier_name"],
          "supplier_date": item["supplier_date"],
          "items_name": item["items_name"],
        };

        await sqlDb.insert("incoming_invoice_itemsview", row);

        // Server item
        serverItems.add({
          "items_id": item["items_id"],
          "supplier_id": item["supplier_id"],
          "storehouse_count": sCount,
          "pos1_count": p1Count,
          "pos2_count": p2Count,
          "cost_price": costPrice,
          "note": item["note"].text,
        });
      }

      // 2. Upload to server
      var response = await incomingInvoicesData.add({
        "invoice_date": invoiceDate,
        "items": serverItems,
      });

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          Get.snackbar("نجاح", "تم حفظ الفاتورة محلياً ورفعها للسيرفر بنجاح");
          Get.back();
        } else {
          Get.snackbar(
            "تنبيه",
            "تم الحفظ محلياً ولكن فشل الرفع للسيرفر: ${response['message']}",
          );
        }
      } else {
        Get.snackbar(
          "تنبيه",
          "تم الحفظ محلياً ولكن تعذر الاتصال بالسيرفر للرفع",
        );
      }
    } catch (e) {
      print("Error saving invoice: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء الحفظ");
    }

    statusRequest = StatusRequest.success;
    update();
  }
}
