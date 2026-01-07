import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/items/view_controller.dart';
import 'package:store_house/controller/usd/view_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';
import 'package:store_house/core/functions/show_error_dialog.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ItemsControllerImp controller = Get.find<ItemsControllerImp>();
    UsdControllerImp usd = Get.find<UsdControllerImp>();
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("المنتجات")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.goToPageItemsAdd();
        },
        child: const Icon(Icons.add, color: AppColor.white),
      ),
      body: GetBuilder<ItemsControllerImp>(
        builder:
            (controller) => RefreshWrapper(
              onRefresh:
                  () => controller.getItemsByCategories(
                    controller.selectedCat!,
                    forceRefresh: true,
                  ),
              child: HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: ListView.separated(
                    itemCount: controller.data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.data[index];
                      // 2.  منطق السعر والخصم في سعر الجملة
                      final wholesaleprice = item.itemsWholesalePrice ?? 0;
                      final wholesalepricediscount =
                          item.itemsWholesaleDiscount ?? 0;
                      final wholesalepriceDiscount = wholesalepricediscount > 0;
                      // السعر بعد الخصم (من المودل مباشرة إذا كان محسوباً أو يمكن حسابه)
                      final wholesalepriceAfterDiscount =
                          item.itemswholesalepricediscount ??
                          (item.itemsWholesalePrice -
                              (item.itemsWholesalePrice *
                                  item.itemsWholesaleDiscount /
                                  100));

                      // 2. منطق السعر والخصم في سعر المفرق
                      final retailprice = item.itemsRetailPrice ?? 0;
                      final retailpricediscount = item.itemsRetailDiscount ?? 0;
                      final retailpriceDiscount = retailpricediscount > 0;
                      // السعر بعد الخصم (من المودل مباشرة إذا كان محسوباً أو يمكن حسابه)
                      final retailpriceAfterDiscount =
                          item.itemsretailpricediscount ??
                          (item.itemsRetailPrice -
                              (item.itemsRetailPrice *
                                  item.itemsRetailDiscount /
                                  100));

                      final sycostprice =
                          item.itemsCostPrice * int.parse(usd.price);

                      final sywholesalepriceAfterDiscount =
                          wholesalepriceAfterDiscount * int.parse(usd.price);

                      final sywholesaleprice =
                          wholesaleprice * int.parse(usd.price);

                      final syretailpriceAfterDiscount =
                          retailpriceAfterDiscount * int.parse(usd.price);

                      final syretailprice = retailprice * int.parse(usd.price);

                      return Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () {
                            controller.goToPageEdit(
                              item,
                              int.parse(controller.catid!),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // === العمود الأيسر: أيقونات التعديل والحذف ===
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // زر التعديل
                                    InkWell(
                                      onTap: () {
                                        controller.goToPageEdit(
                                          item,
                                          int.parse(controller.catid!),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.grey.shade800,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // زر الحذف
                                    InkWell(
                                      onTap: () {
                                        showErrorDialog(
                                          titleKey: 'تحذير',
                                          messageKey:
                                              'هل انت متأكد من حذف العنصر؟',
                                          onConfirm: () {
                                            controller.deleteItems(
                                              controller.data[index].itemsId!
                                                  .toString(),
                                            );
                                            Get.back();
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: AppColor.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 12),

                                // === العمود الأوسط: بيانات الصنف ===
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // الاسم
                                      Text(
                                        item.itemsName ?? '-',
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 8),
                                      // معرف المتجر + الكمية
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 14,
                                            color: AppColor.secondaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "المخزن: ${item.itemsStorehouseCount ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),
                                      // معرف المتجر + الكمية
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 14,
                                            color: AppColor.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "نقطة البيع الاولى: ${item.itemsPointofsale1Count ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),
                                      // معرف المتجر + الكمية
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 14,
                                            color: AppColor.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "نقطة البيع الثانية: ${item.itemsPointofsale2Count ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.orange,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      customText(
                                        context,
                                        text: "سعر التكلفة :",
                                        style: font10SecondaryColor600W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      customText(
                                        context,
                                        text: "${item.itemsCostPrice} \$",
                                        style: font10Black700W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      customText(
                                        context,
                                        text: "$sycostprice ل.س",
                                        style: font10primaryColor600W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),

                                      const SizedBox(height: 5),
                                      customText(
                                        context,
                                        text: "سعر مبيع الجملة",
                                        style: font10SecondaryColor600W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "$wholesalepriceAfterDiscount \$", // عرض السعر النهائي
                                            style: font10Black700W(
                                              context,
                                              size: size_12(context),
                                            ),
                                          ),
                                          if (wholesalepriceDiscount) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              "$wholesaleprice \$", // السعر القديم
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "($wholesalepricediscount%)", // نسبة الخصم
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "$sywholesalepriceAfterDiscount ل.س", // عرض السعر النهائي
                                        style: font10primaryColor700W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      if (wholesalepriceDiscount) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "$sywholesaleprice ل.س", // السعر القديم
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "($wholesalepricediscount%)", // نسبة الخصم
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 5),
                                      customText(
                                        context,
                                        text: "سعر مبيع المفرق",
                                        style: font10SecondaryColor600W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "$retailpriceAfterDiscount \$", // عرض السعر النهائي
                                            style: font10Black700W(
                                              context,
                                              size: size_12(context),
                                            ),
                                          ),
                                          if (retailpriceDiscount) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              "$retailprice \$", // السعر القديم
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "($retailpricediscount%)", // نسبة الخصم
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "$syretailpriceAfterDiscount ل.س", // عرض السعر النهائي
                                        style: font10primaryColor700W(
                                          context,
                                          size: size_12(context),
                                        ),
                                      ),
                                      if (retailpriceDiscount) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "$syretailprice ل.س", // السعر القديم
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "($retailpricediscount%)", // نسبة الخصم
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // === العمود الأيمن: الصورة والحالة ===
                                SizedBox(
                                  width: 92,
                                  height: 92,
                                  child: QrImageView(
                                    data: item.itemsQr ?? '',
                                    version: QrVersions.auto,
                                    size: 92,
                                    gapless: false,
                                  ),
                                ),
                              ],
                            ),
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
