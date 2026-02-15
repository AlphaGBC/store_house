import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/functions/checkinternet.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';

// Basic Authentication Header
String _basicAuth = "Basic ${base64Encode(utf8.encode(':'))}";
Map<String, String> _myheaders = {"authorization": _basicAuth};

class Crud {
  // --- Retry Configuration ---
  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 5);
  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    if (!await checkInternet()) {
      return const Left(StatusRequest.offlinefailure);
    }

    // Loop to handle automatic retries
    for (int i = 0; i < maxRetries; i++) {
      try {
        var response = await http
            .post(Uri.parse(linkurl), body: data, headers: _myheaders)
            .timeout(const Duration(seconds: 30)); // Timeout for the request

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody); // Success
        } else {
          // Server responded with an error, no need to retry
          return const Left(StatusRequest.serverfailure);
        }
      } on TimeoutException {
        Get.snackbar("فشل الاتصال", "انتهت مهلة الطلب. جارٍ إعادة المحاولة...");
        await Future.delayed(retryDelay); // Wait before the next retry
      } on SocketException {
        Get.snackbar(
          "فشل الاتصال",
          "تحقق من اتصالك بالإنترنت. جارٍ إعادة المحاولة...",
        );
        await Future.delayed(retryDelay); // Wait before the next retry
      } catch (e) {
        FancySnackbar.show(
          title: "خطأ",
          message: "حدث خطأ. جاري إعادة المحاولة...",
          isError: true,
        );

        await Future.delayed(retryDelay); // Wait before the next retry
      }
    }

    // If all retries fail
    return const Left(StatusRequest.serverfailure);
  }

  Future<Either<StatusRequest, Map>> postJsonData(
    String linkurl,
    Map data,
  ) async {
    if (!await checkInternet()) {
      return const Left(StatusRequest.offlinefailure);
    }

    for (int i = 0; i < maxRetries; i++) {
      try {
        var response = await http
            .post(
              Uri.parse(linkurl),
              body: jsonEncode(data),
              headers: {..._myheaders, "Content-Type": "application/json"},
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } catch (e) {
        await Future.delayed(retryDelay);
      }
    }

    return const Left(StatusRequest.serverfailure);
  }

  Future<Either<StatusRequest, Map>> addRequestWithImageOne(
    String url,
    Map data,
    File? image, [
    String? namerequest,
  ]) async {
    if (!await checkInternet()) {
      return const Left(StatusRequest.offlinefailure);
    }

    File? imageToUpload = image;
    // Compress the image before uploading if it exists
    if (image != null) {
      // Get.snackbar("257".tr, "258".tr, showProgressIndicator: true);
      try {
        final tempDir = await getTemporaryDirectory();
        final targetPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          targetPath,
          quality: 70, // Adjust quality from 0 (lowest) to 100 (highest)
        );

        if (result != null) {
          imageToUpload = File(result.path);
        } else {
          // Compression failed, fallback to uploading the original image
          imageToUpload = image;
        }
      } catch (e) {
        Get.back(); // Close the "compressing" snackbar in case of error
        imageToUpload = image; // Fallback to original
      }
    }

    // Loop to handle automatic retries
    for (int i = 0; i < maxRetries; i++) {
      try {
        var uri = Uri.parse(url);
        var request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_myheaders);

        // Add the image file to the request if it exists
        if (imageToUpload != null) {
          var length = await imageToUpload.length();
          var stream = http.ByteStream(imageToUpload.openRead());
          stream.cast();
          var multipartFile = http.MultipartFile(
            namerequest ?? "files",
            stream,
            length,
            filename: basename(imageToUpload.path),
          );
          request.files.add(multipartFile);
        }

        // Add other data fields to the request, ensuring values are strings
        request.fields.addAll(
          data.map((key, value) => MapEntry(key.toString(), value.toString())),
        );

        // Send the request and get the response
        var myrequest = await request.send().timeout(
          const Duration(seconds: 80),
        ); // Longer timeout for uploads
        var response = await http.Response.fromStream(myrequest);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody); // Success
        } else {
          // Server responded, but with an error code. No need to retry.
          return const Left(StatusRequest.serverfailure);
        }
      } on TimeoutException {
        Get.snackbar("فشل التحميل", "انتهت مهلة الطلب. جارٍ إعادة المحاولة...");
        await Future.delayed(retryDelay); // Wait before next retry
      } on SocketException {
        Get.snackbar(
          "فشل الاتصال",
          "تحقق من اتصالك بالإنترنت. جارٍ إعادة المحاولة...",
        );
        await Future.delayed(retryDelay); // Wait before next retry
      } catch (e) {
        FancySnackbar.show(
          title: "خطأ".tr,
          message: "حدث خطأ. جاري إعادة المحاولة...",
          isError: true,
        );
        await Future.delayed(retryDelay); // Wait before next retry
      }
    }

    // If all retries fail
    return const Left(StatusRequest.serverfailure);
  }
}
