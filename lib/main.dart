import 'package:jiffy/jiffy.dart';
import 'package:store_house/bindings/intialbindings.dart';
import 'package:store_house/core/constant/apptheme.dart';
import 'package:store_house/core/services/services.dart';
import 'package:store_house/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Jiffy.setLocale("ar");
  await initialServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store House',
      locale: Locale("ar"),
      theme: themeArabic,
      initialBinding: InitialBindings(),
      getPages: routes,
    );
  }
}
