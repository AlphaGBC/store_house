import 'package:store_house/core/class/crud.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/linkapi.dart';
import 'package:dartz/dartz.dart';

class ItemsData {
  Crud crud;
  ItemsData(this.crud);

  view(String categoriesid) async {
    var response = await crud.postData(AppLink.itemsview, {
      "categoriesid": categoriesid,
    });
    return response.fold((l) => l, (r) => r);
  }

  add(Map data) async {
    var response = await crud.postData(AppLink.itemsadd, data);
    return response.fold((l) => l, (r) => r);
  }

  upgrade(Map payload) async {
    var response = await crud.postData(AppLink.itemsupgrade, payload);
    return response.fold((l) => l, (r) => r);
  }

  delete(Map data) async {
    var response = await crud.postData(AppLink.itemsdelete, data);
    return response.fold((l) => l, (r) => r);
  }

  edit(Map data) async {
    Either<StatusRequest, Map> response;
    response = await crud.postData(AppLink.itemsedit, data);

    return response.fold((l) => l, (r) => r);
  }
}
