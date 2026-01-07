import 'package:flutter/material.dart';
import 'package:store_house/core/shared/custom_text.dart';
import 'package:store_house/core/util/app_dimensions.dart';
import 'package:store_house/core/util/text_styles.dart';

class Cardadmin extends StatelessWidget {
  final void Function()? onTap;
  final String url;
  final String title;
  final bool isSelected;

  const Cardadmin({
    super.key,
    required this.onTap,
    required this.url,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              isSelected
                  ? BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.primary,
                  )
                  : BorderSide(color: Colors.transparent),
        ),
        elevation: isSelected ? 8 : 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(child: Image.asset(url, width: 80)),
            SizedBox(height: 5),
            customText(
              context,
              text: title,
              style: font10Black600W(context, size: size_12(context)),
            ),
          ],
        ),
      ),
    );
  }
}
