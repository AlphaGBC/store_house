import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/data/model/incoming_invoices_model.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/routes.dart';

class IncomingInvoicesDetails extends StatelessWidget {
  const IncomingInvoicesDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final List<IncomingInvoicesModel> items = Get.arguments['items'];
    final int invoiceId = Get.arguments['invoiceId'];

    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل الفاتورة #$invoiceId"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColor.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "رقم الفاتورة: $invoiceId",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "التاريخ: ${items.first.invoiceDate?.split(' ')[0] ?? ""}",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "العناصر والموردين:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemsName ?? "منتج غير معروف",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoute.incomingInvoicesEdit,
                                    arguments: {"model": item},
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildDetailRow(
                            "المورد",
                            item.supplierName ?? "غير معروف",
                          ),
                          _buildDetailRow("سعر التكلفة", "${item.costPrice}"),
                          _buildDetailRow(
                            "الكميات (مستودع/نقطة اولى/نقطة ثانية)",
                            "${item.storehouseCount} / ${item.pos1Count} / ${item.pos2Count}",
                          ),
                          if (item.incomingInvoiceItemsNote != null &&
                              item.incomingInvoiceItemsNote!.isNotEmpty)
                            _buildDetailRow(
                              "ملاحظات",
                              item.incomingInvoiceItemsNote!,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
