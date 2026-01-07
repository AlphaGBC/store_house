import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/error_dialog.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';
import 'package:store_house/core/functions/handingdatacontroller.dart';
import 'package:store_house/core/services/services.dart';
import 'package:store_house/data/datasource/remote/auth/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:store_house/routes.dart';

abstract class LoginController extends GetxController {
  login();
}

class LoginControllerImp extends LoginController {
  LoginData loginData = LoginData(Get.find());

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController email;
  late TextEditingController password;

  bool isshowpassword = true;

  MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  showPassword() {
    isshowpassword = isshowpassword == true ? false : true;
    update();
  }

  @override
  login() async {
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();
      var response = await loginData.postdata(email.text, password.text);
      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          if (response['data']['admin_approve'].toString() == "1") {
            myServices.sharedPreferences.setString(
              "id",
              response['data']['admin_id'].toString(),
            );
            String userid = myServices.sharedPreferences.getString("id")!;
            myServices.sharedPreferences.setString(
              "username",
              response['data']['admin_name'],
            );
            myServices.sharedPreferences.setString(
              "email",
              response['data']['admin_email'],
            );
            myServices.sharedPreferences.setString(
              "phone",
              response['data']['admin_phone'],
            );
            myServices.sharedPreferences.setString("step", "2");

            FirebaseMessaging.instance.subscribeToTopic("admin");
            FirebaseMessaging.instance.subscribeToTopic("admin$userid");

            Get.offNamed(AppRoute.homepage);
          } else {
            FancySnackbar.show(
              title: "حسابك غير موثق",
              message: "اطلب التوثيق من مزود الخدمة.",
              isError: true,
            );
          }
        } else {
          errorDialog(
            titleKey: 'تحذير',
            messageKey: "البريد الالكتروني أو كلمة المرور غير صحيحة",
          );
          statusRequest = StatusRequest.failure;
        }
      }
      update();
    } else {}
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
