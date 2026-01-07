import 'package:store_house/controller/auth/login_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
import 'package:store_house/core/constant/imgaeasset.dart';
import 'package:store_house/core/functions/alertexitapp.dart';
import 'package:store_house/core/functions/validinput.dart';
import 'package:store_house/core/shared/custom_button.dart';
import 'package:store_house/core/shared/custom_text_form.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/view/widget/auth/password_field.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginControllerImp());
    return Scaffold(
      body: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            alertExitApp();
          }
        },
        child: GetBuilder<LoginControllerImp>(
          builder:
              (controller) => HandlingDataRequest(
                statusRequest: controller.statusRequest,
                widget: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 20,
                  ),
                  child: Form(
                    key: controller.formstate,
                    child: ListView(
                      children: [
                        // طريقة بسيطة داخل CircleAvatar -- الصورة ستتمدّد لملء الدائرة (قد تشوه)
                        CircleAvatar(
                          radius: 75, // => 150x150
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              AppImageAsset.logo,
                              width: 150,
                              height: 150,
                              fit:
                                  BoxFit
                                      .fill, // هنا السلوك الذي طلبته: يملأ الدائرة بالكامل (مع تشويه ممكن)
                            ),
                          ),
                        ),

                        customTextForm(
                          context,
                          "البريد الالكتروني",
                          "ادخل البريد الالكتروني",
                          null,
                          controller.email,
                          (val) {
                            return validInput(val!, 3, 50, "email");
                          },
                        ),
                        SizedBox(height: 10),

                        GetBuilder<LoginControllerImp>(
                          builder:
                              (controller) => PasswordField(
                                valid: (val) {
                                  return validInput(val!, 3, 30, "password");
                                },
                                controller: controller.password,
                                hintTexts: "ادخل كلمة المرور",
                                onPressed: () {
                                  controller.showPassword();
                                },
                                obscureText: controller.isshowpassword,
                              ),
                        ),
                        SizedBox(height: 15),
                        customButton(
                          context,
                          title: "تسجيل الدخول",
                          h: 55,
                          onPressed: () {
                            controller.login();
                          },
                          style: font10White500W(
                            context,
                            size: size_14(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
