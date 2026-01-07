import 'dart:io';

import 'package:store_house/core/class/crud.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/linkapi.dart';
import 'package:dartz/dartz.dart';

class CategoriesData {
  Crud crud;
  CategoriesData(this.crud);

  add(Map data, File file) async {
    var response = await crud.addRequestWithImageOne(
      AppLink.categoriesadd,
      data,
      file,
    );
    return response.fold((l) => l, (r) => r);
  }

  view() async {
    var response = await crud.postData(AppLink.categoriesview, {});
    return response.fold((l) => l, (r) => r);
  }

  upgrade(Map payload) async {
    var response = await crud.postData(AppLink.categoriesupgrade, payload);
    return response.fold((l) => l, (r) => r);
  }

  // addupgrade(Map data) async {
  //   var response = await crud.postData(AppLink.categoriesaddupgrade, data);
  //   return response.fold((l) => l, (r) => r);
  // }

  delete(Map data) async {
    var response = await crud.postData(AppLink.categoriesdelete, data);
    return response.fold((l) => l, (r) => r);
  }

  edit(Map data) async {
    Either<StatusRequest, Map> response;
    response = await crud.postData(AppLink.categoriesedit, data);

    return response.fold((l) => l, (r) => r);
  }
}
