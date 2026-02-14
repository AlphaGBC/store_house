import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/sqflite.dart';

class ItemMovementController extends GetxController {
  final SqlDb sqlDb = SqlDb();
  StatusRequest statusRequest = StatusRequest.none;
  TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  List<ItemsModel> searchResults = [];
  ItemsModel? selectedItem;
  List<Map<String, dynamic>> movements = [];

  void searchItems(String query) async {
    if (query.trim().isEmpty) {
      isSearch = false;
      searchResults.clear();
      update();
      return;
    }
    isSearch = true;
    update();
    try {
      final db = await sqlDb.db;
      // البحث في itemsview بناءً على ملف sqflite.dart
      final res = await db!.rawQuery(
        "SELECT * FROM itemsview WHERE items_name LIKE ?",
        ['%$query%'],
      );
      if (res.isNotEmpty) {
        searchResults = res.map((e) => ItemsModel.fromJson(e)).toList();
      } else {
        searchResults.clear();
      }
    } catch (e) {
      debugPrint("Local Search Error: $e");
      searchResults.clear();
    }
    update();
  }

  void onItemSelected(ItemsModel item) {
    selectedItem = item;
    isSearch = false;
    searchController.text = item.itemsName ?? "";
    searchResults.clear();
    getItemMovements(item.itemsId!);
    update();
  }

  Future<void> getItemMovements(int itemId) async {
    statusRequest = StatusRequest.loading;
    movements.clear();
    update();
    try {
      final db = await sqlDb.db;

      // 1. استعلام الوارد (Incoming Invoices)
      final incomingRes = await db!.rawQuery(
        '''
        SELECT 'وارد' as type, i.supplier_name as source, i.invoice_date as date, ii.storehouse_count as qty, ii.cost_price as price
        FROM incoming_invoice_items ii
        JOIN incoming_invoices i ON ii.invoice_id = i.invoice_id
        WHERE ii.items_id = ?
      ''',
        [itemId],
      );

      // 2. استعلام الصادر - مبيعات (Orders)
      final salesRes = await db.rawQuery(
        '''
        SELECT 'صادر (طلب)' as type, o.wholesale_customers_name as source, o.created_at as date, oi.items_quantity as qty, oi.items_unit_price as price
        FROM order_items oi
        JOIN orders o ON oi.orders_id = o.orders_id
        WHERE oi.items_id = ?
      ''',
        [itemId],
      );

      // 3. استعلام الصادر - فواتير صادرة (Issued Invoices) - بناءً على البنية المحددة
      final issuedRes = await db.rawQuery(
        '''
        SELECT 
          'صادر (فاتورة)' as type, 
          i.supplier_name as source, 
          i.issued_invoices_date as date, 
          ii.storehouse_count as qty, 
          ii.wholesale_price as price
        FROM issued_invoices_items ii
        JOIN issued_invoices i ON ii.issued_invoices_id = i.issued_invoices_id
        WHERE ii.items_id = ?
      ''',
        [itemId],
      );

      movements.addAll(incomingRes);
      movements.addAll(salesRes);
      movements.addAll(issuedRes);

      // ترتيب الحركات تنازلياً حسب التاريخ
      movements.sort((a, b) {
        final dateA = a['date'] as String?;
        final dateB = b['date'] as String?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      statusRequest =
          movements.isEmpty ? StatusRequest.none : StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("Error fetching local movements: $e");
    }
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
