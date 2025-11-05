import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/result_controller.dart';
import '../../roadmap/view/roadmaps_page.dart';
import '../../../core/network/dio_client.dart';

class ResultPage extends StatefulWidget {
  final String userName;
  const ResultPage({super.key, required this.userName});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final ResultController controller = Get.put(ResultController());
  bool _genAcademic = false;
  bool _genNonAcademic = false;

  Future<void> _generate(String career, bool isAcademic) async {
    setState(() {
      if (isAcademic) {
        _genAcademic = true;
      } else {
        _genNonAcademic = true;
      }
    });
    try {
      await DioClient.dio.get('/user/roadmaps/$career');
      Get.to(() => const RoadmapsPage());
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) {
        setState(() {
          _genAcademic = false;
          _genNonAcademic = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Career Prediction Results"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.primary.withOpacity(0.15),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.celebration_rounded,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Congratulations, ${widget.userName}!",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Based on your input, we've found these career paths that suit you best",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Results Cards Section - Responsive layout
                      if (isSmallScreen)
                        // Column layout for small screens
                        Column(
                          children: [
                            _CareerCard(
                              title: "Academic-based Career",
                              career: controller.academicResult.value,
                              color: Colors.deepPurple,
                              icon: Icons.school_rounded,
                            ),
                            const SizedBox(height: 16),
                            _CareerCard(
                              title: "Personality Career",
                              career: controller.nonAcademicResult.value,
                              color: Colors.orange,
                              icon: Icons.work_rounded,
                            ),
                          ],
                        )
                      else
                        // Row layout for larger screens
                        Row(
                          children: [
                            Expanded(
                              child: _CareerCard(
                                title: "Academic-based Career",
                                career: controller.academicResult.value,
                                color: Colors.deepPurple,
                                icon: Icons.school_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _CareerCard(
                                title: "Personality-based Career",
                                career: controller.nonAcademicResult.value,
                                color: Colors.orange,
                                icon: Icons.work_rounded,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Action Buttons Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "What would you like to do next?",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Responsive button layout
                          isSmallScreen
                              ? Column(
                                  children: [
                                    _ActionButton(
                                      onPressed: () => Get.offAllNamed('/'),
                                      icon: Icons.restart_alt_rounded,
                                      label: "Start Over",
                                      isOutline: true,
                                      isLoading: false,
                                    ),
                                    const SizedBox(height: 12),
                                    _ActionButton(
                                      onPressed: _genAcademic
                                          ? null
                                          : () {
                                              final career = controller
                                                  .academicResult
                                                  .value
                                                  .replaceAll(' ', '-')
                                                  .replaceAll('\n', '');
                                              _generate(career, true);
                                            },
                                      icon: Icons.auto_graph_rounded,
                                      label:
                                          "${controller.academicResult.value.replaceAll('\n', '')} Roadmap",
                                      color: Colors.deepPurple,
                                      isLoading: _genAcademic,
                                    ),
                                    const SizedBox(height: 12),
                                    _ActionButton(
                                      onPressed: _genNonAcademic
                                          ? null
                                          : () {
                                              final career = controller
                                                  .nonAcademicResult
                                                  .value
                                                  .replaceAll(' ', '-')
                                                  .replaceAll('\n', '');
                                              _generate(career, false);
                                            },
                                      icon: Icons.trending_up_rounded,
                                      label:
                                          "${controller.nonAcademicResult.value.replaceAll('\n', ' ')} Roadmap",
                                      color: Colors.orange,
                                      isLoading: _genNonAcademic,
                                    ),
                                  ],
                                )
                              : Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    // Start Over Button
                                    _ActionButton(
                                      onPressed: () => Get.offAllNamed('/'),
                                      icon: Icons.restart_alt_rounded,
                                      label: "Start Over",
                                      isOutline: true,
                                      isLoading: false,
                                    ),

                                    // Academic Roadmap Button
                                    _ActionButton(
                                      onPressed: _genAcademic
                                          ? null
                                          : () {
                                              final career = controller
                                                  .academicResult
                                                  .value
                                                  .replaceAll(' ', '-');
                                              _generate(career, true);
                                            },
                                      icon: Icons.auto_graph_rounded,
                                      label: "Academic Roadmap",
                                      color: Colors.deepPurple,
                                      isLoading: _genAcademic,
                                    ),

                                    // Non-Academic Roadmap Button
                                    _ActionButton(
                                      onPressed: _genNonAcademic
                                          ? null
                                          : () {
                                              final career = controller
                                                  .nonAcademicResult
                                                  .value
                                                  .replaceAll(' ', '-');
                                              _generate(career, false);
                                            },
                                      icon: Icons.trending_up_rounded,
                                      label: "Personality Roadmap",
                                      color: Colors.orange,
                                      isLoading: _genNonAcademic,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Career Card Widget
class _CareerCard extends StatelessWidget {
  final String title;
  final String career;
  final Color color;
  final IconData icon;

  const _CareerCard({
    required this.title,
    required this.career,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  career,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Action Button Widget
class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color? color;
  final bool isLoading;
  final bool isOutline;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
    this.isLoading = false,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
