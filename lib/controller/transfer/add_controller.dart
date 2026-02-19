import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/transfer_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/sqflite.dart';
import '../../routes.dart';
import 'view_controller.dart';
import '../items/view_controller.dart';

class TransferAddController extends GetxController {
  SqlDb sqlDb = SqlDb();
  TransferData transferData = TransferData(Get.find());
  StatusRequest statusRequest = StatusRequest.none;

  List<ItemsModel> allItems = [];
  List<ItemsModel> filteredItems = [];
  TextEditingController searchItemController = TextEditingController();

  // List of items to be transferred
  List<Map<String, dynamic>> selectedTransferItems = [];

  @override
  void onInit() {
    loadLocalItems();
    super.onInit();
  }

  loadLocalItems() async {
    statusRequest = StatusRequest.loading;
    update();
    var itemsRes = await sqlDb.read("itemsview");
    allItems =
        itemsRes
            .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
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

  void selectItem(ItemsModel item) {
    // Check if item already added
    if (selectedTransferItems.any(
      (element) => element["items_id"] == item.itemsId,
    )) {
      Get.snackbar("تنبيه", "هذا العنصر مضاف مسبقاً");
      return;
    }

    selectedTransferItems.insert(0, {
      "items_id": item.itemsId,
      "items_name": item.itemsName,
      "original_storehouse_count":
          item.itemsStorehouseCount, // Fixed original count
      "current_storehouse_display":
          item.itemsStorehouseCount.toString(), // Reactive display
      "pos1_controller": TextEditingController(),
      "pos2_controller": TextEditingController(),
      "note_controller": TextEditingController(),
    });

    searchItemController.clear();
    filteredItems = [];
    update();
  }

  void removeItem(int index) {
    selectedTransferItems.removeAt(index);
    update();
  }

  // Logic to update storehouse count display as user types in POS fields
  void updateStorehouseDisplay(int index) {
    var item = selectedTransferItems[index];
    int original = item["original_storehouse_count"] ?? 0;
    int p1 = int.tryParse(item["pos1_controller"].text) ?? 0;
    int p2 = int.tryParse(item["pos2_controller"].text) ?? 0;

    int remaining = original - (p1 + p2);
    item["current_storehouse_display"] = remaining.toString();
    update();
  }

  Future<void> saveData() async {
    if (selectedTransferItems.isEmpty) {
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
    // Validate quantities
    for (var item in selectedTransferItems) {
      int remaining = int.tryParse(item["current_storehouse_display"]) ?? 0;
      if (remaining < 0) {
        FancySnackbar.show(
          title: "خطأ",
          message:
              "الكمية المنقولة للعنصر ${item["items_name"]} تتجاوز المتوفر في المستودع",
          isError: true,
        );
        return;
      }
      int p1 = int.tryParse(item["pos1_controller"].text) ?? 0;
      int p2 = int.tryParse(item["pos2_controller"].text) ?? 0;
      if (p1 == 0 && p2 == 0) {
        FancySnackbar.show(
          title: "تنبيه",
          message: "يرجى تحديد كمية للنقل للعنصر ${item["items_name"]}",
          isError: true,
        );

        return;
      }
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      int transferId = DateTime.now().millisecondsSinceEpoch;
      // بما أن السيرفر أقدم بـ 3 ساعات، نرسل الوقت الحالي مطروحاً منه 3 ساعات ليتوافق مع توقيت السيرفر
      DateTime now = DateTime.now();
      String transferDate = now.subtract(const Duration(hours: 3)).toString();
      List<Map<String, dynamic>> serverItems = [];

      for (var item in selectedTransferItems) {
        int p1 = int.tryParse(item["pos1_controller"].text) ?? 0;
        int p2 = int.tryParse(item["pos2_controller"].text) ?? 0;
        int newStorehouseTotal =
            int.tryParse(item["current_storehouse_display"]) ?? 0;

        // Local storage
        Map<String, Object?> row = {
          "transfer_of_items_id": DateTime.now().microsecondsSinceEpoch,
          "transfer_of_items_transfer_id": transferId,
          "transfer_of_items_items_id": item["items_id"],
          "storehouse_count": newStorehouseTotal,
          "pos1_count": p1,
          "pos2_count": p2,
          "transfer_of_items_note": item["note_controller"].text,
          "transfer_id": transferId,
          "transfer_date": transferDate,
          "items_name": item["items_name"],
        };
        await sqlDb.insert("transfer_of_itemsview", row);

        // Server data
        serverItems.add({
          "items_id": item["items_id"],
          "storehouse_count": newStorehouseTotal,
          "pos1_count": p1,
          "pos2_count": p2,
          "note": item["note_controller"].text,
        });
      }

      var response = await transferData.add({
        "transfer_date": transferDate,
        "items": serverItems,
      });

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          FancySnackbar.show(title: "نجاح", message: "تمت عملية التحويل بنجاح");

          // تحديث بيانات العناصر تلقائياً
          if (Get.isRegistered<ItemsControllerImp>()) {
            Get.find<ItemsControllerImp>().refreshItems();
          }

          if (Get.isRegistered<TransferController>()) {
            Get.find<TransferController>().getData();
          }

          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
          Get.offNamedUntil(
            AppRoute.transferView,
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
