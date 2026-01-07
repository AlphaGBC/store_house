import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';

class Custombuttomlarge extends StatelessWidget {
  final String languageName;
  final String sampleText;
  final String url;
  final Color bordercolor;
  final void Function() onPressed;

  const Custombuttomlarge({
    super.key,
    required this.languageName,
    required this.sampleText,
    required this.onPressed,
    required this.url,
    required this.bordercolor,
  });

  @override
  Widget build(BuildContext context) {
    // استخدمنا GestureDetector لجعل الحاوية بأكملها قابلة للنقر
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(10.0),
          // تغيير لون الحدود بناءً على ما إذا كانت البطاقة محددة أم لا
          border: Border.all(color: bordercolor, width: 2),
        ),
        child: Row(
          children: [
            ClipOval(child: Image.asset(url, width: 60, height: 60)),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  context,
                  text: languageName,
                  style: font10primaryColor600W(
                    context,
                    size: size_14(context),
                  ),
                ),
                const SizedBox(height: 8),
                customText(
                  context,
                  text: sampleText,
                  style: font10Black300W(context, size: size_8(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
