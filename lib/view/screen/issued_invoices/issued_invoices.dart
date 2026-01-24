import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/issued_invoices_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/routes.dart';

class IssuedInvoices extends StatelessWidget {
  const IssuedInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IssuedInvoicesController());

    return Scaffold(
      appBar: AppBar(title: const Text("الفواتير الصادرة"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: () {
          controller.openInvoice(); // فتح فاتورة جديدة
          Get.toNamed(AppRoute.issuedInvoicesAdd);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<IssuedInvoicesController>(
        builder: (controller) {
          // إذا كانت الحالة none (أي لا توجد بيانات بعد)، نظهر رسالة تشجيعية بدلاً من شاشة فارغة تماماً
          if (controller.statusRequest == StatusRequest.none &&
              controller.allInvoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد فواتير مضافة بعد",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "اضغط على زر + لإضافة أول فاتورة",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: RefreshIndicator(
              onRefresh: () => controller.getAllInvoices(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.allInvoices.length,
                itemBuilder: (context, index) {
                  final issuedinvoice = controller.allInvoices[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      title: Text(
                        issuedinvoice['supplier_name'] ?? "مورد غير معروف",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "التاريخ: ${issuedinvoice['issued_invoices_date']}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (issuedinvoice['status'] != 'uploaded')
                              SizedBox(
                                height: 30,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      () => controller.uploadInvoiceToServer(
                                        issuedinvoice,
                                      ),
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "رفع البطاقة",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColor.primaryColor,
                                    side: const BorderSide(
                                      color: AppColor.primaryColor,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "تم الرفع",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "حذف الفاتورة",
                            middleText:
                                "هل أنت متأكد من حذف هذه الفاتورة نهائياً؟",
                            textConfirm: "حذف",
                            textCancel: "إلغاء",
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () {
                              controller.deleteInvoice(
                                issuedinvoice['issued_invoices_id'],
                              );
                              Get.back();
                            },
                          );
                        },
                      ),
                      onTap: () {
                        controller.openInvoice(
                          id: issuedinvoice['issued_invoices_id'],
                          name: issuedinvoice['supplier_name'],
                        );
                        Get.toNamed(AppRoute.issuedInvoicesView);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
