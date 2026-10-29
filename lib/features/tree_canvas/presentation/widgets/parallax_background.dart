import 'package:flutter/material.dart';

class ParallaxBackground extends StatelessWidget {
  final TransformationController controller;
  final bool isDark;

  const ParallaxBackground({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final matrix = controller.value;
        final dx = matrix.getTranslation().x;
        final dy = matrix.getTranslation().y;
        final scale = matrix.getMaxScaleOnAxis();

        final bgOffset = Offset(dx * 0.1, dy * 0.1);
        final patternOffset = Offset(dx * 0.3, dy * 0.3);

        return Stack(
          children: [
            Container(
              color: isDark ? const Color(0xFF0F1115) : const Color(0xFFF9F8F6),
            ),
            Positioned(
              left: bgOffset.dx,
              top: bgOffset.dy,
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  'assets/background/bg_stylized_tree.png',
                  width: 2048,
                  height: 2048,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const SizedBox(width: 2048, height: 2048),
                ),
              ),
            ),
            Positioned(
              left: patternOffset.dx - 1000,
              top: patternOffset.dy - 1000,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  isDark
                      ? 'assets/background/bg_grain_dark.png'
                      : 'assets/background/bg_grain_light.png',
                  repeat: ImageRepeat.repeat,
                  width: 4000,
                  height: 4000,
                  errorBuilder: (c, e, s) =>
                      const SizedBox(width: 4000, height: 4000),
                ),
              ),
            ),
            if (scale < 0.4)
              Container(
                color: (isDark ? Colors.black : Colors.white).withOpacity(
                  (0.4 - scale).clamp(0.0, 0.7),
                ),
              ),
          ],
        );
      },
    );
  }
}
