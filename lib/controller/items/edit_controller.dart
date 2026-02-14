import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/Sqflite.dart';
import 'package:store_house/controller/items/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/items_data.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/routes.dart';

class ItemsEditController extends GetxController {
  ItemsData itemsData = ItemsData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController storehousecount;
  late TextEditingController pointofsale1count;
  late TextEditingController pointofsale2count;
  late TextEditingController costprice;
  late TextEditingController wholesaleprice;
  late TextEditingController retailprice;
  late TextEditingController wholesalediscount;
  late TextEditingController retaildiscount;

  int? catid;

  ItemsModel? itemsModel;

  StatusRequest? statusRequest = StatusRequest.none;

  SqlDb sqlDb = SqlDb();

  final Duration serverOffset = Duration(hours: 3);

  @override
  void onInit() {
    itemsModel = Get.arguments['ItemsModel'];
    catid = Get.arguments['catid'];
    name = TextEditingController();
    storehousecount = TextEditingController();
    pointofsale1count = TextEditingController();
    pointofsale2count = TextEditingController();
    costprice = TextEditingController();
    wholesaleprice = TextEditingController();
    retailprice = TextEditingController();
    wholesalediscount = TextEditingController();
    retaildiscount = TextEditingController();

    name.text = itemsModel!.itemsName ?? '';
    storehousecount.text = (itemsModel!.itemsStorehouseCount ?? 0).toString();
    pointofsale1count.text =
        (itemsModel!.itemsPointofsale1Count ?? 0).toString();
    pointofsale2count.text =
        (itemsModel!.itemsPointofsale2Count ?? 0).toString();
    costprice.text = itemsModel!.itemsCostPrice?.toString() ?? '0';
    wholesaleprice.text = itemsModel!.itemsWholesalePrice?.toString() ?? '0';
    retailprice.text = itemsModel!.itemsRetailPrice?.toString() ?? '0';
    wholesalediscount.text =
        itemsModel!.itemsWholesaleDiscount?.toString() ?? '0';
    retaildiscount.text = itemsModel!.itemsRetailDiscount?.toString() ?? '0';
    super.onInit();
  }

  // helper: format DateTime to "YYYY-MM-DD HH:MM:SS"
  String _formatForServer(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}";
  }

  // update local immediately using the exact columns (items_storehouse_count, etc.)
  Future<void> _updateLocal() async {
    try {
      final id = itemsModel!.itemsId;
      if (id == null) return;
      String nowStr = DateTime.now().toString();

      await sqlDb.update("itemsview", {
        "items_name": name.text.trim(),
        "items_storehouse_count": int.tryParse(storehousecount.text) ?? 0,
        "items_pointofsale1_count": int.tryParse(pointofsale1count.text) ?? 0,
        "items_pointofsale2_count": int.tryParse(pointofsale2count.text) ?? 0,
        "items_cost_price": double.tryParse(costprice.text) ?? 0,
        "items_wholesale_price": double.tryParse(wholesaleprice.text) ?? 0,
        "items_retail_price": double.tryParse(retailprice.text) ?? 0,
        "items_wholesale_discount":
            double.tryParse(wholesalediscount.text) ?? 0,
        "items_retail_discount": double.tryParse(retaildiscount.text) ?? 0,
        // store local timestamp (local time)
        "items_date": nowStr,
      }, "items_id = $id");
    } catch (e) {
      if (kDebugMode) {
        print("Local update error items: $e");
      }
    }
  }

  // send edit payload to server using edit/upgrade endpoint
  Future<bool> _sendUpdateToServer() async {
    try {
      final id = itemsModel!.itemsId;
      if (id == null) return false;

      // convert local time -> server time by subtracting serverOffset
      DateTime localNow = DateTime.now();
      DateTime serverAligned = localNow.subtract(serverOffset);
      String serverDateStr = _formatForServer(serverAligned);

      Map data = {
        "name": name.text,
        "storehousecount": storehousecount.text,
        "pointofsale1count": pointofsale1count.text,
        "pointofsale2count": pointofsale2count.text,
        "costprice": costprice.text,
        "wholesaleprice": wholesaleprice.text,
        "retailprice": retailprice.text,
        "wholesalediscount": wholesalediscount.text,
        "retaildiscount": retaildiscount.text,
        // send server-aligned items_date
        "items_date": serverDateStr,
        "items_id": itemsModel!.itemsId!.toString(),
      };

      var response = await itemsData.edit(data);
      var st = handlingData(response);
      if (st == StatusRequest.success && response['status'] == "success") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("sendUpdateToServer exception items: $e");
      }
      return false;
    }
  }

  editData() async {
    if (!formState.currentState!.validate()) return;

    statusRequest = StatusRequest.loading;
    update();

    // 1) update local immediately
    await _updateLocal();

    // 2) try to send to server using edit(...)
    bool ok = await _sendUpdateToServer();

    // 3) refresh UI and list
    statusRequest = StatusRequest.success;
    update();

    // Get.back();
    Get.offAllNamed(AppRoute.homepage);
    ItemsControllerImp c = Get.find();
    if (catid != null) {
      c.getItemsByCategories(catid!);
    }

    if (!ok) {
      Get.snackbar(
        'حفظ محلي',
        'تم حفظ التعديل محلياً وسيتم رفعه للسيرفر عند توفر الشبكة.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
