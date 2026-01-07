import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/items/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/items_data.dart';
import 'package:store_house/view/widget/scan_qr_page.dart';

class ItemsAddController extends GetxController {
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
  late TextEditingController itemsQr;

  int? catid;

  StatusRequest? statusRequest = StatusRequest.none;

  void openQrScanner() async {
    // نستخدم Get.to للانتقال لشاشة المسح ثم نسترجع النتيجة
    final result = await Get.to(() => ScanQrPage());
    if (result != null && result is String && result.isNotEmpty) {
      itemsQr.text = result;
      update(); // لتحديث واجهة المستخدم
    }
  }

  addData() async {
    if (formState.currentState!.validate()) {
      if (!await checkInternet()) {
        FancySnackbar.show(
          title: "خطأ",
          message: "لا يوجد اتصال بالانترنت",
          isError: true,
        );
        return;
      }

      statusRequest = StatusRequest.loading;
      update();
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
        "items_categories": catid!.toString(),
        "itemsqr": itemsQr.text,
      };
      var response = await itemsData.add(data);
      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        // Start backend
        if (response['status'] == "success") {
          Get.back();
          ItemsControllerImp c = Get.find();
          c.getItemsByCategories(catid!, forceRefresh: true);
        } else {
          FancySnackbar.show(
            title: "خطأ",
            message: "لا يوجد اتصال بالانترنت",
            isError: true,
          );
        }
        // End
      }
      update();
    }
  }

  @override
  void onInit() {
    catid = int.parse(Get.arguments['catid']);
    name = TextEditingController();
    storehousecount = TextEditingController();
    pointofsale1count = TextEditingController();
    pointofsale2count = TextEditingController();
    costprice = TextEditingController();
    wholesaleprice = TextEditingController();
    retailprice = TextEditingController();
    wholesalediscount = TextEditingController();
    retaildiscount = TextEditingController();
    itemsQr = TextEditingController();
    super.onInit();
  }
}
