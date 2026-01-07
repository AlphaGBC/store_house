import 'package:store_house/controller/usd/view_controller.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsdView extends StatelessWidget {
  const UsdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("سعر تصريف الدولار")),
      body: GetBuilder<UsdControllerImp>(
        builder:
            (controller) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: InkWell(
                onTap: () => controller.goToPageEdit(),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "سعر الدولار: ",
                                        style: font10Black600W(
                                          context,
                                          size: size_15(context),
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      Text(
                                        " ${controller.price}",
                                        style: font10SecondaryColor600W(
                                          context,
                                          size: size_15(context),
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),

                                // زر تعديل صغير
                                InkWell(
                                  onTap: () {
                                    controller.goToPageEdit();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
