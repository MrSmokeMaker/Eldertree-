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

        // Раздельные скорости параллакса для глубины пространства
        final farOffset = Offset(dx * 0.05, dy * 0.05);
        final midOffset = Offset(dx * 0.12, dy * 0.12);
        final nearOffset = Offset(dx * 0.22, dy * 0.22);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Небесный атмосферный градиент (от кроны вверху к корням внизу)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Color(0xFF0D1C16), // Изумрудное сияние кроны вверху
                          Color(0xFF0F141B), // Сумерки ствола
                          Color(0xFF07090C), // Глубинный оникс у корней
                        ]
                      : const [
                          Color(0xFFF4F9F4), // Светлое небо сквозь крону
                          Color(0xFFF9F7F1), // Теплый пергамент
                          Color(0xFFEDE6D8), // Земляное основание у корней
                        ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // 2. Силуэт великого векового дуба (Trunk, Canopy, Roots)
            Positioned.fill(
              child: CustomPaint(
                painter: _GrandTreeSilhouettePainter(
                  offset: midOffset,
                  isDark: isDark,
                  scale: scale,
                ),
              ),
            ),

            // 3. Вековые годовые кольца и солнечные лучи сквозь листву
            Positioned.fill(
              child: CustomPaint(
                painter: _GodRaysAndRingsPainter(
                  offset: farOffset,
                  isDark: isDark,
                ),
              ),
            ),

            // 4. Парящая золотистая пыльца и светлячки
            Positioned.fill(
              child: CustomPaint(
                painter: _LivingSporesPainter(
                  offset: nearOffset,
                  isDark: isDark,
                ),
              ),
            ),

            // 5. Тонкая зернистость пергамента / холста
            Positioned(
              left: (nearOffset.dx % 400) - 400,
              top: (nearOffset.dy % 400) - 400,
              child: Opacity(
                opacity: isDark ? 0.04 : 0.035,
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

            // 6. Виньетка по краям экрана
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.3,
                    colors: [
                      Colors.transparent,
                      (isDark ? const Color(0xFF040608) : const Color(0xFFCFC4B0))
                          .withValues(alpha: 0.4),
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

/// Художественный силуэт ствола, корней и кроны векового древа
class _GrandTreeSilhouettePainter extends CustomPainter {
  final Offset offset;
  final bool isDark;
  final double scale;

  _GrandTreeSilhouettePainter({
    required this.offset,
    required this.isDark,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy + 80;

    final treeGold = isDark ? const Color(0xFFD4AF37) : const Color(0xFFB58A28);
    final treeEmerald = isDark ? const Color(0xFF1B3B2B) : const Color(0xFF3B5D4D);

    // 1. Крона вверху (пышные полупрозрачные купола листьев)
    final canopyPaint = Paint()
      ..color = treeEmerald.withValues(alpha: isDark ? 0.08 : 0.06)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35.0);

    canvas.drawCircle(Offset(centerX, centerY - 450), 380, canopyPaint);
    canvas.drawCircle(Offset(centerX - 240, centerY - 380), 280, canopyPaint);
    canvas.drawCircle(Offset(centerX + 240, centerY - 380), 280, canopyPaint);
    canvas.drawCircle(Offset(centerX, centerY - 620), 260, canopyPaint);

    // 2. Силуэт могучего ствола (Trunk)
    final trunkPath = Path();
    // Корни внизу (y = centerY + 500)
    trunkPath.moveTo(centerX - 180, centerY + 650);
    // Корневые лапы
    trunkPath.cubicTo(centerX - 130, centerY + 450, centerX - 70, centerY + 250, centerX - 45, centerY);
    // Главная развилка в крону
    trunkPath.cubicTo(centerX - 60, centerY - 150, centerX - 180, centerY - 300, centerX - 320, centerY - 480);
    trunkPath.lineTo(centerX - 270, centerY - 500);
    trunkPath.cubicTo(centerX - 140, centerY - 320, centerX - 25, centerY - 200, centerX, centerY - 140);
    trunkPath.cubicTo(centerX + 25, centerY - 200, centerX + 140, centerY - 320, centerX + 270, centerY - 500);
    trunkPath.lineTo(centerX + 320, centerY - 480);
    trunkPath.cubicTo(centerX + 180, centerY - 300, centerX + 60, centerY - 150, centerX + 45, centerY);
    // Правая сторона ствола к корням
    trunkPath.cubicTo(centerX + 70, centerY + 250, centerX + 130, centerY + 450, centerX + 180, centerY + 650);
    trunkPath.close();

    final trunkPaint = Paint()
      ..color = treeEmerald.withValues(alpha: isDark ? 0.06 : 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawPath(trunkPath, trunkPaint);

    // Тонкие золотистые прожилки и годовые контуры ствола
    final trunkVeinPaint = Paint()
      ..color = treeGold.withValues(alpha: isDark ? 0.07 : 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final veinPath = Path()
      ..moveTo(centerX - 30, centerY + 550)
      ..cubicTo(centerX - 20, centerY + 300, centerX - 15, centerY + 100, centerX - 10, centerY - 50)
      ..cubicTo(centerX - 10, centerY - 180, centerX - 100, centerY - 320, centerX - 200, centerY - 440);
    canvas.drawPath(veinPath, trunkVeinPaint);

    final veinPath2 = Path()
      ..moveTo(centerX + 30, centerY + 550)
      ..cubicTo(centerX + 20, centerY + 300, centerX + 15, centerY + 100, centerX + 10, centerY - 50)
      ..cubicTo(centerX + 10, centerY - 180, centerX + 100, centerY - 320, centerX + 200, centerY - 440);
    canvas.drawPath(veinPath2, trunkVeinPaint);
  }

  @override
  bool shouldRepaint(covariant _GrandTreeSilhouettePainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}

/// Солнечные лучи и золотые кольца времени
class _GodRaysAndRingsPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;

  _GodRaysAndRingsPainter({required this.offset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2 + offset.dx;
    final topY = offset.dy - 100;
    final gold = isDark ? const Color(0xFFE5C158) : const Color(0xFFC59A27);

    // Мягкие диагональные световые полосы (God Rays) из верхней кроны
    final rayPaint = Paint()
      ..color = gold.withValues(alpha: isDark ? 0.025 : 0.035)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30.0);

    for (int i = -3; i <= 3; i++) {
      final rayPath = Path()
        ..moveTo(centerX + i * 160, topY)
        ..lineTo(centerX + i * 320 + 250, size.height + 200)
        ..lineTo(centerX + i * 320 + 120, size.height + 200)
        ..close();
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GodRaysAndRingsPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}

/// Парящие споры и золотая пыльца рода
class _LivingSporesPainter extends CustomPainter {
  final Offset offset;
  final bool isDark;

  _LivingSporesPainter({required this.offset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final goldColor = isDark ? const Color(0xFFE5C158) : const Color(0xFFB8860B);
    final paint = Paint()..style = PaintingStyle.fill;

    const count = 40;
    for (int i = 0; i < count; i++) {
      final seedX = (math.sin(i * 811.0) * 0.5 + 0.5) * (size.width + 600) - 300;
      final seedY = (math.cos(i * 577.0) * 0.5 + 0.5) * (size.height + 600) - 300;

      final x = (seedX + offset.dx * (0.9 + (i % 4) * 0.1)) % (size.width + 200) - 100;
      final y = (seedY + offset.dy * (0.9 + (i % 4) * 0.1)) % (size.height + 200) - 100;

      final radius = 1.0 + (i % 3) * 0.9;
      final alpha = isDark ? (0.2 + (i % 5) * 0.12) : (0.15 + (i % 5) * 0.08);

      paint.color = goldColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);

      if (radius > 2.0 && isDark) {
        paint.color = goldColor.withValues(alpha: 0.07);
        canvas.drawCircle(Offset(x, y), radius * 4.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LivingSporesPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isDark != isDark;
  }
}
