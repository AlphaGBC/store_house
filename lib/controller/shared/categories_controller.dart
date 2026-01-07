import 'package:store_house/sqflite.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:get/get.dart';

abstract class CategoriesController extends GetxController {
  intialData();
  changeCat(int val, String catval);
  getcategories();
}

class CategoriesControllerImp extends GetxController {
  List categories = [];
  String? catid;
  int? selectedCat;

  late StatusRequest statusRequest;

  SqlDb sqlDb = SqlDb();

  @override
  void onInit() {
    intialData();
    super.onInit();
  }

  intialData() async {
    getcategories();
    if (catid != null) {
      catid = Get.arguments['catid'];
    }
    update();
  }

  changeCat(val, catval) {
    selectedCat = val;
    catid = catval;
    update();
  }

  getcategories() async {
    categories.clear();
    statusRequest = StatusRequest.loading;
    update();

    List<Map> response = await sqlDb.read("categories");
    statusRequest = handlingData(response);

    StatusRequest.success == statusRequest;
    categories.addAll(response);

    update();
  }
}
