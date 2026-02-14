import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/supplier_data.dart';
import 'package:store_house/data/model/supplier_model.dart';
import 'package:store_house/sqflite.dart';

class SupplierViewController extends GetxController {
  SupplierData supplierData = SupplierData(Get.find());

  List<SupplierModel> data = [];

  SqlDb sqlDb = SqlDb();

  late StatusRequest statusRequest;

  // قراءة الصفوف المحلية
  Future<List<Map<String, dynamic>>> _readLocalRows() async {
    try {
      final rows = await sqlDb.read("supplier");
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      if (kDebugMode) {
        print("readLocalRows supplier error: $e");
      }
      return [];
    }
  }

  // upsert محلي (إدراج أو تحديث)
  Future<void> _upsertLocal(SupplierModel model) async {
    try {
      List<Map<String, dynamic>> rows = await _readLocalRows();
      final idStr = model.supplierId?.toString() ?? '';
      final exists = rows.any(
        (r) => (r['supplier_id'] ?? '').toString() == idStr,
      );

      final values = {
        "supplier_id": model.supplierId,
        "supplier_name": model.supplierName,
        "supplier_date": model.supplierDate,
      };

      if (exists) {
        await sqlDb.update("supplier", values, "supplier_id = $idStr");
        // print("Local updated wholesale id=$idStr");
      } else {
        await sqlDb.insert("supplier", values);
        // print("Local inserted wholesale id=$idStr");
      }
    } catch (e) {
      if (kDebugMode) {
        print("upsertLocal wholesale error for id=${model.supplierId}: $e");
      }
    }
  }

  // جلب البيانات: عرض محلي أولاً ثم مزامنة من السيرفر وحفظ محليًا
  Future<void> getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    // 1) عرض المحلي أولًا (offline-first)
    try {
      final localRows = await _readLocalRows();
      data =
          localRows
              .map((e) => SupplierModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
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

    // 2) محاولة جلب البيانات من السيرفر وحفظها محليًا
    try {
      var response = await supplierData.view();
      var st = handlingData(response);

      if (st == StatusRequest.success && response['status'] == "success") {
        List datalist = response["data"];
        // احفظ/حدّث كل سجل محليًا
        for (var item in datalist) {
          try {
            final model = SupplierModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            await _upsertLocal(model);
          } catch (e) {
            if (kDebugMode) {
              print("getData - error upserting wholesale item: $e");
            }
          }
        }

        // 3) أعد تحميل المحلي بعد المزامنة لعرض أحدث البيانات
        final finalLocalRows = await _readLocalRows();
        data =
            finalLocalRows
                .map(
                  (e) => SupplierModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
        statusRequest = StatusRequest.success;
        update();
      } else {
        // لم تنجح الاستجابة من السيرفر؛ نترك البيانات المحلية كما هي
      }
    } catch (e) {
      if (kDebugMode) {
        print("getData - remote fetch exception: $e");
      }
    }
  }

  // حذف: احذف على السيرفر أولاً ثم محليًا فقط عند النجاح
  Future<void> delete(String id) async {
    if (!await checkInternet()) {
      FancySnackbar.show(
        title: "خطأ",
        message: "لا يوجد اتصال بالانترنت",
        isError: true,
      );
      return;
    }
    try {
      var resp = await supplierData.delete({"id": id});
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        // حذف محلي
        await sqlDb.delete("supplier", "supplier_id = $id");
        data.removeWhere((element) => element.supplierId.toString() == id);
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("delete supplier exception: $e");
      }
    }
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
