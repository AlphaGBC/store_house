import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/util/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool? dottedBorder;
  final String? Function(String?)? validator;
  final double? padding;
  final double? horizontalPadding;
  final bool? readOnly;
  final String? initialValue;
  final Color? borderColor;
  final double? radius;
  final Color? suffixColor;
  final double? borderWidth;
  final Color? enableBorderColor;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.dottedBorder,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.padding,
    this.readOnly,
    this.initialValue,
    this.borderColor,
    this.radius,
    this.suffixColor,
    this.horizontalPadding,
    this.borderWidth,
    this.enableBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        cursorColor: enableBorderColor ?? AppColor.primaryColor,
        readOnly: readOnly ?? false,
        initialValue: initialValue,
        clipBehavior: Clip.hardEdge,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: AppColor.black),
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: suffixIcon,
          suffixIconColor: suffixColor,
          prefixIcon: prefixIcon,
          prefixIconColor: AppColor.gryColor_5,
          labelStyle: font10Grey400W(context),
          contentPadding: EdgeInsets.symmetric(
            vertical: padding ?? 20,
            horizontal: horizontalPadding ?? 20,
          ),
          enabledBorder:
              dottedBorder ?? false
                  ? OutlineInputBorder(borderSide: BorderSide.none)
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      radius != null ? radius! : 8,
                    ),
                    borderSide: BorderSide(
                      color: borderColor ?? AppColor.black,
                      width: borderWidth ?? 1,
                    ),
                  ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: enableBorderColor ?? AppColor.primaryColor,
              width: borderWidth ?? 1,
            ),
          ),
          border:
              dottedBorder ?? false
                  ? OutlineInputBorder(borderSide: BorderSide.none)
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: borderWidth ?? 1),
                  ),
        ),
      ),
    );
  }
}
