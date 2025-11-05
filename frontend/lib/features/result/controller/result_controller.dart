import 'package:get/get.dart';

class ResultController extends GetxController {
  static ResultController get to => Get.find();
  var academicResult = "".obs;
  var nonAcademicResult = "".obs;

  void setAcademicResult(String result) {
    academicResult.value = result;
  }

  void setNonAcademicResult(String result) {
    nonAcademicResult.value = result;
  }
}
