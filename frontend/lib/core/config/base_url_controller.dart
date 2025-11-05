import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../../features/auth/view/login_page.dart';

class BaseUrlController extends GetxController {
  final urlController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    urlController.text = '';
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }

  Future<void> setBaseUrl() async {
    final baseUrl = urlController.text.trim();
    if (baseUrl.isNotEmpty) {
      isLoading.value = true;

      try {
        // Update the Dio client with the new base URL
        DioClient.updateBaseUrl(baseUrl);

        // Test the connection
        final isConnected = await DioClient.testConnection();

        if (isConnected) {
          Get.snackbar(
            "Success",
            "Connected to API server successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Navigate to login page to authenticate
          Get.to(() => LoginPage());
        } else {
          Get.snackbar(
            "Connection Failed",
            "Could not connect to the API server. Please check the URL and try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to connect: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar(
        "Error",
        "Please enter a valid base URL",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // No persistence for base URL by design
}
