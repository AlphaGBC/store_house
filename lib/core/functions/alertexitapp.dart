import 'dart:io';
import 'package:store_house/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> alertExitApp() {
  return Get.defaultDialog<bool>(
    backgroundColor: AppColor.white,
    title: "تنبيه",
    titleStyle: const TextStyle(
      color: AppColor.primaryColor, // Primary green color
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    middleText: "هل تريد الخروج من التطبيق",
    middleTextStyle: const TextStyle(color: AppColor.black, fontSize: 18),
    radius: 16,
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColor.gryColor_3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () {
          Get.back();
        },
        child: Text(
          "الغاء",
          style: const TextStyle(
            color: AppColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColor.orange, // Secondary orange color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () {
          exit(0);
        },
        child: Text(
          "تاكيد",
          style: const TextStyle(
            color: AppColor.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ).then((value) => value ?? false);
}
