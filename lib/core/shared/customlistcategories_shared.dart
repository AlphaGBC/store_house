import 'package:store_house/controller/shared/categories_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:store_house/data/model/categoriesmodel.dart';
import 'package:store_house/linkapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

class CustomlistcategoriesShared extends GetView<CategoriesControllerImp> {
  const CustomlistcategoriesShared({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final model = CategoriesModel.fromJson(controller.categories[index]);
        return CategoryCard(model: model, index: index);
      },
    );
  }
}

class CategoryCard extends GetView<CategoriesControllerImp> {
  final CategoriesModel model;
  final int index;
  const CategoryCard({super.key, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColor.orange.withValues(alpha: 0.3),
        onTap: () {
          final catId = model.categoriesId.toString();

          controller.changeCat(index, catId);

          Get.toNamed(
            AppRoute.itemsView,
            arguments: {
              'categories': controller.categories,
              'selectedcat': index,
              'catid': catId,
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl:
                    "${AppLink.imagestCategories}/${model.categoriesImage}",
                fit: BoxFit.cover,

                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.storefront, color: AppColor.gray),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColor.primaryColor.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 8,
                right: 8,
                child: customText(
                  context,
                  text: model.categoriesName!,
                  style: font10White600W(context, size: size_12(context)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
