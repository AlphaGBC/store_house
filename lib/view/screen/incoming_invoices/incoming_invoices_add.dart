import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/incoming_invoices/add_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';

class IncomingInvoicesAdd extends StatelessWidget {
  const IncomingInvoicesAdd({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(IncomingInvoicesAddController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة فاتورة إدخال"),
        centerTitle: true,
        actions: [
          GetBuilder<IncomingInvoicesAddController>(
            builder:
                (controller) => IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => controller.saveData(),
                ),
          ),
        ],
      ),
      body: GetBuilder<IncomingInvoicesAddController>(
        builder:
            (controller) => HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Column(
                children: [
                  // Search Item Field
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: controller.searchItemController,
                      decoration: InputDecoration(
                        hintText: "ابحث عن عنصر لإضافته...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) => controller.filterItems(val),
                    ),
                  ),

                  // Item Suggestions
                  if (controller.filteredItems.isNotEmpty)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return ListTile(
                            title: Text(item.itemsName ?? ""),
                            subtitle: Text("السعر: ${item.itemsCostPrice}"),
                            onTap: () => controller.selectItem(item),
                          );
                        },
                      ),
                    ),

                  // Selected Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.selectedInvoiceItems.length,
                      itemBuilder: (context, index) {
                        final itemData = controller.selectedInvoiceItems[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      itemData["items_name"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => controller.removeItem(index),
                                    ),
                                  ],
                                ),
                                const Divider(),

                                // Supplier Search in Card
                                TextField(
                                  controller:
                                      itemData["supplier_search_controller"],
                                  decoration: const InputDecoration(
                                    labelText: "ابحث عن مورد...",
                                    prefixIcon: Icon(Icons.person_search),
                                  ),
                                  onChanged: (val) {
                                    controller.filterSuppliers(val);
                                    itemData["show_supplier_suggestions"] =
                                        val.isNotEmpty;
                                    controller.update();
                                  },
                                ),

                                // Supplier Suggestions
                                if (itemData["show_supplier_suggestions"] &&
                                    controller.filteredSuppliers.isNotEmpty)
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          controller.filteredSuppliers.length,
                                      itemBuilder: (ctx, sIndex) {
                                        final supplier =
                                            controller
                                                .filteredSuppliers[sIndex];
                                        return ListTile(
                                          title: Text(
                                            supplier.supplierName ?? "",
                                          ),
                                          onTap:
                                              () => controller.selectSupplier(
                                                index,
                                                supplier,
                                              ),
                                        );
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                // Input Fields Row 1
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            itemData["storehouse_count"],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "كمية المستودع",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: itemData["pos1_count"],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "كمية نقطة 1",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Input Fields Row 2
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: itemData["pos2_count"],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "كمية نقطة 2",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: itemData["cost_price"],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "سعر التكلفة",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Note Field
                                TextField(
                                  controller: itemData["note"],
                                  decoration: const InputDecoration(
                                    labelText: "ملاحظات",
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
            ),
      ),
    );
  }
}
