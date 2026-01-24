import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:store_house/linkapi.dart';

class IssuedInvoicesData {
  // 1. دالة الرفع (POST) - ترسل JSON خام
  Future<dynamic> uploadInvoice(Map data) async {
    try {
      if (kDebugMode) print("Sending POST to: ${AppLink.issuedinvoicesAdd}");
      String body = jsonEncode(data);

      var response = await http
          .post(
            Uri.parse(AppLink.issuedinvoicesAdd),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "failure",
          "message": "Server Error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": "failure", "message": "Connection Error: $e"};
    }
  }

  // 2. دالة الجلب (GET) - تجلب البيانات من السيرفر
  Future<dynamic> viewInvoices() async {
    try {
      if (kDebugMode) print("Sending GET to: ${AppLink.issuedinvoicesview}");

      var response = await http
          .get(
            Uri.parse(AppLink.issuedinvoicesview),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "failure",
          "message": "Server Error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": "failure", "message": "Connection Error: $e"};
    }
  }
}
