import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/inventory_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/routes.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InventoryController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("الجرد العام"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Get.toNamed(AppRoute.requiredItemsView),
            tooltip: "قائمة المواد المطلوبة",
          ),
        ],
      ),
      body: GetBuilder<InventoryController>(
        builder:
            (controller) => HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Summary Cards
                    _buildSummarySection(controller),
                    const SizedBox(height: 16),

                    // Search Bar
                    _buildSearchBar(controller),
                    const SizedBox(height: 16),

                    // Items List
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return _buildItemCard(context, item, controller);
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

  Widget _buildSummarySection(InventoryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                "المستودع",
                controller.totalStorehouseCount.toString(),
                Icons.warehouse,
              ),
              _buildSummaryItem(
                "نقطة 1",
                controller.totalPos1Count.toString(),
                Icons.store,
              ),
              _buildSummaryItem(
                "نقطة 2",
                controller.totalPos2Count.toString(),
                Icons.store,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                "إجمالي رأس المال: ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${controller.totalCapital.toStringAsFixed(2)} \$",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchBar(InventoryController controller) {
    return TextField(
      controller: controller.searchController,
      onChanged: (val) => controller.search(val),
      decoration: InputDecoration(
        hintText: "ابحث عن عنصر في الجرد...",
        prefixIcon: const Icon(Icons.search, color: AppColor.primaryColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    dynamic item,
    InventoryController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _showItemDetails(context, item, controller),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemsName ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "سعر التكلفة: ${item.itemsCostPrice} \$",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "الإجمالي: ${(item.itemsStorehouseCount ?? 0) + (item.itemsPointofsale1Count ?? 0) + (item.itemsPointofsale2Count ?? 0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  Text(
                    "م: ${item.itemsStorehouseCount} | ن1: ${item.itemsPointofsale1Count} | ن2: ${item.itemsPointofsale2Count}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(
    BuildContext context,
    dynamic item,
    InventoryController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.itemsName ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            const Divider(height: 30),
            _buildDetailRow(
              "الكمية في المستودع",
              item.itemsStorehouseCount.toString(),
            ),
            _buildDetailRow(
              "الكمية في نقطة 1",
              item.itemsPointofsale1Count.toString(),
            ),
            _buildDetailRow(
              "الكمية في نقطة 2",
              item.itemsPointofsale2Count.toString(),
            ),
            _buildDetailRow("سعر التكلفة", "${item.itemsCostPrice} \$"),
            _buildDetailRow("سعر الجملة", "${item.itemsWholesalePrice} \$"),
            _buildDetailRow("سعر المفرق", "${item.itemsRetailPrice} \$"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.addToRequired(item);
                  Get.back();
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  "إضافة إلى قائمة المواد المطلوبة",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
