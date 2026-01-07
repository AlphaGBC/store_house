import 'dart:io';
import 'package:store_house/core/constant/color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

imageUploadCamera() async {
  final XFile? file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 1280, // قلل العرض
    maxHeight: 1280, // قلل الارتفاع إذا أردت
    imageQuality: 75,
  );

  if (file != null) {
    return File(file.path);
  } else {
    return null;
  }
}

fileUploadGallery() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [
      "svg",
      "SVG",
      "png",
      "PNG",
      "jpg",
      "JPG",
      "jpeg",
      "JPEG",
    ],
  );
  if (result != null) {
    return File(result.files.single.path!);
  } else {
    return null;
  }
}

showBottoumMenu(Function() imageUploadCamera, Function() fileUploadGallery) {
  Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(color: AppColor.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Text(
                  'اختر صورة',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Camera Option
            InkWell(
              onTap: () {
                imageUploadCamera();
                Get.back();
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColor.orange.withValues(alpha: 0.2),
              child: ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  size: 36,
                  color: AppColor.orange,
                ),
                title: Text(
                  'التقاط من الكاميرا',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.gray,
                  ),
                ),
              ),
            ),

            // Gallery Option
            InkWell(
              onTap: () {
                fileUploadGallery();
                Get.back();
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColor.orange.withValues(alpha: 0.2),
              child: ListTile(
                leading: Icon(
                  Icons.photo_library,
                  size: 36,
                  color: AppColor.orange,
                ),
                title: Text(
                  'اختر من المعرض',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.gray,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Divider
            Divider(
              thickness: 1.5,
              color: AppColor.primaryColor.withValues(alpha: 0.3),
            ),

            // Cancel Button
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
  );
}
