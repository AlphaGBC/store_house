import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/items/edit_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/validinput.dart';
import 'package:store_house/core/shared/custom_button.dart';
import 'package:store_house/core/shared/custom_text_form.dart';

class ItemsEdit extends StatelessWidget {
  const ItemsEdit({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ItemsEditController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("تعديل المنتج"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: GetBuilder<ItemsEditController>(
              builder:
                  (ctrl) => HandlingDataView(
                    statusRequest: ctrl.statusRequest!,
                    widget: SingleChildScrollView(
                      child: Form(
                        key: ctrl.formState,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header card — مظهر فخم متناسق مع بقية الصفحات
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
                                        Icons.edit,
                                        color: AppColor.orange,
                                        size: 28,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "تعديل بيانات الصنف",
                                            style: theme.textTheme.titleLarge!
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "حدِّث الاسم، الوصف، الأسعار، والتصنيفات الخاصة بهذا الصنف.",
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                  color: Colors.white70,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 18),
                            customTextForm(
                              context,
                              "إسم الصنف بالعربي",
                              "إسم الصنف بالعربي",
                              Icon(Icons.text_fields),
                              ctrl.name,
                              (val) => validInput(val!, 1, 30, ""),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "الكمية في المستودع",
                                    "عدد العناصر المتاحة",
                                    Icon(Icons.format_list_numbered),
                                    ctrl.storehousecount,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "سعر التكلفة",
                                    "سعر التكلفة",
                                    Icon(Icons.price_check),
                                    ctrl.costprice,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "الكمية في نقطة البيع الاولى",
                                    "عدد العناصر المتاحة",
                                    Icon(Icons.format_list_numbered),
                                    ctrl.pointofsale1count,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "الكمية في نقطة البيع الثانية",
                                    "عدد العناصر المتاحة",
                                    Icon(Icons.format_list_numbered),
                                    ctrl.pointofsale2count,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "سعر الجملة",
                                    "سعر الجملة",
                                    Icon(Icons.price_check),
                                    ctrl.wholesaleprice,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: customTextForm(
                                    context,
                                    "سعر المفرق",
                                    "سعر المفرق",
                                    Icon(Icons.price_check),
                                    ctrl.retailprice,
                                    (val) => validInput(val!, 1, 30, ""),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            customTextForm(
                              context,
                              "الحسم للجملة (%)",
                              "الحسم بالنسبة المئوية لسعر الجملة",
                              Icon(Icons.local_offer),
                              ctrl.wholesalediscount,
                              (val) => validInput(val!, 1, 30, ""),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 14),
                            customTextForm(
                              context,
                              "الحسم للمفرق (%)",
                              "الحسم بالنسبة المئوية لسعر المفرق",
                              Icon(Icons.local_offer),
                              ctrl.retaildiscount,
                              (val) => validInput(val!, 1, 30, ""),
                              keyboardType: TextInputType.number,
                            ),

                            SizedBox(height: 14),

                            // زر الحفظ
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: customButton(
                                context,
                                h: 52,
                                title: "تعديل الصنف",
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  ctrl.editData();
                                },

                                buttoncolor: AppColor.primaryColor,
                              ),
                            ),

                            SizedBox(height: 12),
                          ],
                        ),
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
