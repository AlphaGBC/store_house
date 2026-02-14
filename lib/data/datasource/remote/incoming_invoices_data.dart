import 'package:store_house/core/class/crud.dart';
import 'package:store_house/linkapi.dart';

class IncomingInvoicesData {
  Crud crud;
  IncomingInvoicesData(this.crud);

  Future view() async {
    var response = await crud.postData(AppLink.incomingInvoicesview, {});
    return response.fold((l) => l, (r) => r);
  }

  Future add(Map data) async {
    var response = await crud.postData(AppLink.incomingInvoicesview, data);
    return response.fold((l) => l, (r) => r);
  }
}
