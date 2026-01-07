import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/util/app_dimensions.dart';

Text customText(
  BuildContext context, {
  int? maxLines,
  TextStyle? style,
  FontWeight? fontWeight,
  TextOverflow? textOverFlow,
  TextAlign? textAlign,
  required String text,
  double? size,
  Color? color,
  bool underline = false,
}) {
  return Text(
    text,
    textAlign: textAlign,
    overflow: textOverFlow,
    maxLines: maxLines,
    style:
        style ??
        TextStyle(
          fontWeight: fontWeight,
          fontSize: size ?? size_10(context),
          color: color ?? AppColor.black,
          decoration:
              underline ? TextDecoration.underline : TextDecoration.none,
        ),
  );
}
