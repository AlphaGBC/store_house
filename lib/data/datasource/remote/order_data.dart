import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/linkapi.dart';

/// OrderCardsData fetches order card data from the server for the parent app.
class OrderCardsData {
  OrderCardsData();

  /// Fetch orders with optional filters.
  /// Returns a List<Map> on success, or a StatusRequest value on failure.
  Future<dynamic> getOrders({
    int? poSource,
    int? customerType, // 1 = wholesale, 0 = retail, null = all
  }) async {
    // Build query parameters - convert all to strings
    final Map<String, String> queryParams = {};
    if (poSource != null) queryParams['pos_source'] = poSource.toString();
    if (customerType != null) {
      queryParams['customer_type'] = customerType.toString();
    }

    // Build URL with query parameters
    final uri = Uri.parse(
      AppLink.vieworder,
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    // Basic auth header
    final String basicAuth = 'Basic ${base64Encode(utf8.encode(':'))}';
    final Map<String, String> headers = {'authorization': basicAuth};

    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 5);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final parsed = jsonDecode(response.body);

          if (parsed is Map) {
            if (parsed['status'] == 'success') {
              final rawData = parsed['data'];
              // Coerce rawData into a List to handle both array and object responses
              List dataList;
              if (rawData == null) {
                dataList = [];
              } else if (rawData is List) {
                dataList = rawData;
              } else if (rawData is Map) {
                // Server sent object instead of array; convert values to list
                try {
                  dataList = rawData.values.toList();
                } catch (e) {
                  if (kDebugMode) {
                    print('Failed to convert Map to List: $e');
                  }
                  dataList = [];
                }
              } else {
                dataList = [];
              }

              return dataList;
            } else {
              return StatusRequest.serverfailure;
            }
          } else if (parsed is List) {
            // Server returned a bare list
            return parsed;
          } else {
            // Unexpected type (e.g., integer or string)

            return StatusRequest.serverfailure;
          }
        } else {
          return StatusRequest.serverfailure;
        }
      } on TimeoutException {
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      } on SocketException {
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      }
    }

    return StatusRequest.serverfailure;
  }
}
