import 'package:store_house/core/class/crud.dart';
import 'package:store_house/linkapi.dart';

class WholesaleData {
  Crud crud;
  WholesaleData(this.crud);

  add(Map data) async {
    var response = await crud.postData(AppLink.wholesaleadd, data);
    return response.fold((l) => l, (r) => r);
  }

  view() async {
    var response = await crud.postData(AppLink.wholesaleview, {});
    return response.fold((l) => l, (r) => r);
  }

  delete(Map data) async {
    var response = await crud.postData(AppLink.wholesaledelete, data);
    return response.fold((l) => l, (r) => r);
  }
}
