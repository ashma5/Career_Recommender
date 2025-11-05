import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/config/base_url_page.dart';
import 'features/auth/view/login_page.dart';
import 'features/home/view/home_page.dart';
import 'features/result/controller/result_controller.dart';

void main() {
  Get.put(ResultController(), permanent: true);
  runApp(const CareerApp());
}

class CareerApp extends StatelessWidget {
  const CareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Career Predictor',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<_StartDest>(
        future: _determineStart(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final dest = snapshot.data!;
          switch (dest) {
            case _StartDest.baseUrl:
              return BaseUrlPage();
            case _StartDest.login:
              return const LoginPage();
            case _StartDest.home:
              return const HomePage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<_StartDest> _determineStart() async {
    // Always prompt for Base URL first, then proceed to login/home
    return _StartDest.baseUrl;
  }
}

enum _StartDest { baseUrl, login, home }
