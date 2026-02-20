import 'package:store_house/controller/supplier/view_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/show_error_dialog.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class SupplierView extends StatelessWidget {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SupplierViewController());
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("الموردين")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoute.supplierAdd);
        },
        child: Icon(Icons.add, color: AppColor.white),
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<SupplierViewController>(
          builder:
              (controller) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: ListView.separated(
                  itemCount: controller.data.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = controller.data[index];

                    return Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.supplierName ?? "بدون اسم",
                                style: font10Black600W(
                                  context,
                                  size: size_15(context),
                                ),
                                textAlign: TextAlign.start,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  showErrorDialog(
                                    titleKey: 'تحذير',
                                    messageKey: 'هل انت متأكد من حذف العميل',
                                    onConfirm: () {
                                      controller.delete(
                                        item.supplierId!.toString(),
                                      );
                                      Get.back();
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.14,
                                        ),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: AppColor.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}
