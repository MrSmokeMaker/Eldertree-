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
    final goldBase = const Color(0xFFD4AF37);
    final greenBase = const Color(0xFF2D4A3E);
    final accentColor = isDark ? goldBase : greenBase;

    final parentPaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final spousePaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const cardRadius = 60.0;

    for (var rel in relationships) {
      if (hiddenNodeIds.contains(rel.member1Id) || hiddenNodeIds.contains(rel.member2Id)) {
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
          p1.dx, startY + 100,
          p2.dx, endY - 100,
          p2.dx, endY,
        );
        canvas.drawPath(path, parentPaint);
      } else if (rel.relationshipType == RelationshipType.spouse) {
        final startX = p1.dx < p2.dx ? p1.dx + cardRadius : p1.dx - cardRadius;
        final endX = p2.dx > p1.dx ? p2.dx - cardRadius : p2.dx + cardRadius;
        
        path.moveTo(startX, p1.dy);
        path.quadraticBezierTo(
          (startX + endX) / 2, p1.dy + 30,
          endX, p2.dy,
        );
        canvas.drawPath(path, spousePaint);
        
        canvas.drawCircle(
          Offset((startX + endX) / 2, p1.dy + 15),
          6.0,
          Paint()..color = accentColor..style = PaintingStyle.stroke..strokeWidth = 2.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter oldDelegate) {
    return oldDelegate.nodes != nodes || 
           oldDelegate.isDark != isDark || 
           oldDelegate.hiddenNodeIds != hiddenNodeIds;
  }
}
