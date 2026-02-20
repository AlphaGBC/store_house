import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/item_movement_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/class/statusrequest.dart';

class ItemMovementView extends StatelessWidget {
  const ItemMovementView({super.key});

  @override
  Widget build(BuildContext context) {
    final ItemMovementController controller = Get.put(ItemMovementController());
    return Scaffold(
      appBar: AppBar(
        title:
            controller.isFilteredByDate
                ? Text(
                  "من: ${controller.selectedDate.toString().split(' ')[0]} "
                  "${controller.selectedEndDate != null ? 'إلى: ${controller.selectedEndDate.toString().split(' ')[0]}' : ''}",
                  style: const TextStyle(fontSize: 14),
                )
                : const Text("حركة العنصر"),
        centerTitle: true,
        actions: [
          // زر التاريخ - يظهر فقط عند عدم الفلترة بالتاريخ
          if (!controller.isFilteredByDate)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              tooltip: 'تصفية بتاريخ أو مجال تواريخ',
              onPressed: () async {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('اختر طريقة التصفية'),
                        contentPadding: const EdgeInsets.all(24),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    controller.setFilterDate(picked);
                                  }
                                },
                                icon: const Icon(Icons.calendar_month),
                                label: const Text('تاريخ واحد'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  DateTimeRange? picked;
                                  if (context.mounted) {
                                    picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      currentDate: DateTime.now(),
                                    );
                                  }
                                  if (picked != null) {
                                    controller.setFilterDateRange(picked);
                                  }
                                },
                                icon: const Icon(Icons.date_range),
                                label: const Text('مجال تواريخ'),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<ItemMovementController>(
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      // Search Bar مع زر حذف الفلترة
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColor.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: controller.searchController,
                                onChanged: (val) => controller.searchItems(val),
                                decoration: InputDecoration(
                                  hintText:
                                      controller.isFilteredByDate
                                          ? "ابحث عن عنصر في هذا التاريخ..."
                                          : "ابحث عن عنصر لمراجعة حركته...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: AppColor.primaryColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // زر حذف الفلترة بجانب مربع البحث
                          if (controller.isFilteredByDate)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.red.shade700,
                                    size: 22,
                                  ),
                                  tooltip: 'حذف التصفية',
                                  onPressed: () => controller.clearFilter(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Movements List
                      Expanded(
                        child:
                            controller.statusRequest == StatusRequest.loading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : controller.isFilteredByDate
                                ? (controller.movements.isEmpty
                                    ? const Center(
                                      child: Text(
                                        "لا توجد حركات في هذا التاريخ",
                                      ),
                                    )
                                    : _buildMovementsList(controller))
                                : controller.selectedItem == null
                                ? const Center(
                                  child: Text("يرجى اختيار عنصر لعرض حركته"),
                                )
                                : controller.movements.isEmpty
                                ? const Center(
                                  child: Text(
                                    "لا توجد حركات مسجلة لهذا العنصر",
                                  ),
                                )
                                : _buildMovementsList(controller),
                      ),
                    ],
                  ),

                  // Search Results Overlay - فقط عند البحث عن عنصر، وليس عند البحث بالتاريخ
                  if (controller.isSearch &&
                      controller.searchResults.isNotEmpty &&
                      !controller.isFilteredByDate)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Material(
                        elevation: 8,
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
                                subtitle: Text(
                                  "المتوفر: ${item.itemsStorehouseCount}",
                                ),
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
      ),
    );
  }

  // دالة مساعدة لبناء قائمة الحركات
  Widget _buildMovementsList(ItemMovementController controller) {
    return ListView.builder(
      itemCount: controller.movements.length,
      itemBuilder: (context, index) {
        final move = controller.movements[index];
        final type = move['type'];
        final itemName =
            move['items_name'] ??
            (controller.selectedItem?.itemsName ?? 'غير محدد');

        Color typeColor;
        IconData typeIcon;

        if (type == 'وارد') {
          typeColor = Colors.green;
          typeIcon = Icons.add_circle_outline;
        } else if (type == 'مبيعات') {
          typeColor = Colors.red;
          typeIcon = Icons.remove_circle_outline;
        } else {
          typeColor = Colors.blue;
          typeIcon = Icons.swap_horiz;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: typeColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم العنصر في الأعلى
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(typeIcon, color: typeColor, size: 20),
                  ],
                ),
                const Divider(height: 12),
                // نوع الحركة والكمية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: typeColor,
                      ),
                    ),
                    Text(
                      "${move['qty']} قطعة",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // التفاصيل
                Text(
                  "التفاصيل: ${move['details']}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (move['price'] != 0)
                  Text(
                    "السعر: ${move['price']}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                if (move['note'] != null && move['note'].toString().isNotEmpty)
                  Text(
                    "ملاحظة: ${move['note']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 8),
                // التاريخ
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${move['date']}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
