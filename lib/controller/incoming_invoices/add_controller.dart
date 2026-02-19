import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/incoming_invoices_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/data/model/supplier_model.dart';
import 'package:store_house/sqflite.dart';
import '../../routes.dart';
import 'view_controller.dart';
import '../items/view_controller.dart';

class IncomingInvoicesAddController extends GetxController {
  SqlDb sqlDb = SqlDb();
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());
  StatusRequest statusRequest = StatusRequest.none;

  List<ItemsModel> allItems = [];
  List<ItemsModel> filteredItems = [];
  TextEditingController searchItemController = TextEditingController();

  List<SupplierModel> allSuppliers = [];
  List<SupplierModel> filteredSuppliers = [];

  List<Map<String, dynamic>> selectedInvoiceItems = [];

  @override
  void onInit() {
    loadLocalData();
    super.onInit();
  }

  loadLocalData() async {
    statusRequest = StatusRequest.loading;
    update();
    var itemsRes = await sqlDb.read("itemsview");
    allItems =
        itemsRes
            .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
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
      FancySnackbar.show(
        title: "تنبيه",
        message: "يرجى إضافة عنصر واحد على الأقل",
        isError: true,
      );
      return;
    }
    if (!await checkInternet()) {
      FancySnackbar.show(
        title: "خطأ",
        message: "لا يوجد اتصال بالانترنت",
        isError: true,
      );
      return;
    }
    statusRequest = StatusRequest.loading;
    update();

    try {
      int invoiceId = DateTime.now().millisecondsSinceEpoch;
      // بما أن السيرفر أقدم بـ 3 ساعات، نرسل الوقت الحالي مطروحاً منه 3 ساعات ليتوافق مع توقيت السيرفر
      // هذا يضمن أن المزامنة ستعتبر البيانات القادمة من السيرفر "حديثة" بالنسبة للتوقيت المحلي المعدل
      DateTime now = DateTime.now();
      String invoiceDate = now.subtract(const Duration(hours: 3)).toString();
      List<Map<String, dynamic>> serverItems = [];

      for (var item in selectedInvoiceItems) {
        if (item["supplier_id"] == null) {
          FancySnackbar.show(
            title: "خطأ",
            message: "يرجى اختيار مورد للعنصر: ${item["items_name"]}",
            isError: true,
          );
          statusRequest = StatusRequest.success;
          update();
          return;
        }

        double costPrice = double.tryParse(item["cost_price"].text) ?? 0.0;
        int sCount = int.tryParse(item["storehouse_count"].text) ?? 0;
        int p1Count = int.tryParse(item["pos1_count"].text) ?? 0;
        int p2Count = int.tryParse(item["pos2_count"].text) ?? 0;

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

      var response = await incomingInvoicesData.add({
        "invoice_date": invoiceDate,
        "items": serverItems,
      });

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          FancySnackbar.show(title: "نجاح", message: "تم حفظ الفاتورة بنجاح");

          // تحديث بيانات العناصر تلقائياً
          if (Get.isRegistered<ItemsControllerImp>()) {
            Get.find<ItemsControllerImp>().refreshItems();
          }

          if (Get.isRegistered<IncomingInvoicesController>()) {
            Get.find<IncomingInvoicesController>().getData();
          }

          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
          Get.offNamedUntil(
            AppRoute.incomingInvoices,
            ModalRoute.withName(AppRoute.homepage),
          );
        } else {
          FancySnackbar.show(
            title: "خطأ",
            message: "لا يوجد اتصال بالانترنت",
            isError: true,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving invoice: $e");
      }
      FancySnackbar.show(
        title: "خطأ",
        message: "حدث خطأ أثناء الحفظ",
        isError: true,
      );
    }

    statusRequest = StatusRequest.success;
    update();
  }
}
