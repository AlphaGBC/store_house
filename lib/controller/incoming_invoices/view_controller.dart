import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/sqflite.dart';
import '../../data/datasource/remote/incoming_invoices_data.dart';
import '../../data/model/incoming_invoices_model.dart';

class IncomingInvoicesController extends GetxController {
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());
  SqlDb sqlDb = SqlDb();

  List<IncomingInvoicesModel> data = [];
  List<IncomingInvoicesModel> filteredData = [];

  StatusRequest statusRequest = StatusRequest.none;
  DateTime? selectedDate;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    statusRequest = StatusRequest.loading;
    update();

    // 1. Load from Local Database first
    await getLocalData();

    // 2. Try to sync with Server if online
    await syncWithServer();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> getLocalData() async {
    var response = await sqlDb.read("incoming_invoice_itemsview");
    data =
        response
            .map(
              (e) =>
                  IncomingInvoicesModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
    applyFilter();
  }

  Future<void> syncWithServer() async {
    try {
      var response = await incomingInvoicesData.view();
      var serverStatus = handlingData(response);

      if (StatusRequest.success == serverStatus &&
          response['status'] == "success") {
        List datalist = response["data"];

        // Clear local table and insert fresh data from server to keep it in sync
        // Note: In a production app, you might want a more sophisticated sync (delta sync)
        await sqlDb.delete("incoming_invoice_itemsview", null);

        for (var item in datalist) {
          await sqlDb.insert(
            "incoming_invoice_itemsview",
            Map<String, Object?>.from(item),
          );
        }

        // Reload local data after sync
        await getLocalData();
      }
    } catch (e) {
      print("Sync failed: $e");
    }
  }

  void applyFilter() {
    if (selectedDate == null) {
      filteredData = List.from(data);
    } else {
      String formattedDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      filteredData =
          data
              .where(
                (item) =>
                    item.invoiceDate != null &&
                    item.invoiceDate!.contains(formattedDate),
              )
              .toList();
    }
    update();
  }

  void setFilterDate(DateTime? date) {
    selectedDate = date;
    applyFilter();
  }

  void clearFilter() {
    selectedDate = null;
    applyFilter();
  }
}
