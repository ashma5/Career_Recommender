import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/academic_controller.dart';
import '../../nonacademic/view/nonacademic_questions_page.dart';

class AcademicQuestionsPage extends StatelessWidget {
  final String userName;
  AcademicQuestionsPage({super.key, required this.userName});
  final AcademicController controller = Get.put(AcademicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Academic Quiz")),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              "Select your gender:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PremiumGenderButton(
                  label: "Male",
                  selected: controller.genderSelection[0],
                  onTap: () => controller.setGender(0),
                  icon: Icons.male,
                ),
                const SizedBox(width: 16),
                _PremiumGenderButton(
                  label: "Female",
                  selected: controller.genderSelection[1],
                  onTap: () => controller.setGender(1),
                  icon: Icons.female,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Do you participate in extracurricular activities?",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PremiumToggleButton(
                  label: "No",
                  selected: controller.extracurricular.value == 0,
                  onTap: () => controller.setExtracurricular(0),
                  icon: Icons.close,
                ),
                const SizedBox(width: 16),
                _PremiumToggleButton(
                  label: "Yes",
                  selected: controller.extracurricular.value == 1,
                  onTap: () => controller.setExtracurricular(1),
                  icon: Icons.check,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...controller.subjects.map(
              (subject) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your ${controller.subjectLabels[subject]} marks:",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  _PremiumNumberField(
                    value: controller.scores[subject]!,
                    onChanged: (val) => controller.setScore(subject, val),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool loadingShown = false;
                try {
                  // Show a modern loading overlay
                  loadingShown = true;
                  Get.dialog(
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                  await controller.submit();
                  if (loadingShown) Get.back(); // Remove loading overlay
                  Get.to(() => NonAcademicQuestionsPage(userName: userName));
                } catch (e) {
                  if (loadingShown) Get.back();
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: const [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Submission Failed"),
                        ],
                      ),
                      content: Text(
                        "Could not submit your academic data. ${e.toString()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      // actions: [
                      //   TextButton(
                      //     onPressed: () => Get.back(),
                      //     child: const Text("Cancel"),
                      //   ),
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       Get.back();
                      //       // Retry
                      //       FocusScope.of(context).unfocus();
                      //       Future.delayed(
                      //         const Duration(milliseconds: 100),
                      //         () {
                      //           // Re-trigger the button
                      //           (context as Element).markNeedsBuild();
                      //         },
                      //       );
                      //     },
                      //     child: const Text("Retry"),
                      //   ),
                      // ],
                    ),
                    barrierDismissible: true,
                  );
                }
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumGenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  const _PremiumGenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  const _PremiumToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumNumberField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PremiumNumberField({required this.value, required this.onChanged});
  @override
  State<_PremiumNumberField> createState() => _PremiumNumberFieldState();
}

class _PremiumNumberFieldState extends State<_PremiumNumberField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _PremiumNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value.toString() != _controller.text) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      onChanged: (val) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 0 && parsed <= 100) {
          widget.onChanged(parsed);
        }
      },
    );
  }
}
