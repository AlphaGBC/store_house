import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/categories/add_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/validinput.dart';
import 'package:store_house/core/shared/custom_button.dart';
import 'package:store_house/core/shared/custom_text_form.dart';
import 'package:store_house/core/util/text_styles.dart';

class CategoriesAdd extends StatelessWidget {
  const CategoriesAdd({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesAddController());
    return Scaffold(
      appBar: AppBar(title: Text("إضافة قسم"), centerTitle: true, elevation: 2),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: GetBuilder<CategoriesAddController>(
            builder:
                (controller) => HandlingDataView(
                  statusRequest: controller.statusRequest!,
                  widget: SingleChildScrollView(
                    child: Form(
                      key: controller.formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header فخم
                          Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColor.orange.withValues(alpha: 0.95),
                                    AppColor.primaryColor.withValues(
                                      alpha: 0.78,
                                    ),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white24,
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.category,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "أضف قسمًا جديدًا",
                                          style: font10White700W(context),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "أدخل اسم القسم بالعربي والإنكليزي واختر صورة مميزة للقسم.",
                                          style: font10White500W(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 18),

                          // حقل اسم القسم بالعربي
                          customTextForm(
                            context,
                            "إسم القسم بالعربي",
                            "إسم القسم بالعربي",
                            Icon(Icons.text_fields),
                            controller.name,
                            (val) {
                              return validInput(val!, 1, 30, "");
                            },
                          ),

                          SizedBox(height: 18),

                          // منطقة اختيار الصورة الكبيرة (متطابقة تقريبًا مع AdsAdd)
                          GestureDetector(
                            onTap: () => controller.chooseImage(),
                            child: Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                gradient:
                                    controller.file == null
                                        ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.grey.shade50,
                                            Colors.grey.shade100,
                                          ],
                                        )
                                        : null,
                              ),
                              child: Center(
                                child:
                                    controller.file == null
                                        ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.orange,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.photo_library,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "إختر صورة القسم",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "اضغط هنا لاختيار صورة من الجهاز",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                        : Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: Image.file(
                                                File(controller.file!.path),
                                                width: double.infinity,
                                                height: 160,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            // زر إزالة دائري فوق الصورة
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  controller.file = null;
                                                  controller.update();
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.12,
                                                            ),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.redAccent,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12),

                          // عرض اسم الملف وحجمه إن وُجد
                          if (controller.file != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.file_present_outlined,
                                    size: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.file!.path.split('/').last,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "${(File(controller.file!.path).lengthSync() / 1024).round()} KB",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 18),

                          // زر اختيار الصورة (بديل) وزر إضافة القسم
                          customButton(
                            context,

                            buttoncolor: AppColor.primaryColor,
                            h: 50,
                            title: "إضافة القسم",
                            onPressed: () {
                              controller.addData();
                            },
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
