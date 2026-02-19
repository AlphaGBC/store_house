import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/sqflite.dart';

class InventoryController extends GetxController {
  final SqlDb sqlDb = SqlDb();
  StatusRequest statusRequest = StatusRequest.none;

  List<ItemsModel> allItems = [];
  List<ItemsModel> filteredItems = [];
  List<ItemsModel> requiredItems = [];

  TextEditingController searchController = TextEditingController();

  double totalCapital = 0.0;
  int totalStorehouseCount = 0;
  int totalPos1Count = 0;
  int totalPos2Count = 0;

  @override
  void onInit() {
    getInventoryData();
    getRequiredItems();
    super.onInit();
  }

  Future<void> getInventoryData() async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      final db = await sqlDb.db;
      final List<Map<String, dynamic>> res = await db!.query("itemsview");

      allItems = res.map((e) => ItemsModel.fromJson(e)).toList();
      filteredItems = List.from(allItems);

      calculateTotals();

      statusRequest =
          allItems.isEmpty ? StatusRequest.none : StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("Inventory Data Error: $e");
    }
    update();
  }

  Future<void> getRequiredItems() async {
    try {
      final db = await sqlDb.db;
      final List<Map<String, dynamic>> res = await db!.query("required_items");
      requiredItems = res.map((e) => ItemsModel.fromJson(e)).toList();
      update();
    } catch (e) {
      debugPrint("Error fetching required items: $e");
    }
  }

  void calculateTotals() {
    totalCapital = 0.0;
    totalStorehouseCount = 0;
    totalPos1Count = 0;
    totalPos2Count = 0;

    for (var item in allItems) {
      int sCount = item.itemsStorehouseCount ?? 0;
      int p1Count = item.itemsPointofsale1Count ?? 0;
      int p2Count = item.itemsPointofsale2Count ?? 0;
      double cost =
          double.tryParse(item.itemsCostPrice?.toString() ?? "0") ?? 0.0;

      totalStorehouseCount += sCount;
      totalPos1Count += p1Count;
      totalPos2Count += p2Count;
      totalCapital += (sCount + p1Count + p2Count) * cost;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      filteredItems = List.from(allItems);
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

  Future<void> addToRequired(ItemsModel item) async {
    try {
      final db = await sqlDb.db;

      // Check if already exists
      List<Map> check = await db!.query(
        "required_items",
        where: "items_id = ?",
        whereArgs: [item.itemsId],
      );

      if (check.isEmpty) {
        await db.insert("required_items", {
          "items_id": item.itemsId,
          "items_name": item.itemsName,
          "items_storehouse_count": item.itemsStorehouseCount,
          "items_pointofsale1_count": item.itemsPointofsale1Count,
          "items_pointofsale2_count": item.itemsPointofsale2Count,
          "items_cost_price": item.itemsCostPrice,
          "items_wholesale_price": item.itemsWholesalePrice,
          "items_retail_price": item.itemsRetailPrice,
        });

        requiredItems.add(item);
        update();

        Get.snackbar(
          "نجاح",
          "تمت إضافة ${item.itemsName} إلى قائمة المواد المطلوبة",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "تنبيه",
          "العنصر موجود بالفعل في القائمة",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint("Error adding to required items: $e");
      Get.snackbar("خطأ", "فشل في إضافة العنصر");
    }
  }

  Future<void> removeFromRequired(int itemId) async {
    try {
      final db = await sqlDb.db;
      await db!.delete(
        "required_items",
        where: "items_id = ?",
        whereArgs: [itemId],
      );
      requiredItems.removeWhere((item) => item.itemsId == itemId);
      update();

      Get.snackbar(
        "تم الحذف",
        "تمت إزالة العنصر من القائمة",
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      debugPrint("Error removing from required items: $e");
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
