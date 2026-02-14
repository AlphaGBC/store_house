import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/incoming_invoices/view_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';

class IncomingInvoices extends StatefulWidget {
  const IncomingInvoices({super.key});

  @override
  State<IncomingInvoices> createState() => _IncomingInvoicesState();
}

class _IncomingInvoicesState extends State<IncomingInvoices> {
  @override
  Widget build(BuildContext context) {
    final IncomingInvoicesController controller = Get.put(
      IncomingInvoicesController(),
    );
    return Scaffold(
      appBar: AppBar(title: const Text("فواتير الادخال"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: () {
          // controller.openInvoice(); // فتح فاتورة جديدة
          // Get.toNamed(AppRoute.incomingInvoicesAdd);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<IncomingInvoicesController>(
        builder:
            (controller) => RefreshWrapper(
              onRefresh: () => controller.getData(),
              child: HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: ListView.separated(
                    itemCount: controller.data.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = controller.data[index];

                      return GestureDetector(
                        onTap: () {},
                        // => controller.goToPageEdit(item),
                        child: Card(
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
                                color: AppColor.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            title: Text(
                              item.supplierName ?? "مورد غير معروف",
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
                                    "التاريخ: ${item.invoiceDate ?? "غير معروف"}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

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
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                // controller.openInvoice(
                                //   id: invoice['invoice_id'],
                                //   name: invoice['supplier_name'],
                                // );
                                // Get.toNamed("/incomingInvoicesAdd");
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
