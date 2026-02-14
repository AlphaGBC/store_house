import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/supplier/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/data/datasource/remote/supplier_data.dart';
import 'package:store_house/routes.dart';

class SupplierAddController extends GetxController {
  SupplierData supplierData = SupplierData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;

  StatusRequest? statusRequest = StatusRequest.none;

  Future<void> addData() async {
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

      var response = await supplierData.add(data);

      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        // Start backend
        if (response['status'] == "success") {
          Get.offNamedUntil(
            AppRoute.supplierView,
            ModalRoute.withName(AppRoute.homepage),
          );
          SupplierViewController c = Get.find();
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
