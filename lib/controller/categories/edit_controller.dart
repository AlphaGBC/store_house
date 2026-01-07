import 'package:flutter/foundation.dart';
import 'package:store_house/sqflite.dart';
import 'package:store_house/controller/categories/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/categories_data.dart';
import 'package:store_house/data/model/categoriesmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class CategoriesEditController extends GetxController {
  CategoriesData categoriesData = CategoriesData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;
  CategoriesModel? categoriesModel;

  StatusRequest? statusRequest = StatusRequest.none;

  // use existing SqlDb instance to update local DB
  SqlDb sqlDb = SqlDb();

  // Server offset: server is 3 hours behind client
  final Duration serverOffset = Duration(hours: 3);

  @override
  void onInit() {
    categoriesModel = Get.arguments['CategoriesModel'];
    name = TextEditingController();
    name.text = categoriesModel!.categoriesName ?? '';
    super.onInit();
  }

  // helper: format DateTime to "YYYY-MM-DD HH:MM:SS"
  String _formatForServer(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}";
  }

  // update local sqlite entry immediately
  Future<void> _updateLocal(String id, String newName) async {
    try {
      String nowStr =
          DateTime.now()
              .toString(); // keep as ISO-like in local; other parts of app parse it
      // update local DB: set name and update categories_date to now (local time)
      await sqlDb.update("categories", {
        "categories_name": newName,
        "categories_date": nowStr,
      }, "categories_id = $id");
    } catch (e) {
      if (kDebugMode) {
        print("Local update error for id=$id => $e");
      }
    }
  }

  // send the update to remote (with server-aligned date)
  Future<bool> _sendUpdateToRemote(String id, String newName) async {
    try {
      // build payload — align categories_date to server time (subtract offset)
      DateTime localNow = DateTime.now();
      DateTime serverAligned = localNow.subtract(serverOffset);
      String serverDateStr = _formatForServer(serverAligned);

      Map payload = {
        "id":
            id, // if your server expects "id" (original code used "id"), else use "categories_id"
        // include other fields names expected by your API:
        "name": newName,
        "categories_date": serverDateStr,
      };

      // call upgrade (update) endpoint
      var response = await categoriesData.edit(payload);
      var st = handlingData(response);
      if (st == StatusRequest.success && response['status'] == "success") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Remote update exception for id=$id => $e");
      }
      return false;
    }
  }

  editData() async {
    if (!formState.currentState!.validate()) return;

    statusRequest = StatusRequest.loading;
    update();

    final id = categoriesModel?.categoriesId?.toString() ?? '';
    final newName = name.text.trim();

    if (id.isEmpty) {
      // if no id, bail out — should not happen for edit
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    // 1) update local DB immediately so offline changes are applied
    await _updateLocal(id, newName);

    // 2) try to send update to remote
    bool remoteOk = await _sendUpdateToRemote(id, newName);

    // 3) react based on remote result
    if (remoteOk) {
      // success on server: go back and refresh the categories view
      statusRequest = StatusRequest.success;
      update();

      // navigate back to categories view and refresh
      Get.offNamedUntil(
        AppRoute.categoriesView,
        ModalRoute.withName(AppRoute.homepage),
      );

      // refresh the categories listing (will read from local DB and also try sync)
      try {
        CategoriesViewController c = Get.find();
        c.getData();
      } catch (e) {
        if (kDebugMode) {
          print("Could not find CategoriesViewController to refresh: $e");
        }
      }
    } else {
      // failed to update remote (likely offline) — keep local changes and notify the user.
      // The sync mechanism (upgradeData) will pick up and push this local newer record when online.
      statusRequest = StatusRequest.success; // operation succeeded locally
      update();

      // Navigate back but show a notification to user (optional)
      Get.offNamedUntil(
        AppRoute.categoriesView,
        ModalRoute.withName(AppRoute.homepage),
      );

      // try to refresh listing so user sees local change
      try {
        CategoriesViewController c = Get.find();
        c.getData();
      } catch (e) {
        if (kDebugMode) {
          print("Could not find CategoriesViewController to refresh: $e");
        }
      }
    }
  }

  // navigation hooks
  goBack() {
    Get.back();
  }

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }
}
