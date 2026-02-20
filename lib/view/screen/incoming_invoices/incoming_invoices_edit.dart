import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/incoming_invoices/edit_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';

class IncomingInvoicesEdit extends StatelessWidget {
  const IncomingInvoicesEdit({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(IncomingInvoicesEditController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل فاتورة إدخال"),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<IncomingInvoicesEditController>(
          builder:
              (controller) => HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        "تعديل العنصر: ${controller.model.itemsName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller.storehouseCount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "كمية المستودع",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.pos1Count,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "كمية نقطة 1",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.pos2Count,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "كمية نقطة 2",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.costPrice,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "سعر التكلفة",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller.note,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "ملاحظات",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => controller.editData(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text("حفظ التعديلات"),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
