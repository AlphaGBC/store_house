import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/constant/color.dart';

Future<void> errorDialog({
  required String titleKey,
  required String messageKey,
}) {
  return Get.defaultDialog(
    title: titleKey.tr,
    titleStyle: const TextStyle(
      color: AppColor.primaryColor, // اللون الأساسي
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    middleText: messageKey.tr,
    middleTextStyle: const TextStyle(color: AppColor.black, fontSize: 16),
    backgroundColor: AppColor.white,
    radius: 12,
    barrierDismissible: true,
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColor.orange, // اللون الثانوي
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: Text(
          "102".tr,
          style: const TextStyle(
            color: AppColor.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
