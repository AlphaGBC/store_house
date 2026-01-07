import 'package:store_house/controller/categories/view_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/functions/refresh_wrapper.dart';
import 'package:store_house/core/functions/show_error_dialog.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:store_house/linkapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("الأقسام الرئيسية")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoute.categoriesAdd);
        },
        child: Icon(Icons.add, color: AppColor.white),
      ),
      body: GetBuilder<CategoriesViewController>(
        builder:
            (controller) => RefreshWrapper(
              onRefresh: () => controller.getData(),
              child: HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: ListView.separated(
                    itemCount: controller.data.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = controller.data[index];
                      final imageUrl =
                          "${AppLink.imagestCategories}/${item.categoriesImage}";

                      return GestureDetector(
                        onTap: () => controller.goToPageEdit(item),
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // صورة القسم مع زر حذف دائري فوقها
                                Expanded(
                                  flex: 4,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (c, u, e) => Container(
                                                height: 130,
                                                color: Colors.grey.shade100,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                      // تدرج خفيف لأسفل الصورة لتحسين قابلية قراءة النص إن وُجد
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // عنوان القسم
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.categoriesName ??
                                                    "بدون اسم",
                                                style: font10Black600W(
                                                  context,
                                                  size: size_15(context),
                                                ),
                                                textAlign: TextAlign.start,
                                                //  overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            // زر تعديل صغير
                                            InkWell(
                                              onTap: () {
                                                controller.goToPageEdit(item);
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20),

                                        // وصف أو معلومة إضافية (مثلاً id أو عدد المنتجات إن توفر)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "معرف: ${item.categoriesId ?? '-'}",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            // زر الحذف الطافي في الزاوية اليمنى العليا للصورة
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              onTap: () {
                                                showErrorDialog(
                                                  titleKey: 'تحذير',
                                                  messageKey:
                                                      'هل انت متأكد من حذف القسم؟',
                                                  onConfirm: () {
                                                    controller.deleteCategory(
                                                      item.categoriesId!
                                                          .toString(),
                                                      item.categoriesImage
                                                          .toString(),
                                                    );
                                                    Get.back();
                                                  },
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      blurRadius: 8,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: AppColor.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),
                                      ],
                                    ),
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
