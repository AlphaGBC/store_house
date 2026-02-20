import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/constant/color.dart';

class TransferDetails extends StatelessWidget {
  const TransferDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Map arguments = Get.arguments;
    final List<Map<String, dynamic>> items = arguments["items"];
    final int transferId = arguments["transferId"];

    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل التحويل: $transferId"),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["items_name"] ?? "عنصر غير معروف",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                            "المستودع (بعد)",
                            item["storehouse_count"].toString(),
                          ),
                          _buildInfoColumn(
                            "نقطة 1 (منقول)",
                            item["pos1_count"].toString(),
                          ),
                          _buildInfoColumn(
                            "نقطة 2 (منقول)",
                            item["pos2_count"].toString(),
                          ),
                        ],
                      ),
                      if (item["transfer_of_items_note"] != null &&
                          item["transfer_of_items_note"].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "ملاحظات: ${item["transfer_of_items_note"]}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
