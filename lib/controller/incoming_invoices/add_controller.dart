import 'package:store_house/controller/categories/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/data/datasource/remote/incoming_invoices_data.dart';
import 'package:store_house/routes.dart';
import 'package:store_house/sqflite.dart';

class IncomingInvoicesAddController extends GetxController {
  final SqlDb sqlDb = SqlDb();
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  StatusRequest statusRequest = StatusRequest.none;

  Future<void> addData() async {
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

      Map data = {};

      var response = await incomingInvoicesData.add(data);

      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        // Start backend
        if (response['status'] == "success") {
          Get.offNamedUntil(
            AppRoute.categoriesView,
            ModalRoute.withName(AppRoute.homepage),
          );
          CategoriesViewController c = Get.find();
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
    super.onInit();
  }
}
