import 'dart:math' as math;
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

        // Скорости параллакса
        final particlesOffset = Offset(dx * 0.25, dy * 0.25);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Антикварное пергаментное полотно
            Positioned.fill(
              child: Image.asset(
                'assets/background/bg_parchment.jpg',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: isDark
                      ? const Color(0xFF0D1117)
                      : const Color(0xFFF7F2E7),
                ),
              ),
            ),
            // Мягкая тонировка пергамента для ночной темы
            if (isDark)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),

            // 2. Мягкая атмосферная подсветка пергамента
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      (particlesOffset.dx / 1200).clamp(-0.8, 0.8),
                      (particlesOffset.dy / 1200).clamp(-0.8, 0.8) - 0.2,
                    ),
                    radius: 1.3,
                    colors: [
                      (isDark
                              ? const Color(0xFF1B3B2B)
                              : const Color(0xFFD4AF37))
                          .withValues(alpha: isDark ? 0.20 : 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.75],
                  ),
                ),
              ),
            ),

            // 4. Парящая золотая пыльца и мерцающие споры
            Positioned.fill(
              child: CustomPaint(
                painter: _LivingSporesPainter(
                  offset: particlesOffset,
                  isDark: isDark,
                ),
              ),
            ),

            // 5. Виньетка по краям экрана для глубины
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.25,
                    colors: [
                      Colors.transparent,
                      (isDark
                              ? const Color(0xFF05070A)
                              : const Color(0xFFCDC2AE))
                          .withValues(alpha: 0.55),
                    ],
                    stops: const [0.65, 1.0],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Парящие споры и золотая пыльца рода
class _LivingSporesPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;

  _LivingSporesPainter({required this.offset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final goldColor =
        isDark ? const Color(0xFFE5C158) : const Color(0xFFB8860B);
    final paint = Paint()..style = PaintingStyle.fill;

    const count = 45;
    for (int i = 0; i < count; i++) {
      final seedX =
          (math.sin(i * 811.0) * 0.5 + 0.5) * (size.width + 600) - 300;
      final seedY =
          (math.cos(i * 577.0) * 0.5 + 0.5) * (size.height + 600) - 300;

      final x =
          (seedX + offset.dx * (0.9 + (i % 4) * 0.1)) % (size.width + 200) -
              100;
      final y =
          (seedY + offset.dy * (0.9 + (i % 4) * 0.1)) % (size.height + 200) -
              100;

      final radius = 1.0 + (i % 3) * 1.0;
      final alpha = isDark ? (0.25 + (i % 5) * 0.14) : (0.18 + (i % 5) * 0.1);

      paint.color = goldColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);

      if (radius > 2.0 && isDark) {
        paint.color = goldColor.withValues(alpha: 0.08);
        canvas.drawCircle(Offset(x, y), radius * 4.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LivingSporesPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}
