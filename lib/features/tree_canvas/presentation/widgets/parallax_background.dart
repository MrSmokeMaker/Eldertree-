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
        final scale = matrix.getMaxScaleOnAxis();

        final slowOffset = Offset(dx * 0.08, dy * 0.08);
        final midOffset = Offset(dx * 0.18, dy * 0.18);
        final fastOffset = Offset(dx * 0.32, dy * 0.32);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Базовый атмосферный градиент (глубокий оникс или пергамент)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    (slowOffset.dx / 1000).clamp(-0.8, 0.8),
                    (slowOffset.dy / 1000).clamp(-0.8, 0.8),
                  ),
                  radius: 1.4,
                  colors: isDark
                      ? const [
                          Color(0xFF16201B), // Глубокий отблеск кроны
                          Color(0xFF0F141A),
                          Color(0xFF08090C), // Темный оникс по краям
                        ]
                      : const [
                          Color(0xFFFFFDF8), // Теплый пергамент
                          Color(0xFFF7F3EA),
                          Color(0xFFECE5D7),
                        ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // 2. Вековые концентрические кольца древа и топографические линии
            Positioned.fill(
              child: CustomPaint(
                painter: _TreeRingsPainter(
                  offset: midOffset,
                  isDark: isDark,
                  scale: scale,
                ),
              ),
            ),

            // 3. Золотистая парящая пыльца / звезды предков
            Positioned.fill(
              child: CustomPaint(
                painter: _GoldDustPainter(
                  offset: fastOffset,
                  isDark: isDark,
                ),
              ),
            ),

            // 4. Текстура зернистости (Grain Overlay)
            Positioned(
              left: (fastOffset.dx % 500) - 500,
              top: (fastOffset.dy % 500) - 500,
              child: Opacity(
                opacity: isDark ? 0.05 : 0.04,
                child: Image.asset(
                  isDark
                      ? 'assets/background/bg_grain_dark.png'
                      : 'assets/background/bg_grain_light.png',
                  repeat: ImageRepeat.repeat,
                  width: 3000,
                  height: 3000,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ),

            // 5. Мягкая виньетка глубины горизонта
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      (isDark ? const Color(0xFF050608) : const Color(0xFFD4CBBB))
                          .withValues(alpha: 0.35),
                    ],
                    stops: const [0.7, 1.0],
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

/// Художественная отрисовка вековых годовых колец древа
class _TreeRingsPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;
  final double scale;

  _TreeRingsPainter({
    required this.offset,
    required this.isDark,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldBase = isDark ? const Color(0xFFD4AF37) : const Color(0xFF9E7E38);
    final center = Offset(size.width / 2 + offset.dx, size.height / 2 + offset.dy);

    final ringPaint = Paint()
      ..color = goldBase.withValues(alpha: isDark ? 0.05 : 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final accentRingPaint = Paint()
      ..color = goldBase.withValues(alpha: isDark ? 0.10 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Концентрические вековые эллиптические кольца
    for (int i = 1; i <= 14; i++) {
      final radiusX = i * 90.0;
      final radiusY = i * 75.0;
      final isAccent = i % 3 == 0;

      final path = Path();
      // Легкое органическое искажение кольца
      for (double angle = 0; angle <= 2 * math.pi; angle += 0.2) {
        final wobble = math.sin(angle * 3 + i) * 6.0;
        final x = center.dx + (radiusX + wobble) * math.cos(angle);
        final y = center.dy + (radiusY + wobble) * math.sin(angle);
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, isAccent ? accentRingPaint : ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreeRingsPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.isDark != isDark ||
        oldDelegate.scale != scale;
  }
}

/// Отрисовка парящей золотистой пыльцы
class _GoldDustPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;

  _GoldDustPainter({
    required this.offset,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldColor = isDark ? const Color(0xFFE5C158) : const Color(0xFFC59B27);
    final dustPaint = Paint()..style = PaintingStyle.fill;

    // Псевдослучайные, но стабильные координаты золотых светящихся частиц
    const int count = 35;
    for (int i = 0; i < count; i++) {
      final seedX = (math.sin(i * 997.0) * 0.5 + 0.5) * size.width * 2 - size.width * 0.5;
      final seedY = (math.cos(i * 733.0) * 0.5 + 0.5) * size.height * 2 - size.height * 0.5;

      final x = (seedX + offset.dx * (0.8 + (i % 5) * 0.1)) % (size.width + 100) - 50;
      final y = (seedY + offset.dy * (0.8 + (i % 5) * 0.1)) % (size.height + 100) - 50;

      final radius = 1.0 + (i % 3) * 0.8;
      final alpha = isDark ? (0.2 + (i % 4) * 0.15) : (0.15 + (i % 4) * 0.1);

      dustPaint.color = goldColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, dustPaint);

      // Легкое свечение вокруг крупных частиц
      if (radius > 1.8 && isDark) {
        dustPaint.color = goldColor.withValues(alpha: 0.08);
        canvas.drawCircle(Offset(x, y), radius * 3.5, dustPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GoldDustPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}
