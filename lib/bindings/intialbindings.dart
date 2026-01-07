import 'package:store_house/controller/categories/view_controller.dart';
import 'package:store_house/controller/items/view_controller.dart';
import 'package:store_house/controller/order_cards_controller.dart';
import 'package:store_house/controller/usd/view_controller.dart';
import 'package:store_house/controller/wholesale/view_controller.dart';
import 'package:store_house/core/class/crud.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put(CategoriesViewController());
    Get.put(UsdControllerImp());
    Get.put(WholesaleViewController());
    Get.put(OrderCardsController());
    Get.lazyPut(() => ItemsControllerImp(), fenix: true);
  }
}
