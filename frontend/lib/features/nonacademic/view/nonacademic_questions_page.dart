import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/nonacademic_controller.dart';
import '../../result/view/result_page.dart';

class NonAcademicQuestionsPage extends StatelessWidget {
  final String userName;
  NonAcademicQuestionsPage({super.key, required this.userName}) {
    controller.reset();
  }
  final NonAcademicController controller = Get.put(NonAcademicController());

  static const List<_FaceMood> moods = [
    _FaceMood(0, "😐", Colors.grey),
    _FaceMood(5, "🙂", Colors.blueGrey),
    _FaceMood(10, "😊", Colors.blue),
    _FaceMood(15, "😃", Colors.purple),
    _FaceMood(20, "🤩", Colors.deepPurple),
  ];

  _FaceMood _getMood(int value) {
    if (value <= 2) return moods[0];
    if (value <= 7) return moods[1];
    if (value <= 12) return moods[2];
    if (value <= 17) return moods[3];
    return moods[4];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personality Quiz")),
      body: Obx(() {
        final idx = controller.currentQuestion.value;
        final q = controller.questions[idx];
        final answer = controller.answers[q['key']]!;
        final mood = _getMood(answer);
        final total = controller.questions.length;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${idx + 1}/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: const Color(0xFFF3F0FA), // Soft neutral background
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      q['question']!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: mood.color.withOpacity(0.18),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: mood.color.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        mood.emoji,
                        key: ValueKey(mood.emoji),
                        style: TextStyle(fontSize: 56, color: mood.color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 22,
                    color: mood.color,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text("$answer/20"),
                ),
                const SizedBox(height: 16),
                _AnimatedSlider(
                  value: answer.toDouble(),
                  onChanged: (val) =>
                      controller.setAnswer(q['key']!, val.round()),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (idx > 0)
                      ElevatedButton(
                        onPressed: controller.prevQuestion,
                        child: const Text("Back"),
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        if (idx < controller.questions.length - 1) {
                          controller.nextQuestion();
                        } else {
                          await controller.submit();
                          Get.to(() => ResultPage(userName: userName));
                        }
                      },
                      child: Text(
                        idx < controller.questions.length - 1
                            ? "Next"
                            : "See Result",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FaceMood {
  final int value;
  final String emoji;
  final Color color;
  const _FaceMood(this.value, this.emoji, this.color);
}

class _AnimatedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _AnimatedSlider({required this.value, required this.onChanged});

  Color _getThumbColor(double v) {
    // Match the gradient stops
    if (v <= 4) return Colors.red;
    if (v <= 8) return Colors.orange;
    if (v <= 12) return Colors.yellow;
    if (v <= 16) return Colors.green;
    if (v <= 18) return Colors.blue;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        trackShape: _GradientSliderTrackShape(),
        thumbShape: _GlowingThumbShape(color: _getThumbColor(value)),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 20,
        divisions: 20,
        onChanged: onChanged,
      ),
    );
  }
}

class _GradientSliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx + 16;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 32;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset, // Added for Flutter compatibility
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ).createShader(trackRect);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(4)),
      paint,
    );
  }
}

class _GlowingThumbShape extends SliderComponentShape {
  final Color color;
  const _GlowingThumbShape({this.color = Colors.deepPurple});
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    Offset? secondaryOffset,
  }) {
    final Canvas canvas = context.canvas;
    // Glow
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Thumb
    canvas.drawCircle(center, 14, Paint()..color = color);
  }
}
