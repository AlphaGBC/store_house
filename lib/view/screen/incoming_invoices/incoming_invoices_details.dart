import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/data/model/incoming_invoices_model.dart';
import 'package:store_house/core/constant/color.dart';

class IncomingInvoicesDetails extends StatelessWidget {
  const IncomingInvoicesDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final IncomingInvoicesModel model = Get.arguments['model'];

    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل الفاتورة #${model.invoiceId}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard("معلومات الفاتورة", [
              _buildDetailRow("رقم الفاتورة", model.invoiceId.toString()),
              _buildDetailRow("التاريخ", model.invoiceDate ?? ""),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard("معلومات المورد", [
              _buildDetailRow("اسم المورد", model.supplierName ?? ""),
              _buildDetailRow("تاريخ المورد", model.supplierDate ?? ""),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard("تفاصيل العنصر", [
              _buildDetailRow("اسم المنتج", model.itemsName ?? ""),
              _buildDetailRow("سعر التكلفة", model.costPrice.toString()),
              _buildDetailRow("كمية المستودع", model.storehouseCount.toString()),
              _buildDetailRow("كمية نقطة 1", model.pos1Count.toString()),
              _buildDetailRow("كمية نقطة 2", model.pos2Count.toString()),
              _buildDetailRow("ملاحظات", model.incomingInvoiceItemsNote ?? "لا يوجد"),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            const Divider(),
            ...children,
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
