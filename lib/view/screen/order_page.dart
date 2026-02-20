import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/order_cards_controller.dart';
import 'package:store_house/controller/usd/view_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:store_house/data/model/ordercardmodel.dart';

//// Parent app page to display order cards from all POS locations
class OrderCardsPage extends GetView<OrderCardsController> {
  const OrderCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    UsdControllerImp usd = Get.find<UsdControllerImp>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ارشيف الفواتير'),
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<OrderCardsController>(
          builder: (controller) {
            return Column(
              children: [
                // Filters section - Customer type only
                _buildFiltersSection(controller),

                // Tab bar for POS selection
                _buildTabBar(controller),

                // Orders list
                Expanded(
                  child: RefreshWrapper(
                    onRefresh: () => controller.refreshOrders(),
                    child: HandlingDataView(
                      statusRequest: controller.statusRequest,
                      widget: _buildOrdersList(context, controller, usd.price),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build filters section - only customer type filter
  Widget _buildFiltersSection(OrderCardsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer type filter
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'الكل',
                      selected: controller.selectedCustomerType.value == -1,
                      onSelected: (selected) {
                        if (selected) controller.setCustomerType(-1);
                      },
                    ),
                    _buildFilterChip(
                      label: 'مفرق',
                      selected: controller.selectedCustomerType.value == 0,
                      onSelected: (selected) {
                        if (selected) controller.setCustomerType(0);
                      },
                    ),
                    _buildFilterChip(
                      label: 'جملة',
                      selected: controller.selectedCustomerType.value == 1,
                      onSelected: (selected) {
                        if (selected) controller.setCustomerType(1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      checkmarkColor: AppColor.white,
      backgroundColor: AppColor.white,
      selectedColor: AppColor.primaryColor,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(OrderCardsController controller) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setTab(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTab.value == 0
                                ? AppColor.primaryColor
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: customText(
                      Get.context!,
                      text: 'الكل',
                      style: font10primaryColor600W(
                        Get.context!,
                        size: size_14(Get.context!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setTab(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTab.value == 1
                                ? AppColor.primaryColor
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: customText(
                      Get.context!,
                      text: 'نقطة البيع 1',
                      style: font10primaryColor600W(
                        Get.context!,
                        size: size_14(Get.context!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.setTab(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTab.value == 2
                                ? AppColor.primaryColor
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: customText(
                      Get.context!,
                      text: 'نقطة البيع 2',
                      style: font10primaryColor600W(
                        Get.context!,
                        size: size_14(Get.context!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build orders list
  Widget _buildOrdersList(
    BuildContext context,
    OrderCardsController controller,
    String usd,
  ) {
    final orders = controller.getOrdersForTab();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order, usd);
      },
    );
  }

  /// Build individual order card
  Widget _buildOrderCard(
    BuildContext context,
    OrderCardModel order,
    String usd,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  context,
                  text: 'طلب #${order.ordersId}',
                  style: font10Black600W(context, size: size_13(context)),
                ),
                Chip(
                  label: Text(order.posSourceLabel),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: size_10(context),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Customer info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  context,
                  text: 'العميل',
                  style: font10Black400W(context, size: size_13(context)),
                ),
                order.customerName == ""
                    ? customText(
                      context,
                      text: "مفرق",
                      style: font10Black400W(context, size: size_13(context)),
                    )
                    : customText(
                      context,
                      text: order.customerName,
                      style: font10Black400W(context, size: size_13(context)),
                    ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  context,
                  text: 'التاريخ',
                  style: font10Black400W(context, size: size_12(context)),
                ),
                customText(
                  context,
                  text: order.createdAt.split(' ')[0],
                  style: font10Grey400W(context, size: size_12(context)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'المنتجات',
              style: font10Black400W(context, size: size_12(context)),
            ),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemsName,
                            style: font10Black700W(
                              context,
                              size: size_12(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.itemsQuantity} × ${item.formattedUnitPrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${item.formattedTotalPrice} \$",
                          style: font10Black700W(
                            context,
                            size: size_12(context),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${double.parse(item.formattedTotalPrice) * double.parse(usd)} ل.س",
                          style: font10primaryColor600W(
                            context,
                            size: size_12(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            // Pricing Details
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإجمالي',
                      style: font10Black700W(context, size: size_14(context)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${order.formattedTotal} \$",
                          style: font10SecondaryColor700W(
                            context,
                            size: size_14(context),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${double.parse(order.formattedTotal) * double.parse(usd)} ل.س",
                          style: font10primaryColor600W(
                            context,
                            size: size_12(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
