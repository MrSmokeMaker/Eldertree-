import 'dart:ui';
import '../../../../data/models/member_model.dart';

class GraphNode {
  final MemberModel member;
  int level = 0;
  double x = 0.0;
  double y = 0.0;
  
  final List<GraphNode> spouses = [];
  final List<GraphNode> parents = [];
  final List<GraphNode> children = [];

  GraphNode(this.member);

  String get id => member.id;

  Offset get position => Offset(x, y);
}
