import 'package:store_house/controller/categories/edit_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/validinput.dart';
import 'package:store_house/core/shared/custom_button.dart';
import 'package:store_house/core/shared/custom_text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesEdit extends StatelessWidget {
  const CategoriesEdit({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesEditController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("تعديل القسم"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GetBuilder<CategoriesEditController>(
          builder:
              (ctrl) => HandlingDataView(
                statusRequest: ctrl.statusRequest!,
                widget: SingleChildScrollView(
                  child: Form(
                    key: ctrl.formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColor.orange,
                                  AppColor.primaryColor,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.category,
                                    color: AppColor.orange,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "تعديل القسم",
                                        style: theme.textTheme.titleLarge!
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "حدّث اسم الصورة أو استبدل الصورة الحالية.",
                                        style: theme.textTheme.bodyMedium!
                                            .copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 18),

                        // الحقول النصية
                        customTextForm(
                          context,
                          "إسم القسم بالعربي",
                          "أدخل اسم القسم بالعربي",
                          Icon(Icons.language),
                          ctrl.name,
                          (val) {
                            return validInput(val!, 1, 30, "");
                          },
                        ),

                        SizedBox(height: 18),

                        customButton(
                          context,
                          h: 50,
                          title: "تعديل القسم",
                          onPressed: () {
                            ctrl.editData();
                          },
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
