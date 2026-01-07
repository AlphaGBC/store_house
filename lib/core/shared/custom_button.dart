import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';

Widget customButton(
  BuildContext context, {
  double? h,
  double? w,
  double? borderwidth,
  Color? buttoncolor,
  Color? bordersidecolor,
  Color? textcolor,
  FontWeight? fontweight,
  double? fontSize,
  TextStyle? style,
  IconData? icon,
  Color? iconcolor,
  TextAlign? textAlign,
  bool isIcon = false,
  required String title,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    height: h ?? 62,
    width: w ?? widthmedia(context),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttoncolor ?? AppColor.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: bordersidecolor ?? AppColor.blue,
            width: borderwidth ?? 2,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customText(
            context,
            text: title,
            textAlign: textAlign,
            style: style,
            color: textcolor ?? AppColor.white,
            size: fontSize ?? size_14(context),
          ),
          isIcon ? SizedBox(width: 10) : SizedBox.shrink(),
          isIcon ? Icon(icon, size: 24, color: iconcolor) : SizedBox.shrink(),
        ],
      ),
    ),
  );
}
