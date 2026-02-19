import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/transfer/view_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';
import 'package:store_house/routes.dart';

class TransferView extends StatelessWidget {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.put(TransferController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("عمليات التحويل"), 
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              controller.setFilterDate(picked);
            },
          ),
          if (controller.selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => controller.clearFilter(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: () => Get.toNamed(AppRoute.transferAdd),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<TransferController>(
        builder: (controller) => RefreshWrapper(
          onRefresh: () => controller.getData(),
          child: HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ListView.separated(
                itemCount: controller.transferIds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final int transferId = controller.transferIds[index];
                  final items = controller.groupedTransfers[transferId]!;
                  final firstItem = items.first;

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.transferDetails, arguments: {"items": items, "transferId": transferId});
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_horiz, color: AppColor.primaryColor),
                        ),
                        title: Text(
                          "رقم التحويل: $transferId",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("عدد العناصر: ${items.length}"),
                            Text("التاريخ: ${firstItem["transfer_date"]?.toString().split(' ')[0] ?? "غير معروف"}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
