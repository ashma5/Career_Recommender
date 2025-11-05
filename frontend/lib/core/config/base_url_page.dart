import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_url_controller.dart';

class BaseUrlPage extends StatelessWidget {
  BaseUrlPage({super.key});
  final BaseUrlController controller = Get.put(BaseUrlController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_ethernet, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                "API Configuration",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Please enter the base URL for the API server",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller.urlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Base URL",
                  hintText: "e.g., https://api.example.com or localhost:8000",
                  prefixIcon: Icon(Icons.link),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.setBaseUrl(),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Text(
                "Examples:",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "• https://api.example.com\n• http://localhost:8000\n• 192.168.1.100:3000",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.setBaseUrl,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    controller.isLoading.value ? "Connecting..." : "Continue",
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
