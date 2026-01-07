import 'package:flutter/material.dart';
import 'package:store_house/core/constant/color.dart';
import 'package:store_house/core/util/text_styles.dart';

class CustomAppBar extends StatelessWidget {
  final void Function()? onPressedSearch;
  final void Function(String)? onChanged;
  final TextEditingController mycontroller;
  const CustomAppBar({
    super.key,
    this.onPressedSearch,
    this.onChanged,
    required this.mycontroller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primaryColor,
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          bottom: 10,
          right: 17,
          left: 17,
        ),
        child: buildSearchRow(
          context,
          mycontroller,
          onChanged,
          onPressedSearch,
        ),
      ),
    );
  }
}

Widget buildSearchRow(
  BuildContext context,
  TextEditingController mycontroller,
  Function(String)? onChanged,
  Function()? onPressedSearch,
) {
  return SizedBox(
    height: 46,
    width: 292,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: mycontroller,
      builder: (context, value, child) {
        final hasText = value.text.trim().isNotEmpty;
        return TextField(
          controller: mycontroller,
          onChanged: onChanged,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.webSearch,
          textInputAction: TextInputAction.search,
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              onPressedSearch?.call();
            }
          },
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: hasText ? onPressedSearch : null,
            ),
            // زر المسح يظهر فقط إذا يوجد نص
            suffixIcon:
                hasText
                    ? IconButton(
                      icon: const Icon(Icons.clear_outlined, size: 15),
                      onPressed: () {
                        mycontroller.clear();
                        // إخطار النداء الخارجي أن النص أصبح فارغًا
                        onChanged?.call('');
                        // إذا أردت فقدان/الحفاظ على الفوكس يمكنك تعديل السطر التالي:
                        // FocusScope.of(context).unfocus(); // لفقدان الفوكس بعد المسح
                      },
                    )
                    : null,
            hintText: "البحث عن المنتجات...",
            hintStyle: font10Grey300W(context, size: 8),
            filled: true,
            fillColor: AppColor.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: font10Black400W(context),
        );
      },
    ),
  );
}
