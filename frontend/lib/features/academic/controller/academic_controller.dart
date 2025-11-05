import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../result/controller/result_controller.dart';

class AcademicController extends GetxController {
  var genderSelection = [true, false].obs;
  // var extracurricular = [true, false].obs;
  var extracurricular = 0.obs;
  final subjects = [
    "math_score",
    "history_score",
    "physics_score",
    "chemistry_score",
    "biology_score",
    "english_score",
    "geography_score",
  ];
  final subjectLabels = {
    "math_score": "Math",
    "history_score": "History",
    "physics_score": "Physics",
    "chemistry_score": "Chemistry",
    "biology_score": "Biology",
    "english_score": "English",
    "geography_score": "Geography",
  };
  var scores = <String, int>{}.obs;

  AcademicController() {
    for (var s in subjects) {
      scores[s] = 0;
    }
  }

  void setGender(int idx) {
    for (int i = 0; i < genderSelection.length; i++) {
      genderSelection[i] = i == idx;
    }
  }

  void setExtracurricular(int value) {
    extracurricular.value = value;
    update();
  }

  void setScore(String subject, int value) {
    scores[subject] = value;
    update();
  }

  Future<void> submit() async {
    final gender = genderSelection.indexWhere((e) => e);
    final data = {
      "gender": gender,
      "extracurricular_activities": extracurricular.value,
      ...scores,
    };
    final response = await DioClient.dio.post(
      '/academic/predict-career',
      data: data,
    );
    ResultController.to.setAcademicResult(response.data['predicted_career']);
  }
}
