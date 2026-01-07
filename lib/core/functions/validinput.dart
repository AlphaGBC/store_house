import 'package:get/get.dart';

String? validInput(String val, int min, int max, String type) {
  if (type == "username") {
    final usernameRegEx = RegExp(
      r'^[A-Za-z0-9_.\-\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF ]+$',
    );

    if (!usernameRegEx.hasMatch(val)) {
      return "اسم المستخدم غير صالح";
    }
  }

  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "بريد إلكتروني غير صالح";
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "رقم هاتف غير صالح";
    }
  }

  if (val.isEmpty) {
    return "لا يمكن ترك الحقل فارغًا";
  }

  if (val.length < min) {
    return "can't be less than $min";
  }

  if (val.length > max) {
    return "can't be larger than $max";
  }

  return null; // صالح
}
