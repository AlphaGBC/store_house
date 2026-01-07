import 'package:store_house/controller/home_controller.dart';
import 'package:store_house/controller/search_mix_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/imgaeasset.dart';
import 'package:store_house/core/functions/alertexitapp.dart';
import 'package:store_house/core/shared/customappbar.dart';
import 'package:store_house/routes.dart';
import 'package:store_house/view/screen/list_search_results.dart';
import 'package:store_house/view/widget/home/cardadmin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());
    SearchMixController searchMixController = Get.put(SearchMixController());
    return Scaffold(
      // appBar: AppBar(title: Text("الرئيسية")),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: CustomAppBar(
          mycontroller: searchMixController.search,
          onPressedSearch: () {
            searchMixController.onSearch();
          },
          onChanged: (val) {
            searchMixController.checkSearch(val);
          },
        ),
      ),
      body: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            alertExitApp();
          }
        },
        child: GetBuilder<SearchMixController>(
          builder:
              (controller) => HandlingDataView(
                statusRequest: searchMixController.statusRequest,
                widget:
                    !searchMixController.isSearch
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: [
                              GridView(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          getValueForScreenType<int>(
                                            context: context,
                                            mobile: 3,
                                            tablet: 4,
                                            desktop: 60,
                                          ),
                                      mainAxisExtent: 150,
                                    ),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(AppRoute.categoriesView);
                                    },
                                    url: AppImageAsset.logo,
                                    title: "الاقسام الرئيسية",
                                  ),
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoute.categoriesViewShared,
                                      );
                                    },
                                    url: AppImageAsset.logo,
                                    title: "الاصناف",
                                  ),
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(AppRoute.orderCardsPage);
                                    },
                                    url: AppImageAsset.logo,
                                    title: "الفواتير",
                                  ),
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(AppRoute.scanProductQrPage);
                                    },
                                    url: AppImageAsset.logo,
                                    title: "مسح QR للمنتج",
                                  ),
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(AppRoute.usdView);
                                    },
                                    url: AppImageAsset.logo,
                                    title: "سعر الدولار",
                                  ),
                                  Cardadmin(
                                    onTap: () {
                                      Get.toNamed(AppRoute.wholesaleView);
                                    },
                                    url: AppImageAsset.logo,
                                    title: "عملاء الجملة",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : ListSearchResults(
                          items: searchMixController.listItems,
                        ),
              ),
        ),
      ),
    );
  }
}
