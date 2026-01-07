import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/shared/categories_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';
import 'package:store_house/core/shared/customlistcategories_shared.dart';

class CategoriesViewShared extends StatelessWidget {
  const CategoriesViewShared({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesControllerImp());
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("اختر القسم الرئيسي")),
      body: GetBuilder<CategoriesControllerImp>(
        builder:
            (controller) => RefreshWrapper(
              onRefresh: () => controller.intialData(),
              child: HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: const CustomlistcategoriesShared(),
              ),
            ),
      ),
    );
  }
}
