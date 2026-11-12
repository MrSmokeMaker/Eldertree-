import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/graph_node.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/relationship_model.dart';

/// Мастер-пейнтэр живого ботанического дуба (Botanical Family Tree)
/// Рисует настоящий ствол, мощные корни в пергаменте, скелетные ветви и листву
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
    final visibleNodes = nodes.values
        .where((n) => !hiddenNodeIds.contains(n.id))
        .toList();
    if (visibleNodes.isEmpty) return;

    // Палитра благородного векового дуба
    final barkDark = isDark ? const Color(0xFF1E130B) : const Color(0xFF2A180E);
    final barkMid = isDark ? const Color(0xFF3E2718) : const Color(0xFF55341E);
    final barkLight = isDark ? const Color(0xFF5A3B24) : const Color(0xFF75492A);
    final woodGrain = isDark ? const Color(0xFF7E5434) : const Color(0xFF96633E);
    final goldLight = isDark ? const Color(0xFFD4AF37) : const Color(0xFFDFB743);
    final leafGreen = isDark ? const Color(0xFF235438) : const Color(0xFF2E6B47);
    final leafLight = isDark ? const Color(0xFF387A54) : const Color(0xFF488F63);

    // 1. Поиск основания древа (самое нижнее поколение предков / максимальный dy)
    double maxDy = -999999;
    for (var n in visibleNodes) {
      if (n.position.dy > maxDy) maxDy = n.position.dy;
    }
    final baseNodes = visibleNodes
        .where((n) => (n.position.dy - maxDy).abs() < 50)
        .toList();

    double baseCenterX = 0.0;
    if (baseNodes.isNotEmpty) {
      baseCenterX = baseNodes.map((n) => n.position.dx).reduce((a, b) => a + b) /
          baseNodes.length;
    }

    // 2. ОТРИСОВКА МОГУЧИХ КОРНЕЙ И ОСНОВАНИЯ СТВОЛА В ПЕРГАМЕНТЕ (Grand Roots)
    _drawGrandRootsAndTrunkBase(
      canvas,
      Offset(baseCenterX, maxDy),
      barkDark,
      barkMid,
      barkLight,
      woodGrain,
      goldLight,
      leafGreen,
    );

    // 3. Сбор супружеских пар и родительских союзов
    final Map<String, String> spouseMap = {};
    for (var rel in relationships) {
      if (rel.relationshipType == RelationshipType.spouse &&
          !hiddenNodeIds.contains(rel.member1Id) &&
          !hiddenNodeIds.contains(rel.member2Id)) {
        spouseMap[rel.member1Id] = rel.member2Id;
        spouseMap[rel.member2Id] = rel.member1Id;
      }
    }

    // Отрисовка горизонтальных ветвей союза (Spouse Branches)
    final Set<String> drawnSpouses = {};
    for (var rel in relationships) {
      if (rel.relationshipType == RelationshipType.spouse) {
        if (hiddenNodeIds.contains(rel.member1Id) ||
            hiddenNodeIds.contains(rel.member2Id)) {
          continue;
        }
        final pairKey = [rel.member1Id, rel.member2Id]..sort();
        final keyStr = pairKey.join('_');
        if (drawnSpouses.contains(keyStr)) continue;
        drawnSpouses.add(keyStr);

        final n1 = nodes[rel.member1Id];
        final n2 = nodes[rel.member2Id];
        if (n1 == null || n2 == null) continue;

        _drawSpouseUnionBranch(
          canvas,
          n1.position,
          n2.position,
          barkDark,
          barkMid,
          woodGrain,
          goldLight,
          leafGreen,
        );
      }
    }

    // 4. Группировка детей по родительским союзам для органичного роста ствола и ветвей
    // Map: parentUnionId -> List of children
    final Map<String, List<GraphNode>> parentChildGroups = {};
    final Map<String, Offset> unionCenterMap = {};

    for (var rel in relationships) {
      if (rel.relationshipType == RelationshipType.parent) {
        if (hiddenNodeIds.contains(rel.member1Id) ||
            hiddenNodeIds.contains(rel.member2Id)) {
          continue;
        }

        final parent = nodes[rel.member1Id];
        final child = nodes[rel.member2Id];
        if (parent == null || child == null) continue;

        // Если у родителя есть супруг(а), группируем под единым союзом
        final spouseId = spouseMap[parent.id];
        final GraphNode? spouse = spouseId != null ? nodes[spouseId] : null;

        String unionId;
        Offset unionPos;
        if (spouse != null && !hiddenNodeIds.contains(spouse.id)) {
          final sortedIds = [parent.id, spouse.id]..sort();
          unionId = 'union_${sortedIds.join('_')}';
          unionPos = Offset(
            (parent.position.dx + spouse.position.dx) / 2,
            math.max(parent.position.dy, spouse.position.dy),
          );
        } else {
          unionId = 'parent_${parent.id}';
          unionPos = parent.position;
        }

        unionCenterMap[unionId] = unionPos;
        parentChildGroups.putIfAbsent(unionId, () => []);
        if (!parentChildGroups[unionId]!.any((c) => c.id == child.id)) {
          parentChildGroups[unionId]!.add(child);
        }
      }
    }

    // 5. ОТРИСОВКА СТВОЛА И ВЕТВЕЙ К ПОТОМКАМ (Trunk & Ascending Branches)
    for (var entry in parentChildGroups.entries) {
      final unionId = entry.key;
      final children = entry.value;
      final startPos = unionCenterMap[unionId]!;

      // Сортируем детей по X слева направо
      children.sort((a, b) => a.position.dx.compareTo(b.position.dx));

      if (children.length == 1) {
        // Одиночный ребенок — мощный ствол/ветвь тянется прямо к нему с S-изгибом
        final child = children.first;
        _drawOrganicBranch(
          canvas,
          startPos,
          child.position,
          thickness: 38.0,
          endThickness: 20.0,
          barkDark: barkDark,
          barkMid: barkMid,
          woodGrain: woodGrain,
          goldLight: goldLight,
          leafGreen: leafGreen,
          leafLight: leafLight,
          level: child.level,
        );
      } else {
        // Несколько детей — ствол поднимается вверх до развилки (Fork), затем веером ветвей
        final avgChildY = children.map((c) => c.position.dy).reduce((a, b) => a + b) / children.length;
        final avgChildX = children.map((c) => c.position.dx).reduce((a, b) => a + b) / children.length;
        
        final forkY = startPos.dy + (avgChildY - startPos.dy) * 0.48;
        final forkPos = Offset(
          startPos.dx + (avgChildX - startPos.dx) * 0.35,
          forkY,
        );

        // Главный ствол от родителей до развилки
        _drawOrganicBranch(
          canvas,
          startPos,
          forkPos,
          thickness: 48.0,
          endThickness: 34.0,
          barkDark: barkDark,
          barkMid: barkMid,
          woodGrain: woodGrain,
          goldLight: goldLight,
          leafGreen: leafGreen,
          leafLight: leafLight,
          level: 0,
          isTrunkSegment: true,
        );

        // Ветви от развилки к каждому ребенку
        for (var child in children) {
          _drawOrganicBranch(
            canvas,
            forkPos,
            child.position,
            thickness: 30.0,
            endThickness: 18.0,
            barkDark: barkDark,
            barkMid: barkMid,
            woodGrain: woodGrain,
            goldLight: goldLight,
            leafGreen: leafGreen,
            leafLight: leafLight,
            level: child.level,
          );
        }

        // Пышный дубовый кластер на самой развилке ствола
        _drawLushOakCluster(canvas, forkPos, leafGreen, leafLight, goldLight, count: 5);
      }
    }
  }

  /// Отрисовка вековых корней дуба и расширяющегося комля ствола у основания
  void _drawGrandRootsAndTrunkBase(
    Canvas canvas,
    Offset basePos,
    Color barkDark,
    Color barkMid,
    Color barkLight,
    Color woodGrain,
    Color goldLight,
    Color leafGreen,
  ) {
    final trunkTopY = basePos.dy + 40;
    final groundY = basePos.dy + 160;

    // 1. Комель ствола дуба (расширение к земле)
    final trunkPath = Path()
      ..moveTo(basePos.dx - 48, trunkTopY)
      ..cubicTo(
        basePos.dx - 55,
        trunkTopY + 50,
        basePos.dx - 90,
        groundY - 30,
        basePos.dx - 110,
        groundY,
      )
      ..lineTo(basePos.dx + 110, groundY)
      ..cubicTo(
        basePos.dx + 90,
        groundY - 30,
        basePos.dx + 55,
        trunkTopY + 50,
        basePos.dx + 48,
        trunkTopY,
      )
      ..close();

    // Тень комля
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.45 : 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(trunkPath, shadowPaint);

    // Заливка древесины комля
    final trunkFill = Paint()
      ..shader = LinearGradient(
        colors: [barkDark, barkMid, barkLight, barkMid, barkDark],
        stops: const [0.0, 0.25, 0.5, 0.78, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(basePos.dx - 110, trunkTopY, 220, groundY - trunkTopY));
    canvas.drawPath(trunkPath, trunkFill);

    // Прожилки коры на комле
    final striationPaint = Paint()
      ..color = woodGrain.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = -3; i <= 3; i++) {
      final sPath = Path()
        ..moveTo(basePos.dx + i * 14.0, trunkTopY + 5)
        ..cubicTo(
          basePos.dx + i * 18.0 + math.sin(i * 1.5) * 8,
          trunkTopY + 50,
          basePos.dx + i * 26.0,
          groundY - 20,
          basePos.dx + i * 32.0,
          groundY,
        );
      canvas.drawPath(sPath, striationPaint);
    }

    // 2. Могучие корни дуба, уходящие в пергамент
    final rootsData = [
      // (endOffsetX, endOffsetY, controlX, controlY, startWidth, endWidth)
      (-240.0, 110.0, -160.0, 40.0, 24.0, 4.0),
      (-170.0, 150.0, -110.0, 70.0, 28.0, 5.0),
      (-80.0, 180.0, -50.0, 90.0, 32.0, 6.0),
      (0.0, 200.0, 10.0, 100.0, 36.0, 7.0),
      (80.0, 180.0, 50.0, 90.0, 32.0, 6.0),
      (170.0, 150.0, 110.0, 70.0, 28.0, 5.0),
      (240.0, 110.0, 160.0, 40.0, 24.0, 4.0),
    ];

    for (var r in rootsData) {
      final start = Offset(basePos.dx + r.$1 * 0.35, groundY - 10);
      final end = Offset(basePos.dx + r.$1, groundY + r.$2);
      final ctrl = Offset(basePos.dx + r.$3, groundY + r.$4);

      final rPath = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

      // Тень корня
      final rShadow = Paint()
        ..color = (isDark ? Colors.black : const Color(0xFF4A3625)).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r.$5 + 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(rPath, rShadow);

      // Тело корня
      final rBody = Paint()
        ..color = barkMid
        ..style = PaintingStyle.stroke
        ..strokeWidth = r.$5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(rPath, rBody);

      // Внутреннее волокно корня
      final rCore = Paint()
        ..color = woodGrain
        ..style = PaintingStyle.stroke
        ..strokeWidth = r.$5 * 0.45
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(rPath, rCore);

      // Мелкие корешки на концах
      final subRoot = Path()
        ..moveTo(end.dx - 15, end.dy - 10)
        ..quadraticBezierTo(end.dx + 20, end.dy + 15, end.dx + 40, end.dy + 25);
      canvas.drawPath(
        subRoot,
        Paint()
          ..color = barkDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Моховые и золотые акценты у подножия корней
    _drawRootMossAndSpores(canvas, Offset(basePos.dx, groundY), goldLight, leafGreen);
  }

  /// Органичная деревянная ветвь/ствол дуба с естественным S-изгибом, корой и листвой
  void _drawOrganicBranch(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double thickness,
    required double endThickness,
    required Color barkDark,
    required Color barkMid,
    required Color woodGrain,
    required Color goldLight,
    required Color leafGreen,
    required Color leafLight,
    required int level,
    bool isTrunkSegment = false,
  }) {
    // Вектор и контрольные точки для выразительного дубового изгиба
    final dy = end.dy - start.dy;
    final dx = end.dx - start.dx;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 5) return;

    // Изгиб ветви с естественным деревянным колебанием (Organic sway)
    final wobble = math.sin((start.dx + end.dx) * 0.015) * 28.0;
    final cp1 = Offset(start.dx + wobble * 0.6, start.dy + dy * 0.45);
    final cp2 = Offset(end.dx - wobble * 0.3, start.dy + dy * 0.75);

    final branchPath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    // 1. Мягкая объемная тень на пергамент
    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF4A3423)).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness + 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(branchPath, shadowPaint);

    // 2. Внешняя темная кора
    final outerBark = Paint()
      ..color = barkDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(branchPath, outerBark);

    // 3. Теплое тело древесины (дубовая плоть)
    final heartWood = Paint()
      ..color = barkMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(6.0, thickness - 6.0)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(branchPath, heartWood);

    // 4. Волокна и борозды коры
    final grainPaint = Paint()
      ..color = woodGrain.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, thickness * 0.22)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(branchPath, grainPaint);

    // 5. Солнечный световой блик на верхней кромке ветви
    final highlightPaint = Paint()
      ..color = goldLight.withValues(alpha: isDark ? 0.65 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, thickness * 0.12)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(branchPath, highlightPaint);

    // 6. Листва дуба и желуди вдоль ветви
    final midPoint = Offset(
      (start.dx + end.dx) / 2 + wobble * 0.3,
      (start.dy + end.dy) / 2,
    );

    // Кластер листьев в середине пролета ветви
    _drawLushOakCluster(
      canvas,
      midPoint,
      leafGreen,
      leafLight,
      goldLight,
      count: isTrunkSegment ? 2 : 3,
    );

    // Поддерживающий деревянный сучок под верхним медальоном
    if (!isTrunkSegment) {
      _drawBranchCollar(canvas, end, endThickness, barkDark, barkMid, goldLight);
    }
  }

  /// Горизонтальная ветвь брачного союза с переплетенными кольцами
  void _drawSpouseUnionBranch(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color barkDark,
    Color barkMid,
    Color woodGrain,
    Color goldLight,
    Color leafGreen,
  ) {
    final leftX = math.min(p1.dx, p2.dx);
    final rightX = math.max(p1.dx, p2.dx);
    final y = (p1.dy + p2.dy) / 2;
    final midX = (leftX + rightX) / 2;
    final dipY = y + 24.0;

    final unionPath = Path()
      ..moveTo(leftX + 20, y + 10)
      ..quadraticBezierTo(midX, dipY, rightX - 20, y + 10);

    // Тень
    canvas.drawPath(
      unionPath,
      Paint()
        ..color = (isDark ? Colors.black : const Color(0xFF4A3423)).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Кора ветви
    canvas.drawPath(
      unionPath,
      Paint()
        ..color = barkDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round,
    );

    // Древесина
    canvas.drawPath(
      unionPath,
      Paint()
        ..color = barkMid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round,
    );

    // Золотая жила верности
    canvas.drawPath(
      unionPath,
      Paint()
        ..color = goldLight.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Золотые переплетенные венчальные кольца в центре дуги союза
    _drawWeddingRings(canvas, Offset(midX, dipY - 8), goldLight, leafGreen);
  }

  /// Кластер акварельных дубовых листьев с лопастями и золотыми желудями
  void _drawLushOakCluster(
    Canvas canvas,
    Offset pos,
    Color leafGreen,
    Color leafLight,
    Color goldLight, {
    int count = 3,
  }) {
    final leafPaint = Paint()
      ..color = leafGreen.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    final lightPaint = Paint()
      ..color = leafLight.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final veinPaint = Paint()
      ..color = goldLight.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // Лист 1 (влево-вверх)
    _drawOakLobeLeaf(canvas, pos, -0.65, 20.0, leafPaint, lightPaint, veinPaint);
    // Лист 2 (вправо-вверх)
    _drawOakLobeLeaf(canvas, pos, 0.65, 20.0, leafPaint, lightPaint, veinPaint);

    if (count >= 3) {
      // Центральный листик
      _drawOakLobeLeaf(canvas, pos, 0.05, 18.0, leafPaint, lightPaint, veinPaint);
      // Золотой желудь
      _drawGoldenAcorn(canvas, Offset(pos.dx, pos.dy - 3), goldLight);
    }
  }

  /// Отдельный фигурный лист дуба с характерными закругленными лопастями
  void _drawOakLobeLeaf(
    Canvas canvas,
    Offset origin,
    double angleRad,
    double length,
    Paint fillDark,
    Paint fillLight,
    Paint vein,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angleRad);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-6, -length * 0.3, -11, -length * 0.5, -6, -length * 0.7)
      ..cubicTo(-10, -length * 0.85, -5, -length, 0, -length)
      ..cubicTo(5, -length, 10, -length * 0.85, 6, -length * 0.7)
      ..cubicTo(11, -length * 0.5, 6, -length * 0.3, 0, 0)
      ..close();

    canvas.drawPath(path, fillDark);
    canvas.drawPath(path, fillLight);

    // Центральная прожилка
    canvas.drawLine(const Offset(0, 0), Offset(0, -length * 0.9), vein);

    canvas.restore();
  }

  /// Золотой желудь рода в деревянной чашечке
  void _drawGoldenAcorn(Canvas canvas, Offset pos, Color goldColor) {
    // Чашечка желудя (плюска)
    final capPaint = Paint()
      ..color = const Color(0xFF3E2718)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 3), width: 9, height: 6),
      0,
      math.pi,
      true,
      capPaint,
    );

    // Тело желудя
    final acornPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 2), width: 6.5, height: 8.5),
      acornPaint,
    );
  }

  /// Деревянный сучок/воротничок под рамкой персоны
  void _drawBranchCollar(
    Canvas canvas,
    Offset pos,
    double width,
    Color barkDark,
    Color barkMid,
    Color goldLight,
  ) {
    final collarRect = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy + 12),
      width: width + 14,
      height: 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(collarRect, const Radius.circular(4)),
      Paint()..color = barkDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy + 12), width: width + 8, height: 5),
        const Radius.circular(2.5),
      ),
      Paint()..color = barkMid,
    );
    canvas.drawCircle(Offset(pos.dx, pos.dy + 12), 2.2, Paint()..color = goldLight);
  }

  /// Венчальные кольца союза
  void _drawWeddingRings(Canvas canvas, Offset center, Color goldColor, Color leafGreen) {
    const r = 8.0;
    final pLeft = Offset(center.dx - 4.5, center.dy);
    final pRight = Offset(center.dx + 4.5, center.dy);

    final ringPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Свечение
    final glow = Paint()
      ..color = goldColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(pLeft, r, glow);
    canvas.drawCircle(pRight, r, glow);

    canvas.drawCircle(pLeft, r, ringPaint);
    canvas.drawCircle(pRight, r, ringPaint);
  }

  /// Мох и золотая пыльца у основания корней
  void _drawRootMossAndSpores(Canvas canvas, Offset base, Color goldColor, Color mossColor) {
    final mossPaint = Paint()
      ..color = mossColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 10), width: 140, height: 18),
      mossPaint,
    );

    final sporePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final sx = base.dx + math.sin(i * 123.0) * 110;
      final sy = base.dy + 15 + math.cos(i * 77.0) * 20;
      sporePaint.color = goldColor.withValues(alpha: 0.5 + (i % 5) * 0.1);
      canvas.drawCircle(Offset(sx, sy), 1.6 + (i % 3) * 0.6, sporePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hiddenNodeIds != hiddenNodeIds;
  }
}
