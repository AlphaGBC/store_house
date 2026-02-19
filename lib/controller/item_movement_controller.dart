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

  DateTime? selectedDate;
  DateTime? selectedEndDate; // للتاريخ النهائي في مجال التواريخ
  bool isFilteredByDate = false; // للتمييز بين البحث عن تاريخ أو عنصر

  void searchItems(String query) async {
    if (query.trim().isEmpty) {
      isSearch = false;
      searchResults.clear();
      update();
      return;
    }

    // إذا كان هناك تصفية بالتاريخ، لا نعرض نتائج البحث، فقط نصفي الحركات
    if (isFilteredByDate) {
      debugPrint("🔎 البحث عن '$query' ضمن التاريخ المحدد");
      _filterMovementsByItemName(query);
      return;
    }

    isSearch = true;
    update();
    try {
      final db = await sqlDb.db;
      debugPrint("🔎 البحث عن: '$query'");
      final res = await db!.rawQuery(
        "SELECT * FROM itemsview WHERE items_name LIKE ?",
        ['%$query%'],
      );
      debugPrint("✅ عدد النتائج: ${res.length}");
      if (res.isNotEmpty) {
        searchResults =
            res
                .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
        debugPrint("✅ تم تحويل النتائج بنجاح");
      } else {
        searchResults.clear();
        debugPrint("⚠️ لم يتم العثور على نتائج");
      }
    } catch (e) {
      debugPrint("❌ خطأ البحث: $e");
      searchResults.clear();
    }
    update();
  }

  void _filterMovementsByItemName(String query) {
    // تصفية الحركات الموجودة بناءً على اسم العنصر
    final originalMovements = List<Map<String, dynamic>>.from(movements);
    movements =
        originalMovements
            .where((m) => (m['items_name']?.toString() ?? '').contains(query))
            .toList();
    debugPrint("📊 عدد الحركات بعد البحث ضمن التاريخ: ${movements.length}");
    update();
  }

  void onItemSelected(ItemsModel item) {
    debugPrint("👆 تم اختيار عنصر: ${item.itemsName} (ID: ${item.itemsId})");
    selectedItem = item;
    isSearch = false;
    searchController.text = item.itemsName ?? "";
    searchResults.clear();
    isFilteredByDate = false;
    selectedDate = null;
    getItemMovements(item.itemsId!);
    update();
  }

  Future<void> getMovementsByDate(DateTime date) async {
    statusRequest = StatusRequest.loading;
    movements.clear();
    isFilteredByDate = true;
    selectedDate = date;
    selectedItem = null;
    searchController.clear();
    searchResults.clear();
    update();

    try {
      final db = await sqlDb.db;
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      debugPrint(
        "======== جاري جلب جميع الحركات في التاريخ: $formattedDate ========",
      );

      // 1. Incoming Invoices (وارد)
      debugPrint("🔍 استعلام الوارد...");
      final incomingRes = await db!.rawQuery(
        '''
        SELECT 
          'وارد' as type, 
          supplier_name as source, 
          invoice_date as date, 
          storehouse_count as qty, 
          cost_price as price,
          'مورد: ' || supplier_name as details,
          incoming_invoice_items_note as note,
          items_name as items_name
        FROM incoming_invoice_itemsview
        WHERE DATE(invoice_date) = ?
      ''',
        [formattedDate],
      );
      debugPrint("✅ عدد من جدول الوارد: ${incomingRes.length}");

      // 2. Sales Orders (مبيعات)
      debugPrint("🔍 استعلام المبيعات...");
      final salesRes = await db.rawQuery(
        '''
        SELECT 
          'مبيعات' as type, 
          wholesale_customers_name as source, 
          created_at as date, 
          items_quantity as qty, 
          items_unit_price as price,
          (CASE WHEN orders.is_wholesale = 1 THEN 'جملة' ELSE 'مفرق' END) || ' - نقطة: ' || pos_source as details,
          '' as note,
          items_name as items_name
        FROM order_items
        JOIN orders ON order_items.orders_id = orders.orders_id
        WHERE DATE(created_at) = ?
      ''',
        [formattedDate],
      );
      debugPrint("✅ عدد من جدول المبيعات: ${salesRes.length}");

      // 3. Transfers (تحويل)
      debugPrint("🔍 استعلام التحويلات...");
      final transferRes = await db.rawQuery(
        '''
        SELECT 
          'تحويل' as type, 
          'المستودع' as source, 
          transfer_date as date, 
          (pos1_count + pos2_count) as qty, 
          0 as price,
          'إلى (نقطة اولى: ' || pos1_count || ', نقطة ثانية: ' || pos2_count || ')' as details,
          transfer_of_items_note as note,
          items_name as items_name
        FROM transfer_of_itemsview
        WHERE DATE(transfer_date) = ?
      ''',
        [formattedDate],
      );
      debugPrint("✅ عدد من جدول التحويلات: ${transferRes.length}");

      movements.addAll(incomingRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(salesRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(transferRes.map((e) => Map<String, dynamic>.from(e)));

      // Sort by date descending
      movements.sort((a, b) {
        final dateA = a['date'] as String?;
        final dateB = b['date'] as String?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      debugPrint(
        "========= إجمالي الحركات في التاريخ: ${movements.length} =========",
      );

      statusRequest =
          movements.isEmpty ? StatusRequest.none : StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("❌ خطأ جاري جلب الحركات: $e");
      debugPrint("Stack trace: ${e.toString()}");
    }
    update();
  }

  Future<void> getMovementsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    statusRequest = StatusRequest.loading;
    movements.clear();
    isFilteredByDate = true;
    selectedDate = startDate;
    selectedEndDate = endDate;
    selectedItem = null;
    searchController.clear();
    searchResults.clear();
    update();

    try {
      final db = await sqlDb.db;
      String formattedStartDate =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      String formattedEndDate =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      debugPrint(
        "======== جاري جلب الحركات من $formattedStartDate إلى $formattedEndDate ========",
      );

      // 1. Incoming Invoices (وارد)
      debugPrint("🔍 استعلام الوارد...");
      final incomingRes = await db!.rawQuery(
        '''
        SELECT 
          'وارد' as type, 
          supplier_name as source, 
          invoice_date as date, 
          storehouse_count as qty, 
          cost_price as price,
          'مورد: ' || supplier_name as details,
          incoming_invoice_items_note as note,
          items_name as items_name
        FROM incoming_invoice_itemsview
        WHERE DATE(invoice_date) BETWEEN ? AND ?
      ''',
        [formattedStartDate, formattedEndDate],
      );
      debugPrint("✅ عدد من جدول الوارد: ${incomingRes.length}");

      // 2. Sales Orders (مبيعات)
      debugPrint("🔍 استعلام المبيعات...");
      final salesRes = await db.rawQuery(
        '''
        SELECT 
          'مبيعات' as type, 
          wholesale_customers_name as source, 
          created_at as date, 
          items_quantity as qty, 
          items_unit_price as price,
          (CASE WHEN orders.is_wholesale = 1 THEN 'جملة' ELSE 'مفرق' END) || ' - نقطة: ' || pos_source as details,
          '' as note,
          items_name as items_name
        FROM order_items
        JOIN orders ON order_items.orders_id = orders.orders_id
        WHERE DATE(created_at) BETWEEN ? AND ?
      ''',
        [formattedStartDate, formattedEndDate],
      );
      debugPrint("✅ عدد من جدول المبيعات: ${salesRes.length}");

      // 3. Transfers (تحويل)
      debugPrint("🔍 استعلام التحويلات...");
      final transferRes = await db.rawQuery(
        '''
        SELECT 
          'تحويل' as type, 
          'المستودع' as source, 
          transfer_date as date, 
          (pos1_count + pos2_count) as qty, 
          0 as price,
          'إلى (نقطة اولى: ' || pos1_count || ', نقطة ثانية: ' || pos2_count || ')' as details,
          transfer_of_items_note as note,
          items_name as items_name
        FROM transfer_of_itemsview
        WHERE DATE(transfer_date) BETWEEN ? AND ?
      ''',
        [formattedStartDate, formattedEndDate],
      );
      debugPrint("✅ عدد من جدول التحويلات: ${transferRes.length}");

      movements.addAll(incomingRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(salesRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(transferRes.map((e) => Map<String, dynamic>.from(e)));

      // Sort by date descending
      movements.sort((a, b) {
        final dateA = a['date'] as String?;
        final dateB = b['date'] as String?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      debugPrint(
        "========= إجمالي الحركات من $formattedStartDate إلى $formattedEndDate: ${movements.length} =========",
      );

      statusRequest =
          movements.isEmpty ? StatusRequest.none : StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("❌ خطأ جاري جلب الحركات: $e");
      debugPrint("Stack trace: ${e.toString()}");
    }
    update();
  }

  Future<void> getItemMovements(int itemId) async {
    statusRequest = StatusRequest.loading;
    movements.clear();
    isFilteredByDate = false;
    update();
    try {
      final db = await sqlDb.db;
      debugPrint("======== جاري جلب جميع حركات العنصر برقم: $itemId ========");

      // 1. Incoming Invoices (وارد)
      debugPrint("🔍 استعلام الوارد...");
      final incomingRes = await db!.rawQuery(
        '''
        SELECT 
          'وارد' as type, 
          supplier_name as source, 
          invoice_date as date, 
          storehouse_count as qty, 
          cost_price as price,
          'مورد: ' || supplier_name as details,
          incoming_invoice_items_note as note,
          items_name as items_name,
          incoming_invoice_items_items_id as item_id
        FROM incoming_invoice_itemsview
        WHERE incoming_invoice_items_items_id = ?
      ''',
        [itemId],
      );
      debugPrint("✅ عدد من جدول الوارد: ${incomingRes.length}");

      // 2. Sales Orders (مبيعات)
      debugPrint("🔍 استعلام المبيعات...");
      final salesRes = await db.rawQuery(
        '''
        SELECT 
          'مبيعات' as type, 
          wholesale_customers_name as source, 
          created_at as date, 
          items_quantity as qty, 
          items_unit_price as price,
          (CASE WHEN orders.is_wholesale = 1 THEN 'جملة' ELSE 'مفرق' END) || ' - نقطة: ' || pos_source as details,
          '' as note,
          items_name as items_name,
          items_id as item_id
        FROM order_items
        JOIN orders ON order_items.orders_id = orders.orders_id
        WHERE items_id = ?
      ''',
        [itemId],
      );
      debugPrint("✅ عدد من جدول المبيعات: ${salesRes.length}");

      // 3. Transfers (تحويل)
      debugPrint("🔍 استعلام التحويلات...");
      final transferRes = await db.rawQuery(
        '''
        SELECT 
          'تحويل' as type, 
          'المستودع' as source, 
          transfer_date as date, 
          (pos1_count + pos2_count) as qty, 
          0 as price,
          'إلى (نقطة اولى: ' || pos1_count || ', نقطة ثانية: ' || pos2_count || ')' as details,
          transfer_of_items_note as note,
          items_name as items_name,
          transfer_of_items_items_id as item_id
        FROM transfer_of_itemsview
        WHERE transfer_of_items_items_id = ?
      ''',
        [itemId],
      );
      debugPrint("✅ عدد من جدول التحويلات: ${transferRes.length}");

      movements.addAll(incomingRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(salesRes.map((e) => Map<String, dynamic>.from(e)));
      movements.addAll(transferRes.map((e) => Map<String, dynamic>.from(e)));

      debugPrint("📊 إجمالي الحركات جمعاً: ${movements.length}");

      // Sort by date descending
      movements.sort((a, b) {
        final dateA = a['date'] as String?;
        final dateB = b['date'] as String?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      debugPrint(
        "========= النتيجة النهائية: ${movements.length} حركة =========",
      );

      statusRequest =
          movements.isEmpty ? StatusRequest.none : StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("❌ خطأ جاري جلب الحركات: $e");
      debugPrint("Stack trace: ${e.toString()}");
    }
    update();
  }

  void setFilterDate(DateTime? date) {
    if (date == null) return;
    debugPrint("📅 تحديث تاريخ التصفية: $date");
    getMovementsByDate(date);
  }

  void setFilterDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return;
    debugPrint(
      "📅 تحديث مجال التواريخ: ${dateRange.start} إلى ${dateRange.end}",
    );
    getMovementsByDateRange(dateRange.start, dateRange.end);
  }

  void clearFilter() {
    debugPrint("🗑️ مسح التصفية - العودة للحالة الابتدائية");
    selectedDate = null;
    selectedEndDate = null;
    isFilteredByDate = false;
    selectedItem = null;
    movements.clear();
    searchController.clear();
    searchResults.clear();
    isSearch = false;
    statusRequest = StatusRequest.none;
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
