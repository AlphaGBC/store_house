import 'package:store_house/core/class/crud.dart';
import 'package:store_house/linkapi.dart';

class TransferData {
  Crud crud;
  TransferData(this.crud);

  Future view() async {
    var response = await crud.postData(AppLink.transferView, {});
    return response.fold((l) => l, (r) => r);
  }

  Future add(Map data) async {
    var response = await crud.postJsonData(AppLink.transferAdd, data);
    return response.fold((l) => l, (r) => r);
  }
}
