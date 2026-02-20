import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:store_house/controller/revenue_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';

class RevenueView extends StatelessWidget {
  const RevenueView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RevenueController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("حساب الغلة"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context),
            tooltip: "اختيار مجال تاريخ",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => Get.find<RevenueController>().calculateAllRevenue(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<RevenueController>(
          builder:
              (controller) => HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Range Section (if selected)
                      if (controller.startDate != null)
                        _buildCustomRangeSection(controller),

                      const Text(
                        "الغلة اليومية",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRevenueRow(
                        controller.dailyPos1,
                        controller.dailyPos2,
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "الغلة الأسبوعية (آخر 7 أيام)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRevenueRow(
                        controller.weeklyPos1,
                        controller.weeklyPos2,
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "الغلة الشهرية",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRevenueRow(
                        controller.monthlyPos1,
                        controller.monthlyPos2,
                      ),

                      const SizedBox(height: 30),
                      _buildTotalSummary(controller),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildCustomRangeSection(RevenueController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "غلة الفترة المحددة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.orange),
                onPressed: () => controller.resetCustom(),
              ),
            ],
          ),
          Text(
            "من: ${DateFormat('yyyy-MM-dd').format(controller.startDate!)} إلى: ${DateFormat('yyyy-MM-dd').format(controller.endDate!)}",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildRevenueRow(
            controller.customPos1,
            controller.customPos2,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(
    double pos1,
    double pos2, {
    Color color = AppColor.primaryColor,
  }) {
    return Row(
      children: [
        Expanded(child: _buildPosCard("نقطة بيع 1", pos1, color)),
        const SizedBox(width: 12),
        Expanded(child: _buildPosCard("نقطة بيع 2", pos2, color)),
      ],
    );
  }

  Widget _buildPosCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "${amount.toStringAsFixed(2)} \$",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(RevenueController controller) {
    double totalPos1 = controller.monthlyPos1;
    double totalPos2 = controller.monthlyPos2;
    double grandTotal = totalPos1 + totalPos2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "إجمالي غلة الشهر الحالي",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            "${grandTotal.toStringAsFixed(2)} \$",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white54, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniSummary("ن1", totalPos1),
              _buildMiniSummary("ن2", totalPos2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          "${amount.toStringAsFixed(2)} \$",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      Get.find<RevenueController>().calculateCustomRevenue(
        picked.start,
        picked.end,
      );
    }
  }
}
