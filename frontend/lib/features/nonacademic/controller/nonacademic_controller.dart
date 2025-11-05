import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../result/controller/result_controller.dart';

class NonAcademicController extends GetxController {
  var currentQuestion = 0.obs;
  final questions = [
    {
      "key": "Linguistic",
      "question":
          "How comfortable are you with expressing your ideas clearly in writing or speech? For example, do you find it easy to write essays, tell stories, or explain complex topics to others?",
    },
    {
      "key": "Musical",
      "question":
          "How much do you enjoy or excel at music, singing, or playing instruments?",
    },
    {
      "key": "Bodily",
      "question":
          "How skilled are you at sports, dance, or using your body to solve problems?",
    },
    {
      "key": "Logical_Mathematical",
      "question":
          "How comfortable are you with solving puzzles, logical problems, or math challenges?",
    },
    {
      "key": "Spacial_Visualization",
      "question":
          "How well can you visualize objects, spaces, or directions in your mind?",
    },
    {
      "key": "Interpersonal",
      "question":
          "How easily do you connect with others, work in teams, or understand people's feelings?",
    },
    {
      "key": "Intrapersonal",
      "question":
          "How well do you understand your own feelings, motivations, and goals?",
    },
    {
      "key": "Naturalist",
      "question":
          "How interested are you in nature, animals, or environmental issues?",
    },
  ];
  var answers = <String, int>{
    "Linguistic": 0,
    "Musical": 0,
    "Bodily": 0,
    "Logical_Mathematical": 0,
    "Spacial_Visualization": 0,
    "Interpersonal": 0,
    "Intrapersonal": 0,
    "Naturalist": 0,
  }.obs;

  void setAnswer(String key, int value) {
    answers[key] = value;
    update();
  }

  void nextQuestion() {
    if (currentQuestion.value < questions.length - 1) currentQuestion.value++;
  }

  void prevQuestion() {
    if (currentQuestion.value > 0) currentQuestion.value--;
  }

  void reset() {
    currentQuestion.value = 0;
    answers.updateAll((key, value) => 0);
    update();
  }

  Future<void> submit() async {
    final response = await DioClient.dio.post(
      '/nonacademic/predict-career',
      data: answers,
    );
    ResultController.to.setNonAcademicResult(response.data['predicted_career']);
  }
}
