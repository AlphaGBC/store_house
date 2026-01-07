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

  int? _lastSubcategoriesId;

  SqlDb sqlDb = SqlDb();

  // الفرق: السيرفر أقدم بـ 3 ساعات — نستخدم هذا للتعديل والتحويل.
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

  // ----------------- Local upsert (from remote) -----------------

  Future<void> _upsertLocal(ItemsModel model) async {
    try {
      final rows = await _readLocalRows(model.itemsCategories ?? 0);
      final idStr = model.itemsId.toString();
      final exists = rows.any((r) => (r['items_id'] ?? '').toString() == idStr);

      final values = {
        "items_id": model.itemsId,
        "items_name": model.itemsName,
        "items_storehouse_count": model.itemsStorehouseCount ?? 0,
        "items_pointofsale1_count": model.itemsPointofsale1Count ?? 0,
        "items_pointofsale2_count": model.itemsPointofsale2Count ?? 0,
        "items_cost_price": model.itemsCostPrice,
        "items_wholesale_price": model.itemsWholesalePrice,
        "items_retail_price": model.itemsRetailPrice,
        "items_wholesale_discount": model.itemsWholesaleDiscount,
        "items_retail_discount": model.itemsRetailDiscount,
        "items_qr": model.itemsQr,
        "items_categories": model.itemsCategories,
        "items_date": model.itemsDate,
        "categories_id": model.categoriesId,
        "categories_name": model.categoriesName,
        "categories_image": model.categoriesImage,
        "categories_date": model.categoriesDate,
        "itemswholesalepricediscount": model.itemswholesalepricediscount,
        "itemsretailpricediscount": model.itemsretailpricediscount,
      };

      if (exists) {
        await sqlDb.update("itemsview", values, "items_id = $idStr");
        //print("Local updated item id=$idStr");
      } else {
        await sqlDb.insert("itemsview", values);
        //print("Local inserted item id=$idStr");
      }
    } catch (e) {
      if (kDebugMode) {
        print("upsertLocal items error id=${model.itemsId}: $e");
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

  // Future<bool> _addRemote(ItemsModel model) async {
  //   try {
  //     Map payload = {
  //       "name": model.itemsName ?? "",
  //       "storehousecount": (model.itemsStorehouseCount ?? 0).toString(),
  //       "pointofsale1count": (model.itemsPointofsale1Count ?? 0).toString(),
  //       "pointofsale2count": (model.itemsPointofsale2Count ?? 0).toString(),
  //       "costprice": model.itemsCostPrice?.toString() ?? "0",
  //       "wholesaleprice": model.itemsWholesalePrice?.toString() ?? "0",
  //       "retailprice": model.itemsRetailPrice?.toString() ?? "0",
  //       "wholesalediscount": model.itemsWholesaleDiscount?.toString() ?? "0",
  //       "retaildiscount": model.itemsRetailDiscount?.toString() ?? "0",
  //       "items_qr": model.itemsQr ?? "",
  //       "items_categories": model.itemsCategories?.toString() ?? "",
  //     };

  //     // align items_date for server
  //     DateTime? localDt = _parseDate(model.itemsDate);
  //     if (localDt != null) {
  //       payload["items_date"] = _formatForServer(
  //         localDt.subtract(serverOffset),
  //       );
  //     } else {
  //       payload["items_date"] = _formatForServer(
  //         DateTime.now().subtract(serverOffset),
  //       );
  //     }

  //     final img = model.itemsImage ?? '';
  //     if (img.isNotEmpty && File(img).existsSync()) {
  //       // multipart add (image upload)
  //       var resp = await itemsData.add(payload, File(img));

  //       var st = handlingData(resp);
  //       if (st == StatusRequest.success && resp['status'] == "success") {
  //         // update local id/image/date if server returned them
  //         try {
  //           if (resp.containsKey('data') && resp['data'] != null) {
  //             final d = resp['data'];
  //             String? newId;
  //             String? newImage;
  //             String? newDate;
  //             if (d is Map) {
  //               newId = d['items_id']?.toString();
  //               newImage = d['items_image']?.toString();
  //               newDate = d['items_date']?.toString();
  //             } else if (d is List && d.isNotEmpty && d[0] is Map) {
  //               final m = d[0] as Map;
  //               newId = m['items_id']?.toString();
  //               newImage = m['items_image']?.toString();
  //               newDate = m['items_date']?.toString();
  //             }
  //             final oldId = model.itemsId?.toString() ?? '';
  //             if (newId != null &&
  //                 newId.isNotEmpty &&
  //                 oldId.isNotEmpty &&
  //                 newId != oldId) {
  //               await sqlDb.update("itemsview", {
  //                 "items_id": int.tryParse(newId) ?? newId,
  //                 if (newImage != null) "items_image": newImage,
  //                 if (newDate != null) "items_date": newDate,
  //               }, "items_id = $oldId");
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print(
  //               "addRemote multipart: could not update local after add: $e",
  //             );
  //           }
  //         }
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     } else {
  //       // use addupgrade (text)
  //       var resp = await itemsData.addupgrade(payload);
  //       var st = handlingData(resp);
  //       if (st == StatusRequest.success && resp['status'] == "success") {
  //         try {
  //           if (resp.containsKey('data') && resp['data'] != null) {
  //             final d = resp['data'];
  //             String? newId;
  //             String? newDate;
  //             if (d is Map && d.containsKey('items_id')) {
  //               newId = d['items_id']?.toString();
  //               newDate = d['items_date']?.toString();
  //             } else if (d is List &&
  //                 d.isNotEmpty &&
  //                 d[0] is Map &&
  //                 d[0].containsKey('items_id')) {
  //               final m = d[0] as Map;
  //               newId = m['items_id']?.toString();
  //               newDate = m['items_date']?.toString();
  //             }
  //             final oldId = model.itemsId?.toString() ?? '';
  //             if (newId != null &&
  //                 newId.isNotEmpty &&
  //                 oldId.isNotEmpty &&
  //                 newId != oldId) {
  //               await sqlDb.update("itemsview", {
  //                 "items_id": int.tryParse(newId) ?? newId,
  //                 if (newDate != null) "items_date": newDate,
  //               }, "items_id = $oldId");
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print(
  //               "addRemote text: could not update local after addupgrade: $e",
  //             );
  //           }
  //         }
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("addRemote exception items_id=${model.itemsId}: $e");
  //     }
  //     return false;
  //   }
  // }

  // ----------------- Core sync for category -----------------
  // Important: we first PUSH local newer items (or local-only) to server,
  // then FETCH server list and apply remote->local updates for items that are newer on server.
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
        // If remote fetch failed, we still may attempt to push local-only items (best-effort)
        // push local-only items:
        // for (var localEntry in localMap.entries) {
        //   final localItem = localEntry.value;
        //   // if no remote id or remote not reachable, try to add (best-effort)
        //   if (localItem.itemsId == null) {
        //     await _addRemote(localItem);
        //   }
        // }
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
          // both exist -> compare dates
          DateTime? dl = _parseDate(localItem.itemsDate);
          DateTime? dr = _parseDate(remoteItem.itemsDate);
          if (dr != null && dl != null) {
            final drAdjusted = dr.add(serverOffset); // server -> client axis
            if (dl.isAfter(drAdjusted)) {
              // local is newer -> update remote using upgrade()
              bool _ = await _updateRemote(localItem);
            }
          }
        }
        //  else {
        //   // local exists but remote missing -> add via addupgrade/add
        //   bool _ = await _addRemote(localItem);
        // }
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
          DateTime? dr = _parseDate(remoteItem.itemsDate);
          DateTime? dl = _parseDate(localItem.itemsDate);
          if (dr != null && dl != null) {
            final drAdjusted = dr.add(serverOffset);
            if (drAdjusted.isAfter(dl)) {
              // remote newer -> update local (convert date to local axis)
              remoteItem.itemsDate = _formatLocal(drAdjusted);
              await _upsertLocal(remoteItem);
            } else {
              // local newer or equal -> already pushed in step 2
            }
          }
        } else if (remoteItem != null && localItem == null) {
          // only remote -> insert locally (convert date)
          DateTime? dr = _parseDate(remoteItem.itemsDate);
          if (dr != null) {
            remoteItem.itemsDate = _formatLocal(dr.add(serverOffset));
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

  // ----------------- Public API -----------------
  getItemsByCategories(int catid, {bool forceRefresh = false}) async {
    if (_lastSubcategoriesId == catid && !forceRefresh) return;
    _lastSubcategoriesId = catid;

    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    // 1) show local immediately (offline-first)
    try {
      final localRows = await _readLocalRows(catid);
      data = localRows.map((e) => ItemsModel.fromJson(e)).toList();
      statusRequest = StatusRequest.success;
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getItemsByCategories read local error: $e");
      }
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    // 2) sync (push local newer first, then merge remote)
    try {
      await upgradeItemsForCategory(catid);
    } catch (e) {
      if (kDebugMode) {
        print("getItemsByCategories upgradeItems failed: $e");
      }
    }

    // 3) reload local after sync
    try {
      final refreshedRows = await _readLocalRows(catid);
      data = refreshedRows.map((e) => ItemsModel.fromJson(e)).toList();
      statusRequest = StatusRequest.success;
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getItemsByCategories final read error: $e");
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
