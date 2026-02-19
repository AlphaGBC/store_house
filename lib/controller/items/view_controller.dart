import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:store_house/Sqflite.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/items_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/routes.dart';

abstract class ItemsController extends GetxController {
  intialData();
  changeCat(int val, String catval);
}

class ItemsControllerImp extends ItemsController {
  List categories = [];
  String? catid;
  int? selectedCat;

  ItemsData itemsData = ItemsData(Get.find());

  List<ItemsModel> data = [];

  StatusRequest statusRequest = StatusRequest.none;

  SqlDb sqlDb = SqlDb();

  // الفرق: السيرفر أقدم بـ 3 ساعات — نستخدم هذا للتعديل والتحويل.
  // ملاحظة: إذا كان السيرفر أقدم بـ 3 ساعات، فهذا يعني أن (وقت السيرفر + 3 ساعات = الوقت المحلي)
  final Duration serverOffset = const Duration(hours: 3);

  @override
  void onInit() {
    if (Get.arguments != null) {
      intialData();
    }
    super.onInit();
  }

  @override
  intialData() {
    categories = Get.arguments['categories'];
    selectedCat = Get.arguments['selectedcat'];
    catid = Get.arguments['catid'];
    getItemsByCategories(int.parse(catid!));
  }

  @override
  changeCat(val, catval) {
    selectedCat = val;
    catid = catval;
    update();
  }

  // ----------------- Helpers -----------------

  DateTime? _parseDate(String? s) {
    if (s == null) return null;
    try {
      // تحويل السلسلة النصية إلى DateTime
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      try {
        final ms = int.parse(s);
        return DateTime.fromMillisecondsSinceEpoch(ms);
      } catch (_) {
        return null;
      }
    }
  }

  // دالة لتوحيد التوقيت عند المقارنة (تعديل وقت السيرفر ليتوافق مع المحلي)
  DateTime? _getNormalizedRemoteDate(String? remoteDateStr) {
    DateTime? remoteDt = _parseDate(remoteDateStr);
    if (remoteDt == null) return null;
    // بما أن السيرفر أقدم بـ 3 ساعات، نضيفها لنحصل على التوقيت المحلي المقابل
    return remoteDt.add(serverOffset);
  }

