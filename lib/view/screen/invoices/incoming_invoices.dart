import 'package:dartz/dartz.dart' as StatusRequest;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/incoming_invoices_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';

class IncomingInvoices extends StatelessWidget {
  const IncomingInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Get.put لضمان وجود الـ Controller
    final controller = Get.put(IncomingInvoicesControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text("الفواتير الواردة"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.getAllInvoices(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: () {
          controller.openInvoice(); // فتح فاتورة جديدة
          Get.toNamed("/incomingInvoicesAdd");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<IncomingInvoicesControllerImp>(
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
                  final invoice = controller.allInvoices[index];
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
                          color: AppColor.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      title: Text(
                        invoice['supplier_name'] ?? "مورد غير معروف",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "التاريخ: ${invoice['invoice_date']}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              controller.openInvoice(
                                id: invoice['invoice_id'],
                                name: invoice['supplier_name'],
                              );
                              Get.toNamed("/incomingInvoicesAdd");
                            },
                          ),
                          IconButton(
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
                                    invoice['invoice_id'],
                                  );
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.openInvoice(
                          id: invoice['invoice_id'],
                          name: invoice['supplier_name'],
                        );
                        Get.toNamed("/incomingInvoicesAdd");
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
