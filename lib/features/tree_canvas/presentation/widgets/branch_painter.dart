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
    const emeraldDeep = Color(0xFF183326);

    final barkBase = isDark ? emeraldDeep : const Color(0xFF2C3E33);
    final goldAccent = isDark ? goldPrimary : const Color(0xFFB38822);
    final leafGreen =
        isDark ? const Color(0xFF3B7D58) : const Color(0xFF2E754E);

    const cardRadius = 64.0; // Половина ширины карточки-медальона (128px)

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

      // 1. Родительская связь (Рост от корней снизу к кроне вверху)
      if (rel.relationshipType == RelationshipType.parent) {
        // node1 — родитель, node2 — ребенок
        // В нашей модели роста:
        // Родитель находится ниже (больший Y, ближе к корням/стволу)
        // Ребенок находится выше (меньший Y, в кроне)
        final isParentBelow = p1.dy >= p2.dy;
        final startP = isParentBelow ? p1 : p2; // Нижняя точка (ствол/родитель)
        final endP = isParentBelow ? p2 : p1; // Верхняя точка (крона/ребенок)

        final level = (isParentBelow ? node2.level : node1.level);

        // Расчет органической толщины ветви:
        // Глубокие корни/ствол (level >= 1) — толстые ветви (12-16px)
        // Уровень пользователя (level == 0) — 9-11px
        // Молодые побеги в кроне (level <= -1) — 4-7px
        double branchThickness;
        if (level >= 1) {
          branchThickness = 14.0;
        } else if (level == 0) {
          branchThickness = 10.0;
        } else if (level == -1) {
          branchThickness = 7.0;
        } else {
          branchThickness = 4.5;
        }

        final startY = startP.dy - cardRadius + 10;
        final endY = endP.dy + cardRadius - 10;

        final path = Path()..moveTo(startP.dx, startY);

        // Органический s-образный изгиб ветви дуба
        final controlDistY = (startY - endY).abs() * 0.55;
        final wobbleX = math.sin((startP.dx + endP.dx) * 0.02) * 22.0;

        path.cubicTo(
          startP.dx + wobbleX * 0.6,
          startY - controlDistY,
          endP.dx - wobbleX * 0.4,
          endY + controlDistY,
          endP.dx,
          endY,
        );

        // А. Мягкая объемная тень ветви
        final shadowPaint = Paint()
          ..color = (isDark ? Colors.black : const Color(0xFF6E6457))
              .withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = branchThickness + 5.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, shadowPaint);

        // Б. Тело ветви (кора)
        final barkPaint = Paint()
          ..color = barkBase
          ..style = PaintingStyle.stroke
          ..strokeWidth = branchThickness
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, barkPaint);

        // В. Золотая сердцевина / световая жила рода
        final goldCorePaint = Paint()
          ..color = goldAccent.withValues(alpha: isDark ? 0.8 : 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, branchThickness * 0.25)
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, goldCorePaint);

        // Г. Лиственные кластеры на ветви (чем выше в крону, тем гуще листва)
        final midX = (startP.dx + endP.dx) / 2 + wobbleX * 0.3;
        final midY = (startY + endY) / 2;
        _drawOakLeafSprig(
          canvas,
          Offset(midX, midY),
          leafGreen,
          goldAccent,
          isUpperCanopy: level <= 0,
        );

        // Д. Ложе/поддерживающий сучок под верхним медальоном
        _drawBranchSupportFoot(canvas, Offset(endP.dx, endY), branchThickness,
            barkBase, goldAccent);
      } else if (rel.relationshipType == RelationshipType.spouse) {
        // 2. Супружеская ветвь (боковое переплетение на одном ярусе)
        final isLeftToRight = p1.dx < p2.dx;
        final startX =
            isLeftToRight ? p1.dx + cardRadius - 6 : p1.dx - cardRadius + 6;
        final endX =
            isLeftToRight ? p2.dx - cardRadius + 6 : p2.dx + cardRadius - 6;

        final path = Path()..moveTo(startX, p1.dy + 8);
        final midX = (startX + endX) / 2;
        final arcDipY = p1.dy + 42.0;

        path.quadraticBezierTo(midX, arcDipY, endX, p2.dy + 8);

        // Тень
        final spouseShadow = Paint()
          ..color = (isDark ? Colors.black : const Color(0xFF6E6457))
              .withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawPath(path, spouseShadow);

        // Ветвь союза
        final spouseBranch = Paint()
          ..color = barkBase
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, spouseBranch);

        final spouseGold = Paint()
          ..color = goldAccent.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawPath(path, spouseGold);

        // Брачные переплетенные кольца в центре дуги союза
        _drawWeddingWreath(
            canvas, Offset(midX, arcDipY - 14), goldAccent, leafGreen, isDark);
      }
    }
  }

  /// Ложе ветви, на котором покоится медальон персоны
  void _drawBranchSupportFoot(
    Canvas canvas,
    Offset pos,
    double branchWidth,
    Color barkColor,
    Color goldColor,
  ) {
    final supportPaint = Paint()
      ..color = barkColor
      ..style = PaintingStyle.fill;

    final goldCap = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;

    // Расширение ветви под основанием карточки
    final rect = Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + 2), width: branchWidth + 8, height: 6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), supportPaint);
    canvas.drawCircle(Offset(pos.dx, pos.dy), 2.5, goldCap);
  }

  /// Кластер дубовых листьев с золотыми прожилками на развилке ветви
  void _drawOakLeafSprig(
    Canvas canvas,
    Offset pos,
    Color greenColor,
    Color goldColor, {
    required bool isUpperCanopy,
  }) {
    final leafFill = Paint()
      ..color = greenColor.withValues(alpha: isDark ? 0.9 : 0.85)
      ..style = PaintingStyle.fill;

    final goldVein = Paint()
      ..color = goldColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // Левый дубовый листик
    final leftLeaf = Path()
      ..moveTo(pos.dx, pos.dy)
      ..cubicTo(pos.dx - 12, pos.dy - 6, pos.dx - 18, pos.dy - 1, pos.dx - 16,
          pos.dy + 5)
      ..cubicTo(
          pos.dx - 12, pos.dy + 10, pos.dx - 4, pos.dy + 4, pos.dx, pos.dy);
    canvas.drawPath(leftLeaf, leafFill);
    canvas.drawPath(leftLeaf, goldVein);

    // Правый листик
    final rightLeaf = Path()
      ..moveTo(pos.dx, pos.dy)
      ..cubicTo(pos.dx + 12, pos.dy - 6, pos.dx + 18, pos.dy - 1, pos.dx + 16,
          pos.dy + 5)
      ..cubicTo(
          pos.dx + 12, pos.dy + 10, pos.dx + 4, pos.dy + 4, pos.dx, pos.dy);
    canvas.drawPath(rightLeaf, leafFill);
    canvas.drawPath(rightLeaf, goldVein);

    // Золотой желудь / почка на верхушке ветви
    if (isUpperCanopy) {
      final acornPaint = Paint()
        ..color = goldColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pos.dx, pos.dy - 2), 2.8, acornPaint);
    }
  }

  /// Брачный венок с кольцами союза
  void _drawWeddingWreath(
    Canvas canvas,
    Offset center,
    Color goldColor,
    Color leafColor,
    bool isDark,
  ) {
    const ringRadius = 7.5;

    final glow = Paint()
      ..color = goldColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final ringBorder = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final leftCenter = Offset(center.dx - 4.5, center.dy);
    final rightCenter = Offset(center.dx + 4.5, center.dy);

    // Свечение
    canvas.drawCircle(leftCenter, ringRadius, glow);
    canvas.drawCircle(rightCenter, ringRadius, glow);

    // Сами кольца
    canvas.drawCircle(leftCenter, ringRadius, ringBorder);
    canvas.drawCircle(rightCenter, ringRadius, ringBorder);

    // Маленькие листики союза по бокам
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 16, center.dy), 2.2, leafPaint);
    canvas.drawCircle(Offset(center.dx + 16, center.dy), 2.2, leafPaint);
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hiddenNodeIds != hiddenNodeIds;
  }
}
