import 'package:store_house/core/class/crud.dart';
import 'package:store_house/linkapi.dart';

class UsdData {
  Crud crud;
  UsdData(this.crud);

  view() async {
    var response = await crud.postData(AppLink.usdview, {});
    return response.fold((l) => l, (r) => r);
  }

  edit(Map data) async {
    var response = await crud.postData(AppLink.usdedit, data);
    return response.fold((l) => l, (r) => r);
  }
}
