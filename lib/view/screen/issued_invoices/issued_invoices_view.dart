import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/issued_invoices_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/class/statusrequest.dart';

class IssuedInvoicesView extends StatelessWidget {
  const IssuedInvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Get.find لأن الـ Controller تم تعريفه ووضعه في الذاكرة في الصفحة السابقة
    return GetBuilder<IssuedInvoicesController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.currentissuedInvoicesId == null
                  ? "إضافة فاتورة جديدة"
                  : "عرض فاتورة",
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // 1. حقل اسم المورد (نصي يدوي)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: controller.supplierName,
                          readOnly: true, // يمنع التعديل
                          showCursor: false, // يخفي المؤشر
                          enableInteractiveSelection:
                              false, // يمنع النسخ واللصق
                          focusNode: FocusNode(
                            canRequestFocus: false,
                          ), // يمنع الضغط والتركيز
                          decoration: const InputDecoration(
                            labelText: "اسم الموظف ونقطة البيع",
                            hintText: "اكتب اسم الموظف هنا...",
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.person_outline,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // قائمة الاقتراحات المنبثقة
                    if (controller.isSearch &&
                        controller.searchResults.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
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

                    const SizedBox(height: 16),

                    // 3. قائمة العناصر المضافة (تعديل أفقي)
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.addedItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.addedItems[index];
                          final ctrls =
                              controller.itemControllers[item.itemsId];
                          if (ctrls == null) return const SizedBox();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemsName ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 8),
                                  // السطر الأول: الكميات
                                  Row(
                                    children: [
                                      _buildSmallField(
                                        "مستودع",
                                        ctrls["storehouse"]!,
                                      ),
                                      const SizedBox(width: 6),
                                      _buildSmallField(
                                        "نقطة 1",
                                        ctrls["pos1"]!,
                                      ),
                                      const SizedBox(width: 6),
                                      _buildSmallField(
                                        "نقطة 2",
                                        ctrls["pos2"]!,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // السطر الثاني: الأسعار
                                  Row(
                                    children: [
                                      _buildSmallField("تكلفة", ctrls["cost"]!),
                                      const SizedBox(width: 6),
                                      _buildSmallField(
                                        "جملة",
                                        ctrls["wholesale"]!,
                                      ),
                                      const SizedBox(width: 6),
                                      _buildSmallField(
                                        "مفرق",
                                        ctrls["retail"]!,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // السطر الثالث: الخصومات
                                  Row(
                                    children: [
                                      _buildSmallField(
                                        "خصم ج %",
                                        ctrls["w_discount"]!,
                                      ),
                                      const SizedBox(width: 6),
                                      _buildSmallField(
                                        "خصم م %",
                                        ctrls["r_discount"]!,
                                      ),
                                    ],
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
              if (controller.statusRequest == StatusRequest.loading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallField(String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            readOnly: true, // يمنع التعديل
            showCursor: false, // يخفي المؤشر
            enableInteractiveSelection: false, // يمنع النسخ واللصق
            focusNode: FocusNode(canRequestFocus: false), // يمنع الضغط والتركيز
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
