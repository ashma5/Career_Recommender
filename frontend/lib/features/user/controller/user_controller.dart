import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../academic/view/academic_questions_page.dart';

class UserController extends GetxController {
  final nameController = TextEditingController();

  void onNameSubmitted() {
    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      Get.to(() => AcademicQuestionsPage(userName: name));
    } else {
      Get.snackbar("Error", "Please enter your name");
    }
  }
}
