import 'dart:io';
import 'package:store_house/controller/categories/view_controller.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/core/functions/uploadfile.dart';
import 'package:store_house/data/datasource/remote/categories_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class CategoriesAddController extends GetxController {
  CategoriesData categoriesData = CategoriesData(Get.find());

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;
  StatusRequest? statusRequest = StatusRequest.none;

  File? file;

  chooseImage() async {
    file = await fileUploadGallery();
    update();
  }

  addData() async {
    if (formState.currentState!.validate()) {
      if (file == null) {
        FancySnackbar.show(title: "خطأ", message: "يرجى اختيار صورة");
        return;
      }
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

      Map data = {"name": name.text};

      var response = await categoriesData.add(data, file!);

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
    name = TextEditingController();
    super.onInit();
  }
}
