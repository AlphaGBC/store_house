import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/transfer/add_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';

class TransferAdd extends StatelessWidget {
  const TransferAdd({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransferAddController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة عملية تحويل"),
        centerTitle: true,
        actions: [
          GetBuilder<TransferAddController>(
            builder: (controller) => IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => controller.saveData(),
            ),
          )
        ],
      ),
      body: GetBuilder<TransferAddController>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Box
                TextField(
                  controller: controller.searchItemController,
                  onChanged: (val) => controller.filterItems(val),
                  decoration: InputDecoration(
                    hintText: "ابحث عن عنصر للنقل...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (controller.filteredItems.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 5)],
                    ),
                    child: ListView.builder(
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        return ListTile(
                          title: Text(item.itemsName!),
                          subtitle: Text("المتوفر: ${item.itemsStorehouseCount}"),
                          onTap: () => controller.selectItem(item),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.selectedTransferItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.selectedTransferItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                      item["items_name"],
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primaryColor),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => controller.removeItem(index),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("المستودع (المتبقي)", style: TextStyle(color: Colors.grey)),
                                        Text(
                                          "${item["current_storehouse_display"]}",
                                          style: TextStyle(
                                            fontSize: 20, 
                                            fontWeight: FontWeight.bold,
                                            color: int.parse(item["current_storehouse_display"]) < 0 ? Colors.red : Colors.green
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: item["pos1_controller"],
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => controller.updateStorehouseDisplay(index),
                                      decoration: const InputDecoration(labelText: "نقطة 1", border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: item["pos2_controller"],
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => controller.updateStorehouseDisplay(index),
                                      decoration: const InputDecoration(labelText: "نقطة 2", border: OutlineInputBorder()),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: item["note_controller"],
                                decoration: const InputDecoration(labelText: "ملاحظات", border: OutlineInputBorder()),
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
        ),
      ),
    );
  }
}
