import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/graph_node.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/relationship_model.dart';

class BranchPainter extends CustomPainter {
  final Map<String, GraphNode> nodes;
  final List<RelationshipModel> relationships;
  final bool isDark;
  final Set<String> hiddenNodeIds;

  BranchPainter({
    required this.nodes,
    required this.relationships,
    required this.isDark,
    required this.hiddenNodeIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF3E5AB);
    const emeraldCore = Color(0xFF1E3A2F);
    const barkDark = Color(0xFF231B15);

    final branchBaseColor = isDark ? emeraldCore : const Color(0xFF384E44);
    final goldAccent = isDark ? goldPrimary : const Color(0xFFB8860B);

    // 1. Тень ветвей для объема
    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF8C8275)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..strokeCap = StrokeCap.round;

    // 2. Основная ветвь (ствол)
    final mainBranchPaint = Paint()
      ..color = branchBaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    // 3. Золотая жила рода (внутренняя световая нить)
    final goldCorePaint = Paint()
      ..color = goldAccent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // 4. Супружеская связь
    final spouseArcPaint = Paint()
      ..color = goldAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const cardRadius = 60.0;

    for (var rel in relationships) {
      if (hiddenNodeIds.contains(rel.member1Id) ||
          hiddenNodeIds.contains(rel.member2Id)) {
        continue;
      }

      final node1 = nodes[rel.member1Id];
      final node2 = nodes[rel.member2Id];
      if (node1 == null || node2 == null) continue;

      final p1 = node1.position;
      final p2 = node2.position;

      final path = Path();

      if (rel.relationshipType == RelationshipType.parent) {
        final startY = p1.dy + cardRadius;
        final endY = p2.dy - cardRadius;

        path.moveTo(p1.dx, startY);
        path.cubicTo(
          p1.dx,
          startY + 90,
          p2.dx,
          endY - 90,
          p2.dx,
          endY,
        );

        // Рисуем тень -> основную ветвь -> золотую жилу
        canvas.drawPath(path, shadowPaint);
        canvas.drawPath(path, mainBranchPaint);
        canvas.drawPath(path, goldCorePaint);

        // Декоративный геральдический золотой росток/листик на развилке
        final midY = (startY + endY) / 2;
        final midX = (p1.dx + p2.dx) / 2;
        _drawGoldenLeafCluster(canvas, Offset(midX, midY), isDark ? goldLight : goldPrimary);

      } else if (rel.relationshipType == RelationshipType.spouse) {
        final isLeftToRight = p1.dx < p2.dx;
        final startX = isLeftToRight ? p1.dx + cardRadius : p1.dx - cardRadius;
        final endX = isLeftToRight ? p2.dx - cardRadius : p2.dx + cardRadius;

        path.moveTo(startX, p1.dy);
        path.quadraticBezierTo(
          (startX + endX) / 2,
          p1.dy + 35,
          endX,
          p2.dy,
        );

        canvas.drawPath(path, shadowPaint);
        canvas.drawPath(path, spouseArcPaint);

        // Переплетенные золотые брачные кольца союза
        final ringCenter = Offset((startX + endX) / 2, p1.dy + 18);
        _drawIntertwinedWeddingRings(canvas, ringCenter, goldAccent, isDark);
      }
    }
  }

  /// Отрисовка двух переплетенных золотых колец
  void _drawIntertwinedWeddingRings(
    Canvas canvas,
    Offset center,
    Color goldColor,
    bool isDark,
  ) {
    const ringRadius = 7.0;

    final ringFill = Paint()
      ..color = (isDark ? const Color(0xFF161A22) : const Color(0xFFFFFDF8))
      ..style = PaintingStyle.fill;

    final ringBorder = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final glow = Paint()
      ..color = goldColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final leftCenter = Offset(center.dx - 4.5, center.dy);
    final rightCenter = Offset(center.dx + 4.5, center.dy);

    // Свечение
    canvas.drawCircle(leftCenter, ringRadius, glow);
    canvas.drawCircle(rightCenter, ringRadius, glow);

    // Заливка и контуры колец
    canvas.drawCircle(leftCenter, ringRadius, ringFill);
    canvas.drawCircle(leftCenter, ringRadius, ringBorder);

    canvas.drawCircle(rightCenter, ringRadius, ringFill);
    canvas.drawCircle(rightCenter, ringRadius, ringBorder);

    // Центральная точка союза
    final unionDot = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, unionDot);
  }

  /// Отрисовка золотого ростка жизни на родительской ветви
  void _drawGoldenLeafCluster(Canvas canvas, Offset pos, Color goldColor) {
    final leafPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final leafBorder = Paint()
      ..color = const Color(0xFF1B3B2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Маленький левый листик
    final leftLeaf = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx - 7, pos.dy - 6, pos.dx - 10, pos.dy - 2)
      ..quadraticBezierTo(pos.dx - 6, pos.dy + 3, pos.dx, pos.dy);
    canvas.drawPath(leftLeaf, leafPaint);
    canvas.drawPath(leftLeaf, leafBorder);

    // Маленький правый листик
    final rightLeaf = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + 7, pos.dy - 6, pos.dx + 10, pos.dy - 2)
      ..quadraticBezierTo(pos.dx + 6, pos.dy + 3, pos.dx, pos.dy);
    canvas.drawPath(rightLeaf, leafPaint);
    canvas.drawPath(rightLeaf, leafBorder);

    // Центральная жемчужина-почка
    final budPaint = Paint()
      ..color = const Color(0xFFFFF9E6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 2.2, budPaint);
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hiddenNodeIds != hiddenNodeIds;
  }
}
