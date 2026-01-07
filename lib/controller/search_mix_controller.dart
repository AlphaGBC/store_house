import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/routes.dart';
import 'package:store_house/sqflite.dart';

class SearchMixController extends GetxController {
  List<ItemsModel> listItems = [];
  StatusRequest statusRequest = StatusRequest.none;

  // sqlite instance
  final SqlDb sqlDb = SqlDb();

  // Search now queries local DB (itemsview) only
  searchData() async {
    final q = search.text.trim();
    if (q.isEmpty) {
      listItems.clear();
      statusRequest = StatusRequest.none;
      update();
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      final db = await sqlDb.db;
      final res = await db!.rawQuery(
        "SELECT * FROM itemsview WHERE items_name LIKE ? COLLATE NOCASE",
        ['%$q%'],
      );

      listItems.clear();
      if (res.isNotEmpty) {
        listItems.addAll(
          res
              .map((e) => ItemsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
        statusRequest = StatusRequest.success;
      } else {
        statusRequest = StatusRequest.failure;
      }
    } catch (e) {
      if (kDebugMode) {
        print("searchData local exception: $e");
      }
      statusRequest = StatusRequest.failure;
    }

    update();
  }

  bool isSearch = false;
  late TextEditingController search;

  checkSearch(val) {
    if (val == "") {
      statusRequest = StatusRequest.none;
      isSearch = false;
      listItems.clear();
    }
    update();
  }

  void clearSearch() {
    search.clear();
    statusRequest = StatusRequest.none;
    isSearch = false;
    listItems.clear();
    update();
  }

  onSearch() {
    isSearch = true;
    searchData();
    update();
  }

  goToPageEdit(ItemsModel itemsModel, int? catid) {
    Get.toNamed(
      AppRoute.itemsedit,
      arguments: {"ItemsModel": itemsModel, "catid": catid},
    );
  }

  @override
  void onInit() {
    update();
    search = TextEditingController();
    super.onInit();
  }
}
