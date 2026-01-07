import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/shared/custom_text_field.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';

Widget customTextForm(
  BuildContext context,
  String title,
  String labelText,
  Widget? suffixIcon,
  TextEditingController? controller,
  String? Function(String?)? valid, {
  TextInputType? keyboardType, // <- باراميتر اختياري مسمّى (اختياري)
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      customText(
        context,
        text: title,
        style: font10Black500W(context, size: size_14(context)),
      ),
      SizedBox(height: 5),
      CustomTextField(
        suffixIcon: suffixIcon,
        suffixColor: AppColor.secondaryColor,
        validator: valid,
        labelText: labelText,
        borderColor: AppColor.gryColor_3,
        controller: controller,
        // مرّر القيمة إن وُجدت، وإلا استخدم الافتراضية داخل CustomTextField
        keyboardType: keyboardType ?? TextInputType.text,
      ),
    ],
  );
}
