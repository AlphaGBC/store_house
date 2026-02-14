import 'package:store_house/core/constant/color.dart';
import 'package:flutter/material.dart';

ThemeData themeArabic = ThemeData(
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColor.white,
  ),
  cardColor: AppColor.white,
  cardTheme: CardThemeData(color: AppColor.white),
  scaffoldBackgroundColor: AppColor.white,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColor.primaryColor,
  ),
  iconTheme: IconThemeData(color: AppColor.secondaryColor),

  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColor.white),
    titleTextStyle: TextStyle(
      color: AppColor.white,
      fontWeight: FontWeight.w700,
      fontFamily: "ReadexPro",
      fontSize: 20,
    ),
    backgroundColor: AppColor.primaryColor,
  ),
  fontFamily: "ReadexPro",
  primarySwatch: Colors.green,
);