  String _formatForServer(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}";
  }

  String _formatLocal(DateTime dt) {
    return dt.toString(); // store local ISO-like string
  }

  Future<List<Map<String, dynamic>>> _readLocalRows(int categoryId) async {
    try {
      final db = await sqlDb.db;
      final res = await db!.query(
        "itemsview",
        where: "items_categories = ?",
        whereArgs: [categoryId],
      );
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      if (kDebugMode) {
        print("readLocalRows error: $e");
      }
      return [];
    }
  }

  Future<Map<String, ItemsModel>> _localMap(int categoryId) async {
    final m = <String, ItemsModel>{};
    try {
      final rows = await _readLocalRows(categoryId);
      for (var r in rows) {
        final map = Map<String, dynamic>.from(r);
        final model = ItemsModel.fromJson(map);
        final id = model.itemsId?.toString() ?? '';
        if (id.isNotEmpty) m[id] = model;
      }
    } catch (e) {
      if (kDebugMode) {
        print("localMap error: $e");
      }
    }
    return m;
  }

  Map<String, ItemsModel> _remoteMapFromRaw(List remoteRaw) {
    final m = <String, ItemsModel>{};
    try {
      for (var r in remoteRaw) {
        final model = ItemsModel.fromJson(Map<String, dynamic>.from(r));
        final id = model.itemsId?.toString() ?? '';
        if (id.isNotEmpty) m[id] = model;
      }
    } catch (e) {
      if (kDebugMode) {
        print("remoteMapFromRaw error: $e");
      }
    }
    return m;
  }

  Future<void> _upsertLocal(ItemsModel model) async {
    final db = await sqlDb.db;
    if (db == null) return;

    final values = {
      "items_id": model.itemsId,
      "items_name": model.itemsName ?? '',
      "items_storehouse_count": model.itemsStorehouseCount ?? 0,
      "items_pointofsale1_count": model.itemsPointofsale1Count ?? 0,
      "items_pointofsale2_count": model.itemsPointofsale2Count ?? 0,
      "items_cost_price": model.itemsCostPrice ?? 0,
      "items_wholesale_price": model.itemsWholesalePrice ?? 0,
      "items_retail_price": model.itemsRetailPrice ?? 0,
      "items_wholesale_discount": model.itemsWholesaleDiscount ?? 0,
      "items_retail_discount": model.itemsRetailDiscount ?? 0,
      "items_qr": model.itemsQr ?? '',
      "items_categories": model.itemsCategories ?? 0,
      "items_date": model.itemsDate ?? DateTime.now().toString(),
      "categories_id": model.categoriesId ?? 0,
      "categories_name": model.categoriesName ?? '',
      "categories_image": model.categoriesImage ?? '',
      "categories_date": model.categoriesDate ?? DateTime.now().toString(),
      "itemswholesalepricediscount": model.itemswholesalepricediscount ?? 0,
      "itemsretailpricediscount": model.itemsretailpricediscount ?? 0,
    };

    try {
      await db.transaction((txn) async {
        final updated = await txn.update(
          'itemsview',
          values,
          where: 'items_id = ?',
          whereArgs: [model.itemsId],
        );
        if (updated == 0) {
          await txn.insert('itemsview', values);
        }
      });
      if (kDebugMode) {
        print("Upsert (transaction) succeeded for id=${model.itemsId}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("upsertLocal transaction error id=${model.itemsId}: $e");
      }
    }
  }

  // ----------------- Remote ops (use upgrade for updates, addupgrade/add for adds) -----------------

  Future<bool> _updateRemote(ItemsModel model) async {
    try {
      // build payload expected by server for update
      Map payload = {
        "name": model.itemsName ?? "",
        "storehousecount": (model.itemsStorehouseCount ?? 0).toString(),
        "pointofsale1count": (model.itemsPointofsale1Count ?? 0).toString(),
        "pointofsale2count": (model.itemsPointofsale2Count ?? 0).toString(),
        "costprice": model.itemsCostPrice?.toString() ?? "0",
        "wholesaleprice": model.itemsWholesalePrice?.toString() ?? "0",
        "retailprice": model.itemsRetailPrice?.toString() ?? "0",
        "wholesalediscount": model.itemsWholesaleDiscount?.toString() ?? "0",
        "retaildiscount": model.itemsRetailDiscount?.toString() ?? "0",
        "items_id": model.itemsId?.toString() ?? "",
      };

      // align items_date for server: localDate - serverOffset
      DateTime? localDt = _parseDate(model.itemsDate);
      if (localDt != null) {
        payload["items_date"] = _formatForServer(
          localDt.subtract(serverOffset),
        );
      } else {
        payload["items_date"] = _formatForServer(
          DateTime.now().subtract(serverOffset),
        );
      }

      // Use upgrade(...) endpoint for updates
      var resp = await itemsData.upgrade(payload);
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        // server update ok
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("updateRemote exception items_id=${model.itemsId}: $e");
      }
      return false;
    }
  }

  Future<void> refreshItems() async {
    if (catid != null) {
      await getItemsByCategories(int.parse(catid!));
    }
  }

  Future<void> upgradeItemsForCategory(int categoryId) async {
    try {
      // 0) Build maps
      // get local map
      final localMap = await _localMap(categoryId);

      // 1) Try fetch remote (we still fetch remote map to know which ids exist).
      var remoteResponse = await itemsData.view(categoryId.toString());
      var stRemote = handlingData(remoteResponse);
      if (stRemote != StatusRequest.success ||
          remoteResponse['status'] != "success") {
        return;
      }

      List remoteRaw = remoteResponse['data'] ?? [];
      final remoteMap = _remoteMapFromRaw(remoteRaw);

      // 2) First: iterate localMap and for each local decide to push if needed
      for (var entry in localMap.entries) {
        final id = entry.key;
        final localItem = entry.value;
        final remoteItem = remoteMap[id];

        if (remoteItem != null) {
          // كلاهما موجود -> قارن التواريخ
          DateTime? dl = _parseDate(localItem.itemsDate);
          DateTime? drAdjusted = _getNormalizedRemoteDate(remoteItem.itemsDate);

          if (drAdjusted != null && dl != null) {
            // إذا كان المحلي أحدث من السيرفر (بعد تعديل فارق التوقيت)
            if (dl.isAfter(drAdjusted.add(const Duration(seconds: 5)))) {
              // المحلي أحدث -> ارفع التحديث للسيرفر
              await _updateRemote(localItem);
            }
          }
        }
      }

      // 3) Then: iterate remoteMap and merge remote -> local for items that are newer or local-missing
      final allIds =
          <String>{}
            ..addAll(remoteMap.keys)
            ..addAll(localMap.keys);

      for (var id in allIds) {
        final remoteItem = remoteMap[id];
        final localItem = localMap[id];

        if (remoteItem != null && localItem != null) {
          DateTime? drAdjusted = _getNormalizedRemoteDate(remoteItem.itemsDate);
          DateTime? dl = _parseDate(localItem.itemsDate);

          if (drAdjusted != null && dl != null) {
            // إذا كان السيرفر أحدث من المحلي (بعد تعديل فارق التوقيت)
            if (drAdjusted.isAfter(dl.add(const Duration(seconds: 5)))) {
              // السيرفر أحدث -> حدث القاعدة المحلية
              // نخزن التاريخ المحلي المقابل (المعدل) لضمان استمرار المزامنة بشكل صحيح
              remoteItem.itemsDate = _formatLocal(drAdjusted);
              await _upsertLocal(remoteItem);
            }
          }
        } else if (remoteItem != null && localItem == null) {
          // موجود فقط في السيرفر -> أضفه محلياً
          DateTime? drAdjusted = _getNormalizedRemoteDate(remoteItem.itemsDate);
          if (drAdjusted != null) {
            remoteItem.itemsDate = _formatLocal(drAdjusted);
          }
          await _upsertLocal(remoteItem);
        } else {
          // local-only handled in step 2
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("upgradeItemsForCategory exception: $e");
      }
    }
  }

  getItemsByCategories(int catid) async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    // 1) show local
    try {
      final localRows = await _readLocalRows(catid);
      data =
          localRows
              .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
      statusRequest = StatusRequest.success;
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getview - read local error: $e");
      }
      statusRequest = StatusRequest.failure;
      update();
    }

    // 2) sync (compare dates & delete missing) — this will insert remote-only items into local
    try {
      await upgradeItemsForCategory(int.parse(catid.toString()));
    } catch (e) {
      if (kDebugMode) {
        print("getview - upgradeItemsForCategory failed: $e");
      }
    }

    // 3) reload local and update UI
    try {
      final refreshed = await _readLocalRows(catid);
      data =
          refreshed
              .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getview - final reload error: $e");
      }
    }
  }

  // delete (remote then local)
  deleteItems(String id) async {
    if (!await checkInternet()) {
      FancySnackbar.show(
        title: "خطأ",
        message: "لا يوجد اتصال بالانترنت",
        isError: true,
      );
      return;
    }
    try {
      var resp = await itemsData.delete({"id": id});
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        await sqlDb.delete("itemsview", "items_id = $id");
        data.removeWhere((element) => element.itemsId.toString() == id);
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("deleteItems exception: $e");
      }
    }
  }

  goToPageEdit(ItemsModel itemsModel, int? catid) {
    Get.toNamed(
      AppRoute.itemsedit,
      arguments: {"ItemsModel": itemsModel, "catid": catid},
    );
  }

  goToPageItemsAdd() {
    Get.toNamed(AppRoute.itemsAdd, arguments: {"catid": catid});
  }
}
