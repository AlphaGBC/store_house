import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/item_movement_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/class/statusrequest.dart';

class ItemMovementView extends StatelessWidget {
  const ItemMovementView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(ItemMovementController());
    return Scaffold(
      appBar: AppBar(title: const Text("حركة العنصر"), centerTitle: true),
      body: GetBuilder<ItemMovementController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: (val) => controller.searchItems(val),
                        decoration: const InputDecoration(
                          hintText: "ابحث عن عنصر لمراجعة حركته...",
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColor.primaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          controller.statusRequest == StatusRequest.loading
                              ? const Center(child: CircularProgressIndicator())
                              : controller.selectedItem == null
                              ? const Center(
                                child: Text("يرجى اختيار عنصر لعرض حركته"),
                              )
                              : controller.movements.isEmpty
                              ? const Center(
                                child: Text("لا توجد حركات مسجلة لهذا العنصر"),
                              )
                              : ListView.builder(
                                itemCount: controller.movements.length,
                                itemBuilder: (context, index) {
                                  final move = controller.movements[index];
                                  final isIncoming = move['type'] == 'وارد';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color:
                                            isIncoming
                                                ? Colors.green.shade200
                                                : Colors.red.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            isIncoming
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                        child: Icon(
                                          isIncoming
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color:
                                              isIncoming
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            move['type'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isIncoming
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                          Text(
                                            "${move['qty']} قطعة",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            "المصدر/العميل: ${move['source'] ?? 'غير محدد'}",
                                          ),
                                          Text("السعر: ${move['price']}"),
                                          const SizedBox(height: 4),
                                          Text(
                                            "التاريخ: ${move['date']}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
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
                if (controller.isSearch && controller.searchResults.isNotEmpty)
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: controller.searchResults.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = controller.searchResults[index];
                            return ListTile(
                              title: Text(item.itemsName ?? ""),
                              onTap: () => controller.onItemSelected(item),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
