import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/items_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/sqflite.dart';

class IncomingInvoicesControllerImp extends GetxController {
  final ItemsData itemsData = ItemsData(Get.find());
  final SqlDb sqlDb = SqlDb();

  StatusRequest statusRequest = StatusRequest.none;
  bool isSearch = false;

  // قائمة الفواتير (البطاقات) للعرض في الصفحة الرئيسية
  List<Map<String, dynamic>> allInvoices = [];

  // بيانات الفاتورة الحالية المفتوحة
  int? currentInvoiceId;
  TextEditingController supplierName = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<ItemsModel> searchResults = [];
  List<ItemsModel> addedItems = [];

  // خريطة لتخزين المتحكمات لكل عنصر مضاف
  Map<int, Map<String, TextEditingController>> itemControllers = {};

  final Duration serverOffset = const Duration(hours: 3);

  @override
  void onInit() {
    getAllInvoices();
    super.onInit();
  }

  // جلب جميع الفواتير من قاعدة البيانات
  Future<void> getAllInvoices() async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final res = await sqlDb.read("incoming_invoices");
      allInvoices = List<Map<String, dynamic>>.from(res).reversed.toList();
      if (allInvoices.isEmpty) {
        statusRequest = StatusRequest.none;
      } else {
        statusRequest = StatusRequest.success;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching invoices: $e");
      statusRequest = StatusRequest.failure;
    }
    update();
  }

  // فتح فاتورة جديدة أو موجودة
  void openInvoice({int? id, String? name}) async {
    currentInvoiceId = id;
    addedItems.clear();

    // تصفية المتحكمات القديمة قبل المسح
    itemControllers.forEach((key, controllers) {
      controllers.forEach((k, v) => v.dispose());
    });
    itemControllers.clear();

    searchController.clear();

    if (id != null) {
      supplierName.text = name ?? "";
      await _loadInvoiceItems(id);
    } else {
      supplierName.clear();
    }
    update();
  }

  Future<void> _loadInvoiceItems(int invoiceId) async {
    try {
      final db = await sqlDb.db;
      final res = await db!.query(
        "incoming_invoice_items",
        where: "invoice_id = ?",
        whereArgs: [invoiceId],
      );

      for (var row in res) {
        ItemsModel item = ItemsModel(
          itemsId: row['items_id'] as int,
          itemsName: row['items_name'] as String,
          itemsStorehouseCount: row['storehouse_count'] as int?,
          itemsPointofsale1Count: row['pos1_count'] as int?,
          itemsPointofsale2Count: row['pos2_count'] as int?,
          itemsCostPrice:
              row['cost_price'] != null
                  ? (row['cost_price'] as num).toDouble()
                  : null,
          itemsWholesalePrice:
              row['wholesale_price'] != null
                  ? (row['wholesale_price'] as num).toDouble()
                  : null,
          itemsRetailPrice:
              row['retail_price'] != null
                  ? (row['retail_price'] as num).toDouble()
                  : null,
          itemsWholesaleDiscount:
              row['wholesale_discount'] != null
                  ? (row['wholesale_discount'] as num).toDouble()
                  : null,
          itemsRetailDiscount:
              row['retail_discount'] != null
                  ? (row['retail_discount'] as num).toDouble()
                  : null,
        );
        addedItems.add(item);
        _initControllersForItem(item);
      }
    } catch (e) {
      if (kDebugMode) print("Error loading invoice items: $e");
    }
  }

  void searchItems(String query) async {
    if (query.trim().isEmpty) {
      isSearch = false;
      searchResults.clear();
      update();
      return;
    }
    isSearch = true;
    try {
      final db = await sqlDb.db;
      final res = await db!.rawQuery(
        "SELECT * FROM itemsview WHERE items_name LIKE ? COLLATE NOCASE LIMIT 10",
        ['%${query.trim()}%'],
      );
      searchResults.clear();
      if (res.isNotEmpty) {
        searchResults.addAll(
          res
              .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) print("Search error: $e");
    }
    update();
  }

  void onItemSelected(ItemsModel item) {
    if (addedItems.any((element) => element.itemsId == item.itemsId)) {
      Get.snackbar("تنبيه", "هذا العنصر مضاف بالفعل");
    } else {
      addedItems.add(item);
      _initControllersForItem(item);
    }
    isSearch = false;
    searchResults.clear();
    searchController.clear();
    update();
  }

  void _initControllersForItem(ItemsModel item) {
    int id = item.itemsId!;
    itemControllers[id] = {
      "name": TextEditingController(text: item.itemsName),
      "storehouse": TextEditingController(
        text: (item.itemsStorehouseCount ?? 0).toString(),
      ),
      "pos1": TextEditingController(
        text: (item.itemsPointofsale1Count ?? 0).toString(),
      ),
      "pos2": TextEditingController(
        text: (item.itemsPointofsale2Count ?? 0).toString(),
      ),
      "cost": TextEditingController(
        text: item.itemsCostPrice?.toString() ?? '0',
      ),
      "wholesale": TextEditingController(
        text: item.itemsWholesalePrice?.toString() ?? '0',
      ),
      "retail": TextEditingController(
        text: item.itemsRetailPrice?.toString() ?? '0',
      ),
      "w_discount": TextEditingController(
        text: item.itemsWholesaleDiscount?.toString() ?? '0',
      ),
      "r_discount": TextEditingController(
        text: item.itemsRetailDiscount?.toString() ?? '0',
      ),
    };
  }

  void removeItem(int index) {
    int? id = addedItems[index].itemsId;
    if (id != null) {
      itemControllers[id]?.forEach((k, v) => v.dispose());
      itemControllers.remove(id);
    }
    addedItems.removeAt(index);
    update();
  }

  Future<void> saveAndCloseInvoice() async {
    if (supplierName.text.trim().isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال اسم المورد");
      return;
    }
    if (addedItems.isEmpty) {
      Get.snackbar("تنبيه", "الفاتورة فارغة");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      int invoiceId;
      if (currentInvoiceId == null) {
        invoiceId = await sqlDb.insert("incoming_invoices", {
          "supplier_name": supplierName.text.trim(),
          "status": "closed",
        });
      } else {
        invoiceId = currentInvoiceId!;
        await sqlDb.update("incoming_invoices", {
          "supplier_name": supplierName.text.trim(),
          "status": "closed",
        }, "invoice_id = $invoiceId");
        await sqlDb.delete("incoming_invoice_items", "invoice_id = $invoiceId");
      }

      for (var item in addedItems) {
        var ctrl = itemControllers[item.itemsId];
        if (ctrl == null) continue;

        await sqlDb.insert("incoming_invoice_items", {
          "invoice_id": invoiceId,
          "items_id": item.itemsId,
          "items_name": ctrl["name"]!.text,
          "storehouse_count": int.tryParse(ctrl["storehouse"]!.text) ?? 0,
          "pos1_count": int.tryParse(ctrl["pos1"]!.text) ?? 0,
          "pos2_count": int.tryParse(ctrl["pos2"]!.text) ?? 0,
          "cost_price": double.tryParse(ctrl["cost"]!.text) ?? 0,
          "wholesale_price": double.tryParse(ctrl["wholesale"]!.text) ?? 0,
          "retail_price": double.tryParse(ctrl["retail"]!.text) ?? 0,
          "wholesale_discount": double.tryParse(ctrl["w_discount"]!.text) ?? 0,
          "retail_discount": double.tryParse(ctrl["r_discount"]!.text) ?? 0,
        });

        await _updateOriginalItem(item.itemsId!, ctrl);
      }

      await getAllInvoices();
      Get.back();
      Get.snackbar("نجاح", "تم إغلاق وحفظ الفاتورة بنجاح");
    } catch (e) {
      if (kDebugMode) print("Error saving invoice: $e");
      Get.snackbar("خطأ", "فشل حفظ الفاتورة");
    } finally {
      statusRequest = StatusRequest.none;
      update();
    }
  }

  Future<void> _updateOriginalItem(
    int itemId,
    Map<String, TextEditingController> ctrl,
  ) async {
    await sqlDb.update("itemsview", {
      "items_name": ctrl["name"]!.text.trim(),
      "items_storehouse_count": int.tryParse(ctrl["storehouse"]!.text) ?? 0,
      "items_pointofsale1_count": int.tryParse(ctrl["pos1"]!.text) ?? 0,
      "items_pointofsale2_count": int.tryParse(ctrl["pos2"]!.text) ?? 0,
      "items_cost_price": double.tryParse(ctrl["cost"]!.text) ?? 0,
      "items_wholesale_price": double.tryParse(ctrl["wholesale"]!.text) ?? 0,
      "items_retail_price": double.tryParse(ctrl["retail"]!.text) ?? 0,
      "items_wholesale_discount":
          double.tryParse(ctrl["w_discount"]!.text) ?? 0,
      "items_retail_discount": double.tryParse(ctrl["r_discount"]!.text) ?? 0,
      "items_date": DateTime.now().toString(),
    }, "items_id = $itemId");

    try {
      String serverDate =
          DateTime.now().subtract(serverOffset).toString().split('.')[0];
      await itemsData.edit({
        "name": ctrl["name"]!.text,
        "storehousecount": ctrl["storehouse"]!.text,
        "pointofsale1count": ctrl["pos1"]!.text,
        "pointofsale2count": ctrl["pos2"]!.text,
        "costprice": ctrl["cost"]!.text,
        "wholesaleprice": ctrl["wholesale"]!.text,
        "retailprice": ctrl["retail"]!.text,
        "wholesalediscount": ctrl["w_discount"]!.text,
        "retaildiscount": ctrl["r_discount"]!.text,
        "items_date": serverDate,
        "items_id": itemId.toString(),
      });
    } catch (e) {
      if (kDebugMode) print("Server sync error: $e");
    }
  }

  void deleteInvoice(int id) async {
    await sqlDb.delete("incoming_invoices", "invoice_id = $id");
    await sqlDb.delete("incoming_invoice_items", "invoice_id = $id");
    await getAllInvoices();
  }

  @override
  void onClose() {
    supplierName.dispose();
    searchController.dispose();
    itemControllers.forEach((key, controllers) {
      controllers.forEach((k, v) => v.dispose());
    });
    super.onClose();
  }
}
