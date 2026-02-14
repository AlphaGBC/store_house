import 'package:store_house/core/class/crud.dart';
import 'package:store_house/linkapi.dart';

class SupplierData {
  Crud crud;
  SupplierData(this.crud);

  Future add(Map data) async {
    var response = await crud.postData(AppLink.supplieradd, data);
    return response.fold((l) => l, (r) => r);
  }

  Future view() async {
    var response = await crud.postData(AppLink.supplierview, {});
    return response.fold((l) => l, (r) => r);
  }

  Future delete(Map data) async {
    var response = await crud.postData(AppLink.supplierdelete, data);
    return response.fold((l) => l, (r) => r);
  }
}
