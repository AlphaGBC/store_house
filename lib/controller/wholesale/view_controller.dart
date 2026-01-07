import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/wholesale_data.dart';
import 'package:store_house/data/model/wholesale_model.dart';
import 'package:store_house/sqflite.dart';

class WholesaleViewController extends GetxController {
  WholesaleData wholesaleData = WholesaleData(Get.find());

  List<WholesaleModel> data = [];

  SqlDb sqlDb = SqlDb();

  late StatusRequest statusRequest;

  // قراءة الصفوف المحلية
  Future<List<Map<String, dynamic>>> _readLocalRows() async {
    try {
      final rows = await sqlDb.read("wholesale_customers");
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      if (kDebugMode) {
        print("readLocalRows wholesale error: $e");
      }
      return [];
    }
  }

  // upsert محلي (إدراج أو تحديث)
  Future<void> _upsertLocal(WholesaleModel model) async {
    try {
      List<Map<String, dynamic>> rows = await _readLocalRows();
      final idStr = model.wholesaleCustomersId?.toString() ?? '';
      final exists = rows.any(
        (r) => (r['wholesale_customers_id'] ?? '').toString() == idStr,
      );

      final values = {
        "wholesale_customers_id": model.wholesaleCustomersId,
        "wholesale_customers_name": model.wholesaleCustomersName,
        "wholesale_customers_date": model.wholesaleCustomersDate,
      };

      if (exists) {
        await sqlDb.update(
          "wholesale_customers",
          values,
          "wholesale_customers_id = $idStr",
        );
        // print("Local updated wholesale id=$idStr");
      } else {
        await sqlDb.insert("wholesale_customers", values);
        // print("Local inserted wholesale id=$idStr");
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          "upsertLocal wholesale error for id=${model.wholesaleCustomersId}: $e",
        );
      }
    }
  }

  // جلب البيانات: عرض محلي أولاً ثم مزامنة من السيرفر وحفظ محليًا
  getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    // 1) عرض المحلي أولًا (offline-first)
    try {
      final localRows = await _readLocalRows();
      data =
          localRows
              .map((e) => WholesaleModel.fromJson(Map<String, dynamic>.from(e)))
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
      var response = await wholesaleData.view();
      var st = handlingData(response);

      if (st == StatusRequest.success && response['status'] == "success") {
        List datalist = response["data"];
        // احفظ/حدّث كل سجل محليًا
        for (var item in datalist) {
          try {
            final model = WholesaleModel.fromJson(
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
                  (e) => WholesaleModel.fromJson(Map<String, dynamic>.from(e)),
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
  delete(String id) async {
    if (!await checkInternet()) {
      FancySnackbar.show(
        title: "خطأ",
        message: "لا يوجد اتصال بالانترنت",
        isError: true,
      );
      return;
    }
    try {
      var resp = await wholesaleData.delete({"id": id});
      var st = handlingData(resp);
      if (st == StatusRequest.success && resp['status'] == "success") {
        // حذف محلي
        await sqlDb.delete(
          "wholesale_customers",
          "wholesale_customers_id = $id",
        );
        data.removeWhere(
          (element) => element.wholesaleCustomersId.toString() == id,
        );
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("delete wholesale exception: $e");
      }
    }
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
