import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/wholesale/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/wholesale_data.dart';
import 'package:store_house/routes.dart';

class WholesaleAddController extends GetxController {
  WholesaleData wholesaleData = WholesaleData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;

  StatusRequest? statusRequest = StatusRequest.none;

  addData() async {
    if (formState.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      if (!await checkInternet()) {
        FancySnackbar.show(
          title: "خطأ",
          message: "لا يوجد اتصال بالانترنت",
          isError: true,
        );
        return;
      }
      update();
      Map data = {"name": name.text};

      var response = await wholesaleData.add(data);

      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        // Start backend
        if (response['status'] == "success") {
          Get.offNamedUntil(
            AppRoute.wholesaleView,
            ModalRoute.withName(AppRoute.homepage),
          );
          WholesaleViewController c = Get.find();
          c.getData();
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
    name = TextEditingController();
    super.onInit();
  }
}
