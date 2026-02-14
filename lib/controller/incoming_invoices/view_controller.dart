import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';

import '../../data/datasource/remote/incoming_invoices_data.dart';
import '../../data/model/incoming_invoices_model.dart';

class IncomingInvoicesController extends GetxController {
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());

  List<IncomingInvoicesModel> data = [];

  late StatusRequest statusRequest;

  Future<void> getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    var response = await incomingInvoicesData.view();

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      // Start backend
      if (response['status'] == "success") {
        List datalist = response["data"];
        data.addAll(datalist.map((e) => IncomingInvoicesModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
      // End
    }
    update();
  }

  // void goToPageEdit(CategoriesModel categoriesModel) {
  //   Get.toNamed(
  //     AppRoute.categoriesedit,
  //     arguments: {"CategoriesModel": categoriesModel},
  //   );
  // }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
