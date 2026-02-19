import 'package:get/get.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/sqflite.dart';
import '../../data/datasource/remote/transfer_data.dart';

class TransferController extends GetxController {
  TransferData transferData = TransferData(Get.find());
  SqlDb sqlDb = SqlDb();

  List<Map<String, dynamic>> allItems = [];
  Map<int, List<Map<String, dynamic>>> groupedTransfers = {};
  List<int> transferIds = [];

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
    var response = await sqlDb.read("transfer_of_itemsview");
    allItems = response.map((e) => Map<String, dynamic>.from(e)).toList();
    _groupAndFilter();
  }

  void _groupAndFilter() {
    groupedTransfers.clear();
    transferIds.clear();

    for (var item in allItems) {
      if (selectedDate != null) {
        String formattedDate =
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
        if (item["transfer_date"] == null ||
            !item["transfer_date"].toString().contains(formattedDate)) {
          continue;
        }
      }

      int id = item["transfer_id"];
      if (!groupedTransfers.containsKey(id)) {
        groupedTransfers[id] = [];
        transferIds.add(id);
      }
      groupedTransfers[id]!.add(item);
    }

    transferIds.sort((a, b) => b.compareTo(a));
    update();
  }

  Future<void> syncWithServer() async {
    try {
      var response = await transferData.view();
      var serverStatus = handlingData(response);

      if (StatusRequest.success == serverStatus &&
          response['status'] == "success") {
        List datalist = response["data"];
        await sqlDb.delete("transfer_of_itemsview", null);
        for (var item in datalist) {
          await sqlDb.insert(
            "transfer_of_itemsview",
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
