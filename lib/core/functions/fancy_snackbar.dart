import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/core/constant/color.dart';

class FancySnackbar {
  /// يعرض سناببار عصري وفخم بهوية المتجر
  /// - [title] نص العنوان
  /// - [message] نص الرسالة
  /// - [isError] عند تفعيله، يتم عرض ألوان وأيقونة الخطأ
  static void show({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool isError = false, //  <-- 1. إضافة متغير الخطأ الاختياري هنا
  }) {
    // 2. تحديد الألوان والأيقونة بناءً على حالة الخطأ
    final List<Color> gradientColors =
        isError
            ? [Colors.red.shade700, Colors.orange.shade800] // <-- ألوان الخطأ
            : [AppColor.primaryColor, AppColor.orange]; // <-- الألوان الأساسية

    final IconData icon =
        isError
            ? Icons
                .error_outline // <-- أيقونة الخطأ
            : Icons.shopping_bag; // <-- الأيقونة الأساسية

    Get.rawSnackbar(
      backgroundColor: Colors.transparent,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.TOP,
      overlayBlur: 1,
      overlayColor: AppColor.black.withValues(alpha: 0.05),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: EdgeInsets.zero,
      duration: duration,
      messageText: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors, // <-- 3. استخدام قائمة الألوان المحددة
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColor.white,
              size: 28,
            ), // <-- 4. استخدام الأيقونة المحددة
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
