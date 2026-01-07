import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/util/text_styles.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintTexts;
  final bool obscureText;
  final Function() onPressed;
  final String? Function(String?) valid;
  const PasswordField({
    super.key,
    required this.controller,
    required this.hintTexts,
    required this.onPressed,
    required this.obscureText,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColor.primaryColor,
        ),
      ),
      child: TextFormField(
        validator: valid,
        controller: controller,
        obscureText: obscureText == false ? false : true,
        decoration: InputDecoration(
          hintText: hintTexts,
          hintStyle: font10Grey400W(context),
          suffixIcon: IconButton(
            onPressed: onPressed,
            icon:
                obscureText == false
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility_outlined),
          ),
          filled: false,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColor.silver, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColor.primaryColor, width: 2.5),
          ),
        ),
      ),
    );
  }
}
