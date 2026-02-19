import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/inventory_controller.dart';
import 'package:store_house/core/constant/color.dart';

class RequiredItemsView extends StatelessWidget {
  const RequiredItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<InventoryController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("قائمة المواد المطلوبة"),
        centerTitle: true,
      ),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.requiredItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "القائمة فارغة حالياً",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: controller.requiredItems.length,
              itemBuilder: (context, index) {
                final item = controller.requiredItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        Icons.inventory_2,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    title: Text(
                      item.itemsName ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "المتوفر حالياً: ${(item.itemsStorehouseCount ?? 0) + (item.itemsPointofsale1Count ?? 0) + (item.itemsPointofsale2Count ?? 0)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed:
                          () => controller.removeFromRequired(item.itemsId!),
                      tooltip: "إزالة من القائمة",
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
