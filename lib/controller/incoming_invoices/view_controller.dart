import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/sqflite.dart';
import '../../data/datasource/remote/incoming_invoices_data.dart';
import '../../data/model/incoming_invoices_model.dart';

class IncomingInvoicesController extends GetxController {
  IncomingInvoicesData incomingInvoicesData = IncomingInvoicesData(Get.find());
  SqlDb sqlDb = SqlDb();

  List<IncomingInvoicesModel> allItems = [];
  Map<int, List<IncomingInvoicesModel>> groupedInvoices = {};
  List<int> invoiceIds = [];

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

    await getLocalData();
    await syncWithServer();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> getLocalData() async {
    var response = await sqlDb.read("incoming_invoice_itemsview");
    allItems =
        response
            .map(
              (e) =>
                  IncomingInvoicesModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
    _groupAndFilter();
  }

  void _groupAndFilter() {
    groupedInvoices.clear();
    invoiceIds.clear();

    for (var item in allItems) {
      // Apply date filter if selected
      if (selectedDate != null) {
        String formattedDate =
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
        if (item.invoiceDate == null ||
            !item.invoiceDate!.contains(formattedDate)) {
          continue;
        }
      }

      int id = item.invoiceId!;
      if (!groupedInvoices.containsKey(id)) {
        groupedInvoices[id] = [];
        invoiceIds.add(id);
      }
      groupedInvoices[id]!.add(item);
    }

    // Sort invoice IDs descending (newest first)
    invoiceIds.sort((a, b) => b.compareTo(a));
    update();
  }

  Future<void> syncWithServer() async {
    try {
      var response = await incomingInvoicesData.view();
      var serverStatus = handlingData(response);

      if (StatusRequest.success == serverStatus &&
          response['status'] == "success") {
        List datalist = response["data"];
        await sqlDb.delete("incoming_invoice_itemsview", null);
        for (var item in datalist) {
          await sqlDb.insert(
            "incoming_invoice_itemsview",
            Map<String, Object?>.from(item),
          );
        }
        await getLocalData();
      }
    } catch (e) {
      print("Sync failed: $e");
    }
  }

  void setFilterDate(DateTime? date) {
    selectedDate = date;
    _groupAndFilter();
  }

  void clearFilter() {
    selectedDate = null;
    _groupAndFilter();
  }
}
