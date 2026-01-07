import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/search_mix_controller.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:store_house/data/model/itemsmodel.dart';

class ListSearchResults extends GetView<SearchMixController> {
  final List<ItemsModel> items;
  final ScrollPhysics physics;

  const ListSearchResults({
    super.key,
    required this.items,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: physics,
      itemBuilder: (context, index) {
        final itemIndex = index;
        final item = items[itemIndex];
        return _buildProductItem(context, item);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, ItemsModel item) {
    return InkWell(
      onTap: () => controller.goToPageEdit(item, item.itemsId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Card(
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: customText(
                    context,
                    text: "${item.itemsName}",
                    style: font10Black600W(context, size: size_10(context)),
                  ),
                ),

                SizedBox(width: 10),
                customText(
                  context,
                  text: "${item.categoriesName}",
                  style: font10SecondaryColor600W(
                    context,
                    size: size_10(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
