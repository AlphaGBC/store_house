import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/core/services/services.dart';
import 'package:store_house/data/datasource/remote/usd_data.dart';
import 'package:store_house/data/model/usd_model.dart';
import 'package:store_house/routes.dart';
import 'package:store_house/sqflite.dart';

abstract class UsdController extends GetxController {}

class UsdControllerImp extends UsdController {
  String price = '0';

  List<UsdModel> data = [];

  UsdData usdData = UsdData(Get.find());

  MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  SqlDb sqlDb = SqlDb();

  @override
  void onInit() {
    getprice().whenComplete(() {
      readprice();
    });
    super.onInit();
  }

  getprice() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await usdData.view();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List datalist = response["data"];
        data.addAll(datalist.map((e) => UsdModel.fromJson(e)));
        List<Map> usd = await sqlDb.read("usd");
        if (usd.isEmpty) {
          int _ = await sqlDb.insert("usd", {
            "usd_id": data[0].usdId,
            "usd_price": data[0].usdPrice.toString(),
            "usd_data": data[0].usdData,
          });
        } else {
          int _ = await sqlDb.update("usd", {
            "usd_price": data[0].usdPrice.toString(),
          }, "usd_id = ${data[0].usdId}");
        }
      } else {
        statusRequest = StatusRequest.failure;
      }
    }

    update();
  }

  readprice() async {
    List<Map> rows = await sqlDb.read("usd");
    price = rows[0]['usd_price'].toString();
    update();
  }

  goToPageEdit() {
    Get.toNamed(AppRoute.usdEdit, arguments: {"price": price});
  }
}
