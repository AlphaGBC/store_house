import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/usd/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/usd_data.dart';

class UsdEditController extends GetxController {
  UsdData usdData = UsdData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController price;

  StatusRequest? statusRequest = StatusRequest.none;

  editData() async {
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
      Map data = {"price": price.text};

      var response = await usdData.edit(data);

      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        // Start backend
        if (response['status'] == "success") {
          Get.back();
          UsdControllerImp c = Get.find();
          c.getprice();
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
    price = TextEditingController();
    price.text = Get.arguments['price'];
    super.onInit();
  }
}
