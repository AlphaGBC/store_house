import 'package:flutter/foundation.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/sqflite.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/categories_data.dart';
import 'package:store_house/data/model/categoriesmodel.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class CategoriesViewController extends GetxController {
  CategoriesData categoriesData = CategoriesData(Get.find());

  List<CategoriesModel> data = [];

  late StatusRequest statusRequest;

  SqlDb sqlDb = SqlDb();

  final Duration serverOffset = Duration(hours: 3);

  // ----------------- Helpers -----------------

  DateTime? _parseDate(String? s) {
    if (s == null) return null;
    try {
      String t = s.replaceFirst(' ', 'T');
      return DateTime.parse(t);
    } catch (e) {
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

  Future<Map<String, CategoriesModel>> _localMap() async {
    final m = <String, CategoriesModel>{};
    try {
      List rows = await sqlDb.read("categories");
      for (var r in rows) {
        final map = Map<String, dynamic>.from(r);
        final model = CategoriesModel.fromJson(map);
        final id = model.categoriesId?.toString() ?? '';
        if (id.isNotEmpty) m[id] = model;
      }
    } catch (e) {
      if (kDebugMode) {
        print("localMap error: $e");
      }
    }
    return m;
  }

  Map<String, CategoriesModel> _remoteMapFromRaw(List remoteRaw) {
    final m = <String, CategoriesModel>{};
    try {
      for (var r in remoteRaw) {
        final model = CategoriesModel.fromJson(Map<String, dynamic>.from(r));
        final id = model.categoriesId?.toString() ?? '';
        if (id.isNotEmpty) m[id] = model;
      }
    } catch (e) {
      if (kDebugMode) {
        print("remoteMapFromRaw error: $e");
      }
    }
    return m;
  }

  DateTime? _maxDateFromList(List<CategoriesModel> list) {
    DateTime? max;
    for (var it in list) {
      final d = _parseDate(it.categoriesDate);
      if (d == null) continue;
      if (max == null || d.isAfter(max)) max = d;
    }
    return max;
  }

  // ----------------- Local upsert -----------------

  Future<void> _upsertLocal(CategoriesModel model) async {
    try {
      List rows = await sqlDb.read("categories");
      final idStr = model.categoriesId?.toString() ?? '';
      bool exists = rows.any((r) {
        final id = (r['categories_id'] ?? '').toString();
        return id == idStr;
      });

      final values = {
        "categories_id": model.categoriesId,
        "categories_name": model.categoriesName,
        "categories_image": model.categoriesImage,
        "categories_date": model.categoriesDate,
      };

      if (exists) {
        await sqlDb.update("categories", values, "categories_id = $idStr");
      } else {
        await sqlDb.insert("categories", values);
      }
    } catch (e) {
      if (kDebugMode) {
        print("upsertLocal error for id=${model.categoriesId}: $e");
      }
    }
  }

  // ----------------- Remote ops -----------------

  // Update remote (upgrade) sending server-aligned date
  Future<bool> _updateRemote(CategoriesModel model) async {
    try {
      Map payload = {
        "categories_id": model.categoriesId?.toString() ?? "",
        "categories_name": model.categoriesName ?? "",
        "categories_image":
            model.categoriesImage ??
            model.categoriesImage ??
            model.categoriesImage,
      };

      // align date to server
      DateTime? localDt = _parseDate(model.categoriesDate);
      if (localDt != null) {
        payload["categories_date"] = _formatForServer(
          localDt.subtract(serverOffset),
        );
      } else {
        payload["categories_date"] = _formatForServer(
          DateTime.now().subtract(serverOffset),
        );
      }

      var resp = await categoriesData.upgrade(payload);
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("updateRemote exception for id=${model.categoriesId}: $e");
      }
      return false;
    }
  }

  // // Add remote: if categories_image points to local file path -> upload file
  // Future<bool> _addRemote(CategoriesModel model) async {
  //   try {
  //     Map payload = {"categories_name": model.categoriesName ?? ""};

  //     // align categories_date to server
  //     DateTime? localDt = _parseDate(model.categoriesDate);
  //     if (localDt != null) {
  //       payload["categories_date"] = _formatForServer(
  //         localDt.subtract(serverOffset),
  //       );
  //     } else {
  //       payload["categories_date"] = _formatForServer(
  //         DateTime.now().subtract(serverOffset),
  //       );
  //     }

  //     // If image is a local file path -> upload file; else call addupgrade (API expecting name/image string)
  //     final img = model.categoriesImage ?? '';
  //     if (img.isNotEmpty && File(img).existsSync()) {
  //       // attempt multipart add(file)
  //       var resp = await categoriesData.add(payload, File(img));
  //       var st = handlingData(resp);
  //       if (st == StatusRequest.success && resp['status'] == "success") {
  //         // if server returned id, update local
  //         try {
  //           if (resp.containsKey('data') && resp['data'] != null) {
  //             final d = resp['data'];
  //             String? newId;
  //             String? newImage;
  //             String? newDate;
  //             if (d is Map) {
  //               newId = d['categories_id']?.toString();
  //               newImage = d['categories_image']?.toString();
  //               newDate = d['categories_date']?.toString();
  //             } else if (d is List && d.isNotEmpty && d[0] is Map) {
  //               final m = d[0] as Map;
  //               newId = m['categories_id']?.toString();
  //               newImage = m['categories_image']?.toString();
  //               newDate = m['categories_date']?.toString();
  //             }
  //             final oldId = model.categoriesId?.toString() ?? '';
  //             if (newId != null &&
  //                 newId.isNotEmpty &&
  //                 oldId.isNotEmpty &&
  //                 newId != oldId) {
  //               await sqlDb.update("categories", {
  //                 "categories_id": int.tryParse(newId) ?? newId,
  //                 if (newImage != null) "categories_image": newImage,
  //                 if (newDate != null) "categories_date": newDate,
  //               }, "categories_id = $oldId");
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print(
  //               "addRemote: could not update local after multipart add: $e",
  //             );
  //           }
  //         }

  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //      else {
  //       // no local file - use text endpoint
  //       var resp = await categoriesData.addupgrade(payload);
  //       var st = handlingData(resp);
  //       if (st == StatusRequest.success && resp['status'] == "success") {
  //         // update local id if server returned one
  //         try {
  //           if (resp.containsKey('data') && resp['data'] != null) {
  //             final d = resp['data'];
  //             String? newId;
  //             if (d is Map && d.containsKey('categories_id')) {
  //               newId = d['categories_id']?.toString();
  //             } else if (d is List &&
  //                 d.isNotEmpty &&
  //                 d[0] is Map &&
  //                 d[0].containsKey('categories_id')) {
  //               newId = d[0]['categories_id']?.toString();
  //             }
  //             final oldId = model.categoriesId?.toString() ?? '';
  //             if (newId != null &&
  //                 newId.isNotEmpty &&
  //                 oldId.isNotEmpty &&
  //                 newId != oldId) {
  //               await sqlDb.update("categories", {
  //                 "categories_id": int.tryParse(newId) ?? newId,
  //               }, "categories_id = $oldId");
  //             }
  //           }
  //         } catch (e) {
  //           if (kDebugMode) {
  //             print("addRemote: could not update local after addupgrade: $e");
  //           }
  //         }
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("addRemote exception for id=${model.categoriesId}: $e");
  //     }
  //     return false;
  //   }
  // }

  // ----------------- Core sync logic -----------------
  // Two-phase: quick checks by count/max-date (for diagnostic/logging), then element-level resolution.
  Future<void> upgradeData() async {
    try {
      var remoteResponse = await categoriesData.view();
      var stRemote = handlingData(remoteResponse);
      if (stRemote != StatusRequest.success ||
          remoteResponse['status'] != "success") {
        return;
      }

      List remoteRaw = remoteResponse['data'] ?? [];
      List<CategoriesModel> remoteList =
          remoteRaw
              .map<CategoriesModel>(
                (e) => CategoriesModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();

      final remoteMap = _remoteMapFromRaw(remoteRaw);
      final localMap = await _localMap();

      // quick diagnostics
      final _ = remoteList.length;
      final _ = localMap.length;
      final _ = _maxDateFromList(remoteList);
      final _ = _maxDateFromList(localMap.values.toList());

      // element-level resolution (covers additions & updates both sides)
      final allIds =
          <String>{}
            ..addAll(remoteMap.keys)
            ..addAll(localMap.keys);

      for (var id in allIds) {
        final remoteItem = remoteMap[id];
        final localItem = localMap[id];

        if (remoteItem != null && localItem != null) {
          // both sides exist -> compare by date (align remote to client axis)
          DateTime? dr = _parseDate(remoteItem.categoriesDate);
          DateTime? dl = _parseDate(localItem.categoriesDate);

          if (dr != null && dl != null) {
            final drAdjusted = dr.add(serverOffset); // remote -> client axis
            if (drAdjusted.isAfter(dl)) {
              // remote is newer -> update local

              await _upsertLocal(remoteItem);
            } else if (dl.isAfter(drAdjusted)) {
              bool _ = await _updateRemote(localItem);
            } else {
              // equal -> nothing
            }
          }
        } else if (remoteItem != null && localItem == null) {
          await _upsertLocal(remoteItem);
        }
        // else if (remoteItem == null && localItem != null) {
        //   // only on local -> upload to remote
        //   bool _ = await _addRemote(localItem);
        // }
      }
    } catch (e) {
      if (kDebugMode) {
        print("upgradeData exception: $e");
      }
    }
  }

  // ----------------- getData flow: show local then sync then refresh local -----------------

  Future<void> getData() async {
    // 1) show local immediately (offline first)
    statusRequest = StatusRequest.loading;
    update();

    try {
      List localRows = await sqlDb.read("categories");
      data.clear();
      data.addAll(
        localRows.map<CategoriesModel>(
          (e) => CategoriesModel.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      statusRequest = StatusRequest.success;
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getData - read local error: $e");
      }
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    // 2) try to sync (element-level) with remote
    try {
      await upgradeData();
    } catch (e) {
      if (kDebugMode) {
        print("getData - upgradeData failed: $e");
      }
    }

    // 3) refresh local view after sync
    try {
      List finalLocalRows = await sqlDb.read("categories");
      data.clear();
      data.addAll(
        finalLocalRows.map<CategoriesModel>(
          (e) => CategoriesModel.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      statusRequest = StatusRequest.success;
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getData - final reload error: $e");
      }
    }
  }

  // ----------------- deleteCategory (kept but be careful: deletion is shared) -----------------

  deleteCategory(String id, String imagename) async {
    if (!await checkInternet()) {
      FancySnackbar.show(
        title: "خطأ",
        message: "لا يوجد اتصال بالانترنت",
        isError: true,
      );
      return;
    }
    try {
      var resp = await categoriesData.delete({
        "id": id,
        "imagename": imagename,
      });
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        // remove locally as well
        await sqlDb.delete("categories", "categories_id = $id");
        data.removeWhere((element) => element.categoriesId.toString() == id);
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("deleteCategory exception: $e");
      }
    }
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  goToPageEdit(CategoriesModel categoriesModel) {
    Get.toNamed(
      AppRoute.categoriesEdit,
      arguments: {"CategoriesModel": categoriesModel},
    );
  }

  back() {
    return Future.value(false);
  }
}
