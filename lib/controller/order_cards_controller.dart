import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/data/datasource/remote/order_data.dart';
import 'package:store_house/data/model/ordercardmodel.dart';
import 'package:store_house/sqflite.dart';

/// Controller for displaying order cards from the server (parent app)
class OrderCardsController extends GetxController {
  OrderCardsData orderCardsData = OrderCardsData();
  final SqlDb sqlDb = SqlDb();

  RxList<OrderCardModel> allOrders = <OrderCardModel>[].obs;
  RxList<OrderCardModel> pos1Orders = <OrderCardModel>[].obs;
  RxList<OrderCardModel> pos2Orders = <OrderCardModel>[].obs;

  RxBool isLoading = false.obs;
  late StatusRequest statusRequest;

  // Filters
  RxInt selectedTab = 0.obs; // 0 = all, 1 = pos1, 2 = pos2
  RxInt selectedCustomerType = (-1).obs; // -1 = all, 0 = retail, 1 = wholesale

  @override
  void onInit() {
    super.onInit();
    loadOrderCards();
  }

  /// ---------- Local persistence helpers ----------
  Future<void> _upsertOrderLocal(Map<String, dynamic> raw) async {
    try {
      final db = await sqlDb.db;
      if (db == null) return;

      final ordersId = raw['orders_id'] ?? raw['id'] ?? raw['order_id'];
      if (ordersId == null) return;
      final intOid = int.tryParse(ordersId.toString()) ?? 0;
      if (intOid == 0) return;

      final wholesaleId = raw['wholesale_customers_id'];
      final wholesaleName = raw['wholesale_customers_name'];
      final totalItemsCount = raw['total_items_count'] ?? 0;
      final subtotal = raw['subtotal'] ?? 0;
      final discountAmount = raw['discount_amount'] ?? 0;
      final total = raw['total'] ?? 0;
      final isWholesale = raw['is_wholesale'] ?? 0;
      final posSource = raw['pos_source'] ?? 1;
      final createdAt = raw['created_at'] ?? DateTime.now().toIso8601String();
      final rawJson = jsonEncode(raw);

      final existsRes = await db.query(
        'orders',
        where: 'orders_id = ?',
        whereArgs: [intOid],
        limit: 1,
      );

      final values = {
        'orders_id': intOid,
        'wholesale_customers_id': wholesaleId,
        'wholesale_customers_name': wholesaleName,
        'total_items_count': totalItemsCount,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'total': total,
        'is_wholesale': isWholesale,
        'status': 'uploaded',
        'pos_source': posSource,
        'created_at': createdAt,
        'raw_json': rawJson,
      };

      if (existsRes.isNotEmpty) {
        await db.update(
          'orders',
          values,
          where: 'orders_id = ?',
          whereArgs: [intOid],
        );
      } else {
        await db.insert('orders', values);
      }

      // Replace order_items
      await db.delete(
        'order_items',
        where: 'orders_id = ?',
        whereArgs: [intOid],
      );

      final itemsRaw = raw['items'];
      List itemsList = [];
      if (itemsRaw is List) {
        itemsList = itemsRaw;
      } else if (itemsRaw is String) {
        try {
          final parsed = jsonDecode(itemsRaw);
          if (parsed is List) itemsList = parsed;
        } catch (_) {}
      } else if (itemsRaw is Map) {
        try {
          itemsList = List<dynamic>.from(itemsRaw.values);
        } catch (_) {}
      }

      for (var it in itemsList) {
        try {
          final itm = Map<String, dynamic>.from(it);
          await db.insert('order_items', {
            'orders_id': intOid,
            'ordersdetails_id': itm['ordersdetails_id'],
            'items_id': itm['items_id'],
            'items_name': itm['items_name'],
            'items_image': itm['items_image'],
            'items_quantity': itm['items_quantity'],
            'items_unit_price': itm['items_unit_price'],
            'items_discount_percentage': itm['items_discount_percentage'],
            'items_price_before_discount':
                itm['items_unit_price'] != null && itm['items_quantity'] != null
                    ? (double.tryParse(itm['items_unit_price'].toString()) ??
                            0) *
                        (int.tryParse(itm['items_quantity'].toString()) ?? 0)
                    : 0,
            'items_price_after_discount': itm['items_total_price'],
            'items_total_price': itm['items_total_price'],
            'is_wholesale': itm['is_wholesale'] ?? 0,
          });
        } catch (e) {
          // skip bad item
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('_upsertOrderLocal error: $e');
      }
    }
  }

  Future<List<OrderCardModel>> _readOrdersFromLocal({
    int? posSource,
    int? isWholesale,
  }) async {
    final List<OrderCardModel> out = [];
    try {
      final db = await sqlDb.db;
      if (db == null) return out;

      String where = '';
      List<dynamic> whereArgs = [];
      if (posSource != null && posSource != 0) {
        where += 'pos_source = ?';
        whereArgs.add(posSource);
      }
      if (isWholesale != null && isWholesale != -1) {
        if (where.isNotEmpty) where += ' AND ';
        where += 'is_wholesale = ?';
        whereArgs.add(isWholesale);
      }

      final res = await db.query(
        'orders',
        where: where.isEmpty ? null : where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
      );
      for (var r in res) {
        try {
          final rawJson = r['raw_json'];
          Map<String, dynamic> raw;
          if (rawJson != null) {
            raw = Map<String, dynamic>.from(jsonDecode(rawJson.toString()));
          } else {
            raw = {
              'orders_id': r['orders_id'],
              'wholesale_customers_name': r['wholesale_customers_name'],
              'total_items_count': r['total_items_count'],
              'subtotal': r['subtotal'],
              'discount_amount': r['discount_amount'],
              'total': r['total'],
              'is_wholesale': r['is_wholesale'],
              'pos_source': r['pos_source'],
              'created_at': r['created_at'],
              'items': [],
            };
            final items = await db.query(
              'order_items',
              where: 'orders_id = ?',
              whereArgs: [r['orders_id']],
            );
            raw['items'] = items;
          }
          out.add(_mapToOrderCardModel(raw));
        } catch (e) {
          if (kDebugMode) {
            print('_readOrdersFromLocal - map error: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('_readOrdersFromLocal error: $e');
      }
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> _readLocalOrderRows({
    int? posSource,
    int? isWholesale,
  }) async {
    try {
      final db = await sqlDb.db;
      if (db == null) return [];
      String where = '';
      List<dynamic> whereArgs = [];
      if (posSource != null && posSource != 0) {
        where += 'pos_source = ?';
        whereArgs.add(posSource);
      }
      if (isWholesale != null && isWholesale != -1) {
        if (where.isNotEmpty) where += ' AND ';
        where += 'is_wholesale = ?';
        whereArgs.add(isWholesale);
      }

      final res = await db.query(
        'orders',
        where: where.isEmpty ? null : where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
      );
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      if (kDebugMode) {
        print('_readLocalOrderRows error: $e');
      }
      return [];
    }
  }

  /// Delete local orders (and their items) that are not present in remoteIds, for the current filter.
  Future<void> _deleteLocalMissingOrdersForFilter(
    Set<int> remoteIds, {
    int? posSource,
    int? isWholesale,
  }) async {
    try {
      if (remoteIds.isEmpty) {
        // إذا كانت الاستجابة خالية فلا نحذف شيء لتجنّب المسح العرضي
        return;
      }

      final localRows = await _readLocalOrderRows(
        posSource: posSource,
        isWholesale: isWholesale,
      );

      final db = await sqlDb.db;
      if (db == null) return;

      // حذف كل صف محلي ليس موجودًا في remoteIds
      for (var r in localRows) {
        final localIdVal = r['orders_id'];
        if (localIdVal == null) continue;
        final localId = int.tryParse(localIdVal.toString()) ?? 0;
        if (localId == 0) continue;
        if (!remoteIds.contains(localId)) {
          try {
            await db.delete(
              'order_items',
              where: 'orders_id = ?',
              whereArgs: [localId],
            );
            await db.delete(
              'orders',
              where: 'orders_id = ?',
              whereArgs: [localId],
            );
          } catch (e) {
            if (kDebugMode) {
              print('Failed deleting local order id=$localId -> $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('_deleteLocalMissingOrdersForFilter error: $e');
      }
    }
  }

  /// ---------- Core: load from server with local fallback ----------
  Future<void> loadOrderCards() async {
    try {
      isLoading.value = true;
      statusRequest = StatusRequest.loading;
      update();

      // 1) show local data immediately (offline-first behavior)
      final localSnapshot = await _readOrdersFromLocal(
        posSource: selectedTab.value == 0 ? null : selectedTab.value,
        isWholesale:
            selectedCustomerType.value == -1
                ? null
                : selectedCustomerType.value,
      );
      allOrders.assignAll(localSnapshot);
      pos1Orders.assignAll(
        localSnapshot.where((c) => c.posSource == 1).toList(),
      );
      pos2Orders.assignAll(
        localSnapshot.where((c) => c.posSource == 2).toList(),
      );
      statusRequest = StatusRequest.success;
      update();

      // 2) try to fetch remote (if online)
      final response = await orderCardsData.getOrders(
        poSource: selectedTab.value == 0 ? null : selectedTab.value,
        customerType:
            selectedCustomerType.value == -1
                ? null
                : selectedCustomerType.value,
      );

      if (response is StatusRequest) {
        FancySnackbar.show(
          title: 'تنبيه',
          message: 'لا يوجد اتصال بالإنترنت — عرض البيانات المحفوظة محلياً',
          isError: true,
        );
        return;
      }

      if (response is List) {
        final remoteIds = <int>{};
        for (var item in response) {
          try {
            final Map<String, dynamic> raw = Map<String, dynamic>.from(item);
            await _upsertOrderLocal(raw);
            final idv = raw['orders_id'] ?? raw['id'] ?? raw['order_id'];
            final intId = int.tryParse(idv?.toString() ?? '') ?? 0;
            if (intId != 0) remoteIds.add(intId);
          } catch (e) {
            if (kDebugMode) {
              print('loadOrderCards - saving remote item failed: $e');
            }
          }
        }

        // attempt deletion of local orders missing on server (for this filter)
        await _deleteLocalMissingOrdersForFilter(
          remoteIds,
          posSource: selectedTab.value == 0 ? null : selectedTab.value,
          isWholesale:
              selectedCustomerType.value == -1
                  ? null
                  : selectedCustomerType.value,
        );

        // reload local and update UI
        final updated = await _readOrdersFromLocal(
          posSource: selectedTab.value == 0 ? null : selectedTab.value,
          isWholesale:
              selectedCustomerType.value == -1
                  ? null
                  : selectedCustomerType.value,
        );

        allOrders.assignAll(updated);
        pos1Orders.assignAll(updated.where((c) => c.posSource == 1).toList());
        pos2Orders.assignAll(updated.where((c) => c.posSource == 2).toList());
        statusRequest = StatusRequest.success;
        update();
      } else {
        FancySnackbar.show(
          title: 'خطأ',
          message: 'استجابة غير متوقعة من السيرفر',
          isError: true,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in loadOrderCards: $e');
      }
      FancySnackbar.show(
        title: 'تنبيه',
        message:
            'لا يوجد اتصال أو حدث خطأ أثناء التحديث — عرض البيانات المحلية',
        isError: true,
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshOrders() async {
    try {
      await loadOrderCards();
    } catch (e) {
      if (kDebugMode) {
        print('refreshOrders caught: $e');
      }
      FancySnackbar.show(
        title: "تنبيه",
        message: "تعذر تحديث البيانات — يتم عرض البيانات المحلية.",
        isError: true,
      );
      update();
    }
  }

  void setTab(int tabIndex) {
    selectedTab.value = tabIndex;
    loadOrderCards();
  }

  void setCustomerType(int type) {
    selectedCustomerType.value = type;
    loadOrderCards();
  }

  List<OrderCardModel> getOrdersForTab() {
    if (selectedTab.value == 1) {
      return pos1Orders;
    } else if (selectedTab.value == 2) {
      return pos2Orders;
    } else {
      return allOrders;
    }
  }

  // mapping function kept as before (omitted here for brevity in this snippet)
  OrderCardModel _mapToOrderCardModel(Map<String, dynamic> data) {
    // ... (use your existing mapping implementation)
    // keep exactly what you had previously to ensure compatibility
    List<dynamic> itemsList = [];
    try {
      final raw = data['items'];
      if (raw == null) {
        itemsList = [];
      } else if (raw is List) {
        itemsList = List<dynamic>.from(raw);
      } else if (raw is Map) {
        final values = raw.values;
        itemsList = values.whereType<Map>().toList();
        if (itemsList.isEmpty && values.isNotEmpty) {
          itemsList = List<dynamic>.from(values);
        }
      } else if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            itemsList = List<dynamic>.from(decoded);
          } else if (decoded is Map) {
            final values = decoded.values;
            itemsList = values.whereType<Map>().toList();
            if (itemsList.isEmpty && values.isNotEmpty) {
              itemsList = List<dynamic>.from(values);
            }
          }
        } catch (_) {
          itemsList = [];
        }
      } else {
        itemsList = [];
      }
    } catch (e) {
      itemsList = [];
    }

    final items = <OrderItemCardModel>[];
    for (final item in itemsList) {
      try {
        if (item is! Map) continue;
        final itemData = Map<String, dynamic>.from(item);
        final itemsId = itemData['items_id'];
        final itemsName = itemData['items_name'];
        final itemsQuantity = itemData['items_quantity'];
        if (itemsId == null || itemsName == null || itemsQuantity == null) {
          continue;
        }

        items.add(
          OrderItemCardModel(
            ordersdetailsId: _parseInt(itemData['ordersdetails_id']),
            itemsId: _parseInt(itemsId),
            itemsName: itemsName.toString(),
            itemsImage: itemData['items_image'],
            itemsQuantity: _parseInt(itemsQuantity),
            itemsUnitPrice: _parseDouble(itemData['items_unit_price']),
            itemsDiscountPercentage: _parseDouble(
              itemData['items_discount_percentage'],
            ),
            itemsPriceBeforeDiscount:
                _parseDouble(itemData['items_unit_price']) *
                _parseInt(itemsQuantity),
            itemsPriceAfterDiscount: _parseDouble(
              itemData['items_total_price'],
            ),
            itemsTotalPrice: _parseDouble(itemData['items_total_price']),
            isWholesale: _parseInt(itemData['is_wholesale']) == 1,
          ),
        );
      } catch (e) {
        // skip malformed item
      }
    }

    return OrderCardModel(
      ordersId: _parseInt(data['orders_id']),
      wholesaleCustomersId: null,
      wholesaleCustomersName: data['wholesale_customers_name'],
      totalItemsCount: _parseInt(data['total_items_count']),
      subtotal: _parseDouble(data['subtotal']),
      discountAmount: _parseDouble(data['discount_amount']),
      total: _parseDouble(data['total']),
      isWholesale: _parseInt(data['is_wholesale']) == 1,
      status: 'uploaded',
      posSource: _parseInt(data['pos_source']),
      createdAt: data['created_at'] ?? DateTime.now().toIso8601String(),
      items: items,
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
